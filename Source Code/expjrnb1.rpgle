      *=====================================================================*
      *                                                                     *
      *  Application . : EXPJRNE                                            *
      *  Object  . . . : EXPJRNER1                                          *
      *  Description . : Export Journal Entries - POP                       *
      *  Author  . . . : Thomas Raddatz   <thomas.raddatz§tools400.de>      *
      *  Date  . . . . : 19.09.2008                                         *
      *                                                                     *
      *=====================================================================*
      *                                                                     *
      *  This software is free software, you can redistribute it and/or     *
      *  modify it under the terms of the GNU General Public License (GPL)  *
      *  as published by the Free Software Foundation.                      *
      *                                                                     *
      *  See GNU General Public License for details.                        *
      *          http://www.opensource.org                                  *
      *          http://www.opensource.org/licenses/gpl-license.html        *
      *                                                                     *
      *=====================================================================*
      *  History:                                                           *
      *                                                                     *
      *  Date        Name          Comment                                  *
      *  ----------  ------------  ---------------------------------------  *
      *  20.09.2008  Th.Raddatz    Redesigned EXPJRNE to support additional *
      *                            object types, starting with *DTAARA.     *
      *                                                                     *
      *=====================================================================*
      * >>PRE-COMPILER<<                                                    *
      *   >>CRTCMD<< CRTRPGMOD    MODULE(&LI/&OB) +                         *
      *                           SRCFILE(&SL/&SF) +                        *
      *                           SRCMBR(&SM);                              *
      *   >>IMPORTANT<<                                                     *
      *     >>PARM<< TRUNCNBR(*NO);                                         *
      *     >>PARM<< DBGVIEW(*LIST);                                        *
      *     >>PARM<< TGTRLS(V6R1M0);                                        *
      *   >>END-IMPORTANT<<                                                 *
      *   >>EXECUTE<<                                                       *
      * >>END-PRE-COMPILER<<                                                *
      *=====================================================================*
       Ctl-Opt option(*SRCSTMT : *NODEBUGIO) dftActGrp(*no);
      *=====================================================================*
      *
     D PGM_ENTRY_POINT...
     D                 PR                  extpgm('EXPJRNER1')
     D  gi_cmd                       20A   const
     D  go_string                 32767A          varying
      *
      *  Main procedure
     D main...
     D                 PR
     D  i_cmd                              const like(gi_cmd      )
     D  o_string                                 like(go_string   )
      *
      *==================================================================*
      *  Program entry point
      *==================================================================*
      *
     D PGM_ENTRY_POINT...
     D                 PI
     D  gi_cmd                       20A   const
     D  go_string                 32767A          varying
      *-------------------------------------------------------------------
      /FREE

         main(gi_cmd: go_string);

         *inlr = *on;

      /END-FREE
      *
      *==================================================================*
      *  Main procedure
      *==================================================================*
      *
     P main...
     P                 B
     D                 PI
     D  i_cmd                              const like(gi_cmd      )
     D  o_string                                 like(go_string   )
      *
     D today           S               D   inz
      *-------------------------------------------------------------------
      /FREE

         today = %date();

         o_string = '??FROMDATE(' + %char(today: *JOBRUN0) + ') ' +
                    '??TODATE(' + %char(today: *JOBRUN0) + ') ' +
                    '??FROMTIME(000000) ' +
                    '??TOTIME(235959)';

      /END-FREE
     P                 E
      *
