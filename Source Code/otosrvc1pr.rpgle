
  /* output options data structure */
  /* if this is changed OTOSRV1PR must be changed to match it */
  /* this must be copied into OTOxxCX programs manually since there is no copy books in CL */
  DCL &OTO *CHAR 4096
  DCL   &outMdl   *CHAR   2 STG(*DEFINED) DEFVAR(&OTO    1 ) /* Module */
  DCL   &pgmNme   *CHAR  10 STG(*DEFINED) DEFVAR(&OTO    3 ) /* Program Name */
  DCL   &prtOut   *CHAR   1 STG(*DEFINED) DEFVAR(&OTO   13 ) /* Print output (Y/N) */
  DCL   &emlOut   *CHAR   1 STG(*DEFINED) DEFVAR(&OTO   14 ) /* Email output (Y/N) */
  DCL   &arcOut   *CHAR   1 STG(*DEFINED) DEFVAR(&OTO   15 ) /* Archie ouput (Y/N) */
  DCL   &faxOut   *CHAR   1 STG(*DEFINED) DEFVAR(&OTO   16 ) /* Fax Output */
  DCL   &pstFlg   *CHAR   1 STG(*DEFINED) DEFVAR(&OTO   17 ) /* post (Y/N) */
  DCL   &prtDev   *CHAR  10 STG(*DEFINED) DEFVAR(&OTO   18 ) /* Printer ID */
  DCL   &prtOtq   *CHAR  10 STG(*DEFINED) DEFVAR(&OTO   28 ) /* ouptut queue */
  DCL   &hldOut   *CHAR   5 STG(*DEFINED) DEFVAR(&OTO   38 ) /* hold (*YES/*NO) */
  DCL   &savOut   *CHAR   5 STG(*DEFINED) DEFVAR(&OTO   43 ) /* save output (*YES/*NO) */
  DCL   &prtFrm   *CHAR  10 STG(*DEFINED) DEFVAR(&OTO   48 ) /* form */
  DCL   &usrDta   *CHAR  10 STG(*DEFINED) DEFVAR(&OTO   58 ) /* user data */
  DCL   &nbrCpy   *CHAR   3 STG(*DEFINED) DEFVAR(&OTO   68 ) /* copies */
  DCL   &prtQul   *CHAR  10 STG(*DEFINED) DEFVAR(&OTO   71 ) /* print quality */
  DCL   &prtOvl   *CHAR  10 STG(*DEFINED) DEFVAR(&OTO   81 ) /* overlay, used on chgprtf */
  DCL   &arcFlr   *CHAR 128 STG(*DEFINED) DEFVAR(&OTO   91 ) /* Archive File name */
  DCL   &aarFlr   *CHAR 128 STG(*DEFINED) DEFVAR(&OTO  219 ) /* Auto Archive folder */
  DCL   &faxNbr   *CHAR  20 STG(*DEFINED) DEFVAR(&OTO  347 ) /* fax number */
  DCL   &emlAdd   *CHAR  60 STG(*DEFINED) DEFVAR(&OTO  367 ) /* Email address */
  DCL   &emlNme   *CHAR  30 STG(*DEFINED) DEFVAR(&OTO  427 ) /* Email Name */
  DCL   &frmEml   *CHAR  60 STG(*DEFINED) DEFVAR(&OTO  457 ) /* from address */
  DCL   &frmNme   *CHAR  30 STG(*DEFINED) DEFVAR(&OTO  517 ) /* from name */
  DCL   &cc1Eml   *CHAR  60 STG(*DEFINED) DEFVAR(&OTO  547 ) /* cc address 1 */
  DCL   &cc1Nme   *CHAR  30 STG(*DEFINED) DEFVAR(&OTO  607 ) /* cc name 1 */
  DCL   &cc2Eml   *CHAR  60 STG(*DEFINED) DEFVAR(&OTO  637 ) /* cc address 2 */
  DCL   &cc2Nme   *CHAR  30 STG(*DEFINED) DEFVAR(&OTO  697 ) /* cc name 2 */
  DCL   &cc3Eml   *CHAR  60 STG(*DEFINED) DEFVAR(&OTO  727 ) /* cc address 3 */
  DCL   &cc3Nme   *CHAR  30 STG(*DEFINED) DEFVAR(&OTO  787 ) /* cc name 3 */
  DCL   &bccEml   *CHAR  60 STG(*DEFINED) DEFVAR(&OTO  817 ) /* bcc address */
  DCL   &bccNme   *CHAR  30 STG(*DEFINED) DEFVAR(&OTO  877 ) /* bcc name */
  DCL   &emlSbj   *CHAR  60 STG(*DEFINED) DEFVAR(&OTO  907 ) /* subject */
  DCL   &ataTyp   *CHAR   5 STG(*DEFINED) DEFVAR(&OTO  967 ) /* Attachment type */
  DCL   &vldAta   *CHAR   1 STG(*DEFINED) DEFVAR(&OTO  972 ) /* Vld Att Typ,=PDF,TIFF;2=+CSV,3=+XML,4=+XLS*/
  DCL   &ataNme   *CHAR 128 STG(*DEFINED) DEFVAR(&OTO  973 ) /* File Name */
  DCL   &ataFmt   *CHAR   1 STG(*DEFINED) DEFVAR(&OTO 1101 ) /* CSV File format (1=Data,2=Report) */
  DCL   &crtXma   *CHAR   1 STG(*DEFINED) DEFVAR(&OTO 1102 ) /* Create XML attribute file (Y/N) */
  DCL   &emlMsg01 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1103 ) /* Message 1  */
  DCL   &emlMsg02 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1178 ) /* Message 2  */
  DCL   &emlMsg03 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1253 ) /* Message 3  */
  DCL   &emlMsg04 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1328 ) /* Message 4  */
  DCL   &emlMsg05 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1403 ) /* Message 5  */
  DCL   &emlMsg06 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1478 ) /* Message 6  */
  DCL   &emlMsg07 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1553 ) /* Message 7  */
  DCL   &emlMsg08 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1628 ) /* Message 8  */
  DCL   &emlMsg09 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1703 ) /* Message 9  */
  DCL   &emlMsg10 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1778 ) /* Message 10 */
  DCL   &emlMsg11 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1853 ) /* Message 11 */
  DCL   &emlMsg12 *CHAR  75 STG(*DEFINED) DEFVAR(&OTO 1928 ) /* Message 12 */
  DCL   &pstFlr   *CHAR 128 STG(*DEFINED) DEFVAR(&OTO 2003 ) /* System Post Folder */
  DCL   &prtFle   *CHAR  10 STG(*DEFINED) DEFVAR(&OTO 2131 ) /* Print file name */
  DCL   &pgeWid   *CHAR   3 STG(*DEFINED) DEFVAR(&OTO 2141 ) /* Print file page width */
  DCL   &pgeLen   *CHAR   3 STG(*DEFINED) DEFVAR(&OTO 2144 ) /* Print file page length */
  DCL   &endChr   *CHAR   1 STG(*DEFINED) DEFVAR(&OTO 4096 ) /* Populated with an astrisk */

