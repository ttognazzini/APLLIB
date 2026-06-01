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
      /if defined(XLPARSE_H)
      /eof
      /endif
      /define XLPARSE_H

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
      *
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
     D xlparse_workbook...
     D                 PR            10I 0
     D    Filename                 1024A   const varying
     D    Numeric                      *   procptr value
     D    String                       *   procptr value
     D    Formula                      *   procptr value options(*nopass)
     D    RetainLog                    N   const options(*nopass:*omit)


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
     D xlparse_notify...
     D                 PR
     D   startRow                      *   value procptr
     D   endRow                        *   value procptr
