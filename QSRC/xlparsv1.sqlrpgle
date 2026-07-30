     /*-                                                                            +
      * Copyright (c) 2003-2010 Scott C. Klement                                    +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms, with or without          +
      * modification, are permitted provided that the following conditions          +
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice, this list of conditions and the following disclaimer.            +
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice, this list of conditions and the following disclaimer in the      +
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ''AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +
      * Service Program for parsing Excel spreadsheets (Event Model)
      *                                 Scott Klement, January 2004
      *
      *  Licensed program requirements to compile:
      *   - ILE RPG Compiler (57xx-WDS, opt 31)
      *   - IBM Developer Kit for Java (57xx-JV1, *base)
      *   - One of the Java Developer Kit 5.0 or higher (57xx-JV1, opt 7+)
      *   - QShell (57xx-SS1, opt 30) not required, but highly recommended
      *
      * Requirements for parsing Binary Excel (XLS) workbooks:
      *   - Scott Klement's XLPARSE (from March 2010 or later)
      *       = xlparse.jar
      *   - Apache POI version 3.6 (or higher)
      *       = poi-3.6-20091214.jar
      *
      * Requirements for parsing Excel XML (XLSX) workbooks:
      *   - Scott Klement's XLPARSE (from March 2010 or later)
      *       = xlparse.jar
      *   - Apache POI version 3.6 (or higher)
      *       = poi-3.6-20091214.jar
      *       = poi-ooxml-3.6-20091214.jar
      *       = poi-ooxml-schemas-3.6-20091214.jar
      *   - Apache DOM4J 1.6.1 (or higher)
      *       = dom4j-1.6.1.jar
      *   - Apache XmlBeans 2.5.0 (or higher)
      *       = jsr173_1.0_api.jar
      *       = xbean.jar
      *
      *  All of the above JAR files should be in your CLASSPATH
      *  before the JVM is loaded in the job.
      *
      * To compile:
      *
      *   CRTSQLRPGI OBJ(QTEMP/XLPARSV1) SRCFILE(APLLIB/QSRC)
      *               OBJTYPE(*MODULE) DBGVIEW(*SOURCE)
      *   CRTSRVPGM  SRVPGM(APLLIB/XLPARSER4) MODULE(QTEMP/XLPARSV1)
      *               TEXT('Excel File Parser') EXPORT(*SRCFILE) ACTGRP(XLPARSE)
      *               STGMDL(*INHERIT) SRCFILE(QSRC) SRCMBR(XLPARSN1)
      *   DLTMOD     MODULE(QTEMP/XLPARSV1)
      *   ADDBNDDIRE BNDDIR(APLLIB/APLLIB) OBJ((XLPARSER4 *SRVPGM))
      *
     H NOMAIN OPTION(*SRCSTMT: *NODEBUGIO: *NOSHOWCPY)

      /copy QSRC,XLPARSV1PR

     D XLPARSE_CLASS   C                   'com.iseriesnetwork.clubtech.-
     D                                     xlparse.ParseSheet'
     D XSSFPARSE_CLASS...
     D                 C                   'com.iseriesnetwork.clubtech.-
     D                                     xlparse.ParseSheetXssf'
     D CBCLASS         C                   'com.iseriesnetwork.clubtech.-
     D                                     xlparse.ParseSheetCallback'

     D callbackStringCell...
     D                 PR                  ExtProc(*JAVA: CBCLASS:
     D                                             'callbackStringCell')
     D                                     static
     D  Sheet                      1024A   const varying
     D  Row                          10I 0 value
     D  Column                        5I 0 value
     D  Value                     32767A   const varying

     D callbackNumericCell...
     D                 PR                  ExtProc(*JAVA: CBCLASS:
     D                                             'callbackNumericCell')
     D                                     static
     D  Sheet                      1024A   const varying
     D  Row                          10I 0 value
     D  Column                        5I 0 value
     D  Value                         8F   value

     D callbackFormulaCell...
     D                 PR                  ExtProc(*JAVA: CBCLASS:
     D                                             'callbackFormulaCell')
     D                                     static
     D  Sheet                      1024A   const varying
     D  Row                          10I 0 value
     D  Column                        5I 0 value
     D  Value                         8F   value
     D  Nan                           5I 0 value
     D  Formula                   32767A   const varying

     D StringProc      PR             1N   ExtProc(pStringProc)
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                    32767A   varying const

     D NumericProc     PR             1N   ExtProc(pNumericProc)
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                        8F   value

     D FormulaProc     PR             1N   ExtProc(pFormulaProc)
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                        8F   value
     D   Nan                          5I 0 value
     D   Formula                  32767A   varying const

     D EndRowProc      PR                  ExtProc(pEndRowProc)
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value

     D NewRowProc      PR                  ExtProc(pNewRowProc)
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value

     D Escape          PR             1N
     D   StackCnt                    10I 0 value
     D   MsgTxt                     256A   const

     D open_fds        PR
     D isXssf          PR            10i 0
     D   pathName                  1024a   const varying

     D Last            ds                  qualified
     D   Sheet                     1024a   varying inz('*NONE')
     D   Row                         10i 0 inz(-1)

     D pStringProc     s               *   procptr inz(*NULL)
     D pNumericProc    s               *   procptr inz(*NULL)
     D pFormulaProc    s               *   procptr inz(*NULL)
     D pEndRowProc     s               *   procptr inz(*NULL)
     D pNewRowProc     s               *   procptr inz(*NULL)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * xlparse_notify():  Enable notifications.  This will cause
      *      XLPARSER4 to call subprocedures before and after
      *      each row that's read from the spreadsheet.
      *
      *    StartRow = (input) routine to call when a row begins
      *      EndRow = (input) routine to call when a row ends
      *
      * You can set one/both of these procedure pointers to *NULL
      * if you do not want to receive notification callbacks for
      * before/after events.
      *
      * A callback for either routine (before or after) should be
      * prototyped like this:
      *
      *      D mycallback      PR
      *      D  Sheet                      1024A   const varying
      *      D  Row                          10I 0 value
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P xlparse_notify...
     P                 B                   EXPORT
     D xlparse_notify...
     D                 PI
     D   startRow                      *   value procptr
     D   endRow                        *   value procptr
      /free
         pNewRowProc = startRow;
         pEndRowProc = endRow;
      /end-free
     P                 e


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * xlparse_workbook(): Parse the contents of an XLS workbook
      *
      *      Filename = /path/to/my/file.xls
      *       Numeric = procedure to call for each numeric cell in sheet
      *        String = procedure to call for each string cell in sheet
      *       Formula = procedure to call for each formula cell in sheet
      *
      * Returns 0 if successful, or -1 when a Java exception occurs
      *
      *  Callback procedures should be prototyped as follows:
      *
      *  D MyString        PR             1N
      *  D   Sheet                     1024A   varying const
      *  D   Row                         10I 0 value
      *  D   Col                          5I 0 value
      *  D   Value                    32767A   varying const
      *
      *  D MyNumeric       PR             1N
      *  D   Sheet                     1024A   varying const
      *  D   Row                         10I 0 value
      *  D   Col                          5I 0 value
      *  D   Value                        8F   value

      *  D MyFormula       PR             1N
      *  D   Sheet                     1024A   varying const
      *  D   Row                         10I 0 value
      *  D   Col                          5I 0 value
      *  D   Value                        8F   value
      *  D   Nan                          5I 0 value
      *  D   Formula                  32767A   varying const
      *
      *  The following information is sent to them:
      *
      *          Sheet = name of worksheet
      *            Row = row number (where 0 is the first row)
      *            Col = column number (where 0=A, 1=B, etc)
      *          Value = numeric or string of formula value of cell
      *
      *   You may return *ON to cancel processing, or *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P xlparse_workbook...
     P                 B                   EXPORT
     D xlparse_workbook...
     D                 PI            10I 0
     D    Filename                 1024A   const varying
     D    Numeric                      *   procptr value
     D    String                       *   procptr value
     D    Formula                      *   procptr value options(*nopass)
     D    RetainLog                    N   const options(*nopass:*omit)

     D unlink          PR            10I 0 ExtProc('unlink')
     D   path                          *   Value options(*string)

     D ParseSheet_parse...
     D                 PR                  ExtProc(*JAVA
     D                                            : XLPARSE_CLASS
     D                                            : 'parse201003' )
     D                                     static
     D    Filename                 1024A   const varying

     D ParseSheetXssf_parse...
     D                 PR                  ExtProc(*JAVA
     D                                            : XSSFPARSE_CLASS
     D                                            : 'parse' )
     D                                     static
     D    Filename                 1024A   const varying

     D Retain          s                   like(RetainLog)
     D RC              s             10I 0

      /free
            if (%parms() >= 4);
                pFormulaProc = Formula;
            else;
                pFormulaProc = *null;
            endif;

            if (%parms() >= 5 and %addr(RetainLog)<>*NULL);
                Retain = RetainLog;
            else;
                Retain = *off;
            endif;

            pNumericProc = Numeric;
            pStringProc = String;

            RC = 0;
            reset Last;

            monitor;
               open_fds();
               if isXssf(filename) = 1;
                  ParseSheetXssf_parse(Filename);
               else;
                  ParseSheet_parse(Filename);
               endif;
            on-error;
               RC = -1;
            endmon;

            if (Last.Row>=0 and pEndRowProc<>*NULL);
               EndRowProc(Last.Sheet: Last.Row);
            endif;

            return RC;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * hssf_callback_numeric_cell():  This is called back by Java
      *   for each numeric cell in a spreadsheet.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P callbackNumericCell...
     P                 B                   EXPORT
     D callbackNumericCell...
     D                 PI                  static
     D  Sheet                      1024A   const varying
     D  Row                          10I 0 value
     D  Col                           5I 0 value
     D  Value                         8F   value
      /free
          if (Last.Row<>Row or Last.Sheet<>Sheet);
              if (Last.Row>=0 and pEndRowProc<>*NULL);
                 EndRowProc(Last.Sheet: Last.Row);
              endif;
              if (pNewRowProc<>*NULL);
                 NewRowProc(Sheet: Row);
              endif;
              Last.Sheet = Sheet;
              Last.Row   = Row;
          endif;

          if (pNumericProc <> *NULL);
             if (NumericProc(Sheet: Row: Col: Value) = *On);
                escape(1: 'End Of Data');
             endif;
          elseif (pStringProc <> *NULL);
             if (StringProc(Sheet: Row: Col: %char(Value)) = *On);
                escape(1: 'End Of Data');
             endif;
          endif;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * hssf_callback_string_cell():  This is called back by Java
      *   for each string cell ("label") in a spreadsheet.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P callbackStringCell...
     P                 B                   EXPORT
     D callbackStringCell...
     D                 PI                  static
     D  Sheet                      1024A   const varying
     D  Row                          10I 0 value
     D  Col                           5I 0 value
     D  Value                     32767A   const varying

      /free
          if (Last.Row<>Row or Last.Sheet<>Sheet);
              if (Last.Row>=0 and pEndRowProc<>*NULL);
                 EndRowProc(Last.Sheet: Last.Row);
              endif;
              if (pNewRowProc<>*NULL);
                 NewRowProc(Sheet: Row);
              endif;
              Last.Sheet = Sheet;
              Last.Row   = Row;
          endif;

          if (pStringProc <> *NULL);
             if (StringProc(Sheet: Row: Col: Value) = *On);
                escape(1: 'End Of Data');
             endif;
          endif;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * hssf_callback_formula_cell():  This is called back by Java
      *   for each formula cell in a spreadsheet.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P callbackFormulaCell...
     P                 B                   EXPORT
     D callbackFormulaCell...
     D                 PI                  static
     D  Sheet                      1024A   const varying
     D  Row                          10I 0 value
     D  Col                           5I 0 value
     D  Value                         8F   value
     D  Nan                           5I 0 value
     D  Formula                   32767A   const varying
      /free
          if (Last.Row<>Row or Last.Sheet<>Sheet);
              if (Last.Row>=0 and pEndRowProc<>*NULL);
                 EndRowProc(Last.Sheet: Last.Row);
              endif;
              if (pNewRowProc<>*NULL);
                 NewRowProc(Sheet: Row);
              endif;
              Last.Sheet = Sheet;
              Last.Row   = Row;
          endif;

          if (pFormulaProc <> *NULL);
             if (FormulaProc(Sheet: Row: Col: Value: NaN: Formula) = *On);
                escape(1: 'End Of Data');
             endif;
          elseif (NaN=0 and pNumericProc <> *NULL);
             if (NumericProc(Sheet: Row: Col: Value) = *On);
                escape(1: 'End Of Data');
             endif;
          elseif (pStringProc <> *NULL);
             if (StringProc(Sheet: Row: Col: Formula) = *On);
                escape(1: 'End Of Data');
             endif;
          endif;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Escape():
      *   This sends back a fatal error message (an "escape" message)
      *   with MSGID CPF9897 to the specified level in the call stack,
      *   ending any higher level programs.
      *
      *   peStackCnt = (input) Specifies which program's msgq to send
      *       *ESCAPE message to by specifying a number of levels back...
      *   peMsgTxt   = (input) Text of message to send
      *
      * Returns *OFF if it failed.  If it succeeds, this routine
      *   does not return, since it's call level is ended.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Escape          B
     D Escape          PI             1N
     D   StackCnt                    10I 0 value
     D   MsgTxt                     256A   const

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                 1024A   options(*varsize)

     D dsEC            DS
     D  BytesProv                    10I 0 inz(0)
     D  BytesAvail                   10I 0 inz(0)

     D MsgLen          S             10I 0
     D MsgKey          S              4A

      /free

         MsgLen = %len(%trimr(MsgTxt));
         if (MsgLen < 1);
            return *off;
         endif;

         QMHSNDPM( 'CPF9897'
                 : 'QCPFMSG   *LIBL'
                 : MsgTxt
                 : MsgLen
                 : '*ESCAPE'
                 : '*'
                 : StackCnt
                 : MsgKey
                 : dsEC );

         return *off;

      /end-free
     P                 E


      *-----------------------------------------------------------------
      *  open_fds():  Make sure we have 3 FDs open before starting JVM
      *
      *  The JVM will encounter strange errors (I/O errors?) if
      *  there aren't at least 3 file descriptors open.  This code
      *  verifies that there are at least 3.
      *-----------------------------------------------------------------
     P open_fds        B
     D open_fds        PI

     D started         s              1n   inz(*off) static

     D SndPgmMsg       PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                     80A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                32767A   options(*varsize)

     D my_open         PR            10I 0 ExtProc('open')
     D  path                           *   value options(*string)
     D  openflags                    10I 0 value
     D  mode                         10U 0 value options(*nopass)
     D my_unlink       PR            10I 0 ExtProc('unlink')
     D   path                          *   Value options(*string)
     D my_dup          PR            10I 0 ExtProc('dup')
     D   fildes                      10I 0 Value

     D my_Mode         C                   const(438)
     D my_tmpnam       PR              *   extproc('_C_IFS_tmpnam')
     D   string                      39A   options(*omit)
     D my_close        PR            10I 0 ExtProc('close')
     D  fildes                       10I 0 value
     D O_RDWR          C                   4
     D O_CREAT         C                   8

     D ErrorNull       ds
     D   BytesProv                   10I 0 inz(0)
     D   BytesAvail                  10I 0 inz(0)

     D fd              s             10I 0
     D filename        s               *
     D key             s              4A

      /free
         if (started);
           return;
         endif;

         fd = my_open('/dev/null': O_RDWR);
         if (fd = -1);
             filename = my_tmpnam(*omit);
             fd = my_open(filename: O_RDWR+O_CREAT: my_Mode);
             my_unlink(filename);
         endif;

         if (fd > 2);
            my_close(fd);
         endif;

         dow ( fd < 2 );
            if (fd = -1);
                SndPgmMsg( 'CPF9897'
                         : 'QCPFMSG   *LIBL'
                         : 'Unable to open three descriptors!'
                         : 80
                         : '*ESCAPE'
                         : '*PGMBDY'
                         : 1
                         : Key
                         : ErrorNull );
                return;
            endif;
            fd = my_dup(fd);
         enddo;
      /end-free
     P                 E


     P isXssf          B
     D isXssf          PI            10i 0
     D   pathName                  1024a   const varying

     D my_open         PR            10I 0 ExtProc('open')
     D  path                           *   value options(*string)
     D  openflags                    10I 0 value
     D  mode                         10U 0 value options(*nopass)
     D my_read         PR            10I 0 ExtProc('read')
     D  fildes                       10i 0 value
     D  buf                            *   value
     D  bytes                        10U 0 value
     D my_close        PR            10I 0 ExtProc('close')
     D  fildes                       10I 0 value
     D O_RDONLY        C                   1

     D fd              s             10i 0
     D len             s             10i 0
     D data            s              8a

      /free
         // can't open file.  Never a good sign.
         fd = my_open(%trimr(pathName): O_RDONLY);
         if (fd = -1);
            return -1;
         endif;

         len = my_read(fd: %addr(data): %size(data));
         my_close(fd);

         // file isn't even 8 bytes long.  Can't be
         // a valid Xssf file, then.
         if (len < %size(data));
            return 0;
         endif;

         if data = x'D0CF11E0A1B11AE1';
            return 0;
         else;
            return 1;
         endif;
      /end-free
     P                 E
