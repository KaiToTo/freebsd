/*
 * Copyright (C) 2001  Internet Software Consortium.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND INTERNET SOFTWARE CONSORTIUM
 * DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
 * INTERNET SOFTWARE CONSORTIUM BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING
 * FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
 * WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

/* $Id: strerror.h,v 1.3 2001/11/20 01:45:47 gson Exp $ */

#ifndef ISC_STRERROR_H
#define ISC_STRERROR_H

#include <sys/types.h>

#include <isc/lang.h>

ISC_LANG_BEGINDECLS

#define ISC_STRERRORSIZE 128

/*
 * Provide a thread safe wrapper to strerrror().
 *
 * Requires:
 * 	'buf' to be non NULL.
 */
void
isc__strerror(int num, char *buf, size_t bufsize);

ISC_LANG_ENDDECLS

#endif /* ISC_STRERROR_H */
