# $FreeBSD$

.PATH:	${.CURDIR}/../../dev/wtap

# Declare Name of kernel module
KMOD	=  wtap

# Enumerate Source files for kernel module
SRCS	=  if_wtap_module.c if_wtap.c if_medium.c

.PATH:	${.CURDIR}/../../dev/wtap/wtap_hal
SRCS	+= hal.c

.PATH:	${.CURDIR}/../../dev/wtap/plugins
SRCS	+= visibility.c

SRCS	+= opt_global.h

.if defined(KERNBUILDDIR)
MKDEP=          -include ${KERNBUILDDIR}/opt_global.h
.else
CFLAGS+=        -include opt_global.h
MKDEP=          -include opt_global.h

opt_global.h:
	echo "#define VIMAGE 1" > ${.TARGET}
.endif

# Include kernel module makefile
.include <bsd.kmod.mk>
