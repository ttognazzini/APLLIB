     H OPTION(*SRCSTMT: *NOSHOWCPY)
     D lo              c                   'abcdefghijklmnopqrstuvwxyz'
     D up              c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     C*
     C     *ENTRY        PLIST
     C                   PARM                    PSEXTN           10
     C*
     C* FIND THE LAST PERIOD, EVERYTHING AFTER THAT IS THE EXTENSION
     C                   EVAL      PSEXTN=%XLATE(UP:LO:PSEXTN)
     C*
     C                   SETON                                        LR
     C                   RETURN
     C*
