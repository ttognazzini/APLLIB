      ****************************************************************
      * Copy Spooled File To Duplicate Spooled File                  *
      ****************************************************************
      *  Allows overidding the user data and output queue.           *
      *  Can easily be modified to overide other attributes by       *
      *  defining them in the SplfAtt data strucutre, just google    *
      *  the format SPLA0200 to find a list of what is in the        *
      *  data structure.                                             *
      ****************************************************************
     D SplfAtt         DS
     D  AtrData                1   4200
     D  UserName              59     68
     D  SplfNum               85     88B 0
     D  UserData              99    108
     D  Outq                 191    210                                         Qualifled,name,lib
     D*
     D APIError        DS
     D  EBytesP                1      4B 0 INZ(40)
     D  EBytesA                5      8B 0
     D  EMsgID                 9     15
     D  EReserverd            16     16
     D  EData                 17     56
     D*
     D                 DS
     D Splf#b                  1      4B 0
     D CSpl#                   1      4
     D*
     D SplSpc1         C                   CONST('SPL001US  QTEMP     ')
     D*
     D SpcPtr          S               *
     D*
     D SpcName         S             20
     D SpcAtr          S             10
     D SpcSiz          S             10I 0 INZ(32767)
     D SpcInv          S              1
     D SpcAut          S             10    INZ('*ALL')
     D SpcDes          S             50    INZ('User Space Spool APIs')
     D SpcRepl         S             10    INZ('*YES')
     D SpcFormat       S              8
     D*
     D JobName         S             26
     D JobID           S             26    INZ
     D SplFID          S             26    INZ
     D EndOper         S             10    INZ('*WAIT')
     D RecLen          S              9B 0 INZ(%size(SplfAtt))
     D SplfIH          S              9B 0
     D SplfOH          S              9B 0
     D #Buff           S              9B 0
     D Buffer#         S              9B 0
     D Splf#d          S              6  0
     D*
     D FILELIB         S             20
     D MESSAGETYP      S             10
     D MESSAGEQUE      S             10
     D MSGF            S             20    INZ('QCPFMSG   QSYS      ')
     D*
     D ERRORDS         DS           116    INZ
     D  BYTESPRV               1      4B 0 INZ(116)
     D  BYTESAVL               5      8B 0
     D  MESSAGEID              9     15
     D  ERR###                16     16
     D  MESSAGEDTA            17    116
     D                 DS
     D  SPACELEN               1      4B 0
     D  RECEIVELEN             5      8B 0
     D  MESSAGEKEY             9     12B 0
     D  MSGDTALEN             13     16B 0
     D  MSGQUENBR             17     20B 0
     D                SDS
     D  WSID                 244    253
     D  USER                 254    263
     D  PARMS            *PARMS
     C****************************************************************
     C*
     C     *ENTRY        PLIST
     C                   PARM                    File             10
     C                   PARM                    JobName          26
     C                   PARM                    Splf#x            6 0
     C                   PARM                    psusrdta         10
     C                   PARM                    psoutq           20
     C                   PARM                    psovrusr          4
     C*
     C                   EXSR      $RTVSPLFA
     C                   EVAL      SPCNAME = SPLSPC1
     C                   EXSR      $CRTSP
     C                   EXSR      $CREATESF
     C                   EXSR      $OPENSF
     C                   EXSR      $GETSF
     C                   EXSR      $PUTSF
     C                   EXSR      $CLOSESF
     C*                  EXSR      $DLTSP
     C*
     C                   SETON                                        LR
     C                   RETURN
     C**************************************************************
     C* Create Spooled File                                        *
     C**************************************************************
     C     $CREATESF     BEGSR
     C*
     C                   CALL      'QSPCRTSP'
     C                   PARM                    SplfOH
     C                   PARM                    SplfAtt
     C                   PARM                    APIError
     C*
     C                   ENDSR
     C**************************************************************
     C* Open Spooled File                                          *
     C**************************************************************
     C     $OPENSF       BEGSR
     C*
     C                   eval      #Buff = -1
     C*
     C                   CALL      'QSPOPNSP'
     C                   PARM                    SplfIH
     C                   PARM                    JobName
     C                   PARM                    JobID
     C                   PARM                    SplfID
     C                   PARM                    File
     C                   PARM                    Splf#b
     C                   PARM                    #Buff
     C                   PARM                    APIError
     C*
     C*
     C                   ENDSR
     C**************************************************************
     C* Get Spooled File Data                                      *
     C**************************************************************
     C     $GETSF        BEGSR
     C*
     C                   eval      Buffer# = -1
     C*
     C                   CALL      'QSPGETSP'
     C                   PARM                    SplfIH
     C                   PARM                    SpcName
     C                   PARM      'SPFR0200'    SpcFormat
     C                   PARM                    Buffer#
     C                   PARM                    EndOper
     C                   PARM                    APIError
     C*
     C                   ENDSR
     C**************************************************************
     C* Put Spooled File Data                                      *
     C**************************************************************
     C     $PUTSF        BEGSR
     C*
     C                   CALL      'QSPPUTSP'
     C                   PARM                    SplfOH
     C                   PARM                    SpcName
     C                   PARM                    APIError
     C*
     C                   ENDSR
     C**************************************************************
     C* Close Spooled File                                         *
     C**************************************************************
     C     $CLOSESF      BEGSR
     C*
     C                   CALL      'QSPCLOSP'
     C                   PARM                    SplfIH
     C                   PARM                    APIError
     C*
     C                   CALL      'QSPCLOSP'
     C                   PARM                    SplfOH
     C                   PARM                    APIError
     C*
     C                   ENDSR
     C**************************************************************
     C* Call Retrieve Spooled File Attributes API                  *
     C**************************************************************
     C     $RTVSPLFA     BEGSR
     C*
     C                   z-add     Splf#x        Splf#d
     C                   eval      Splf#b = Splf#d
     C*
     C                   CALL      'QUSRSPLA'
     C                   PARM                    SplfAtt
     C                   PARM                    RecLen
     C                   PARM      'SPLA0200'    SpcFormat
     C                   PARM                    JobName
     C                   PARM                    JobID
     C                   PARM                    SplfID
     C                   PARM                    File
     C                   PARM                    Splf#b
     C*
     C* OVERRIDE THE USER DATA IF PASSED
     C                   IF        PSUSRDTA<>'*SAME' AND PSUSRDTA<>' '
     C                   EVAL      USERDATA=PSUSRDTA
     C                   ENDIF
     C*
     C* OVERRIDE THE OUTQ IF PASSED
     C                   IF        PSOUTQ<>'*SAME' AND PSOUTQ<>' '
     C                   EVAL      OUTQ=PSOUTQ
     C                   ENDIF
     C*
     C* OVERRIDE TO THE CURRENT USER, THIS WILL CHANGE THE JOB TO
     C* THE CURRENTS USERS qprt... JOB
     C                   IF        PSOVRUSR='*YES'
     C                   EVAL      USERNAME=USER
     C                   ENDIF
     C*
     C* If the spooled file number coming in is 0 (*ONLY) or -1 (*LAST)
     C* replace SPLF#B with the real number from the attributes.
     C                   IF        Splf#x=-1 OR Splf#x=0
     C                   EVAL      Splf#b=SplfNum
     C                   ENDIF
     C*
     C                   ENDSR
     C**************************************************************
     C* Create User Space                                          *
     C**************************************************************
     C     $CRTSP        BEGSR
     C*
     C                   CALL      'QUSCRTUS'
     C                   PARM                    SpcName
     C                   PARM                    SpcAtr
     C                   PARM                    SpcSiz
     C                   PARM                    SpcInv
     C                   PARM                    SpcAut
     C                   PARM                    SpcDes
     C                   PARM                    SpcRepl
     C                   PARM                    ERRORDS
     C*
     c*  IF ERROR SEND IF AND QUIT PROGRAM
     C                   IF        MESSAGEID <> *BLANKS
     C                   EXSR      SNDMSG
     C                   RETURN
     C                   ENDIF
     C*
     C                   ENDSR
     C**************************************************************
     C* Retrieve Pointer To User Space                             *
     C**************************************************************
     C     $RTVSP        BEGSR
     C*
     C                   CALL      'QUSPTRUS'
     C                   PARM                    SpcName
     C                   PARM                    SpcPtr
     C*
     C                   ENDSR
     C**************************************************************
     C* Delete User Space                                          *
     C**************************************************************
     C     $DLTSP        BEGSR
     C*
     C                   CALL      'QUSDLTUS'
     C                   PARM                    SpcName
     C                   PARM                    APIError
     C*
     C                   ENDSR
     C***************************************************************
      *  SEND ERROR MESSAGE
     C     SNDMSG        BEGSR
     C                   CALL      'QMHSNDPM'
     C                   PARM                    MESSAGEID
     C                   PARM                    MSGF
     C                   PARM                    FILELIB
     C                   PARM      20            MSGDTALEN
     C                   PARM      '*DIAG'       MESSAGETYP
     C                   PARM      '*'           MESSAGEQUE
     C                   PARM      2             MSGQUENBR
     C                   PARM                    MESSAGEKEY
     C                   PARM                    ERRORDS
     C                   ENDSR
     C***************************************************************
