/*-
 * Copyright (c) 2009 Rui Paulo
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
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <sys/cdefs.h>
#ifdef __FreeBSD__
__FBSDID("$FreeBSD$");
#endif

/*
 * IEEE 802.11s Mesh Point (MBSS) support.
 */
#include "opt_inet.h"
#include "opt_wlan.h"

#include <sys/param.h>
#include <sys/systm.h> 
#include <sys/mbuf.h>   
#include <sys/malloc.h>
#include <sys/kernel.h>

#include <sys/socket.h>
#include <sys/sockio.h>
#include <sys/endian.h>
#include <sys/errno.h>
#include <sys/proc.h>
#include <sys/sysctl.h>

#include <net/if.h>
#include <net/if_media.h>
#include <net/if_llc.h>
#include <net/ethernet.h>

#include <net/bpf.h>

#include <net80211/ieee80211_var.h>
#include <net80211/ieee80211_mesh.h>
#include <net80211/ieee80211_input.h>

static void	mesh_vattach(struct ieee80211vap *);
static int	mesh_newstate(struct ieee80211vap *, enum ieee80211_state, int);
static int	mesh_input(struct ieee80211_node *, struct mbuf *, int, int,
		    uint32_t);

void
ieee80211_mesh_attach(struct ieee80211com *ic)
{
	ic->ic_vattach[IEEE80211_M_MBSS] = mesh_vattach;
}

void
ieee80211_mesh_detach(struct ieee80211com *ic)
{
}

static void
mesh_vattach(struct ieee80211vap *vap)
{
	vap->iv_newstate = mesh_newstate;
	vap->iv_input = mesh_input;
	vap->iv_opdetach = mesh_vdetach;
}

static int
mesh_newstate(struct ieee80211vap *vap, enum ieee80211_state nstate, int arg)
{
	struct ieee80211com *ic = vap->iv_ic;
	enum ieee80211_state ostate;

	IEEE80211_LOCK_ASSERT(ic);

        ostate = vap->iv_state;
        IEEE80211_DPRINTF(vap, IEEE80211_MSG_STATE, "%s: %s -> %s (%d)\n",
            __func__, ieee80211_state_name[ostate],
            ieee80211_state_name[nstate], arg);
        vap->iv_state = nstate;                 /* state transition */
        if (ostate != IEEE80211_S_SCAN)
                ieee80211_cancel_scan(vap);     /* background scan */
        switch (nstate) {
	}
}

