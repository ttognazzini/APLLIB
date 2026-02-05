/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Compile options:                                                 */
/*                                                                   */
/*    CRTCMD CMD(APLLIB/CHGDTAQ)                                     */
/*           PGM(APLLIB/CHGDTQB1)                                    */
/*           SRCFILE(APLLIB/QSRC)                                    */
/*           SRCMBR(CHGDTQM1)                                        */
/*           REPLACE(*YES)                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
             CMD        PROMPT('Change Data Queue') TEXT(*CMDPMT) +
                          VLDCKR(CHGMSDB3) PMTOVRPGM(CHGMSDB2) +
                          HLPID(*CMD) HLPPNLGRP(CHGMSDP1)


             Parm       DTAQ        Q0001                  +
                        Min( 1 )                           +
                        Keyparm( *YES )                    +
                        Prompt( 'Data queue' )

             Parm       AUTRCL      *Char         1        +
                        Rstd( *YES )                       +
                        Dft( *SAME )                       +
                        SpcVal(( *SAME  '*' )              +
                               ( *NO    '0' )              +
                               ( *YES   '1' ))             +
                        Expr( *YES )                       +
                        Prompt( 'Automatic reclaim' )

             Parm       ENFORCE     *Char         1        +
                        Rstd( *YES )                       +
                        Dft( *SAME )                       +
                        SpcVal(( *SAME  '*' )              +
                               ( *NO    '0' )              +
                               ( *YES   '1' ))             +
                        Expr( *YES )                       +
                        Prompt( 'Enforce data queue locks' )


Q0001:       Qual                   *Name        10        +
                        Expr( *YES )

             Qual                   *Name        10        +
                        Dft( *LIBL )                       +
                        SpcVal(( *LIBL ) ( *CURLIB ))      +
                        Expr( *YES )                       +
                        Prompt( 'Library' )

