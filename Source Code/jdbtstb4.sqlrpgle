      *  This code uses service program JDBCR4 referenced in binding directory JDBC
      *
      *  To Compile:
      *     CRTBNDRPG JDBCTEST4 DBGVIEW(*LIST)
      *
      *****************************************************************************
      *  Java data type numeric values
      *  VARCHAR     12
      *  INTEGER     4
      *  SMALLINT    5
      *  DECIMAL     3
      *  BOOLEAN     16
      *  DATE        91
      *  TIME        92
      *  TIMESTAMP   93
      *  CHAR        1
      *  DOUBLE      8
      *  BIGINT      -5
      ****************************************************************************
     H*DFTACTGRP(*NO) BNDDIR('JDBC') CCSID(*CHAR:*JOBRUN)
     H DFTACTGRP(*NO) BNDDIR('APLLIB/APLLIB')

     FQSYSPRT   O    F  132        PRINTER

      /copy QSRC,JDBSRVV1PR // Scott Klements JDBCR4 service program headers

     D JDBCTEST4       PR                  extpgm('JDBCTEST4')
     D    driver                    128A   const
     D    url                       128A   const
     D    database                   30A   const
     D    userid                     15A   const
     D    passwrd                    15A   const
     D    sql                       256A   const
     D    parm1                       1A   const
     D    parm2                      25A   const
     D    parm3                      81A   const
     D JDBCTEST4       PI
     D    driver                    128A   const
      *               SQL Server 2005 example 'com.microsoft.sqlserver.jdbc.SQLServerDriver'
      *               SQL Server 2000 example 'com.microsoft.jdbc.sqlserver.SQLServerDriver'
      *               AS400 example 'com.ibm.as400.access.AS400JDBCDriver'
     D    url                       128A   const
      *               SQL Server 2005 example 'jdbc:sqlserver://hostname:1433'
      *               SQL Server 2000 example 'jdbc:microsoft:sqlserver://hostname:1433;DatabaseName
      *               AS400 example 'jdbc:as400://S102LKZM:446/S102LKZM'
     D    database                   30A   const
      *               SQL Server 2005 example 'fcdorderentry'
     D    userid                     15A   const
     D    passwrd                    15A   const
     D    sql                       256A   const
     D    parm1                       1A   const
     D    parm2                      25A   const
     D    parm3                      81A   const

     D conn            s                   like(Connection)
     D ErrMsg          s             50A
     D wait            s              1A
     D idx             s             10I 0
     D rc              s              1N
     D Row1            s            132A
     D stmt            s                   like(CallableStatement)
     D prop            s                   like(Properties)
     D parm2UCS2       s             50C


      /free
         *inlr = *on;

         prop = JDBC_Properties();
         JDBC_setProp(prop: 'User'    : %trim(userid));
         JDBC_setProp(prop: 'Password': %trim(passwrd));
         JDBC_setProp(prop: 'DatabaseName': %trim(database));

         conn = JDBC_ConnProp( %trim(driver)
                             : %trim(url)
                             : prop );
         JDBC_freeProp(prop);

         if (conn = *NULL);
             return;
         endif;

         // Prepare the stored-proc statement

         stmt = jdbc_PrepCall( conn
                             : %trim(sql)
                             );

         if (stmt = *NULL);
             return;
         endif;

         // jdbc_setChar (stmt: 1: parm1);
         jdbc_setString (stmt: 1: parm1);
         parm2UCS2 = %UCS2(parm2);
         // jdbc_setString (stmt: 2: parm2UCS2);
         jdbc_setString (stmt: 2: parm2);
         jdbc_setString (stmt: 3: parm3);
         // parm 3 is the data type...value 12 is Type.VARCHAR
         // jdbc_registerOutParameter (stmt: 2: 12);
         // jdbc_registerOutParameter (stmt: 3: 12);

         rc = jdbc_ExecCall(stmt);

         // if (rc = *OFF);
         //    Row1 = 'Error on jdbc_ExecCall using SQL: '
         //         + sql;
         //    except;
         //    Row1 = 'Parms passed: '
         //         + parm1 + ':'
         //         + parm2 + ':'
         //         + parm3;
         //    except;
         //    return;
         // endif;

         // parm2 = jdbc_getString(stmt: 2);
         // parm3 = jdbc_getString(stmt: 3);

         // Row1 = 'Parm2: '
         //      + parm2
         //      + ' Parm3: '
         //      + parm3;
         // except;

         jdbc_commit(conn);

         jdbc_freeCallStmt(stmt);

         jdbc_close(conn);
         return;
      /end-free

     OQSYSPRT   E
     O                       Row1               132
