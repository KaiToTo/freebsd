# $FreeBSD$

.PATH:	${.CURDIR}/arch/${MACHINE_CPUARCH}

LIB=	thread_db
SHLIB_MAJOR= 3
SRCS=	thread_db.c
SRCS+=	libpthread_md.c
SRCS+=	libpthread_db.c
SRCS+=	libthr_db.c
INCS=	thread_db.h

CFLAGS+=-I. -I${.CURDIR}
SYM_MAPS+=${.CURDIR}/Symbol.map

SYMBOL_MAPS=${SYM_MAPS}
VERSION_DEF=${.CURDIR}/../libc/Versions.def

.if ${CC:T:Mclang} == "clang"
# Unfortunately, clang gives an incorrect warning about alignment in
# arch/i386/libpthread_md.c, so turn that off for now.
NO_WCAST_ALIGN=
.endif

.include <bsd.lib.mk>
