 /* CRTCMD WRKFLE           +
           PGM(WRKFLED1     +
           REPLACE(*YES)    */
             CMD        PROMPT('Work with All PF''s')

             PARM       KWD(SEARCH) TYPE(*CHAR) LEN(30) +
                          PROMPT('Search, File/Desc/...')
