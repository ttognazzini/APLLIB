**FREE
Dcl-Pr JDBPSTB1 EXTPGM End-Pr;

// variable for Postgres connection
Dcl-S conn         like(Connection); // Returned connection
Dcl-S UserId       Char(50) inz('postgres');
Dcl-S Passwrd      Char(50) inz('password');
Dcl-S url          Char(50) Inz('jdbc:postgresql://IS47LT:5432/as400test');

