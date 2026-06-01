/* TO CREATE COMMAND USE THE FOLLOWING COMMAND:                           +
/* CRTCMD CMD(APLLIB/RTVIFSA)                                           +
/*        PGM(APLLIB/RTVIFSC1)                                          +
/*        SRCFILE(APLLIB/QSRC)                                          +
/*        SRCMBR(RTVIFSM1)                                              +
/*        REPLACE(*YES)                                                 */

CMD PROMPT('Retrieve IFS File Attributes') TEXT(*CMDPMT) HLPID(RTVIFSA) HLPPNLGRP(RTVIFSP1) +
           ALLOW(*IPGM *BPGM *IREXX *BREXX)
    PARM IFSFILE  TYPE(*CHAR) LEN(100) MIN(1)        PROMPT('IFS File (Case SENSITIVE)') +
                  EXPR(*YES)  CASE(*MIXED)
    PARM MODE     TYPE(*DEC)  LEN(10 0) RTNVAL(*YES) PROMPT('File Mode . . . . . . . . (10)')
    PARM INODE    TYPE(*DEC)  LEN(10 0) RTNVAL(*YES) PROMPT('File INODE. . . . . . . (10 0)')
    PARM NLINKS   TYPE(*DEC)  LEN(5 0)  RTNVAL(*YES) PROMPT('Number of Links . . . . .(5 0)')
    PARM USERID   TYPE(*DEC)  LEN(10 0) RTNVAL(*YES) PROMPT('Owner User ID . . . . . (10 0)')
    PARM GROUPID  TYPE(*DEC)  LEN(10 0) RTNVAL(*YES) PROMPT('Owner Group ID. . . . . (10 0)')
    PARM SIZE     TYPE(*DEC)  LEN(10 0) RTNVAL(*YES) PROMPT('File Size . . . . . . . (10 0)')
    PARM ADATE    TYPE(*CHAR) LEN(7)    RTNVAL(*YES) PROMPT('Access Date . . . . . . . .(7)')
    PARM ATIME    TYPE(*CHAR) LEN(6)    RTNVAL(*YES) PROMPT('Access Time . . . . . . . .(6)')
    PARM MDATE    TYPE(*CHAR) LEN(7)    RTNVAL(*YES) PROMPT('Modified Date . . . . . . .(7)')
    PARM MTIME    TYPE(*CHAR) LEN(6)    RTNVAL(*YES) PROMPT('Modified Time . . . . . . .(6)')
    PARM CDATE    TYPE(*CHAR) LEN(7)    RTNVAL(*YES) PROMPT('Changed Date. . . . . . . .(7)')
    PARM CTIME    TYPE(*CHAR) LEN(6)    RTNVAL(*YES) PROMPT('Changed Time. . . . . . . .(6)')
    PARM DEVICE   TYPE(*DEC)  LEN(10 0) RTNVAL(*YES) PROMPT('File Device . . . . . . (10 0)')
    PARM BSIZE    TYPE(*DEC)  LEN(10 0) RTNVAL(*YES) PROMPT('File Block Size . . . . (10 0)')
    PARM ASIZE    TYPE(*DEC)  LEN(10 0) RTNVAL(*YES) PROMPT('File Alloc Size . . . . (10 0)')
    PARM OBJTYPE  TYPE(*CHAR) LEN(12)   RTNVAL(*YES) PROMPT('AS400 Object Type . . . . (12)')
    PARM CODEPAGE TYPE(*DEC)  LEN(10 0) RTNVAL(*YES) PROMPT('Data Code Page. . . . . (10 0)')
    PARM TEXT     TYPE(*CHAR) LEN(50)   RTNVAL(*YES) PROMPT('Text. . . . . . . . . . . (50)')

