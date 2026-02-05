create or replace function APLLIB/edtz
       (number num(15,0), len integer)
returns varchar(15)
LANGUAGE SQL
CONTAINS SQL
DETERMINISTIC
return (
   case
     when len=1
       then substr(VARCHAR_FORMAT(number,'9'),2,1)
     when len=2
       then substr(VARCHAR_FORMAT(number,'99'),2,2)
     when len=3
       then substr(VARCHAR_FORMAT(number,'999'),2,3)
     when len=4
       then substr(VARCHAR_FORMAT(number,'9999'),2,4)
     when len=5
       then substr(VARCHAR_FORMAT(number,'99999'),2,5)
     when len=6
       then substr(VARCHAR_FORMAT(number,'999999'),2,6)
     when len=7
       then substr(VARCHAR_FORMAT(number,'9999999'),2,7)
     when len=8
       then substr(VARCHAR_FORMAT(number,'99999999'),2,8)
     when len=9
       then substr(VARCHAR_FORMAT(number,'999999999'),2,9)
     when len=10
       then substr(VARCHAR_FORMAT(number,'9999999999'),2,10)
     when len=11
       then substr(VARCHAR_FORMAT(number,'99999999999'),2,11)
     when len=12
       then substr(VARCHAR_FORMAT(number,'999999999999'),2,12)
     when len=13
       then substr(VARCHAR_FORMAT(number,'9999999999999'),2,13)
     when len=14
       then substr(VARCHAR_FORMAT(number,'99999999999999'),2,14)
     else substr(VARCHAR_FORMAT(number,'999999999999999'),1,15)
   end);
create or replace function APLLIB/editz
       (number num(15,0), len integer)
returns varchar(15)
LANGUAGE SQL
CONTAINS SQL
DETERMINISTIC
return (
   case
     when len=1
       then substr(VARCHAR_FORMAT(number,'9'),2,1)
     when len=2
       then substr(VARCHAR_FORMAT(number,'99'),2,2)
     when len=3
       then substr(VARCHAR_FORMAT(number,'999'),2,3)
     when len=4
       then substr(VARCHAR_FORMAT(number,'9999'),2,4)
     when len=5
       then substr(VARCHAR_FORMAT(number,'99999'),2,5)
     when len=6
       then substr(VARCHAR_FORMAT(number,'999999'),2,6)
     when len=7
       then substr(VARCHAR_FORMAT(number,'9999999'),2,7)
     when len=8
       then substr(VARCHAR_FORMAT(number,'99999999'),2,8)
     when len=9
       then substr(VARCHAR_FORMAT(number,'999999999'),2,9)
     when len=10
       then substr(VARCHAR_FORMAT(number,'9999999999'),2,10)
     when len=11
       then substr(VARCHAR_FORMAT(number,'99999999999'),2,11)
     when len=12
       then substr(VARCHAR_FORMAT(number,'999999999999'),2,12)
     when len=13
       then substr(VARCHAR_FORMAT(number,'9999999999999'),2,13)
     when len=14
       then substr(VARCHAR_FORMAT(number,'99999999999999'),2,14)
     else substr(VARCHAR_FORMAT(number,'999999999999999'),1,15)
   end);
