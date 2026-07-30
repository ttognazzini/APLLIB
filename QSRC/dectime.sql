Create or Replace Function APLLIB/DECTIME ()
     returns DEC(6,0)
     language rpgle
     deterministic
     no sql
     external name 'APLLIB/#$SQLHLP(DECTIME)'
     parameter style general
     program type sub
     NO EXTERNAL ACTION
