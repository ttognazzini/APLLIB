create or replace function APLLIB/ftime (time decimal(6,0))
returns char(8)
LANGUAGE SQL
CONTAINS SQL
DETERMINISTIC
return
Case when time=0 THEN ' '
     Else (substr(digits(time),1,2) concat ':' concat
           substr(digits(time),3,2) concat ':' concat
           substr(digits(time),5,2))
end;

-- add label and long comment
Label on function APLLIB/FTIME(DECIMAL(6,0)) is 'Format A dec(6) Time to HH:MM:SS';
Comment on function APLLIB/FTIME(DECIMAL(6,0))
  is 'Format Time, Accepts a decimal(6) time field and returns a ''HH:MI:SS'' character field. It is used to make report
 columns look better.';
