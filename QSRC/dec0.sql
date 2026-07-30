create or replace function APLLIB/DEC0 (str varchar(20))
returns dec
deterministic
no external action contains sql
begin
  declare continue handler for sqlstate '22018'
    return 0;
  return dec(str);
end;
