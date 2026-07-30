     H DFTACTGRP(*NO) OPTION(*NODEBUGIO:*NOSHOWCPY:*SRCSTMT)
     F*
     F* Retrieve IFS file attributes, Used by command RTVIFSA
     D*
     D* CONSTANTS
     D SUCCESS         C                   '0'
     D FAILURE         C                   '1'
     D NULL            s              1a   inz( x'00' )
     D*
     D* Get IFS object status via UNIX API stat()
     D stat            pr            10i 0 extproc('stat')
     D  filename                       *   value options(*string)               null terminated str
     D  statStruct                     *   value
     D*
     D* API return structure
     D STATDS          DS
     D  ST_MODE                      10U 0                                      FILE MODE
     D  ST_INO                       10U 0                                      FILE INODE
     D  ST_NLINK                      5U 0                                      # LINKS
     D  ST_PAD                        2A                                        PADDING
     D  ST_UID                       10U 0                                      OWNER'S USER ID
     D  ST_GID                       10U 0                                      OWNER'S GROUP ID
     D  ST_SIZE                      10I 0                                      REGULAR FILE SIZE
     D  ST_ATIME                     10I 0                                      ACCESS DATE/TIME
     D  ST_MTIME                     10I 0                                      MOD DATE/TIME
     D  ST_CTIME                     10I 0                                      CHANGE DATE/TIME
     D  ST_DEV                       10U 0                                      DEVICE ID
     D  ST_BLKSIZE                   10U 0                                      BLOCK SIZE
     D  ST_ALCSIZE                   10U 0                                      ALLOCATED SIZE
     D  ST_OBJTYPE                   12A                                        AS/400 OBJECT TYPE
     D  ST_CODEPAG                    5U 0                                      DATA CODE PAGE
     D  ST_RESERV1                   67A                                        RESERVED
     D*
     D* VARIABLES
     D PATHNAME        S            640A   INZ
     D EPOCH           S               Z   INZ(Z'1970-01-01-00.00.00.00000')
     D STATUS          S             10I 0 INZ
     D WORKDT          S               Z
     D WORKD           S               D
     D WORKT           S               T
     D*
     D* Get IFS object status via UNIX API qgetattr()
     D GetAtr          Pr            10i 0 ExtProc( 'Qp0lGetAttr' )
     D  FilNam                         *   Value
     D  AtrLst                         *   Value
     D  Buffer                         *   Value
     D  BufSizPrv                    10u 0 Value
     D  BufSizAvl                    10u 0
     D  BufSizRtn                    10u 0
     D  FlwSymLnk                    10u 0 Value
     D  Dots                         10i 0 Options( *NoPass )
     D*
     D* VARIABLES USED FOR QGETATTR
     D CUR_CCSID       c                   0
     D CUR_CTRID       c                   x'0000'
     D CUR_LNGID       c                   x'000000'
     D CHR_DLM_1       c                   0
     D Path            Ds                  Qualified  Align
     D  CcsId                        10i 0 Inz( CUR_CCSID )
     D  CtrId                         2a   Inz( CUR_CTRID )
     D  LngId                         3a   Inz( CUR_LNGID )
     D                                3a   Inz( *Allx'00' )
     D  PthTypI                      10i 0 Inz( CHR_DLM_1 )
     D  PthNamLen                    10i 0
     D  PthNamDlm                     2a   Inz( '/ ' )
     D                               10a   Inz( *Allx'00' )
     D  PthNam                     5000a
     D AtrIds          Ds                  Qualified  Align
     D   NbrAtr                      10i 0 Inz( 1 )
     D   AtrId                       10i 0 Dim( 32 )
     D pBuffer         s               *
     D Buffer          Ds                  Qualified  Align  Based( pBufferE )
     D   OfsNxtAtr                   10u 0
     D   AtrId                       10u 0
     D   SizAtr                      10u 0
     D                                4a
     D   AtrDta                    1024a
     D   AtrInt                      10i 0 Overlay( AtrDta )
     D BufSizAvl       s             10u 0 Inz( 0 )
     D NbrBytRtn       s             10u 0 Inz( 0 )
     D ApiBytAlc       s             10u 0
     D PxKeyPrm2       S             10i 0
     D*
     D*
     C**********************************************************************
     C*
     C     *ENTRY        PLIST
     C                   PARM                    INPATH          100
     C                   PARM                    IOMODE           10 0
     C                   PARM                    IOINODE          10 0
     C                   PARM                    IONLINKS          5 0
     C                   PARM                    IOUSERID         10 0
     C                   PARM                    IOGROUPID        10 0
     C                   PARM                    IOSIZE           10 0
     C                   PARM                    IOADATE           7
     C                   PARM                    IOATIME           6
     C                   PARM                    IOMDATE           7
     C                   PARM                    IOMTIME           6
     C                   PARM                    IOCDATE           7
     C                   PARM                    IOCTIME           6
     C                   PARM                    IODEVICE         10 0
     C                   PARM                    IOBSIZE          10 0
     C                   PARM                    IOASIZE          10 0
     C                   PARM                    IOOBJTYPE        12
     C                   PARM                    IOCODEPAGE       10 0
     C                   PARM                    IOERROR           1
     C                   PARM                    IOTEXT           50
     C*
     C                   EVAL      PATHNAME = %TRIM(INPATH) + NULL
     C                   EVAL      STATUS = STAT(%TRIM(PATHNAME):%ADDR(STATDS))
     C                   IF        STATUS = 0
     C                   EVAL      IOERROR = SUCCESS
     C                   ELSE
     C                   EVAL      IOERROR = FAILURE
     C                   ENDIF
     C                   IF        IOERROR = SUCCESS
     C*
     C* ST_MODE (FILE MODE)
     C                   MOVE      ST_MODE       IOMODE
     C* ST_INO (FILE INODE)
     C                   MOVE      ST_INO        IOINODE
     C* ST_NLINK (# OF LINKS TO FILE)
     C                   MOVE      ST_NLINK      IONLINKS
     C* ST_UID (OWNER'S USER ID)
     C                   MOVE      ST_UID        IOUSERID
     C* ST_GID (OWNER'S GROUP ID)
     C                   MOVE      ST_GID        IOGROUPID
     C* ST_SIZE (REGULAR FILE SIZE)
     C                   MOVE      ST_SIZE       IOSIZE
     C* ST_ATIME (ACCESS DATE/TIME)
     C                   EVAL      WORKDT = EPOCH
     C                   ADDDUR    ST_ATIME:*S   WORKDT
     C                   MOVE      WORKDT        WORKD
     C                   MOVE      WORKDT        WORKT
     C     *CYMD0        MOVE      WORKD         IOADATE
     C     *HMS0         MOVE      WORKT         IOATIME
     C* ST_MTIME (MODIFICATION DATE/TIME)
     C                   EVAL      WORKDT = EPOCH
     C                   ADDDUR    ST_MTIME:*S   WORKDT
     C                   MOVE      WORKDT        WORKD
     C                   MOVE      WORKDT        WORKT
     C     *CYMD0        MOVE      WORKD         IOMDATE
     C     *HMS0         MOVE      WORKT         IOMTIME
     C* ST_CTIME (FILE STATUS CHANGED DATE/TIME)
     C                   EVAL      WORKDT = EPOCH
     C                   ADDDUR    ST_CTIME:*S   WORKDT
     C                   MOVE      WORKDT        WORKD
     C                   MOVE      WORKDT        WORKT
     C     *CYMD0        MOVE      WORKD         IOCDATE
     C     *HMS0         MOVE      WORKT         IOCTIME
     C* ST_DEV (FILE DEVICE)
     C                   MOVE      ST_DEV        IODEVICE
     C* ST_BLKSIZE (BLOCK SIZE)
     C                   MOVE      ST_BLKSIZE    IOBSIZE
     C* ST_ALCSIZE (ALLOCATED FILE SIZE)
     C                   MOVE      ST_ALCSIZE    IOASIZE
     C* ST_OBJTYPE (AS/400 OBJECT TYPE)
     C                   MOVE      ST_OBJTYPE    IOOBJTYPE
     C* ST_CODEPAG (DATA CODE PAGE)
     C                   MOVE      ST_CODEPAG    IOCODEPAGE
     C                   ENDIF
     C*
     C* ATTEMPT TO GET THE FILE TEXT VIA THE QGETATTR API
       Path.PthNam    = %trim(INPATH);
       Path.PthNamLen = %Len( %trim(INPATH) );
       AtrIds.NbrAtr    = 1;
       AtrIds.AtrId(1)  = 48;
       ApiBytAlc = 32767;
       pBuffer   = %Alloc( ApiBytAlc );
       STATUS = GetAtr( %Addr( Path )
                      : %Addr( AtrIds )
                      : pBuffer
                      : ApiBytAlc
                      : BufSizAvl
                      : NbrBytRtn
                      : PxKeyPrm2  );
       IF STATUS = 0;
          pBufferE = pBuffer;
          if (buffer.sizatr<=50);
             IOTEXT = %subst(buffer.atrdta:1:buffer.sizatr);
          else;
             IOTEXT = %subst(buffer.atrdta:1:50);
          endif;
       ENDIF;
     C*
     C*
     C                   EVAL      *INLR = *ON
     C                   RETURN
     C*
     C**********************************************************************
