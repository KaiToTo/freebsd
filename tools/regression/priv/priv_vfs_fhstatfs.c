/*-
 * Copyright (c) 2006 nCircle Network Security, Inc.
 * All rights reserved.
 *
 * This software was developed by Robert N. M. Watson for the TrustedBSD
 * Project under contract to nCircle Network Security, Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR, NCIRCLE NETWORK SECURITY,
 * INC., OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD$
 */

/*
 * Confirm that calls to fhstatfs() require privilege, trying with, and
 * without.  We create a temporary file and grab the file handle using
 * getfh() before starting.
 */

#include <sys/param.h>
#include <sys/mount.h>

#include <err.h>
#include <errno.h>
#include <unistd.h>

#include "main.h"

void
priv_vfs_fhstatfs(void)
{
	char fpath[1024];
	struct statfs sf;
	fhandle_t fh;
	int error;

	assert_root();

	setup_file(fpath, UID_ROOT, GID_WHEEL, 0644);

	if (getfh(fpath, &fh) < 0) {
		warn("getfh(%s)", fpath);
		goto out;
	}

	/*
	 * First, try with privilege.
	 */
	if (fhstatfs(&fh, &sf) < 0) {
		warn("fhstatfs(%s) as root", fpath);
		goto out;
	}

	/*
	 * Now, without privilege.
	 */
	set_euid(UID_OTHER);

	error = fhstatfs(&fh, &sf);
	if (error == 0) {
		warnx("fhstatfs(%s) succeeded as !root", fpath);
		goto out;
	}
	if (errno != EPERM) {
		warn("fhstatfs(%s) wrong errno %d as !root", fpath, errno);
		goto out;
	}
out:
	seteuid(UID_ROOT);
	(void)unlink(fpath);
}
