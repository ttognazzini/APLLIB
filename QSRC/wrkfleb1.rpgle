     H OPTION(*srcstmt) DFTACTGRP(*NO) BNDDIR('APLLIB')
     F* REBUILD WRKFLE
     F*
     FBLDFILETMPIF   E             DISK    USROPN
     FWRKFLE    UF A E           K DISK    USROPN
     D/INCLUDE QSRC,BASFNCV1PR // prototypes for all #$ procedures
     C*****************************************************************
     C*
     C     FILKEY        KLIST
     C                   KFLD                    FLELIB
     C                   KFLD                    FLENME
     C*
     C* BUILD THE TEMP FILE IN QTEMP, ADD ALL FILES TO IT
        #$CMD('DLTF QTEMP/BLDFILETMP':1);
        #$CMD('DSPOBJD MRPS38S/*ALL OBJTYPE(*FILE) OUTPUT(*OUTFILE) +
                              OUTFILE(QTEMP/BLDFILETMP) OUTMBR(*FIRST *ADD)');
     C*
     C* OVERRIDE THE FILE TO QTEMP AND OPEN IT
        #$CMD('OVRDBF BLDFILETMP QTEMP/BLDFILETMP');
     C                   OPEN      BLDFILETMP
     C*
     C* CLEAR WRKFLE SO THE RECORDS CAN BE ADDED BACK TO IT
     C                   MONITOR
        #$CMD('CLRPFM WRKFLE':2);
     C                   ON-ERROR
        #$DSPWIN('The file is in use so it could not be cleared. +
                  All new files have been added, but no files have +
                  been removed if they no longer exist.');
     C                   ENDMON
     C*
     C* LOOP THROUGH BLDFILETMP AND ADD RECORDS TO WRKFLE
     C                   OPEN      WRKFLE
     C                   READ      BLDFILETMP
     C                   DOW       NOT %EOF
     C                   EXSR      ADDREC
     C                   READ      BLDFILETMP
     C                   ENDDO
     C*
     C                   CLOSE     BLDFILETMP
     C                   CLOSE     WRKFLE
        #$CMD('DLTOVR BLDFILETMP');
        #$CMD('DLTF QTEMP/BLDFILETMP');
     C*
     C                   SETON                                        LR
     C                   RETURN
     C*****************************************************************
     C     ADDREC        BEGSR
     C*
     C* SKIP ANYTHING THAT IS NOT A PF
     C                   IF        ODOBAT <> 'PF' AND ODOBAT<>'PF38'
     C                   LEAVESR
     C                   ENDIF
     C*
     C* SKIP ANYTHING THAT STARTS WITH A 'Q' AND ENDS IN 'SRC'
     C                   IF        %SUBST(ODOBNM:1:1)='Q' AND
     C                             #$LAST(ODOBNM:3)='SRC'
     C                   LEAVESR
     C                   ENDIF
     C*
     C                   MOVE      ODLBNM        FLELIB
     C                   MOVE      ODOBNM        FLENME
     C     FILKEY        CHAIN     WRKFLE                             77
     C   77              CLEAR     *ALL          WRKFLER
     C   77              MOVE      ODLBNM        FLELIB
     C   77              MOVEL     ODOBNM        FLENME
     C                   MOVEL     ODOBAT        FLETYP
     C                   MOVEL     ODSRCF        SRCFLE
     C                   MOVEL     ODSRCL        SRCLIB
     C                   MOVEL     ODSRCM        SRCMBR
     C*
     C* GET FILE PREFIX, DESCRIPTION, RECORD FORMAT AND CHECK SOURCE MEMBER
     C                   CALL      'WRKFLEC1'
     C                   PARM                    FLELIB
     C                   PARM                    FLENME
     C                   PARM                    FLEDES
     C                   PARM                    FLEPFX
     C                   PARM                    RCDFMT
     C                   PARM                    SRCFLE
     C                   PARM                    SRCLIB
     C                   PARM                    SRCMBR
     C*
     C  N77              UPDATE    WRKFLER
     C   77              WRITE     WRKFLER
     C*
     C                   ENDSR
     C*****************************************************************
