**FREE
Dcl-Pr JDBMSQB1 EXTPGM End-Pr;

// variable for Postgres connection
Dcl-S conn         like(Connection); // Returned connection
Dcl-S UserId       varchar(50) inz('AS400');
Dcl-S Passwrd      varchar(50) inz('@$400#pWd!');
Dcl-S url          varchar(132) Inz('jdbc:sqlserver://PWIBROMVP902:1433;databaseName=TableauData;encrypt=false');

