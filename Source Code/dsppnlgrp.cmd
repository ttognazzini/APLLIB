             CMD        PROMPT('Display Panel Group')
             PARM       KWD(HELP) TYPE(E1) MIN(1) MAX(25) PROMPT('Help Identifiers')
 E1:         ELEM       TYPE(Q1) MIN(1) PROMPT('Pannel group')
             ELEM       TYPE(*CHAR) LEN(32) MIN(1) PROMPT('Help Module')
 Q1:         QUAL       TYPE(*NAME) MIN(1)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL)) PROMPT('Library')

             PARM       KWD(RANGE) TYPE(E2) PROMPT('Help to Display')
 E2:         ELEM       TYPE(*INT4) DFT(*FIRST) REL(*GT 0) SPCVAL((*FIRST 1)) PROMPT('First help')
             ELEM       TYPE(*INT4) DFT(*LAST) REL(*GT 0) SPCVAL((*LAST 0)) PROMPT('Last Help')

             PARM       KWD(TITRE) TYPE(*CHAR) LEN(55) DFT(*BLANK) SPCVAL((*BLANK ' ')) PROMPT('Title to Display')

             PARM       KWD(SCHIDX) TYPE(Q2) PROMPT('Search Index')
 Q2:         QUAL       TYPE(*NAME) DFT(*NONE)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL)) PROMPT('Library')
             PARM       KWD(PLEINECRAN) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(*NO) SPCVAL((*YES Y) (*NO N)) +
                          PROMPT('Full Screen Display')

             PARM       KWD(CURSEUR) TYPE(E3) PROMPT('Cursor position before help')
 E3:         ELEM       TYPE(*INT4) DFT(1) RANGE(1 24) PROMPT('N° Line')
             ELEM       TYPE(*INT4) DFT(1) RANGE(1 80) PROMPT('N° Column')

             PARM       KWD(FENETRE) TYPE(E4) PMTCTL(CTL1) PROMPT('Window')
 E4:         ELEM       TYPE(*INT4) DFT(01) RANGE(1 24) PROMPT('Top Left Corner Row')
             ELEM       TYPE(*INT4) DFT(01) RANGE(1 80) PROMPT('Top Left Corner Column')
             ELEM       TYPE(*INT4) DFT(02) RANGE(1 24) PROMPT('Bottom Right Corner Row')
             ELEM       TYPE(*INT4) DFT(80) RANGE(1 80) PROMPT('Bottom Right Corner Column')
 CTL1:       PMTCTL     CTL(PLEINECRAN) COND((*EQ 'N'))
