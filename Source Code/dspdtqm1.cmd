 /*===============================================================*/
 /* TO COMPILE:                                                   */
 /*                                                               */
 /*   CRTCMD CMD(APLLIB/DSPDTAQ)                                  */
 /*          PGM(APLLIB/DSPDTQD1)                                 */
 /*          SRCFILE(APLLIB/QSRC)                                 */
 /*          SRCMBR(DSPDTQM1)                                     */
 /*          REPLACE(*YES)                                        */
 /*                                                               */
 /*===============================================================*/
 DSPDTAQ:    CMD        PROMPT('Display Data Queue')
             PARM       KWD(DTAQ) TYPE(QUAL) MIN(1) PROMPT('Data +
                          Queue')
 QUAL:       QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB)) EXPR(*YES) PROMPT('Library')
