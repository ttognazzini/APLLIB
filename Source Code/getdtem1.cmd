   /*   CRTCMD CMD(APLLIB/GETDTE)                        +
               PGM(*LIBL/GETDTE)                         +
               SRCFILE(APLLIB/QSRC)                      +
               SRCMBR(GETDTEM1)                          +
               REPLACE(*YES)                             */
             CMD        PROMPT('Get Current Date (YYYYMMDD)') +
                          MAXPOS(1) ALLOW(*IPGM *BPGM *IREXX +
                          *BREXX) HLPID(GETDATE) HLPPNLGRP(GETDTEP1)
             PARM       KWD(Dec8) TYPE(*DEC) LEN(8) RTNVAL(*YES) +
                          PROMPT('Variable for YYYYMMDD    (8 0)')
             PARM       KWD(Chr8) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Variable for YYYYMMDD      (8)')
             PARM       KWD(Dec6) TYPE(*DEC) LEN(6) RTNVAL(*YES) +
                          PROMPT('Variable for YYMMDD      (6 0)')
             PARM       KWD(Chr6) TYPE(*CHAR) LEN(6) RTNVAL(*YES) +
                          PROMPT('Variable for YYMMDD        (6)')
             PARM       KWD(DecMDY8) TYPE(*DEC) LEN(8) RTNVAL(*YES) +
                          PROMPT('Variable for MMDDYYYY    (8 0)')
             PARM       KWD(ChrMDY8) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Variable for MMDDYYYY      (8)')
             PARM       KWD(DecMDY6) TYPE(*DEC) LEN(6) RTNVAL(*YES) +
                          PROMPT('Variable for MMDDYY      (6 0)')
             PARM       KWD(ChrMDY6) TYPE(*CHAR) LEN(6) RTNVAL(*YES) +
                          PROMPT('Variable for MMDDYY        (6)')
             PARM       KWD(DecYYYY) TYPE(*DEC) LEN(4) RTNVAL(*YES) +
                          PROMPT('Variable for YYYY        (4 0)')
             PARM       KWD(CHRYYYY) TYPE(*CHAR) LEN(4) RTNVAL(*YES) +
                          PROMPT('Variable for YYYY          (4)')
             PARM       KWD(DecYY) TYPE(*DEC) LEN(2) RTNVAL(*YES) +
                          PROMPT('Variable for YY          (2 0)')
             PARM       KWD(ChrYY) TYPE(*CHAR) LEN(2) RTNVAL(*YES) +
                          PROMPT('Variable for CHAR(YY)      (2)')
             PARM       KWD(DecMM) TYPE(*DEC) LEN(2) RTNVAL(*YES) +
                          PROMPT('Variable for Dec(MM)     (2 0)')
             PARM       KWD(ChrMM) TYPE(*CHAR) LEN(2) RTNVAL(*YES) +
                          PROMPT('Variable for CHAR(MM)      (2)')
             PARM       KWD(DecDD) TYPE(*DEC) LEN(2) RTNVAL(*YES) +
                          PROMPT('Variable for Dec(DD)     (2 0)')
             PARM       KWD(ChrDD) TYPE(*CHAR) LEN(2) RTNVAL(*YES) +
                          PROMPT('Variable for CHAR(DD)      (2)')
             PARM       KWD(ChrF8) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Variable for YYYY-MM-DD   (10)')
             PARM       KWD(ChrF6) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Variable for YY-MM-DD      (8)')
             PARM       KWD(ChrFMDY8) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Variable for MM-DD-YYYY   (10)')
             PARM       KWD(ChrFMDY6) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Variable for MM-DD-YY      (8)')
             PARM       KWD(ChrS8) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Variable for YYYY/MM/DD   (10)')
             PARM       KWD(ChrS6) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Variable for YY/MM/DD      (8)')
             PARM       KWD(ChrSMDY8) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Variable for MM/DD/YYYY   (10)')
             PARM       KWD(ChrSMDY6) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Variable for MM/DD/YY      (8)')
             PARM       KWD(AddDay) TYPE(*DEC) LEN(5) +
                          PROMPT('Add Days')
             PARM       KWD(SubDay) TYPE(*DEC) LEN(5) +
                          PROMPT('Subtract Days')
             PARM       KWD(AddWrkDay) TYPE(*DEC) LEN(5) +
                          PROMPT('Add Work Days')
             PARM       KWD(SubWrkDay) TYPE(*DEC) LEN(5) +
                          PROMPT('Subtract Work Days')
             PARM       KWD(AddMth) TYPE(*DEC) LEN(5) +
                          PROMPT('Add Months')
             PARM       KWD(SubMth) TYPE(*DEC) LEN(5) +
                          PROMPT('Subtract Months')
             PARM       KWD(AddYear) TYPE(*DEC) LEN(5) +
                          PROMPT('Add Years')
             PARM       KWD(SubYear) TYPE(*DEC) LEN(5) +
                          PROMPT('Subtract Years')
             PARM       KWD(StrDate) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*JOB) VALUES(*JOB *SYS *PASS) MIN(0) +
                          PROMPT('Starting Date')
 P1:         PMTCTL     CTL(StrDate) COND((*EQ '*PASS'))
             PARM       KWD(InDate) TYPE(*CHAR) LEN(8) +
                          CHOICE('YYYYMMDD, Character Data') +
                          PROMPT('Input Date') PMTCTL(P1)
