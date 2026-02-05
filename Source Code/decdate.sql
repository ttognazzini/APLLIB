Create or Replace Function APLLIB/DECDATE ()
     returns DEC(8,0)
     language rpgle
     deterministic
     no sql
     external name 'APLLIB/#$SQLHLP(DECDATE)'
     parameter style general
     program type sub
     NO EXTERNAL ACTION;
