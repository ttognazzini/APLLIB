**FREE

// copies in procedures PageUp, PageDown, SaveOptions, PopOptions, SoprtOptions and Get Options,
// these enver change so no point in duplicating the code in each program


// Load the previous page of data
// *** Do not change anything in here ***
Dcl-Proc PageUp;

  SaveOptions();

  If CurrentRow-SFLPage<0;
    CurrentRow=0;
  Else;
    CurrentRow-=SFLPage;
  EndIf;
  LoadSFL();

End-Proc;


// Load the next page of data
// *** Do not change anything in here ***
Dcl-Proc PageDown;

  SaveOptions();

  If CurrentRow+SFLPage<NumberOfRows;
    CurrentRow+=SFLPage;
  EndIf;

  LoadSFL();

End-Proc;


// Saves options entered in the SFL to optionsArray
// *** Do not change anything in here ***
Dcl-Proc SaveOptions;
  Dcl-S i packed(5:0);
  Dcl-S sflRcd packed(5);

  // If in select mode and enter is pressed try to select the line the cursor is on
  If Selects and KeyPressed='ENTER' and not Selected;
    Chain(e) CsrRrn1 SFL;
    If %found and sel='';
      optionsCount+=1;
      optionsArray(optionsCount).key=Key;
      optionsArray(optionsCount).option='1';
    EndIf;
  EndIf;

  // Check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    Chain(e) sflRcd SFL;
    If %found and sel <> '';
      // Left Justify Option
      Sel=%trim(Sel);
      // add to optionsArray
      found=*off;
      For i = 1 To optionsCount;
        If optionsArray(i).key=Key;
          optionsArray(i).option=Sel;
          found=*on;
          Leave;
        EndIf;
      EndFor;
      If not Found and sel<>'';
        optionsCount+=1;
        optionsArray(i).key=Key;
        optionsArray(i).option=Sel;
      EndIf;
    EndIf;
  EndFor;

End-Proc;


// Removes the first entry of the options array
// This is here so if the user f12's half way through processing a list of option, only the
// processed ones are removed from the array so the others still have the option in front of them.
// *** Do not change anything in here ***
Dcl-Proc PopOptions;
  If optionsCount<=1;
    Clear optionsArray;
    optionsCount=0;
    Return;
  EndIf;

  // move options starting a index 2 to options starting at index 1
  %subarr(optionsArray:1:optionsCount-1)=%subarr(optionsArray:2:optionsCount);

  // clear the last entry
  Clear optionsArray(optionsCount);

  // lower the count by 1
  optionsCount-=1;

End-Proc;


// Sorts the optionArray by the current sort field
// This one is a little wierd, when a user enters an option they get added to the bottom of
// the optionsArray. They can page up and down and change sorts and search so all these options can
// be added in any order. We want to process them in the order of the screen sort at the time they
// finally press enter. To do this we populate the sort values in the array with the field value for
// sort field based on the sort code. Then we sort the array by that value. This should make the
// options get processed in the order they are on the screen regaurdless of the way they were entered.
// *** Do not change anything in here ***
Dcl-Proc SortOptions;
  Dcl-S i int(5);
  Dcl-S temp Char(132);
  Dcl-S sortStm Varchar(1000);

  // if there are no options, skip this
  If optionsCount=0;
    Return;
  EndIf;

  // loop through optionArray and populate the sort field
  For i = 1 To optionsCount;
    sortStm='select ' + %trim(orderByDS.value(filterDs.srtCde)) + ' +
             From ('+sqlstm+') as a +
             Where Key='+%char(optionsArray(i).key);
    Exec SQL Prepare sortStm From :sortStm;
    Exec SQL Declare sortCrs Cursor For sortStm;
    Exec SQL Open sortCrs;
    Exec SQL Fetch Next From sortCrs Into :temp;
    Exec SQL Close sortCrs;
    optionsArray(i).sort=temp;
  EndFor;

  // sort options by sort field then key
  sorta %subarr(optionsArray : 1 : optionsCount) %fields(sort : Key);

End-Proc;


// Retrieves an option for a row
// *** Do not change anything in here ***
Dcl-Proc GetOption;
  Dcl-Pi *n Like(APLDCT.option);
    Key Like(dta.Key);
  End-Pi;
  Dcl-S i packed(5);

  // Loop through optionsArray and return an option if the customer is found
  For i = 1 To optionsCount;
    If optionsArray(i).Key = Key;
      Return optionsArray(i).option;
    EndIf;
  EndFor;

  Return '  ';

End-Proc;


