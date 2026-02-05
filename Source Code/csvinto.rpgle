**free

// Copyright (c) 2018 Scott C. Klement                                         +
// All rights reserved.                                                        +
//                                                                             +
// Redistribution and use in source and binary forms, with or without          +
// modification, are permitted provided that the following conditions          +
// are met:                                                                    +
// 1. Redistributions of source code must retain the above copyright           +
//    notice, this list of conditions and the following disclaimer.            +
// 2. Redistributions in binary form must reproduce the above copyright        +
//    notice, this list of conditions and the following disclaimer in the      +
//    documentation and/or other materials provided with the distribution.     +
//                                                                             +
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND      +
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
// SUCH DAMAGE.                                                                +


// CSVINTO:  This is a DATA-INTO "parser" program for use
//           with the CSVR4 program.
//
//           Requires V7R2 (or newer) with DATA-INTO PTFs!
//
//           to compile:
//              -- make sure PRSCSVV1 and its bnddir have been built
//              -- make sure CSVR4, bnddir and source code are in *LIBL
//        *> CRTBNDRPG PGM(CSVINTO) SRCFILE(QSRC) DBGVIEW(*LIST)   <*
//
//           call this via RPG's DATA-INTO opcode:
//
//           data-into YourDS %DATA('/path/to':'doc=file')
//                            %PARSER('CSVINTO');
//

ctl-opt OPTION(*SRCSTMT:*NODEBUGIO: *NOSHOWCPY)
        BNDDIR('APLLIB/APLLIB') main(CSVINTO);

/copy QOAR/QRPGLESRC,QRNDTAINTO
/copy APLLIB/QSRC,PRSCSVV1PR // Prototypes for the PRSCSVV1 service program

dcl-proc CSVINTO;

   dcl-pi *n;
     parm likeds(QrnDiParm_t);
   end-pi;

   dcl-s h pointer inz(*null);
   dcl-s fldno int(10);
   dcl-s name varchar(20);
   dcl-s val  varucs2(65502) ccsid(1200);
   dcl-s bytes   int(10);
   dcl-s errorNo int(10);
   dcl-s row     int(10);

   pQrnDiEnv = parm.env;

   QrnDiStart(parm.handle);

   QrnDiTrace( parm.handle
             : 'Now opening CSV data from buffer'
             : *OFF );
   monitor;
      h = CSV_openBuf( parm.data: parm.dataLen: parm.dataCCSID
                     : *omit: *omit: *omit: *on );
   on-error;
      h = *null;
   endmon;

   if h = *null;
      QrnDiTrace( parm.handle
                : 'Error opening CSV from buffer! (See job log)'
                : *OFF );
      errorNo = 1001;
      bytes   = 0;
      QrnDiReportError( parm.handle: errorNo: bytes);
      // DATA-INTO does not return control from QdiReportError!
   endif;

   QrnDiStartArray( parm.handle );
   row = 0;

   dow CSV_loadRec( h ) = *ON;

      exsr load_fields;

   enddo;

   CSV_close(h);
   h = *null;

   QrnDiEndArray(parm.handle);
   QrnDiFinish(parm.handle);

   return;

   begsr load_fields;
      QrnDiStartStruct(parm.handle);
      row += 1;

      QrnDiTrace( parm.handle
                : 'Processing row ' + %char(row)
                : *ON );

      fldno = 0;
      dow CSV_getFldUni(h: val: %size(val)) = *on;
         fldno += 1;
         name = 'field' + %char(fldno);
         QrnDiReportNameCCSID( parm.handle: %addr(name: *data): %len(name): 0);
         QrnDiReportValueCCSID( parm.handle: %addr(val: *data): %len(val)*2: 1200);
      enddo;

      QrnDiEndStruct(parm.handle);
   endsr;

// IMPORTANT:
//
//   any QrnDixxxxx routine can stop processing and not return
//   control to the parser!  We must use on-exit (or similar) to
//   clean up anything that might've been left open.
//
on-exit;

   if h <> *null;
      CSV_close(h);
   endif;

end-proc;
