CREATE ALIAS dthrgst   FOR DATABASE emsfnd NO-ERROR.
CREATE ALIAS dthrpmg   FOR DATABASE emsfnd NO-ERROR.
CREATE ALIAS dthrpyc   FOR DATABASE emsfnd NO-ERROR.
CREATE ALIAS dthrtma   FOR DATABASE emsfnd NO-ERROR.

CREATE ALIAS emsbas   FOR DATABASE ems5 NO-ERROR.
CREATE ALIAS emsedi   FOR DATABASE ems5 NO-ERROR.
CREATE ALIAS emsfin   FOR DATABASE ems5 NO-ERROR.
CREATE ALIAS emsuni   FOR DATABASE ems5 NO-ERROR.
CREATE ALIAS emsven   FOR DATABASE ems5 NO-ERROR.
CREATE ALIAS emsnam   FOR DATABASE ems5 NO-ERROR.
CREATE ALIAS movfin   FOR DATABASE ems5 NO-ERROR.

CREATE ALIAS mgadm    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgcex    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgcld    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgdbr    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgdis    FOR DATABASE ems2dis  NO-ERROR.
CREATE ALIAS mgfis    FOR DATABASE ems2fis  NO-ERROR.
CREATE ALIAS mgfro    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgind    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mginv    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgmfg    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgmnt    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgmrp    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgscm    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgsop    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mguni    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS emsgra   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS emsdca   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS ems2oe   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS eai      FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS eai2     FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgadt    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgsor    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mgmp     FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS mdtcrm   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS neogrid  FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS movadm   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS movdbr   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS movdis   FOR DATABASE ems2dis  NO-ERROR.
CREATE ALIAS movfis   FOR DATABASE ems2fis  NO-ERROR.
CREATE ALIAS movfro   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS movind   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS movmfg   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS movmnt   FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS wmovdis  FOR DATABASE ems2dis  NO-ERROR.
CREATE ALIAS mginc    FOR DATABASE ems2log  NO-ERROR.
CREATE ALIAS emsinc   FOR DATABASE ems2log  NO-ERROR.

CREATE ALIAS emsesp    FOR DATABASE custom   NO-ERROR.
/*
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int062rp.p SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int200.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int004.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int011rp-c.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int011rp-l.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int011rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int217rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int227rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int237rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int112rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int142rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int066rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int090rpw.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int147rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int046.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int110-10rp.p  SAVE INTO /tmp/. 
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int110-14rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int110-11rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int110-12rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int055.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int048rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int110-13rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int052rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int012rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int022rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int023rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int027rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int001.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int500rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int008rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int020-1rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int020-2rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int020-3rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int020-4rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int020-5rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int020-6rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int020-7rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int020-8rp.p  SAVE INTO /tmp/.
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int020-9rp.p  SAVE INTO /tmp/.
 
COMPILE /totvs/datasul/totvs12/_custom_prod/intprg/int999.p  SAVE INTO /tmp/.
*/
