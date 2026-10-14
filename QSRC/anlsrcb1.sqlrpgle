        Ctl-Opt DftActGrp(*no) ActGrp(*caller);
      *****************************************************************
      * Program : ANLSRCB1                                            *
      * Function: Analyse Source Files (Sub-Program)                  *
      * Author  : Werner Noll                                         *
      * Modified:                                                     *
      * Remarks : This is free software.                              *
      *           You can redistribute it and/or modify it.           *
      *           The only restriction is that you may not distribute *
      *           it for the purposes of monetary gain.               *
      *           We do not garantee for the expected functionalties. *
      *           The use of this software is always at your own risk.*
      *           All comments or reuqests for enhancements are       *
      *           welcome. My email: werner.noll@gefis.com.           *
      *****************************************************************
      * Overridden source file
     FSRCMBR    IF   F  122        Disk    usropn
      * Printerfile
     FANLSRCO1  O    E             Printer oflind(*in98) usropn
      *****************************************************************
      * Timestamp
     D #tmstmp         s               z
      * Today-Date/Time
     D #today_dat      s               d   datfmt(*iso)
     D #today_tim      s               t   timfmt(*hms)
      *
     D #date_iso       s               d   datfmt(*iso)
     D #date_eur       s               d   datfmt(*eur)
     D #date_jul       s               d   datfmt(*jul)
      *
      * Jobstamp (User/Job/Jobnbr/Date/Time)
     D #jobstmp        s             48a
      *
      * Program status DS (PSDS)
     D #psds          sds
     D  #psds_sts        *status
     D  #psds_pgm        *proc
     D  #psds_job            244    253A
     D  #psds_usr            254    263A
     D  #psds_jnr            264    269A
      *
     D #char008        s              8a   inz(*blanks)
     D #char010        s             10a   inz(*blanks)
     D LetUC           C                   Const('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
     D LetLC           C                   Const('abcdefghijklmnopqrstuvwxyz')
     D i1              s              5u 0
     D #Stg            s             10a   varying
     D P$SrcFLib       s             20a
     D P$Stg01         s             10a
     D P$Stg02         s             10a
     D P$Stg03         s             10a
     D P$Stg04         s             10a
     D P$Stg05         s             10a
     D P$Stg06         s             10a
     D P$Stg07         s             10a
     D P$Stg08         s             10a
     D P$Stg09         s             10a
     D P$Stg10         s             10a
     D P$CMatch        s              1a
     D P$SrcF          s             10a
     D P$SrcLib        s             10a
     D P$Mbr           s             10a
      *****************************************************************
     ISRCMBR    KF
     I                                  1    6  SRCSEQ
     I                                  7   12  SRCDAT
     I                                 13  122  SRCDTA

       // default SQL options, rarely do any of these change
       Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO,
                           DynUsrPrf = *owner, CloSQLCsr = *endmod;

      *****************************************************************
      * Main Routine
      *----------------------------------------------------------------
      *
     C                   if        P$Mbr='*END'
     C                   exsr      $CLOSE
     C                   eval      *inlr=*on
     C                   return
     C                   endif
      *
     C                   eval      wlib=P$SrcLib
     C                   eval      wfile=P$SrcF
     C                   eval      wmbr=P$Mbr
      *
     C                   open      SRCMBR
     C                   do        *hival
     C                   read(e)   SRCMBR
     C                   if        %eof(SRCMBR)
     C                   close     SRCMBR
     C                   leave
     C                   endif
      *
      *-------------------------------------------------------------------------
      * Convert lower to upper case, if case is ignored
     C                   if        P$CMatch='2'
     C     LetLC:LetUC   XLATE     SRCDTA        SRCDTA
     C                   endif
      *-------------------------------------------------------------------------
      * Process Strings 1 - 10
     C                   if        P$Stg01<>*blanks
     C                   eval      #Stg=%trimr(P$Stg01)
     C                   exsr      $SCAN
     C                   endif
     C                   if        P$Stg02<>*blanks
     C                   eval      #Stg=%trimr(P$Stg02)
     C                   exsr      $SCAN
     C                   endif
     C                   if        P$Stg03<>*blanks
     C                   eval      #Stg=%trimr(P$Stg03)
     C                   exsr      $SCAN
     C                   endif
     C                   if        P$Stg04<>*blanks
     C                   eval      #Stg=%trimr(P$Stg04)
     C                   exsr      $SCAN
     C                   endif
     C                   if        P$Stg05<>*blanks
     C                   eval      #Stg=%trimr(P$Stg05)
     C                   exsr      $SCAN
     C                   endif
     C                   if        P$Stg06<>*blanks
     C                   eval      #Stg=%trimr(P$Stg06)
     C                   exsr      $SCAN
     C                   endif
     C                   if        P$Stg07<>*blanks
     C                   eval      #Stg=%trimr(P$Stg07)
     C                   exsr      $SCAN
     C                   endif
     C                   if        P$Stg08<>*blanks
     C                   eval      #Stg=%trimr(P$Stg08)
     C                   exsr      $SCAN
     C                   endif
     C                   if        P$Stg09<>*blanks
     C                   eval      #Stg=%trimr(P$Stg09)
     C                   exsr      $SCAN
     C                   endif
     C                   if        P$Stg10<>*blanks
     C                   eval      #Stg=%trimr(P$Stg10)
     C                   exsr      $SCAN
     C                   endif
      *
     C                   enddo
     C                   return
      *----------------------------------------------------------------
      * Scan source data
      *----------------------------------------------------------------
     C     $SCAN         begsr
      *
      * Convert lower to upper case, if case is ignored
     C                   if        P$CMatch='2'
     C     LetLC:LetUC   XLATE     #Stg          #Stg
     C                   endif
      *
     C     #Stg          scan      SRCDTA
     C                   if        %found
      *
     C                   if        not %open(ANLSRCO1)
     C                   exsr      $OPEN
     C                   endif
      *
     C                   eval      wstg=#Stg
     C                   eval      wseq=SRCSEQ
     C                   eval      wdta=SRCDTA
     C                   write     ANLSRC07
      *
     C                   if        *in98=*on
     C                   write     ANLSRC01
     C                   write     ANLSRC05
     C                   write     ANLSRC06
     C                   eval      *in98=*off
     C                   endif
      *
     C                   endif
      *
     C                   endsr
      *----------------------------------------------------------------
      * Open printer file
      *----------------------------------------------------------------
     C     $OPEN         begsr
      *
     C                   eval      w$job=#jobstmp
     C                   eval      w$srcf=%subst(P$srcflib:1:10)
     C                   eval      w$lib=%subst(P$srcflib:11:10)
      *
     C                   eval      w$stg10=%TrimR(p$Stg01)+'  '+
     C                                     %TrimR(p$stg02)+'  '+
     C                                     %TrimR(p$stg03)+'  '+
     C                                     %TrimR(p$stg04)+'  '+
     C                                     %TrimR(p$stg05)+'  '+
     C                                     %TrimR(p$stg06)+'  '+
     C                                     %TrimR(p$stg07)+'  '+
     C                                     %TrimR(p$stg08)+'  '+
     C                                     %TrimR(p$stg09)+'  '+
     C                                     %TrimR(p$stg10)
      *
     C                   open      ANLSRCO1
     C                   write     ANLSRC01
     C                   write     ANLSRC05
     C                   write     ANLSRC06
      *
     C                   endsr
      *----------------------------------------------------------------
      * Close printer file
      *----------------------------------------------------------------
     C     $CLOSE        begsr
      *
     C                   if        %open(ANLSRCO1)
     C                   write     ANLSRC97
     C                   close     ANLSRCO1
     C                   endif
      *
     C                   endsr
      *----------------------------------------------------------------
      * Initialization subroutine
      *----------------------------------------------------------------
     C     *inzsr        begsr
      *
     C     *entry        plist
     C                   parm                    P$SrcFLib
     C                   parm                    P$Stg01
     C                   parm                    P$Stg02
     C                   parm                    P$Stg03
     C                   parm                    P$Stg04
     C                   parm                    P$Stg05
     C                   parm                    P$Stg06
     C                   parm                    P$Stg07
     C                   parm                    P$Stg08
     C                   parm                    P$Stg09
     C                   parm                    P$Stg10
     C                   parm                    P$CMatch
     C                   parm                    P$SrcF
     C                   parm                    P$SrcLib
     C                   parm                    P$Mbr
      *
      * Retrieve date/time
     C                   time                    #tmstmp
     C                   move      #tmstmp       #today_dat
     C                   move      #tmstmp       #today_tim
      *
      * Retrieve jobstamp
     C                   move      #today_dat    #char010
     C                   move      #today_tim    #char008
     C                   eval      #jobstmp=%trimr(#psds_usr)+'/'+
     C                             %trimr(#psds_job)+'/' + #psds_jnr+
     C                             '/'+#char010+'/'+#char008
      *
     C                   endsr
      *----------------------------------------------------------------
