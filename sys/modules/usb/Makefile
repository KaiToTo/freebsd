#
# $FreeBSD$
#
# Copyright (c) 2008 Hans Petter Selasky. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

SUBDIR = usb
SUBDIR += ehci musb ohci uhci xhci uss820dci ${_at91dci} ${_atmegadci} ${_avr32dci}
SUBDIR += rum run uath upgt usie ural zyd ${_urtw}
SUBDIR += atp uhid ukbd ums udbp ufm uep
SUBDIR += ucom u3g uark ubsa ubser uchcom ucycom ufoma uftdi ugensa uipaq ulpt \
	  umct umcs umodem umoscom uplcom uslcom uvisor uvscom
SUBDIR += uether aue axe cdce cue kue mos rue udav uhso ipheth
SUBDIR += usfs umass urio
SUBDIR += quirk template

.if ${MACHINE_CPUARCH} == "amd64"
_urtw=		urtw
.endif

.if ${MACHINE_CPUARCH} == "arm"
_at91dci=	at91dci
_atmegadci=	atmegadci
.endif

.if ${MACHINE_CPUARCH} == "i386"
_urtw=		urtw
.endif

.if ${MACHINE_CPUARCH} == "avr32"
_avr32dci=	avr32dci
.endif

.include <bsd.subdir.mk>
