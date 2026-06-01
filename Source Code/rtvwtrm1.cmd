/*===============================================================*/
/* TO COMPILE:                                                   */
/*                                                               */
/*     CRTCMD   CMD(APLLIB/RTVWTRSTS)                            */
/*              PGM(APLLIB/RTVWTRB1)                             */
/*              SRCFILE(APLLIB/QSRC)                             */
/*              SRCMBR(RTVWTRM1)                                 */
/*              REPLACE(*YES)                                    */
/*                                                               */
/*===============================================================*/
  CMD  PROMPT('Retrieve Writer Status') +
       TEXT(*CMDPMT) ALLOW(*IPGM *BPGM *IREXX *BREXX)

  PARM KWD(WRTNME) TYPE(*CHAR) LEN(10) MIN(1) PROMPT('Writer Name')

  PARM KWD(WRTSTS) TYPE(*CHAR) LEN(10) RTNVAL(*YES) PROMPT('CL VAR FOR WRTSTS       (10) .')

  PARM KWD(FRMTYP) TYPE(*CHAR) LEN(10) RTNVAL(*YES) PROMPT('CL VAR FOR FRMTYP       (10) .')

