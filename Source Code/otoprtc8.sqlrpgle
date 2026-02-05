     H Dftactgrp(*No) Actgrp(*New) Option(*SrcStmt)  BndDir('APLLIB')
     FOUTPUT    O    F   92        DISK
      /COPY QSRC,BASFNCV1PR // prototypes for all #$ procedures

         // DEFAULT SQL OPTIONS
         Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO,
                  DynUsrPrf = *owner, CloSQLCsr = *endmod;

     C     *ENTRY        PLIST
     C                   PARM                    WSBCAD           60
     C*
     C                   EXCEPT    #DTL
     C                   SETON                                        LR
     C                   RETURN
     C*
     OOUTPUT    E            #DTL
     O                       WSBCAD              72
