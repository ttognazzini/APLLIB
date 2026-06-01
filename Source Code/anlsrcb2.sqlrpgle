        Ctl-Opt DftActGrp(*no) ActGrp(*caller);
    ‚ *****************************************************************
    ‚ * Program : ANLSRCB2                                            *
    ‚ * Function: Retrieve File Description (Version 1)               *
    ‚ * Author  : Werner Noll                                         *
    ‚ *                                                               *
    ‚ * Parameter: P$File         Name of pyhsical file which is to   *
    ‚ *                           retrieve.                           *
    ‚ *                                                               *
    ‚ *            P$Lib          Library where P$File is located     *
    ‚ *                           or *LIBL or *CURLIB                 *
    ‚ *                                                               *
    ‚ *            P$RcvVar       Receiver Variable                   *
    ‚ *                           001-010 Library where the file      *
    ‚ *                                   was found (if *LIBL or      *
    ‚ *                                   *CURLIB was specified)      *
    ‚ *                           011-012 Type (PF or LF)             *
    ‚ *                           013-015 SRC or DTA                  *
    ‚ *                           016-016 K = Keyed access path       *
    ‚ *                           017-018 LC= Level check is on       *
    ‚ *                           019-028 Public authority            *
    ‚ *                                   (*CHANGE, *ALL, *USE,       *
    ‚ *                                   *EXCLUDE, Name of AUTL)     *
    ‚ *                           029-034 Max. members                *
    ‚ *                                   *NOMAX      = No maximum    *
    ‚ *                                   00001-32767 = Max. nbr.     *
    ‚ *                           035-039 Nbr. of members             *
    ‚ *                                   00001-32767                 *
    ‚ *                           040-046 Error message ID            *
    ‚ *                           047-096 Message data                *
    ‚ * Remarks : This is free software.                              *
    ‚ *           You can redistribute it and/or modify it.           *
    ‚ *           The only restriction is that you may not distribute *
    ‚ *           it for the purposes of monetary gain.               *
    ‚ *           We do not garantee for the expected functionalties. *
    ‚ *           The use of this software is always at your own risk.*
    ‚ *           All comments or reuqests for enhancements are       *
    ‚ *           welcome. My email: werner.noll@gefis.com.           *
    ‚ *****************************************************************
      * Workfields
     D P$File          S             10A
     D P$LIB           S             10A
     D P$RcvVar        S             96A
     D vFilLB          S             20A
     D vRtnFL          S             20A
     D Dec5            S              5S 0
     D Char5           S              5A
      *----------------------------------------------------------------
      * Error return code parm for APIs.
      *----------------------------------------------------------------
     D vAPIErrDs       ds
     D  vbytpv                       10i 0 inz(%size(vApiErrDs))
     D  vbytav                       10i 0 inz(0)
     D  vmsgid                        7
     D  vresvd                        1
     D  vexdta                       50
      *----------------------------------------------------------------
     D VRcVar          ds         18000
     D  Dbfhmxm               42     43U 0
     D  Dbfhmnum              48     49U 0
      *-------------------------------------------------------------------------
      * Prototypes
      *-------------------------------------------------------------------------
     D QDBRTVFD        PR                  ExtPgm('QDBRTVFD')
     Db                                    like(VRcVar)
     D                               10i 0 Const
     D                               20
     D                                8    Const
     D                               10
     D                               10    const
     D                                1    const
     D                               10    const
     D                               10    const
     Db                                    like(vAPIErrDS)
      *

       // default SQL options, rarely do any of these change
       Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO,
                           DynUsrPrf = *owner, CloSQLCsr = *endmod;

      ****************************************************************
     C     *entry        plist
     C                   parm                    P$File
     C                   parm                    P$Lib
     C                   parm                    P$RcvVar
      *--------------------------------------------------------------------
     C                   eval      P$RcvVar=*blanks
     C                   reset                   vAPIErrDS
      *--------------------------------------------------------------------
      * Retrieve Database File Description using API QDBRTVFD
     C                   eval      vFilLB=P$File+P$Lib
     C                   callp     QDBRTVFD(vRcVar:%size(vRcVar):vRtnFL:
     C                             'FILD0100':vFilLB:'*ALL':'0':'*LCL':
     C                             '*EXT':vAPIErrDS)
      * If error occured
     C                   if        vMsgID<>*blanks
     C                   eval      %subst(P$RcvVar:40:7)=vMsgID
     C                   eval      %subst(P$RcvVar:47:50)=vExDta
     C                   else
      * If no error
     C                   eval      %subst(P$RcvVar:1:10)=
     C                             %subst(vRtnFL:11:10)
      *   Retrieve PF/LF
 2B  C                   if        TestB('2':%subst(vRcVar:9:1))=*on
     C                   eval      %subst(P$RcvVar:11:2)='LF'
     C                   else
     C                   eval      %subst(P$RcvVar:11:2)='PF'
     C                   endif
      *   Retrieve SRC/DTA
 2B  C                   if        TestB('4':%subst(vRcVar:9:1))=*on
     C                   eval      %subst(P$RcvVar:13:3)='SRC'
     C                   else
     C                   eval      %subst(P$RcvVar:13:3)='DTA'
     C                   endif
      *   Retrieve if file is keyed
 2B  C                   if        TestB('6':%subst(vRcVar:9:1))=*on
     C                   eval      %subst(P$RcvVar:16:1)='K'
     C                   endif
      *   Retrieve if LVLCHK
 2B  C                   if        TestB('0':%subst(vRcVar:10:1))=*on
     C                   eval      %subst(P$RcvVar:17:2)='LC'
     C                   endif
      *   Retrieve public authority
     C                   eval      %subst(P$RcvVar:19:10)=
     C                             %subst(vRcVar:31:10)
      *   Maxium members
     C                   if        Dbfhmxm=*zeros
     C                   eval      %subst(P$RcvVar:29:6)='*NOMAX'
     C                   else
     C                   eval      Dec5=Dbfhmxm
     C                   move      Dec5          Char5
     C                   eval      %subst(P$RcvVar:29:5)=Char5
     C                   endif
      *   Number of members
     C                   eval      Dec5=Dbfhmnum
     C                   move      Dec5          Char5
     C                   eval      %subst(P$RcvVar:35:5)=Char5
     C                   endif
      *--------------------------------------------------------------------
     C                   return
      *-------------------------------------------------------------------------
      * Opcode TESTB is not valid in v5/free.
      * Returns '1' if bit is *ON, '0' if *OFF
      *-------------------------------------------------------------------------
     PTestB            B
     D TestB           PI             1
     D BitToTest                      1    Const
     D ByteToTest                     1    Const
     D ControlByte     S              1
     D HlpByte         S              1
     D Indicator       S              1
     C                   eval      HlpByte=BytetoTest
     C                   bitoff    '01234567'    ControlByte
 1B  C                   select
 1X  C                   when      BitToTest='0'
     C                   biton     '0'           ControlByte
 1X  C                   when      BitToTest='1'
     C                   biton     '1'           ControlByte
 1X  C                   when      BitToTest='2'
     C                   biton     '2'           ControlByte
 1X  C                   when      BitToTest='3'
     C                   biton     '3'           ControlByte
 1X  C                   when      BitToTest='4'
     C                   biton     '4'           ControlByte
 1X  C                   when      BitToTest='5'
     C                   biton     '5'           ControlByte
 1X  C                   when      BitToTest='6'
     C                   biton     '6'           ControlByte
 1X  C                   when      BitToTest='7'
     C                   biton     '7'           ControlByte
 1E  C                   endsl
      *
     C                   testb     ControlByte   HlpByte                  10
     C                   eval      Indicator=*in10
     C                   return    Indicator
     PTestB            E
