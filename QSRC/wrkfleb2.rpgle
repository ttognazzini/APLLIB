     H DEBUG
     F* Figure out file prefix
     FLIBRIN    IPE  F   92        DISK
     ILIBRIN    NS  01   29 CR
     I                                 31   40  RECNAM
     I          NS  04   19 C*
     I          NS  02   29 C    31NC
     I                                 31   36  FLNAME
     I                                 31   31  FLPRFX1
     I                                 31   32  FLPRFX2
     I                                 31   33  FLPRFX3
     I          NS  05
     C******************************************
     C  N99              EXSR      INITSR
     C   01              EXSR      PROC01
     C   02              EXSR      PROC02
     CLR                 EXSR      TOTTLR
     C******************************************
     C     INITSR        BEGSR
     C*
     C     *ENTRY        PLIST
     C                   PARM                    PSPRFX            4
     C                   PARM                    PSRCFM           10
     C*
     C* CLEAR SAVED PREFIX FIELDS AT LENGTHS OF 1,2, AND 3
     C* USE INDICATORS 71,72 AND 73 TO SEE IF EACH LEVEL MATCHES
     C                   MOVE      *BLANKS       SVPRFX1           1
     C                   MOVE      *BLANKS       SVPRFX2           2
     C                   MOVE      *BLANKS       SVPRFX3           3
     C                   SETOFF                                       717273
     C*
     C                   SETON                                        99
     C                   ENDSR
     C******************************************
     C     PROC01        BEGSR
     C*
     C                   MOVE      RECNAM        PSRCFM
     C*
     C                   ENDSR
     C******************************************
     C     PROC02        BEGSR
     C*
     C* SAVE EACH PREFIX, SETON INDICATOR IF THEY ARE NOT THE SAME
     C* AS THE PREVIOUS SAVED PREFIX
     C                   IF        FLPRFX1<>' ' AND SVPRFX1=' '
     C                   MOVEL     FLPRFX1       SVPRFX1
     C                   ELSEIF    FLPRFX1<>' ' AND FLPRFX1<>SVPRFX1
     C                   SETON                                        71
     C                   ENDIF
     C*
     C                   IF        FLPRFX2<>' ' AND SVPRFX2=' '
     C                   MOVEL     FLPRFX2       SVPRFX2
     C                   ELSEIF    FLPRFX2<>' ' AND FLPRFX2<>SVPRFX2
     C                   SETON                                        72
     C                   ENDIF
     C*
     C                   IF        FLPRFX3<>' ' AND SVPRFX3=' '
     C                   MOVEL     FLPRFX3       SVPRFX3
     C                   ELSEIF    FLPRFX3<>' ' AND FLPRFX3<>SVPRFX3
     C                   SETON                                        73
     C                   ENDIF
     C*
     C                   ENDSR
     C******************************************
     C     TOTTLR        BEGSR
     C*
     C                   MOVE      *BLANKS       PSPRFX
     C                   IF        NOT *IN73
     C                   MOVEL     SVPRFX3       PSPRFX
     C                   ELSEIF    NOT *IN72
     C                   MOVEL     SVPRFX2       PSPRFX
     C                   ELSEIF    NOT *IN71
     C                   MOVEL     SVPRFX1       PSPRFX
     C                   ELSE
     C                   MOVEL     '*ERR'        PSPRFX
     C                   ENDIF
     C*
     C                   ENDSR
     C******************************************
