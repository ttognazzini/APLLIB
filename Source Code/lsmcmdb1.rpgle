     H DFTACTGRP(*NO) OPTION(*NODEBUGIO)
     FQRPGSRC   UP   F  112        DISK
      *
      * WRITE RPG NESTING LEVELS
      *
      * was sys170
     D                 DS
     D  SRCDTA                 1    100
     D  D                      1    100
     D                                     DIM(100)
     D  LDTABL                 1      2
     D  NEST                   1      4
     D  BLANK                  5      5
     D  OPCODEX               26     32
     D                 DS
     D  OPCODE                26     32
     D  ENDCOD                26     28
     D  OP2                   26     27
     D  OP3                   26     28
     D*
     D  SRCDTAUP       S            100
     IQRPGSRC   NS  01
     I                                 13  112  SRCDTA
     C     *ENTRY        PLIST
     C                   PARM                    OPTION            6
     C
     C                   EVAL      OPCODE  = %upper(OPCODEX)
     C                   EVAL      SRCDTAUP  = %upper(SRCDTA)
     C                   IF        SRCDTAUP = '**FREE'
     C                   SETON                                        LR
     C                   RETURN
     C                   ENDIF
     c*
     c                   MOVE      *BLANKS       BLANK
     C**
     C**  PROCESS RECORDS...
     C     LDTABL        CASEQ     '**'          ENDPGM
     C     OPTION        CASEQ     'CLEAR'       CLEAR
     C     D(6)          CASEQ     ' '           CLEAR
     C     D(7)          CASEQ     '*'           CLEAR
     C     D(7)          CASEQ     '/'           CLEAR
     C     OPCODE        CASEQ     'ENDSR'       CLEAR
     C     OP2           CASEQ     'DO'          INDENT
     C     OP3           CASEQ     'FOR'         INDENT
     C     OP2           CASEQ     'IF'          INDENT
     C     OPCODE        CASEQ     'SELECT'      INDENT
     C     OPCODE        CASEQ     'MONITOR'     INDENT
     C     OP3           CASEQ     'CAS'         CASE
     C     OP3           CASEQ     'END'         END
     C     OPCODE        CASEQ     'ELSE'        ELSE
     C     OPCODE        CASEQ     'ELSEIF'      ELSE
     C*****      D,6       CASNE'C'       CLEAR
     C                   CAS                     LEVEL
     C                   END
     C**
     C**   SAVE OPCODE, CASXX OPCODES NEED THIS...
     C     D(6)          IFEQ      'C'
     C     D(7)          ANDNE     '*'
     C     D(7)          ANDNE     '/'
     C     D(6)          OREQ      'c'
     C     D(7)          ANDNE     '*'
     C     D(7)          ANDNE     '/'
     C                   MOVE      OP3           SVOP3             3
     C                   ELSE
     C                   CLEAR                   SVOP3
     C                   END
     C     NEXTRCD       TAG
     C**
     C*********************************************************
     C     ENDPGM        BEGSR
     C**
     C**  END THE PROGRAM EARLY...
     C                   MOVE      '1'           *INLR
     C                   ENDSR
     C**
     C*********************************************************
     C     CLEAR         BEGSR
     C**
     C**  CLEAR COLUMNS 1 THRU 5...
     C                   CLEAR                   NEST
     C**
     C                   ENDSR
     C*********************************************************
     C     INDENT        BEGSR
     C**
     C**  INDENT A LEVEL IN...
     C                   EXSR      CLEAR
     C                   MOVEL     'B'           D(1)
     C                   ADD       1             NSTLVL            3 0
     C                   MOVE      NSTLVL        ALPHA3            3
     C                   MOVEA     ALPHA3        D(2)
     C**
     C                   ENDSR
     C*********************************************************
     C**
     C**  CASXX OPCODES...
     C     CASE          BEGSR
     C     SVOP3         CASNE     'CAS'         INDENT
     C                   END
     C**
     C                   ENDSR
     C*********************************************************
     C     END           BEGSR
     C**
     C**  GO BACK A LEVEL (UNINDENT)...
     C                   EXSR      CLEAR
     C                   MOVEL     'E'           D(1)
     C                   MOVE      NSTLVL        ALPHA3
     C                   MOVEA     ALPHA3        D(2)
     C                   SUB       1             NSTLVL
     C**
     C                   ENDSR
     C*********************************************************
     C     ELSE          BEGSR
     C**
     C**   ELSE OPCODE...
     C                   MOVEL     'X'           D(1)
     C                   MOVE      NSTLVL        ALPHA3
     C                   MOVEA     ALPHA3        D(2)
     C**
     C                   ENDSR
     C*********************************************************
     C     LEVEL         BEGSR
     C**
     C** PUT NESTING LEVEL ON C-SPEC...
     C                   CLEAR                   NEST
     C     NSTLVL        IFNE      *ZERO
     C                   MOVEL     ' '           D(1)
     C                   MOVE      NSTLVL        ALPHA3
     C                   MOVEA     ALPHA3        D(2)
     C                   END
     C**
     C                   ENDSR
     C*********************************************************
     OQRPGSRC   D    01
     O                       SRCDTA             112
