/*******************************************************************/
/* RETRIEVE SPOOLED FILE ATTRIBUTES - RTVSPLFA                     */
/*                                                                 */
/* CRTCMD CMD(APLLIB/RTVSPLFA)                                     */
/*        PGM(APLLIB/RTVSPLB1)                                     */
/*        SRCFILE(APLLIB/QSRC)                                     */
/*        SRCMBR(RTVSPLM1)                                         */
/*        ALLOW(*IPGM *BPGM *IREXX *BREXX)                         */
/*        REPLACE(*YES)                                            */
/*                                                                 */
/*  THE RTVSPLFA COMMAND RETRIEVES THE SPOOLED FILE INFORMATION    */
/*  ONE OR MORE ATTRIBUTES MAY BE RETURNED                         */
/*******************************************************************/
             CMD        PROMPT('Retrieve Spooled File Attr') +
                          HLPID(RTVSPLFA) HLPPNLGRP(APLLIB/RTVSPLP1) +
                          TEXT(*CMDPMT) ALLOW(*IPGM *BPGM *IREXX *BREXX)
             PARM       KWD(SPLF) TYPE(*NAME) MIN(1) +
                          PROMPT('Spooled File')
             PARM       KWD(JOB) TYPE(QUAL1) DFT(*) SNGVAL(*) +
                          PROMPT('Job Name')
             PARM       KWD(SPLNBR) TYPE(*CHAR) LEN(6) DFT(*LAST) +
                          SPCVAL(*ONLY *LAST) +
                          PROMPT('Spooled File Number')
             PARM       KWD(FORMTYPE) TYPE(*CHAR) LEN(10) +
                          RTNVAL(*YES) +
                          PROMPT('Form Type                 (10)')
             PARM       KWD(OUTPTY) TYPE(*CHAR) LEN(1) RTNVAL(*YES) +
                          PROMPT('Output Priority            (1)')
             PARM       KWD(CPYLEFT) TYPE(*CHAR) LEN(3) RTNVAL(*YES) +
                          PROMPT('Number of Copies Left      (3)')
             PARM       KWD(COPIES) TYPE(*CHAR) LEN(3) RTNVAL(*YES) +
                          PROMPT('Total Number of Copies     (3)')
             PARM       KWD(MAXRCDS) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Maximum Records           (10)')
             PARM       KWD(FILESEP) TYPE(*CHAR) LEN(1) RTNVAL(*YES) +
                          PROMPT('File Seperators            (1)')
             PARM       KWD(SCHEDULE) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Schedule                   (8)')
             PARM       KWD(HOLD) TYPE(*CHAR) LEN(4) RTNVAL(*YES) +
                          PROMPT('Hold File                  (4)')
             PARM       KWD(SAVE) TYPE(*CHAR) LEN(4) RTNVAL(*YES) +
                          PROMPT('Save After Output          (4)')
             PARM       KWD(DEVTYPE) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Device Type               (10)')
             PARM       KWD(PRTTYPE) TYPE(*CHAR) LEN(5) RTNVAL(*YES) +
                          PROMPT('Printer Type               (5)')
             PARM       KWD(DEVFILE) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Device File               (10)')
             PARM       KWD(DEVFILEL) TYPE(*CHAR) LEN(10) +
                          RTNVAL(*YES) +
                          PROMPT('Device File Library       (10)')
             PARM       KWD(USRDTA) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('User Data                 (10)')
             PARM       KWD(ACGCDE) TYPE(*CHAR) LEN(15) RTNVAL(*YES) +
                          PROMPT('Accounting Code           (15)')
             PARM       KWD(OPNPGM) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Program Which Opened File (10)')
             PARM       KWD(OPNPGML) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('PGM LIB Which Opened File (10)')
             PARM       KWD(OPNDAT) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Open Date                  (8)')
             PARM       KWD(OPNTIM) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Open Time                  (8)')
             PARM       KWD(PAGWTN) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Page Begin Written        (10)')
             PARM       KWD(TOTPAG) TYPE(*CHAR) LEN(10) RTNVAL(*YES) +
                          PROMPT('Total Pages               (10)')
             PARM       KWD(RCDLEN) TYPE(*CHAR) LEN(5) RTNVAL(*YES) +
                          PROMPT('Record Length              (5)')
             PARM       KWD(PAGLEN) TYPE(*CHAR) LEN(3) RTNVAL(*YES) +
                          PROMPT('Page Length                (3)')
             PARM       KWD(PAGWDT) TYPE(*CHAR) LEN(3) RTNVAL(*YES) +
                          PROMPT('Page Width                 (3)')
             PARM       KWD(LPI) TYPE(*CHAR) LEN(1) RTNVAL(*YES) +
                          PROMPT('Lines per Inch             (1)')
             PARM       KWD(CPI) TYPE(*CHAR) LEN(2) RTNVAL(*YES) +
                          PROMPT('Characters per Inch        (2)')
             PARM       KWD(OVRFLW) TYPE(*CHAR) LEN(3) RTNVAL(*YES) +
                          PROMPT('Overflow Line              (3)')
             PARM       KWD(FOLD) TYPE(*CHAR) LEN(4) RTNVAL(*YES) +
                          PROMPT('Fold Print Line            (4)')
             PARM       KWD(CTLCHAR) TYPE(*CHAR) LEN(5) RTNVAL(*YES) +
                          PROMPT('Control Character          (5)')
             PARM       KWD(RPLUNPRT) TYPE(*CHAR) LEN(4) RTNVAL(*YES) +
                          PROMPT('Replace Unprintable Char   (4)')
             PARM       KWD(ALIGN) TYPE(*CHAR) LEN(4) RTNVAL(*YES) +
                          PROMPT('Align Forms                (4)')
             PARM       KWD(PRTQLTY) TYPE(*CHAR) LEN(6) RTNVAL(*YES) +
                          PROMPT('Print Quality              (6)')
             PARM       KWD(FORMFEED) TYPE(*CHAR) LEN(8) RTNVAL(*YES) +
                          PROMPT('Form Feed                  (8)')
             PARM       KWD(DRAWER) TYPE(*CHAR) LEN(1) RTNVAL(*YES) +
                          PROMPT('Drawer                     (1)')
             PARM       KWD(FONT) TYPE(*CHAR) LEN(5) RTNVAL(*YES) +
                          PROMPT('Printer Font               (5)')
             PARM       KWD(PAGRTT) TYPE(*CHAR) LEN(5) RTNVAL(*YES) +
                          PROMPT('Page Rotation              (5)')
             PARM       KWD(JUSTIFY) TYPE(*CHAR) LEN(3) RTNVAL(*YES) +
                          PROMPT('Justification              (3)')
             PARM       KWD(RTVSPLFNBR) TYPE(*CHAR) LEN(6) +
                          RTNVAL(*YES) PROMPT('Retrieved Spooled +
                          File Nbr (6)')
 QUAL1:      QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) MIN(0) +
                          PROMPT('User Name')
             QUAL       TYPE(*CHAR) LEN(6) MIN(0) +
                          PROMPT('Number')
