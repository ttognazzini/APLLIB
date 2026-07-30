     H OPTION(*SrcStmt) DFTACTGRP(*NO)

      * TRT THIS PROGRAM WAS LIFTED FROM: https://github.com/starbuck5250/SEUEXIT
      * I LEFT MOST OF THE AUTHORS COMMENTS INTACT AND ADD SOME OF MY OWN. I ALSO
      * ADDED THE COMMAND UC,LC,UCC AND LCC FOR CASE CONVERSION SINGLE LINE AND
      * BLOCKED.

      * Buck Calabro April 2000
      * large portions lifted from the seu user's guide and reference sc09-2605-00
      * to activate, strseu, press f13, page down and fill in the name of this program
      * seu puts data in qtemp/qsuspc

      * SEU puts data in QTEMP/QSUSPC
      * this space has 3 data blocks:
      *   1. Input from SEU
      *   2. Output back to SEU
      *   3. Actual source lines

      * Supports the following line commands:
      * ATxx - set line attribute (colour, hilight, etc.)
      *    For comment lines it will the attribute right after the first '*'
      *    For others it will put in the 5th position .
      * UC - CONVERT ENTIRE LINE TO UPPER CASE
      * LC - CONVERT ENTIRE LINE TO LOWER CASE
      * UCC - BLOCK CONVERT LINES TO UPPER CASE
      * LCC - BLOCK CONVERT LINES TO LOWER CASE
      * CM - TURN LINE INTO A COMMENT
      * CMM - BLOCK TURN LINES INTO COMMENTS
      * UCM - REMOVE COMMENT (*)
      * UCMM - BLOCK REMOVE COMMENT (*)

      * Supports the following F keys:
      * F7 - Split/join a line (Splits this line to next if cursor in the middle of a line,
      *                         joins next line to this if cursor at the end of a line)

      * Uses messages in a user-created message file:
      *   Message ID  Severity  Message Text
      *    SEU0001        0     Cursor is not positioned within a source statement.
      *    SEU0002        0     Line split complete.
      *    SEU0003        0     Line join complete.
      *    SEU0004        0     Cannot update in Browse mode
      *    SEU0005        0     AT command processed
      *    SEU0006        0     AT command not valid for this member type
      *    SEU0007        0     &1
      *    SEU0008        0     Case changed.
      *    SEU0009        0     New line added

      * USE THESE COMMANDS TO BUILD THE MESSAGE FILE MENTIONED ABOVE
      *
      * CRTMSGF MSGF(APLLIB/SEUEXIT) TEXT('SEU Exit program messages') CCSID(*MSGD)
      * ADDMSGD SEU0001 MSGF(APLLIB/SEUEXIT) MSG('Cursor is not positioned within a source statement.')
      * ADDMSGD SEU0002 MSGF(APLLIB/SEUEXIT) MSG('Line split complete.')
      * ADDMSGD SEU0003 MSGF(APLLIB/SEUEXIT) MSG('Line join complete.')
      * ADDMSGD SEU0004 MSGF(APLLIB/SEUEXIT) MSG('Cannot update in Browse mode.')
      * ADDMSGD SEU0005 MSGF(APLLIB/SEUEXIT) MSG('AT command processed.')
      * ADDMSGD SEU0006 MSGF(APLLIB/SEUEXIT) MSG('AT command not valid for this member type.')
      * ADDMSGD SEU0007 MSGF(APLLIB/SEUEXIT) MSG('&1') FMT((*CHAR 80))
      * ADDMSGD SEU0008 MSGF(APLLIB/SEUEXIT) MSG('Case changed.')
      * ADDMSGD SEU0009 MSGF(APLLIB/SEUEXIT) MSG('New line added.')

      * Input from SEU
     D SEUInput        DS                  BASED(SEUInputP)
     D  StmtLength                   10i 0
     D  CurRec                       10i 0
     D  CurCol                       10i 0
     D  CCSID                        10i 0
     D  InputRecords                 10i 0
     D  SrcMbr                       10
     D  SrcFil                       10
     D  SrcLib                       10
     D  MbrType                      10
     D  FnKey                         1
     D  SEUMode                       1
     D  SplitSession                  1
     D  ReservedInp                   1
     D  BIGFILLER                  1000

      * Output to SEU
     D SEUOutput       DS                  BASED(SEUOutputP)
     D  ReturnCode                    1
     D  ReservedOut1                  3
     D  OutputRecords                10i 0
     D  InsertedSeq                   7
     D  ReservedOut2                 21

      * Source statements.  SEU passes the line the cursor is on,
      *                     and the next line
     D SEUSource       DS                  BASED(SEUSourceP)
     D  LineCmd                       7
     D  LineRetCode                   1
     D  SourceSeq                     6
     D  SourceDate                    6
     D  SourceStmt                  256

      * Work variables
     D SEUInputPParm   s               *
     D SEUOutputPParm  s               *
     D SEUSourcePParm  s               *
     D ThisLineP       s               *
     D NextLineP       s               *
     D WorkLineP       s               *

     D i               s             10i 0 inz
     D CutColumns      s                   like(SourceStmt)
     D ThisLineCmd     s                   like(LineCmd)
     D ThisStmt        s                   like(SourceStmt)
     D NextStmt        s                   like(SourceStmt)
     D SourceLength    s             10i 0
     D CutLen          s             10i 0
     D BlankLineCmd    s                   like(LineCmd)
     D RtnCode         s              7

      * Lowercase and uppercase strings
     D lo              c                   const('abcdefghijklmnopqrstuvwxyz')
     D up              c                   const('ABCDEFGHIJKLMNOPQRSTUVWXYZ')

     DSndMsg           pr
     D MsgID                          7    const
     D RtnCodeOut                          Like(RtnCode)
     D MsgDta                        80    options(*nopass) const

     DLoadWorkFromInp  pr
     D SrcDtaPtrInp                    *   const
     D LineCmdOut                          like(LineCmd)     Options(*Omit)
     D LineRetCodeOut                      like(LineRetCode) Options(*Omit)
     D SourceSeqOut                        like(SourceSeq)   Options(*Omit)
     D SourceDateOut                       like(SourceDate)  Options(*Omit)
     D SourceStmtOut                       like(SourceStmt)  Options(*Omit)

     DLoadOutFromWork  pr
     D SrcDtaPtrInp                    *                     const
     D LineCmdInp                          like(LineCmd)     Options(*Omit)
     D LineRetCodeInp                      like(LineRetCode) Options(*Omit)
     D SourceSeqInp                        like(SourceSeq)   Options(*Omit)
     D SourceDateInp                       like(SourceDate)  Options(*Omit)
     D SourceStmtInp                       like(SourceStmt)  Options(*Omit)

     DGetAttrFromCmd   pr             1
     D LineCmdInp                          like(LineCmd) const

     C*================================================================
     C     *Entry        Plist
     C                   Parm                    SEUInputPParm
     C                   Parm                    SEUOutputPParm
     C                   Parm                    SEUSourcePParm
     C
     C* Get the data referred to by the input pointers
     C                   Eval      SEUInputP    = SEUInputPParm
     C                   Eval      SourceLength = %len(SEUSource) -
     C                                            %len(SourceStmt) +
     C                                            StmtLength
     C                   Eval      SEUOutputP   = SEUOutputPParm
     C                   Eval      ThisLineP    = SEUSourcePParm
     C                   Eval      NextLineP    = SEUSourcePParm + SourceLength
     C
     C* Set default values
     C                   Eval      ReturnCode = '0'
     C                   Eval      OutputRecords = InputRecords - 1
     C                   Eval      InsertedSeq = '0000000'
     C
     C* Allow updates only if in Update mode
     C                   If        SeuMode = 'U'
     C                   Exsr      LineCommands
     C                   Exsr      CmdKeys
     C                   Else
     C                   Eval      ReturnCode = '1'
     C* Send back "Not in update mode" message
     C*#*                   CallP     SndMsg('SEU0004': RtnCode)
     C                   CallP     SndMsg('SEU0007': RtnCode: 'In browse!')
     C                   EndIf
     C
     C                   Eval      *InLR = *On
     C                   Return
     C
     C*================================================================
     C* Process all the line commands (commands typed in the seq number area)
     C* InputRecords includes the "next" line.
     C* For example, if a line command is placed on lines 1 and 5, InputRecords will be 6
     C
     C     LineCommands  Begsr
     C
     C                   Eval      WorkLineP = ThisLineP
     C                   Eval      i = 1
     C                   MOVE      *BLANKS       HLDCMD            4
     C
     C                   DoW       i <= (InputRecords - 1)
     C                   Callp     LoadWorkFromInp(WorkLineP:
     C                                             ThisLineCmd:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
     C* testing
     C                   IF        %subst(ThisLineCmd: 1: 5)  = 'IHEAD'
     C*
     C* Blank out the line command
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             BlankLineCmd:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit)
     C*                  EVAL      %SUBST(THISSTMT: 6) = 'C* HELLO WORLD'
     C* Put the work fields back into the source space
     C*                  Callp     LoadOutFromWork(ThisLineP:
     C*                                            *Omit:
     C*                                            *Omit:
     C*                                            *Omit:
     C*                                            *Omit:
     C*                                            ThisStmt)
     C                   EVAL      %SUBST(NEXTSTMT: 6) =
     C                             'H DATEDIT(*YMD) OPTION(*NODEBUGIO)'
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)
     C                   Eval      NextLineP = SEUSourcePParm + (2*SourceLength)
     C                   EVAL      %SUBST(NEXTSTMT: 6) =
     C                             'F*'
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)
     C                   Eval      NextLineP = SEUSourcePParm + (3*SourceLength)
     C                   EVAL      %SUBST(NEXTSTMT: 6) =
     C                             'F* INSERT MEANINGFUL PROGRAM DESCRIPTION'
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)
     C                   Eval      NextLineP = SEUSourcePParm + (4*SourceLength)
     C                   EVAL      %SUBST(NEXTSTMT: 6) =
     C                             'F*'
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)
     C* Tell SEU that we're returning 2 lines
     C                   Eval      OutputRecords = 5
     C* Send back a message to show that we saw and processed the line cmd
     C                   CallP     SndMsg('SEU0009': RtnCode)
     C                   ENDIF
     C* Line command to set the attribute of the line
     C                   IF        %subst(ThisLineCmd: 1: 2)  = 'AT'
     C* Blank out the line command
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             BlankLineCmd:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit)
     C* Highlight the line by forcing an attribute byte in the proper column
     C* based on the source member type
     C                   If        MbrType = 'RPG'      or
     C                             MbrType = 'RPGLE'    or
     C                             MbrType = 'SQLRPG'   or
     C                             MbrType = 'SQLRPGLE' or
     C                             MbrType = 'PF'       or
     C                             MbrType = 'PRTF'     or
     C                             MbrType = 'DSPF'
     C                   IF        %SUBST(THISSTMT:7:1)= '*'                    A COMMENT LINE
     C                   IF        %SUBST(THISSTMT:8:1)> ' '                    MOVE COMMENT OVER
     C                   EVAL      THISSTMT = %SUBST(THISSTMT:1:7) +
     C                             ' ' +      %SUBST(THISSTMT:8)
     C                   ENDIF
     C                   Eval      %subst(ThisStmt: 8: 1) =
     C                               GetAttrFromCmd(ThisLineCmd)
     C                   ELSE
     C                   Eval      %subst(ThisStmt: 5: 1) =
     C                               GetAttrFromCmd(ThisLineCmd)
     C                   ENDIF
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(ThisLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
     C* Send back a message to show that we saw and processed the line cmd
     C                   CallP     SndMsg('SEU0005': RtnCode)
     C                   Else
     C* Send back a message to show that we saw and ignored the line cmd
     C                   CallP     SndMsg('SEU0006': RtnCode)
     C                   EndIf
     C                   EndIf
     C
     C* SAVING THE HOLD COMMAND IF A MULTI-LINE COMMAND IS OPPENED.
     C                   MOVE      *BLANKS       LAST              1
     C                   IF        (%scan('UCC':ThisLineCmd)<>0 AND
     C                             HLDCMD='UCC') OR
     C                             (%scan('LCC':ThisLineCmd)<>0 AND
     C                             HLDCMD='LCC') OR
     C                             (%scan('CMM':ThisLineCmd)<>0 AND
     C                             HLDCMD='CMM') OR
     C                             (%scan('UCMM':ThisLineCmd)<>0 AND
     C                             HLDCMD='UCMM')
     C                   EVAL      LAST='Y'
     C                   EndIf
     C                   IF        %scan('UCC':ThisLineCmd)<>0 AND
     C                             HLDCMD='   '
     C                   EVAL      HLDCMD='UCC'
     C                   EndIf
     C                   IF        %scan('LCC':ThisLineCmd)<>0 AND
     C                             HLDCMD='   '
     C                   EVAL      HLDCMD='LCC'
     C                   EndIf
     C                   IF        %scan('UCMM':ThisLineCmd)<>0 AND
     C                             HLDCMD='   '
     C                   EVAL      HLDCMD='UCMM'
     C                   ELSE
     C                   IF        %scan('CMM':ThisLineCmd)<>0 AND
     C                             HLDCMD='   '
     C                   EVAL      HLDCMD='CMM'
     C                   EndIf
     C                   EndIf
     C
     C* Line command to convert the line to upper case
     C                   IF        (%scan('UC':ThisLineCmd)<> 0 AND
     C                             %scan('UCM':ThisLineCmd)=  0) OR
     C                             HLDCMD='UCC'
     C* Blank out the line command
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             BlankLineCmd:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit)
     C* convert all characters to upper case
     c                   eval      %SUBST(ThisStmt:1:StmtLength) =
     c                             %xlate(lo:up:%SUBST(ThisStmt:1:StmtLength))
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
     C* Send back a message to show that we saw and processed the line cmd
     C                   CallP     SndMsg('SEU0008': RtnCode)
     C                   EndIf
     C*
     C* Line command to convert the line to lower case
     C                   IF        %scan('LC':ThisLineCmd)<>0 OR
     C                             HLDCMD='LCC'
     C* Blank out the line command
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             BlankLineCmd:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit)
     C* convert all characters to upper case
     C                   eval      %SUBST(ThisStmt:1:StmtLength) =
     C                             %xlate(up:lo:%SUBST(ThisStmt:1:StmtLength))
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
     C* Send back a message to show that we saw and processed the line cmd
     C                   CallP     SndMsg('SEU0008': RtnCode)
     C                   EndIf
     C
     C* Line command to turn line into a comment
     C                   IF        (%scan('CM':ThisLineCmd)<> 0 AND
     C                             %scan('UCM':ThisLineCmd)=  0) OR
     C                             HLDCMD='CMM'
     C* Blank out the line command
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             BlankLineCmd:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit)
     C* Add asterisk to line.
     C                   EVAL      %SUBST(THISSTMT:7:1)= '*'                    A COMMENT LINE
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
     C* Send back a message to show that we saw and processed the line cmd
     C                   CallP     SndMsg('SEU0008': RtnCode)
     C                   EndIf
     C* Line command to remove comment (*)
     C                   IF        %scan('UCM':ThisLineCmd)<>0  OR
     C                             HLDCMD='UCMM'
     C* Blank out the line command
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             BlankLineCmd:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit)
     C* Remove asterisk from line.
     C                   EVAL      %SUBST(THISSTMT:7:1)= ' '                    A COMMENT LINE
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(WorkLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
     C* Send back a message to show that we saw and processed the line cmd
     C                   CallP     SndMsg('SEU0008': RtnCode)
     C                   EndIf
     C*
     C* CLEAR OUT THE HOLD COMMAND IF A MULTI-LINE COMMAND IS CLOSED.
     C                   IF        LAST='Y'
     C                   EVAL      HLDCMD='   '
     C                   EndIf
     C*
     C                   Eval      i = i + 1
     C                   Eval      WorkLineP = WorkLineP + SourceLength
     C                   EndDO
     C*
     C                   EndSR
     C
     C*================================================================
     C* Process the command keys (F7/F8)
     C
     C     CmdKeys       Begsr
     C
     C                   Select
     C
     C* Is the cursor outside of the source statement with an F key press?
     C                   When      (FnKey = '7'  or
     C                              FnKey = '8') and
     C                             CurCol = 0
     C
     C* Tell SEU that the cursor is outside the source area
     C                   CallP     SndMsg('SEU0001': RtnCode)
     C
     C* F7 = split/join
     C                   When      FnKey = '7'
     C
     C* Should we do a split or a join?
     C* Get the line the cursor is on
     C                   Callp     LoadWorkFromInp(ThisLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
     C* Get the next line
     C                   Callp     LoadWorkFromInp(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)
     C
     C* If there is data beyond the current column, split it
     C* If the rest of the line is blank, join the next line to this one
     C                   If        %subst(ThisStmt: CurCol:
     C                                    StmtLength - CurCol - 1) <>
     C                                      *Blanks
     C                   Exsr      SplitLine
     C                   Else
     C                   Exsr      JoinLine
     C                   EndIf
     C
     C                   EndSL
     C
     C                   EndSR
     C
     C*================================================================
     C* Split line at blank
     C
     C     SplitLine     Begsr
     C
     C* Cut the columns to the right including the column the cursor is in
     C                   Eval      CutColumns = %subst(ThisStmt:
     C                                                 CurCol)
     C
     C* Drop the rightmost columns into the next line
     C                   If        (MbrType = 'RPG'      or
     C                              MbrType = 'RPGLE'    or
     C                              MbrType = 'SQLRPG'   or
     C                              MbrType = 'SQLRPGLE') AND
     C                             %SUBST(CUTCOLUMNS:1:8)<>' '
     C                   Eval      NextStmt = '        ' + CutColumns
     C                   ELSE
     C                   Eval      NextStmt = CutColumns
     C                   ENDIF
     C
     C* Trim the cut columns off the right side of this line
     C                   If        CurCol > 1
     C                   Eval      ThisStmt = %subst(ThisStmt:
     C                                               1:
     C                                               CurCol - 1)
     C                   Else
     C                   Eval      ThisStmt = *Blanks
     C                   EndIf
     C
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(ThisLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
     C
     C                   Callp     LoadOutFromWork(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)
     C
     C* Tell SEU that we're returning 2 lines
     C                   Eval      OutputRecords = 2
     C
     C* Tell SEU that the split is complete
     C                   CallP     SndMsg('SEU0002': RtnCode)
     C                   EndSR
     C
     C*================================================================
     C* Join line
     C
     C     JoinLine      Begsr
     C
     C* Don't try to join if the next line is a blank
     C                   If        NextStmt <> *Blanks
     C
     C* Grab the leftmost columns from the next line (as many columns
     C* as are blank at the end of this line)
     C                   Eval      CutColumns = %subst(NextStmt:
     C                                                 1:
     C                                                 (StmtLength -
     C                                                  CurCol +
     C                                                  1               ))
     C
     C* Add the columns from the next line onto the end of this line
     C     ' '           Checkr    CutColumns    CutLen
     C                   Eval      ThisStmt = %subst(ThisStmt:
     C                                               1:
     C                                               CurCol - 1)       +
     C                                         %TRIML(%subst(CutColumns:
     C                                                1:
     C                                                CutLen))
     C
     C* Blank out the cut columns
     C                   Eval      %subst(NextStmt: 1: CutLen) = *Blanks
     C
     C* If we've cut the entire next line, delete it.  Otherwise,
     C* simply cut the columns out - don't shift the remainder of the line
     C                   If        NextStmt = *Blanks
     C                   Eval      OutputRecords = 1
     C                   Eval      InsertedSeq = 'A000000'
     C                   Else
     C                   Eval      OutputRecords = 2
     C                   Eval      InsertedSeq = 'A000000'
     C                   EndIf
     C
     C* Put the work fields back into the source space
     C                   Callp     LoadOutFromWork(ThisLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             ThisStmt)
     C
     C                   Callp     LoadOutFromWork(NextLineP:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             *Omit:
     C                                             NextStmt)
     C
     C* Tell SEU that the join is complete
     C                   CallP     SndMsg('SEU0003': RtnCode)
     C                   EndIf
     C
     C                   EndSR

      *================================================================
      * Send a "status" message back to SEU
      * There's a trick in use here that you need to be aware of.
      * the message stack count is determined by how deep in the call stack the
      * subprocedure is!  Here's why it was set to 3:
      *     STRSEU      1
      *       SEUEXIT   2
      *         SndMsg  3

     PSndMsg           b
     DSndMsg           pi
     D MsgID                          7    const
     D RtnCodeOut                          Like(ErrSMsgID)
     D MsgDta                        80    options(*nopass) const

      * Send message API parameters
     D MsgIDWrk        s                   like(MsgID)
     D MsgFil          s             20    inz('SEUEXIT   *LIBL     ')
     D MsgData         s             80
     D MsgDataLen      s             10i 0
     D MsgType         s             10    inz('*DIAG')
     D MsgStackEnt     s             10    inz('*')
     D MsgStackCnt     s             10i 0 inz(3)
     D MsgKey          s              4
     D MsgErrStruc     s                   like(ErrStruc)

      * API error structure
     D ErrStruc        DS                  inz
     D  ErrSSize                     10i 0 inz(%len(ErrStruc))
     D  ErrSUse                      10i 0
     D  ErrSMsgID                     7
     D  ErrSResrv                     1
     D  ErrSData                     80

     C                   Eval      MsgIdWrk = MsgID
     C                   Eval      MsgErrStruc = ErrStruc
     C* was message data provided?
     C                   If        %parms >= 3
     C                   Eval      MsgData = msgDta
     C                   Eval      MsgDataLen = %len(%trimr(MsgData))
     C                   Else
     C                   Eval      MsgData = *blanks
     C                   Eval      MsgDataLen = 1
     C                   EndIf

     C                   Call      'QMHSNDPM'
     C                   Parm                    MsgIDWrk
     C                   Parm                    MsgFil
     C                   Parm                    MsgData
     C                   Parm                    MsgDataLen
     C                   Parm                    MsgType
     C                   Parm                    MsgStackEnt
     C                   Parm                    MsgStackCnt
     C                   Parm                    MsgKey
     C                   Parm                    MsgErrStruc
     C
     C                   Eval      ErrStruc = MsgErrStruc
     C                   Eval      RtnCodeOut = ErrSMsgID
     C
     PSndMsg           e

      *================================================================
      * Load the work fields from the data SEU sent us

     PLoadWorkFromInp  b
     DLoadWorkFromInp  pi
     D SrcDtaPtrInp                    *   const
     D LineCmdOut                          like(LineCmd)     Options(*Omit)
     D LineRetCodeOut                      like(LineRetCode) Options(*Omit)
     D SourceSeqOut                        like(SourceSeq)   Options(*Omit)
     D SourceDateOut                       like(SourceDate)  Options(*Omit)
     D SourceStmtOut                       like(SourceStmt)  Options(*Omit)

     C* Point to the data within the SEU space
     C                   Eval      SEUSourceP = SrcDtaPtrInp
     C
     C                   If        %addr(LineCmdOut) <> *Null
     C                   Eval            LineCmdOut  =  LineCmd
     C                   Endif
     C                   If        %addr(LineRetCodeOut) <> *Null
     C                   Eval            LineRetCodeOut  =  LineRetCode
     C                   Endif
     C                   If        %addr(SourceSeqOut) <> *Null
     C                   Eval            SourceSeqOut  =  SourceSeq
     C                   Endif
     C                   If        %addr(SourceDateOut) <> *Null
     C                   Eval            SourceDateOut  =  SourceDate
     C                   Endif
     C                   If        %addr(SourceStmtOut) <> *Null
     C                   Eval            SourceStmtOut  =  %subst(SourceStmt: 1:
     C                                                       StmtLength)
     C                   Endif
     C
     P                 e

      *================================================================
      * Load data back to SEU from the work fields

     PLoadOutFromWork  b
     DLoadOutFromWork  pi
     D SrcDtaPtrInp                    *                     const
     D LineCmdInp                          like(LineCmd)     Options(*Omit)
     D LineRetCodeInp                      like(LineRetCode) Options(*Omit)
     D SourceSeqInp                        like(SourceSeq)   Options(*Omit)
     D SourceDateInp                       like(SourceDate)  Options(*Omit)
     D SourceStmtInp                       like(SourceStmt)  Options(*Omit)

     C* Point to the data within the SEU space
     C                   Eval      SEUSourceP = SrcDtaPtrInp
     C
     C                   If        %addr(LineCmdInp) <> *Null
     C                   Eval            LineCmd     =  LineCmdInp
     C                   Endif
     C                   If        %addr(LineRetCodeInp) <> *Null
     C                   Eval            LineRetCode     =  LineRetCodeInp
     C                   Endif
     C                   If        %addr(SourceSeqInp) <> *Null
     C                   Eval            SourceSeq     =  SourceSeqInp
     C                   Endif
     C                   If        %addr(SourceDateInp) <> *Null
     C                   Eval            SourceDate     =  SourceDateInp
     C                   Endif
     C                   If        %addr(SourceStmtInp) <> *Null
     C                   Eval            %SUBST(SourceStmt:1:SOURCELENGTH-20) =
     C                                   SourceStmtInp
     C                   Endif
     C
     P                 e

      *================================================================
      * Extract an attribute byte from the input line command
      * The line command is formatted "ATxx" where XX is a mnemnonic for
      * the attribute byte to assign to the line.  The mnemnonics are the same
      * as used by DDS with the addition of colours.

     PGetAttrFromCmd   b
     DGetAttrFromCmd   pi             1
     D LineCmdInp                          like(LineCmd) const

     D AttributeByte   s              1
     D AttrTest        s              2
     D i               s             10i 0

     DAttrMnemDS       ds
     D                                2    inz('  ')
     D                                2    inz('RI')
     D                                2    inz('HI')
     D                                2    inz('UL')
     D                                2    inz('BL')
     D                                2    inz('CS')
     D                                2    inz('CP')
     D                                2    inz('CL')
     D                                2    inz('GN')
     D                                2    inz('WN')
     D                                2    inz('RN')
     D                                2    inz('TN')
     D                                2    inz('PN')
     D                                2    inz('BN')
     D                                2    inz('YN')
     D                                2    inz('GU')
     D                                2    inz('WU')
     D                                2    inz('RU')
     D                                2    inz('TU')
     D                                2    inz('PU')
     D                                2    inz('BU')
     D                                2    inz('YU')
     D                                2    inz('GR')
     D                                2    inz('WR')
     D                                2    inz('RR')
     D                                2    inz('TR')
     D                                2    inz('PR')
     D                                2    inz('BR')
     D                                2    inz('YR')
     D AttrMnem                       2    dim(29) overlay(AttrMnemDS)

     DAttrDS           ds
     D                                1    inz(x'20')
     D                                1    inz(x'21')
     D                                1    inz(x'22')
     D                                1    inz(x'24')
     D                                1    inz(x'2A')
     D                                1    inz(x'30')
     D                                1    inz(x'38')
     D                                1    inz(x'3A')
     D                                1    inz(x'20')
     D                                1    inz(x'22')
     D                                1    inz(x'28')
     D                                1    inz(x'30')
     D                                1    inz(x'38')
     D                                1    inz(x'3A')
     D                                1    inz(x'32')
     D                                1    inz(x'24')
     D                                1    inz(x'26')
     D                                1    inz(x'2C')
     D                                1    inz(x'34')
     D                                1    inz(x'3C')
     D                                1    inz(x'3E')
     D                                1    inz(x'36')
     D                                1    inz(x'21')
     D                                1    inz(x'23')
     D                                1    inz(x'29')
     D                                1    inz(x'31')
     D                                1    inz(x'39')
     D                                1    inz(x'3B')
     D                                1    inz(x'33')
     D Attr                           1    dim(29) overlay(AttrDS)

     C* Default to normal
     C                   Eval      AttributeByte = Attr(1)
     C
     C* Extract the mnemnonic from the line command
     C                   Eval      AttrTest = %subst(ThisLineCmd: 3: 2)
     C
     C* Convert the mnemnonic to an attribute byte
     C                   Eval      i = 1
     C     AttrTest      Lookup    AttrMnem(i)                            20
     C                   If        *In20 = *On
     C                   Eval      AttributeByte = Attr(i)
     C                   EndIf
     C
     C                   Return    AttributeByte
     P                 e

