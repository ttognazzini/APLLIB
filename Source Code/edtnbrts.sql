-- run this statement to see each option working
Select * From (
Values
  ( '7.2',           -12345.60,edtNbr(-12345.60,'Len(7),Dec(2)') ),
  ( '5.2',            12345.67,edtNbr( 12345.67,'5.2')           ),
  ( '5.2',              345.67,edtNbr(   345.67,'5.2')           ),
  ( '5.2',           -12345.67,edtNbr(-12345.67,'5.2')           ),
  ( '5.2',             -345.67,edtNbr(  -345.67,'5.2')           ),
  ( '2.2',            12345.67,edtNbr( 12345.67,'2.2')           ),
  ( '2.2',           -12345.67,edtNbr(-12345.67,'2.2')           ),
  ( '7.2',            12345.67,edtNbr( 12345.67,'7.2')           ),
  ( '7.2',             2345.67,edtNbr(  2345.67,'7.2')           ),
  ( '7.2',            345.6789,edtNbr( 345.6789,'7.2')           ),
  ( '7.2,nocommas',   12345.67,edtNbr( 12345.67,'7.2,noCommas')  ),
  ( '7.2,left',      -12345.67,edtNbr(-12345.67,'7.2,left')      ),
  ( '7.2,left',        -345.67,edtNbr(  -345.67,'7.2,left')      ),
  ( '7.2,SIGN(CR)',  -12345.67,edtNbr(-12345.67,'7.2,SIGN(CR)')  ),
  ( '7.2,sign(cr)',    -345.67,edtNbr(  -345.67,'7.2,sign(cr)')  ),
  ( '7.2,SIGN(P)',   -12345.67,edtNbr(-12345.67,'7.2,SIGN(P)')   ),
  ( '7.2,sign(p)',     -345.67,edtNbr(  -345.67,'7.2,sign(p)')   ),
  ( '7.2,NOSIGN',    -12345.67,edtNbr(-12345.67,'7.2,NOSIGN')    ),
  ( '7.2,nosign',      -345.67,edtNbr(  -345.67,'7.2,nosign')    ),
  ( '7.2:round(up)',  345.6789,edtNbr( 345.6789,'7.2:round(up)') ),
  ( '7.2:round(u)',   345.6719,edtNbr( 345.6789,'7.2:round(u)')  ),
  ( '7.2 round(t)' ,  345.6789,edtNbr( 345.6789,'7.2:round(t)')  ),
  ( '7.2 round(trunc)', 5.6719,edtNbr(   5.6789,'7.2:round(trunc)'))
)  variables ("Example","Value","Results");

