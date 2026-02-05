      *  Demonstration of using the JDBCR4 service program to interact
      *  with an AS400 database.
      *                               Scott Klement, May 18, 2006
      *
      *  To Compile:
      *     ** First, you need the JDBCR4 service program. See that
      *        source member for instructions. **
      *     CRTBNDRPG JDBCTEST2 SRCFILE(xxx/xxx) DBGVIEW(*LIST)
      *
      *  To Run:
      *     CALL JDBCTEST2 PARM('klemscot' 'bigboy')
      *
      *     Replace 'klemscot' with your userid on the AS400 server
      *     and 'bigboy' with your password.
      *
     H DFTACTGRP(*NO) BNDDIR('APLLIB/APLLIB')

     FQSYSPRT   O    F  132        PRINTER

      /copy QSRC,JDBSRVV1PR // Scott Klements JDBCR4 service program headers

     D JDBCTEST2       PR                  extpgm('JDBCTEST2')
     D    userid                     15A   const
     D    passwrd                    15A   const
     D JDBCTEST2       PI
     D    userid                     15A   const
     D    passwrd                    15A   const

     D conn            s                   like(Connection)
     D ErrMsg          s             50A
     D wait            s              1A
     D count           s             10I 0
     D rs              s                   like(ResultSet)
     D itemNo          s              5P 0
     D Desc            s             25A
     D prop            s                   like(Properties)


      /free
         *inlr = *on;

         prop = JDBC_Properties();
         JDBC_setProp(prop: 'user'    : %trim(userid));
         JDBC_setProp(prop: 'password': %trim(passwrd));
         JDBC_setProp(prop: 'prompt'  : 'false');
         JDBC_setProp(prop: 'errors'  : 'full');
         JDBC_setProp(prop: 'naming'  : 'system');

         conn = JDBC_ConnProp( 'com.ibm.as400.access.AS400JDBCDriver'
                             : 'jdbc:as400://as400.example.com'
                             : prop );
         JDBC_freeProp(prop);

         if (conn = *NULL);
             return;
         endif;

         // Query the database

         rs = jdbc_ExecQry( conn : 'Select imProd,imDesc'
                                 + '  from ITMMAST'
                                 + '  where imProd < 10000'
                                 );
         dow (jdbc_nextRow(rs));
             ItemNo = %int(jdbc_getCol(rs: 1));
             Desc   = jdbc_getCol(rs: 2);
             except;
         enddo;

         jdbc_freeResult(rs);

         jdbc_close(conn);
         return;
      /end-free

     OQSYSPRT   E
     O                       ItemNo        Z      5
     O                       Desc                32
