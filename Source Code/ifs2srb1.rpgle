     H OPTION(*SRCSTMT: *NOSHOWCPY)

     D* VARIABLE TO HOLD THE POSITION OF THE LAST PERIOD IN THE PATH
     D LASTP           S              3P 0

     C     *ENTRY        PLIST
     C                   PARM                    PSPATH          151
     C                   PARM                    PSEXTN           10
     C*
     C                   MOVEL     PSPATH        PATH            150
     C*
     C* FIND THE LAST PERIOD, EVERYTHING AFTER THAT IS THE EXTENSION
     C                   EVAL      LASTP=%SCAN('.':PATH)
     C                   EVAL      PSEXTN=%SUBST(PATH:
     C                                           LASTP+1:
     C                                           %LEN(%TRIM(PATH))-LASTP)
     C*
     C                   SETON                                        LR
     C                   RETURN
     C*
