#!/usr/bin/env python
# $FreeBSD$

# Queue manager
#
# Listens on UNIX socket for requests and maps them to a build machine
# that satisfies resource constraints
#
# By centralizing all queue requests we can potentially make better
# decisions about how to map requests to resources.  For example, we
# can make use of all available build machines for a job, but cede
# priority to a job in the owner's pool when it comes along.
#
# The backend is an SQLite database that stores configuration details
# of the available machines.  This supports a basic query language for
# mapping job requests to machines: a list of lines of the form
#
# <property> <operator> <value>
#
# where
#
# property: one of the schema fields
# operator: = < > <= >=
# value: numeric value or string
# 
# multiple lines are ANDed together, and the query returns the
# machines that match all constraints
#
# * after a machine reboot the jobs are still owned by the clients
#     - client responsibility to monitor and reconfigure or release
#       job if it cannot be resumed in-place

# TODO:
#
# * Test
#     - Make sure sockets clean up properly when they disconnect
#     - Only owner can remove/resume a job
#     - add/remove/modify ACLs
#     - unit tests
#
# * Substring match for pools, boolean match
# - do_jobs and do_status output format (process in client)
# * signal handler - why doesn't it work?
# * SQL relations (job -> machine, machine -> acl)
# * Query running jobs
#
# POSSIBLE FUTURE IDEAS
# - better parser
#     - OR, NOT job description entries
#     - query jobs.machine properties

import os
import sys

pbc = os.getenv('PORTBUILD_CHECKOUT') \
    if os.getenv('PORTBUILD_CHECKOUT') else "/var/portbuild"
pbd = os.getenv('PORTBUILD_DATA') \
    if os.getenv('PORTBUILD_DATA') else "/var/portbuild"

sys.path.insert(0, '%s/lib/python' % pbc)

import socket, threading, time, Queue

from signal import *
from itertools import chain

from qmanagerobj import *
from freebsd_config import *

CONFIG_SUBDIR="conf"
CONFIG_FILENAME="server.conf"

config = getConfig( pbc, CONFIG_SUBDIR, CONFIG_FILENAME )
QMANAGER_SOCKET_FILE = config.get( 'QMANAGER_SOCKET_FILE' )

DEBUG = True
VERBOSE = False

class Worker(object):
    """ Execute commands from the queue """

    workq = None	# work queue to listen on

    def __init__(self, q):
        super(Worker, self).__init__()
        self.name = "worker"
        self.workq = q

    def start(self):

        cmddict = {'status':self.do_status,
                   'try':self.do_try,
                   'acquire':self.do_acquire,
                   'release':self.do_release,
                   'reconnect':self.do_reconnect,
                   'jobs':self.do_jobs,
                   'add':self.do_add,
                   'delete':self.do_delete,
                   'update':self.do_update,
                   'add_acl':self.do_add_acl,
                   'update_acl':self.do_update_acl,
                   'del_acl':self.do_del_acl
                   }

        # Main work loop
        while True:
            conn = self.workq.get(block = True)
            if VERBOSE:
                try:
                    print "qmanager.Worker: handling command %s" % conn.cmd
                except:
                    pass

            try:
                cmddict[conn.cmd](conn)
            except OSError, error:
                # ignore EPIPE
                # XXX MCL why?
                if error.errno != 32:
                    print sys.exc_info()
                else:
                    print "EPIPE"

            self.workq.task_done()
            if VERBOSE:
                try:
                    print "qmanager.Worker: handled command %s" % conn.cmd
                except:
                    pass

    def do_add(self, conn):
        """ Add a machine """

        if conn.uid != 0:
            conn.send(408)
            return

        # Normalize input
        try:
            vars = Machine.normalize(conn.args)
        except (KeyError, ValueError):
            print "Failed to normalize in do_add"
            conn.send(406)
            return

        if vars['name'] in machines:
            # Machine already exists
            conn.send(411, {'name':vars['name']})
            return

        newmachine = Machine(vars)
        session.commit()
        machines[vars['name']] = newmachine

        conn.send(201)

        Job.revalidate_blocked()
        return

    def do_delete(self, conn):
        """ Delete a machine """

        if conn.uid != 0:
            conn.send(408)
            return

        try:
            machine = machines[conn.args['name']]
        except KeyError:
            conn.send(402)
            return

        if machine.curjobs:
            conn.send(409)
            return

        session.delete(machines[machine.name])
        session.commit()
        del machines[machine.name]

        conn.send(201)

        Job.revalidate_blocked()
        return

    def do_update(self, conn):
        """ Update a machine """

        if conn.uid != 0:
            conn.send(408)
            return

        try:
            machine = machines[conn.args['name']]
        except KeyError:
            conn.send(402)
            return

        # Normalize input
        try:
            vars = Machine.normalize(conn.args)
        except (KeyError, ValueError):
            print "Failed to normalize in do_update"
            conn.send(406)
            return

        if 'name' in vars and vars['name'] != machine.name:
            # Rename machine
            machines[vars['name']] = machine
            del machines[machine.name]

            # Update existing jobs
            for j in jobs:
                try:
                    pos = j.machines.index(machine.name)
                    j.machines[pos] = vars['name']
                except ValueError:
                    continue

        if 'acl' in vars:
            machine.clear_validated()

        for (key, value) in vars.iteritems():
            setattr(machine, key, value)

        session.commit()
        conn.send(201)

        Job.revalidate_blocked()
        return

    def do_add_acl(self, conn):
        """ Add an ACL """

        if conn.uid != 0:
            conn.send(408)
            return

        # Normalize input
        try:
            vars = QManagerACL.normalize(conn.args)
        except (KeyError, ValueError):
            print "Failed to normalize in do_add_acl"
            conn.send(406)
            return

        if vars['name'] in acls:
            # Machine already exists
            conn.send(411, {'name':vars['name']})
            return

        newacl = QManagerACL(vars)
        session.commit()
        acls[vars['name']] = newacl

        conn.send(201)
        return

    def do_update_acl(self, conn):
        """ Update an ACL """

        if conn.uid != 0:
            conn.send(408)
            return

        try:
            acl = acls[conn.args['name']]
        except KeyError:
            conn.send(402)
            return

        # Normalize input
        try:
            vars = QManagerACL.normalize(conn.args)
        except (KeyError, ValueError):
            print "Failed to normalize in do_update_acl"
            conn.send(406)
            return

        namechange = ('name' in vars and vars['name'] != acl.name)
        if namechange:
            # Rename acl
            acls[vars['name']] = acl
            del acls[acl.name]

        # Update existing ACLs
        for m in machines:
            try:
                pos = m.acl.index(acl.name)
                if namechange:
                    m.acl[pos] = vars['name']
                m.clear_validated()
            except ValueError:
                continue

        for (key, value) in vars.iteritems():
            setattr(acl, key, value)

        session.commit()
        conn.send(201)

        Job.revalidate_blocked()
        return

    def do_del_acl(self, conn):
        """ Delete an ACL """

        if conn.uid != 0:
            conn.send(408)
            return

        try:
            acl = acls[conn.args['name']]
        except KeyError:
            conn.send(402)
            return

        for m in machines:
            if acl.name in m.acl:
                conn.send(409)
                return

        session.delete(acls[acl.name])
        session.commit()
        del acls[acl.name]

        conn.send(201)
        return

    def do_status(self, conn):
        """ Status of machines """

        try:
            res = SQL.getrequest(conn.args['mdl'])
        except KeyError:
            print "missing mdl argument in do_status"
            conn.send(406)
            return

        status={}
        attr = list(Machine.columns)
        attr.append("curjobs")
        for m in res:
            name = m['name']
            mach = machines[name]
            status[name] = dict((k, getattr(mach, k)) for k in attr)

        conn.send(201, {'body':status})

    def do_try(self, conn):
        """ Non-blocking job slot acquisition """
        return self.do_acquire(conn, block = False)

    def do_acquire(self, conn, block = True):
        """ Job slot acquisition, defaulting to blocking """

        args = conn.args

        try:
            priority = args['priority']
            name = args['name']
            type = args['type']
        except:
            conn.send(407)
            return

        job = Job(name, type, priority, conn.uid, conn.gids,
                  machines=[], starttime=0, mdl=args['mdl'],
                  running=False, conn=conn)
        job.run_or_block(block)

    def do_release(self, conn):
        """ Release a job slot """

        try:
            id = int(conn.args['id'])
        except (TypeError, ValueError):
            conn.send(407)
            return

        try:
            job = jobs[id]
        except KeyError:
            # No such job
#            print "404 for job %s" % id
            conn.send(404)
            return

        try:
            if job.owner != conn.uid and conn.uid != 0:
                conn.send(408)
                return
        except Exception, e:
            print "would have failed at 'if job.owner != conn.uid and conn.uid != 0'"
            print e
            try:
                print job
                print conn
                print job.owner
                print conn.uid
            except Exception, e:
                print "double fault"
                print e

        if not job.running:
            job.unblock(None)
            if job.conn:
                print "job.conn.send(412) for job %s" % job
                job.conn.send(412)

        # XXX MCL 20100311 to catch bad behavior
        try:
            job.finish()
        except Exception, e:
            print "job.finish failed with exception:"
            print str(e)
        conn.send(201)

    def do_jobs(self, conn):
        """ List of jobs running and blocked """

        status={}
        for (id, job) in jobs.iteritems():
            status[id] = dict((k, getattr(job, k)) for k in Job.columns)
            status[id]['connected'] = bool(job.conn is not None)

        conn.send(201, {'body':status})

    def do_reconnect(self, conn):
        """ Reconnect to a blocked job after it was disconnected """

        try:
            id = int(conn.args['id'])
        except (TypeError, ValueError):
            conn.send(407)
            return

        try:
            job = jobs[id]
        except KeyError:
            # No such job
            conn.send(404)
            return

        if job.running:
            # Job already running
            conn.send(409)
            return

        if job.owner != conn.uid:
            # Permission denied
            conn.send(408)
            return

        if job.conn:
            job.conn.send(410)
        job.conn = conn

        try:
            (runnable, mlist) = job.getrunnable()
        except NoMachinesError:
            print "no runnable machines"
            conn.send(406)
            return

        if runnable:
            choice = mlist[0]
        else:
            valid_mlist = mlist

        if choice:
            job.run(choice, True)
            conn.send(202, {"machine":choice.name, "id":job.id})
        else:
            job.block(valid_mlist)
        return

class Listener(threading.Thread):
    """ Socket server for user requests """

    workq = None	# work queue to listen on

    def __init__(self, q):
        super(Listener, self).__init__()
        self.name = "listener"
        self.workq = q
        self.setDaemon(True)

    def run(self):
        # Set up listen sockets
        sockpath=QMANAGER_SOCKET_FILE
        try:
            stats = os.stat(sockpath)
            if stats.st_mode & 0140000:
                os.unlink(sockpath)
        except OSError, error:
            if error.errno != 2: # ENOENT
                raise

        server = MyUnixStreamServer(sockpath, UNIXhandler, workqueue)
        os.chmod(sockpath, 0666)
        server.serve_forever()
        print "qmanager.run: serve_forever exited"

# debug thread added by linimon to try to figure out why it sometimes goes catatonic.
class Monitor(threading.Thread):
    """ debug monitor """

    def __init__(self):
        super(Monitor, self).__init__()
        self.name = "monitor"

    def run(self):

        while ( True ):

            # MCL doesn't understand why the following doesn't work:
            # time.sleep( 60 )
            os.system( "sleep 60" )

            try:
                print "qmanager monitor: active threads: %d" % threading.active_count()
                threads = threading.enumerate()
                for thread in threads:
                    print "    %s is alive: %d" % ( thread.name, thread.isAlive() )
            except Exception, e:
                print "qmanager monitor: Exception:"
                print e


# main code

QMANAGER_PATH = config.get( 'QMANAGER_PATH' )
QMANAGER_DATABASE_FILE = config.get( 'QMANAGER_DATABASE_FILE' )
(engine, session) = startup( \
    os.path.join( QMANAGER_PATH, QMANAGER_DATABASE_FILE ) )

if DEBUG:
    print "qmanager: got engine %s, session %s" % (engine, session)
    print

workqueue = Queue.Queue()

# XXX MCL 20110421 turned this off, it's not telling us what we need to know
#monitor=Monitor()
#try:
#    monitor.start()
#    print "qmanager: started monitor %s" % monitor
#except Exception, e:
#    print "qmanager: could not start monitor %s" % monitor
#    print e

listener=Listener(workqueue)
try:
    listener.start()
    print "qmanager: started listener %s" % listener
except Exception, e:
    print "qmanager: could not start listener %s" % listener
    print e
    sys.exit( 1 )

print

worker=Worker(workqueue)
try:
    worker.start()
    # should never return
    print "qmanager: started worker %s" % worker
except Exception, e:
    print "qmanager: could not start worker %s" % worker
    print e

print "qmanager: exiting"
