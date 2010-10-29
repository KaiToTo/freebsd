/*-
 * Copyright (c) 2010 Andrey V. Elsukov <bu7cher@yandex.ru>
 * All rights reserved.
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
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/cdefs.h>
__FBSDID("$FreeBSD$");

#include <sys/param.h>
#include <sys/linker.h>
#include <sys/mount.h>
#include <ufs/ufs/ufsmount.h>
#include <ufs/ufs/dinode.h>
#include <ufs/ffs/fs.h>
#include <libufs.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <libutil.h>
#include <stdarg.h>
#include <errno.h>
#include <err.h>
#include <dialog.h>
#include <ctype.h>
#include <sysexits.h>
#include <assert.h>
#include <paths.h>
#include <sade.h>
#include <time.h>
#include <libsade.h>
#include "customdlg.h"
#include "mntopts.h"


static char *ask_recreate_msg =
	"WARNING: Selected partition already contains a file system!\n\n"
	"Are you absolutely sure you want to recreate it?";
static char *custom_newfs_title = "Please enter custom parameters for newfs:";
static char *undo_msg = "Are you SURE you want to undo everything?";
static char *write_confirm_msg =
	"WARNING: You are about to save all your changes to device.\n"
	"After that you will can not undo your changes.\n\n"
	"Are you absolutely sure you want to continue?";
static char *pending_write_msg =
	"WARNING: There are some changes pending of write to device.\n\n"
	"Would you like to save these changes?";

TAILQ_HEAD(ufslist, ufsinfo);
struct ufsinfo {
	TAILQ_ENTRY(ufsinfo)	entry;
	char			*devname;	/* parent device name */
	char			*scheme;	/* partitioning scheme */
	char			*partname;	/* partition name */
	off_t			size;		/* partition size */

	/* UFS Info */
	char			*fsmnt;		/* last mounted path */
	char			*volname;	/* volume label */
	int32_t			id[2];		/* UFS ID */
#define	HAS_UFSID(pfs) \
	((pfs)->id[0] != 0 || (pfs)->id[1] != 0)

	int32_t			flags;		/* FS_XX flags */
	int32_t			magic;		/* magic number */

	struct fstab		*fstabent;	/* fstab entry */
	char			*mntonname;	/* current mountpoint */
};

static int ufslist_add(struct ufslist *, struct de_device *, struct de_part *);
static void ufslist_free(struct ufslist *);
static int ufslist_count(struct ufslist *);
static int ufslist_get(struct ufslist *);

static int ufsinspect(struct ufsinfo *);

static int
ufslist_add(struct ufslist *fslist, struct de_device *pdev,
    struct de_part *ppart)
{
	struct ufsinfo *pfs;

	assert(fslist != NULL);
	assert(pdev != NULL);
	assert(ppart != NULL);
	assert(pdev->de_sectorsize > 0);

	pfs = malloc(sizeof(*pfs));
	if (pfs == NULL)
		return (ENOMEM);
	bzero(pfs, sizeof(*pfs));
	pfs->devname = strdup(pdev->de_name);
	pfs->scheme = strdup(pdev->de_scheme);
	pfs->partname = strdup(ppart->de_name);
	pfs->size = (ppart->de_end - ppart->de_start) * pdev->de_sectorsize;
	TAILQ_INSERT_TAIL(fslist, pfs, entry);
	ufsinspect(pfs);
	return (0);
}

static void
ufslist_free(struct ufslist *fslist)
{
	struct ufsinfo *pfs;

	while (!TAILQ_EMPTY(fslist)) {
		pfs = TAILQ_FIRST(fslist);
		free(pfs->devname);
		free(pfs->scheme);
		free(pfs->partname);
		free(pfs->fsmnt);
		free(pfs->volname);
		TAILQ_REMOVE(fslist, pfs, entry);
		free(pfs);
	}
}

static int
ufslist_count(struct ufslist *fslist)
{
	struct ufsinfo *pfs;
	int count;

	count = 0;
	TAILQ_FOREACH(pfs, fslist, entry) {
		count++;
	}
	return (count);
}

static int
ufslist_get(struct ufslist *fslist)
{
	struct de_devlist devices;
	struct de_device *pdev;
	struct de_part *ppart;
	int error;

	assert(fslist != NULL);

	error = de_devlist_partitioned_get(&devices);
	if (error)
		return (error);

	TAILQ_INIT(fslist);
	TAILQ_FOREACH(pdev, &devices, de_device) {
		error = de_partlist_get(pdev);
		if (error)
			break;
		TAILQ_FOREACH(ppart, &pdev->de_part, de_part) {
			/* skip empty chunks */
			if (ppart->de_type == NULL)
				continue;
			if (strcmp(ppart->de_type, "freebsd-ufs") != 0)
				continue;
			error = ufslist_add(fslist, pdev, ppart);
			if (error)
				break;
		}
		de_dev_partlist_free(pdev);
		if (error)
			break;
	}
	de_devlist_free(&devices);
	return (error);
}

static int
ufsinspect(struct ufsinfo *pfs)
{
	struct uufsd disk;
	int error;

	bzero(&disk, sizeof(disk));
	error = ufs_disk_fillout(&disk, pfs->partname);
	if (error != -1) {
		pfs->id[0] = disk.d_fs.fs_id[0];
		pfs->id[1] = disk.d_fs.fs_id[1];
		pfs->flags = disk.d_fs.fs_flags;
		pfs->magic = disk.d_fs.fs_magic;
		if (disk.d_fs.fs_volname[0] != '\0')
			pfs->volname = strndup(disk.d_fs.fs_volname,
			    MAXVOLLEN);
		if (disk.d_fs.fs_fsmnt[0] != '\0')
			pfs->fsmnt = strndup(disk.d_fs.fs_fsmnt,
			    MAXMNTLEN);
	}
	ufs_disk_close(&disk);
	return (error);
}

static void
set_statusline(char *msg)
{
	if (msg) {
		attrset(title_attr);
		mvprintw(LINES - 1, 0, msg);
		attrset(A_NORMAL);
		beep();
	} else {
		move(LINES - 1, 0);
		clrtoeol();
	}
}

enum hist_cmd_type {
	NEWFS, TUNEFS
};

struct hist_cmd_entry {
	enum hist_cmd_type	type;
	struct de_fs		*pfs;
	char			*args;
};

static int
ufsed_history_rollback(void *pentry)
{
	return (0);
}

static int
ufsed_history_play(void *pentry)
{
	return (0);
}

static int
ufslist_reread(struct ufslist *fslist)
{
	int error;

	ufslist_free(fslist);
	error = ufslist_get(fslist);

	return (error);
}

#define	FSED_MENU_TOP		4
#define	FSED_BOTTOM_HEIGHT	7
#define	LABEL(l)		((l) ? (l): "-")

int
ufsed_open(void)
{
	struct ufslist fslist;
	struct ufsinfo *pfs, *selected;
	int count, height, row, i, key, ret;
	int sc = 0, ch = 0, q = 0;
	history_t hist;
	WINDOW *win;
	char *msg, *tmps;
	int error;

	error = ufslist_get(&fslist);
	if (error)
		return (error);
	if (TAILQ_EMPTY(&fslist)) {
		dmenu_open_errormsg("Suitable partitions are not found! "
		    "Create partitions and try again.");
		return (0);
	}
	msg = NULL;
	getmnt_silent = 1;	/* make getmntopts() silent */
	hist = history_init();
	win = savescr();
	keypad(stdscr, TRUE);
	dialog_clear_norefresh(); clear();
	count = ufslist_count(&fslist);
resize:
	if (LINES > VTY_STATUS_LINE)
		height = LINES - 1;
	else
		height = VTY_STATUS_LINE;
	height -= FSED_MENU_TOP + FSED_BOTTOM_HEIGHT;
	do {
		attrset(A_NORMAL);
		mvprintw(0, 0, "%-12s", "Device:");
		clrtobot(); attrset(A_REVERSE);
		mvprintw(0, 61, "File Systems Editor");
		attrset(A_NORMAL);
		mvprintw(2, 0, "%-20s%6s%11s", "Device", "Size", "FS Info");
		row = FSED_MENU_TOP - 1;
		if (sc > 0)
			mvprintw(row, 11, "^(-)");
		else {
			move(row, 0);
			clrtoeol();
		}
		i = 0;
		TAILQ_FOREACH(pfs, &fslist, entry) {
			if (i++ < sc)
				continue;
			if (++row - FSED_MENU_TOP > height - 1)
				break;
			if (ch == row - FSED_MENU_TOP) {
				attrset(A_REVERSE);
				selected = pfs;
			}
			mvprintw(row, 0, "%-20s%6s", LABEL(pfs->partname),
			    fmtsize(pfs->size));
			if (ch == row - FSED_MENU_TOP)
				attrset(A_NORMAL);
		}
		attrset(A_REVERSE);
		mvprintw(0, 12, "%s, %s scheme", selected->devname,
		    selected->scheme);
		attrset(A_NORMAL);
		if (sc + height < count)
			mvprintw(height + FSED_MENU_TOP, 11, "v(+)");
		else {
			move(height + FSED_MENU_TOP, 0);
			clrtoeol();
		}
		switch (selected->magic) {
		case FS_UFS1_MAGIC:
			tmps = "UFS1";
			break;
		case FS_UFS2_MAGIC:
			tmps = "UFS2";
			break;
		default:
			tmps = "unknown";
		}
		mvprintw(FSED_MENU_TOP, 30, "%-20s%s", "File System:", tmps);
		if (selected->magic == FS_UFS1_MAGIC ||
		    selected->magic == FS_UFS2_MAGIC) {
			mvprintw(FSED_MENU_TOP + 1, 30, "%-20s%s",
			    "last mountpoint:",
			    LABEL(selected->fsmnt));
			mvprintw(FSED_MENU_TOP + 2, 30, "%-20s%08x%08x",
			    "UFS id:", selected->id[0], selected->id[1]);
			mvprintw(FSED_MENU_TOP + 3, 30, "%-20s%s",
			    "volume label:", LABEL(selected->volname));
#define	FS_STATUS(pfs, flag) \
	((((pfs)->flags & (flag)) != 0) ? "enabled": "disabled")
			mvprintw(FSED_MENU_TOP + 4, 30, "%-20s%s",
			    "POSIX.1e ACLs:", FS_STATUS(selected, FS_ACLS));
			mvprintw(FSED_MENU_TOP + 5, 30, "%-20s%s",
			    "NFSv4 ACLs:", FS_STATUS(selected, FS_NFS4ACLS));
			mvprintw(FSED_MENU_TOP + 6, 30, "%-20s%s",
			    "MAC multilabel:",
			    FS_STATUS(selected, FS_MULTILABEL));
			mvprintw(FSED_MENU_TOP + 7, 30, "%-20s%s",
			    "soft updates:",
			    FS_STATUS(selected, FS_DOSOFTDEP));
			mvprintw(FSED_MENU_TOP + 8, 30, "%-20s%s",
			    "SU journaling:",
			    FS_STATUS(selected, FS_SUJ));
			mvprintw(FSED_MENU_TOP + 9, 30, "%-20s%s",
			    "gjournal:", FS_STATUS(selected, FS_GJOURNAL));
		}
		mvprintw(height + FSED_MENU_TOP + 1, 0,
		    "The following commands are supported:");
		mvprintw(height + FSED_MENU_TOP + 3, 0,
		    "C = Create File System    M = Modify File System    Q = Finish");
		mvprintw(height + FSED_MENU_TOP + 4, 0,
		    "U = Undo All Changes      W = Write Changes");
		mvprintw(height + FSED_MENU_TOP + 8, 0,
		    "Use F1 or ? to get more help, arrow keys to select");
		set_statusline(msg);
		if (msg)
			msg = NULL;

		key = toupper(getch());
		switch (key) {
		case '\r':
		case '\n':
			break;
		case KEY_ESC:
		case 'Q':
			q = 1;
			break;
		case 'W':
			if (history_isempty(hist)) {
				msg = "Nothing to save.";
				break;
			}
			if (dmenu_open_noyes(write_confirm_msg))
				break;
			error = history_play(hist, ufsed_history_play);
			if (error != 0) {
				/* XXX: report about completed commands */
				history_rollback(hist, ufsed_history_rollback);
			}
			error = ufslist_reread(&fslist);
			break;
		case 'U':
			if (history_isempty(hist)) {
				msg = "Nothing to undo.";
				break;
			}
			if (dmenu_open_noyes(undo_msg))
				break;
			history_rollback(hist, ufsed_history_rollback);
			error = ufslist_reread(&fslist);
			break;
		case KEY_UP:
		case KEY_DOWN:
		case KEY_PPAGE:
		case KEY_HOME:
		case KEY_NPAGE:
		case KEY_END:
			dlg_list_handle_move(key, &ch, &sc, count,
			    height);
			break;
		case KEY_RESIZE:
			sc = ch = 0;
			goto resize;
		default:
			msg = "Type F1 or ? for help";
		};
	} while (q == 0);
	if (!history_isempty(hist))
		history_rollback(hist, ufsed_history_rollback);
	history_free(hist);
	restorescr(win);
	ufslist_free(&fslist);
	return (0);
}

