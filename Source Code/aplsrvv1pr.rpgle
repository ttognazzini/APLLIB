**Free

// Pre-defined variables for new programs

// Indicates a record was found
Dcl-S found ind;
// Holds the character value of the key pressed to return from a screen,
// Like 'Enter','F1', 'RollUp' Extra.
Dcl-S keyPressed Char(10);
// from the screen normally, this declaration just forces them to signed
Dcl-S outCol zoned(3);
// from the screen normally, this declaration just forces them to signed
Dcl-S outRow zoned(3);


// Data structure to reference all fields from dictionaries, new dictionaries need to be added
Dcl-Ds APLDCT extname('APLLIB/APLDCT') Qualified Template End-Ds;


// InfDs for print files
Dcl-Ds InfDs_prt Qualified Template;
  PRT_CUR_LINE  INT(5)     POS(367);    // current line num
  PRT_CUR_PAGE  INT(10)    POS(369);    // current page cnt
  // if the first bit of prt_flags is on, the spooled file has been
  // deleted.  use testb x'80' or testb '0' to test this bit.
  PRT_FLAGS     Char(1)    POS(373);    // print flags
  PRT_MAJOR     Char(2)    POS(401);    // major ret code
  PRT_MINOR     Char(2)    POS(403);    // minor ret code
End-Ds;


// InfDs for Database file
Dcl-Ds InfDs_db Qualified Template;
  FDBK_SIZE     INT(10)    POS(367);    // Current line num
  JOIN_BITS     INT(10)    POS(371);    // JFILE bits
  LOCK_RCDS     INT(5)     POS(377);    // Nbr locked rcds
  POS_BITS      Char(1)    POS(385);    // File pos bits
  DLT_BITS      Char(1)    POS(384);    // Rcd deleted bits
  NUM_KEYS      INT(5)     POS(387);    // Num keys (bin)
  KEY_LEN       INT(5)     POS(393);    // Key length
  MBR_NUM       INT(5)     POS(395);    // Member number
  DB_RRN        INT(10)    POS(397);    // Relative-rcd-num
  Key           Char(2000) POS(401);    // Key value (max size 2000)
End-Ds;


// InfDs for ICF files
Dcl-Ds InfDs_ICF Qualified Template;
  ICF_AID       Char(1)    POS(369);    // AID byte
  ICF_LEN       INT(10)    POS(372);    // Actual data len
  ICF_MAJOR     Char(2)    POS(401);    // Major ret code
  ICF_MINOR     Char(2)    POS(403);    // Minor ret code
  SNA_SENSE     Char(8)    POS(405);    // SNA sense rc
  SAFE_IND      Char(1)    POS(413);    // Safe indicator
  RQSWRT        Char(1)    POS(415);    // Request write
  RMT_FMT       Char(10)   POS(416);    // Remote rcd fmt
  ICF_MODE      Char(8)    POS(430);    // Mode name
End-Ds;


// InfDS for display files
Dcl-Ds dspDs Qualified;
  DSP_FLAG1     Char(2)    POS(367);    // Display flags
  DSP_AID       Char(1)    POS(369);    // AID byte
  Key           Char(1)    pos(369);
  Cursor        Char(2)    POS(370);    // Cursor location
  DATA_LEN      INT(10)    POS(372);    // Actual data len
  SF_RRN        INT(5)     POS(376);    // Subfile rrn
  MIN_RRN       INT(5)     POS(378);    // Subfile min rrn
  NUM_RCDS      INT(5)     POS(380);    // Subfile num rcds
  ACT_CURS      Char(2)    POS(382);    // Active window cursor location
  DSP_MAJOR     Char(2)    POS(401);    // Major ret code
  DSP_MINOR     Char(2)    POS(403);    // Minor ret code
End-Ds;

// These overide the sfl control indictors to named variables
Dcl-Ds Indicators Based(IndPtr);
  sflDrop       Ind pos(11);
  sflClr        Ind pos(50);
  sflDsp        Ind pos(51);
  AlwF23        Ind pos(93);
  EOF           Ind pos(98);
End-Ds;
Dcl-S IndPtr    pointer Inz(%addr(*in));


// Output Parameters for use in all print programs
Dcl-Ds #$outputParms Qualified Template;

  returnKey Char(10); // A key pressed if the user exits the prompt program, Example: F3, F12

  print   Char(1); // Y indicates to print the report
  email   Char(1); // Y indicates to email the report
  fax     Char(1); // Y indicates to fax the report
  archive Char(1); // Y indicated to archive(save to IFS) the report


  // add all print options
  prID    Char(10); // Printer ID/Device Description
  outq    Char(10); // output queue
  outqLib Char(10); // library for output queue
  save    Char(1);  // Y=save ouptut
  hold    Char(1);  // Y=hold output
  form    Char(10); // form
  usrDta  Char(10); // User data
  copies  int(5);   // number of copies
  qualty  Char(10); // print quality

  // add all email options
  emailAddresses   Char(60) dim(10);     // email addresses
  emailBCC         Char(60) dim(10);     // email BCC adresses
  emailFormat      Char(10);             // email format, XLSX, CSV, PDF, TEXT, XML, JSON
  emailFileName    Char(10);             // name of the attached file
  emailSubject     Varchar(100);         // email subject
  emailMessage     Varchar(5000);        // email message/body, type HTML
  emailAttachments Varchar(500) dim(10); // up to 10 additional attachments to add

  // add all fax options, finish later
  faxNum  Char(10); // fax number

  // add all save options, finish later
  path Varchar(500); // path to save to

End-Ds;


// program call to get standard output parameters
Dcl-Pr $GetOutputParms ExtPgm('SYSXXX');
  returnKey Char(10);
  outputParms likeds(#$outputParms);
End-Pr;


Dcl-Ds $securityDs Qualified;
  allowed ind; // user is allowed to use this program
  upd ind;  // user is allowed update with this program
  Create ind;  // user is allowed create new entries with this program
  inquiry ind; // user is allowed inquiry with this program
End-Ds;


// Function Key Data Structure
// Used to handle valid functions for the program, and to
// set the more functions options.
Dcl-Ds fncDs Qualified;
  numberOfKeys Int(5);
  function like(APLDCT.FncKey) Dim(30);
  description like(APLDCT.Des) Dim(30);
  attribute Char(1) Dim(30);
  numberOfLines Int(5);
  lines Char(131) Dim(10);
  validationString Char(100);
  currentLine int(5);
  screenSize packed(3:0);
  F23 Ind;
  F24 Ind;
End-Ds;


// Clear all subfile messages and setoff error indicator
// Paramtere 1. Error Indicator
// Example: $ClearMessages(error);
Dcl-Pr $ClearMessages ExtProc;
End-Pr;


// Handles all error messages
//   adds error to message SFL, turns on error indicator
//   Optionally positions cursor to and highlights a field
// Example for error message only
//   $ErrorMessage('NVT0001');
// Example for error with substitution text and error flag
//   $ErrorMessage('NVT0001':brand:error);
// Example for message with field and substitution text
//   $ErrorMessage('NVT0001':brand1:error:brand1@:'brand1':outRow:outCol:psDsPgmNam);
// Example for message with field, substitution text and an additional field to highlight
//   $ErrorMessage('NVT0001':brand1:error:brand1@:'brand1':outRow:outCol:psDsPgmNam:brand1@);
// Up to 20 additional attribute fields can be passed.
Dcl-Pr $ErrorMessage ExtProc;
  messageIdentifier Char(7) const;
  messageSubstituionText Varchar(256) const options(*nopass);
  errorIndicator Ind options(*nopass);
  attributeField Char(1) options(*nopass);
  posToFieldName Char(10) const options(*nopass);
  Row zoned(3:0) options(*nopass);
  col zoned(3:0) options(*nopass);
  programName Char(10) options(*nopass);
  AdditionalAttributeField01 Char(1) options(*nopass);
  AdditionalAttributeField02 Char(1) options(*nopass);
  AdditionalAttributeField03 Char(1) options(*nopass);
  AdditionalAttributeField04 Char(1) options(*nopass);
  AdditionalAttributeField05 Char(1) options(*nopass);
  AdditionalAttributeField06 Char(1) options(*nopass);
  AdditionalAttributeField07 Char(1) options(*nopass);
  AdditionalAttributeField08 Char(1) options(*nopass);
  AdditionalAttributeField09 Char(1) options(*nopass);
  AdditionalAttributeField10 Char(1) options(*nopass);
  AdditionalAttributeField11 Char(1) options(*nopass);
  AdditionalAttributeField12 Char(1) options(*nopass);
  AdditionalAttributeField13 Char(1) options(*nopass);
  AdditionalAttributeField14 Char(1) options(*nopass);
  AdditionalAttributeField15 Char(1) options(*nopass);
  AdditionalAttributeField16 Char(1) options(*nopass);
  AdditionalAttributeField17 Char(1) options(*nopass);
  AdditionalAttributeField18 Char(1) options(*nopass);
  AdditionalAttributeField19 Char(1) options(*nopass);
  AdditionalAttributeField20 Char(1) options(*nopass);
End-Pr;


// Returns a text version of a pressed key
// Pass in the field key from the dspDs defined on the INFDS of the display files Dcl-F
// The key field is a hex value, this converts it to a character string, so if F3 is
// pressed this returns 'F3'
Dcl-Pr $ReturnKey Char(10) ExtProc;
  Key Char(1);
End-Pr;


// Get the location of a field on the screen

// Pass in the program name for display file name, the field name on the screen,
// variables to receive the row and column of the screen position.

// The error indicator can be passed as well, if it is and there is no error, the
// location will be set, if there is an error the locotion will only changed if it
// is further up the screen than the current location.
Dcl-Pr $GetFieldLocation ExtProc;
  programName Char(10);
  fieldName Char(10) const;
  Row zoned(3:0);
  col zoned(3:0);
  error ind options(*nopass:*omit);
  screen Char(10) options(*nopass:*omit);
End-Pr;


// Get function key information for this program

// Returns instance of fncDs

// Parameters
//  1. Program Name
//  2. Option, Optional Defaults to 1, 1=Select,2=Maintenance,5=Inquiry
//  3. optDs, optional, omittable, subfile options DS to see if F23 needs to be added
//  4. Screen Size, optional, 80 or 132 for screen size width, defualts to 80

// Examples:
//  fncDs=#$GetFunctionKeys(psdsPgmNam);
//  fncDs=#$GetFunctionKeys(psdsPgmNam:Option);
//  fncDs=#$GetFunctionKeys(psdsPgmNam:Option:optDs);
//  fncDs=#$GetFunctionKeys(psdsPgmNam:0:optDs);
//  fncDs=#$GetFunctionKeys(psdsPgmNam:0:*omit:132);
Dcl-Pr $GetFunctionKeys likeds(fncDs) ExtProc;
  programName Char(10) CONST;
  Option like(APLDCT.Option) const options(*nopass);
  optDs LikeDs(optDs) options(*nopass:*omit);
  screenSize packed(3:0) Value options(*nopass);
End-Pr;


// Tests if a keypress is valid for a program

// Parameters
//   1. keyPressed, the key pressed
//   2. fncDs, Function key Data Structure

// Returns true if the key pressed is valid, otherwise false
Dcl-Pr $ValidKeyPressed Ind ExtProc;
  keyPressed Char(10) const;
  fncDs LikeDs(fncDs);
End-Pr;


// Get Next Function Key String
// Returns the text for the next line of function keys
// Parameters
//   1. fncDs, Function key Data Structure
Dcl-Pr $NextFunctionKeys Char(131) ExtProc;
  fnc likeds(fncDs);
End-Pr;


// Changes the text on a function key
// Returns the text for the current line of function keys with any updates
// Parameters
//   1. fncDs, Function key Data Structure
//   2. Function key
//   3. New Text
// Example:
//   fncKeys=$ChangeFuntionKey(fncDs:'F11':'F11=Less Detail');
Dcl-Pr $ChangeFunctionKey Char(131) ExtProc;
  fncDs likeds(fncDs);
  functionKey like(APLDCT.FncKey) CONST;
  newText like(APLDCT.Des) CONST;
End-Pr;


// Changes the attributes of a function key
// Returns the text for the current line of function keys with any updates
// Attribute string is the same as for $SetAttributes
// You have to change it back if you want it regular
// Parameters
//   1. fncDs, Function key Data Structure
//   2. Function key
//   3. Attribute String
// Example, changes F2 to red:
//   fncKeys=$ChangeFuntionKeyAttributes(fncDs:'F2':'Red');
// Example, changes F2 back to the default:
//   fncKeys=$ChangeFuntionKeyAttributes(fncDs:'F2':'');
Dcl-Pr $ChangeFunctionKeyAttributes Char(131) ExtProc;
  fncDs likeds(fncDs);
  functionKey like(APLDCT.FncKey) CONST;
  newAttributes Varchar(50) CONST;
End-Pr;


// Security Information
// This returns an instance of the $securityDs which contains information about what options
// the user has available in the program, like if they can do maintenance or inquiry or not
// have access at all. Downgrades or set the Option based on authorization
Dcl-Pr $Security likeds($securityDs) ExtProc;
  program Char(10);
  user Char(10);
  Option like(APLDCT.Option);
End-Pr;


// Set the attributes of a field
// Parameters
//   1. Field Attribute Field
//   2. Comma seperated list of attributes, case insensative
// Example: $SetAttribute(dctNme@:'ul,RI,Pr');
Dcl-Pr $SetAttribute ExtProc;
  fieldAttributeField Char(1);
  attributes Varchar(50) const;
End-Pr;


// SLF Options Data Structure
// Used to handle valid SFL options for the program, and to
// set the more Options options.
Dcl-Ds optDs Qualified;
  numberOfOptions Int(5);
  Option like(APLDCT.Option) Dim(30);
  description like(APLDCT.Des) Dim(30);
  attribute Char(1) Dim(30);
  numberOfLines Int(5);
  lines Char(131) Dim(10);
  screenSize packed(3:0);
  currentLine int(5);
End-Ds;


// Get SFL Options for this program

// Returns instance of optDs

// Parameters
//  1. Program Name
//  2. Option, Optional Defaults to 1, 1=Select,2=Maintenance,5=Inquiry
//  2. Screen Size, Optional Defaults to 80, 80 or 132 for screen width

// Example: optDs=#$GetSFLOptions(psdspgmNam);
//          optDs=#$GetSFLOptions(psdspgmNam:Option);
//          optDs=#$GetSFLOptions(psdspgmNam:0:132);
Dcl-Pr $GetSFLOptions likeds(optDs) ExtProc;
  programName Char(10) CONST;
  Option like(APLDCT.Option) const options(*nopass);
  screenSize packed(3:0) Value options(*nopass);
End-Pr;


// Get Next SFL Options String
// Returns the text for the next line of SFL Options
// Parameters
//   1. optDs, SFL Options Data Structure
Dcl-Pr $NextSFLOption Char(131) ExtProc;
  opt likeds(optDs);
End-Pr;


// Changes the text on a SFL option
// Returns the text for the current line of options any updates
// Parameters
//   1. optDs, Function key Data Structure
//   2. option
//   3. New Text
// Example:
//   options=$ChangeSFLOption(optDs:'1':'1=Select');
Dcl-Pr $ChangeSFLOption Char(131) ExtProc;
  optDs likeds(optDs);
  Option like(APLDCT.Option) CONST;
  newText like(APLDCT.Des) CONST;
End-Pr;


// Changes the attributes of a SFL option
// Returns the text for the current line of SFL options with any updates
// Attribute string is the same as for $SetAttributes
// You have to change it back if you want it regular
// Parameters
//   1. optDs, SFL Options Data Structure
//   2. Option
//   3. Attribute String
// Example, changes 1 to red:
//   options=$ChangeSFLOptionAttributes(optDs:'1':'Red');
// Example, changes 12 back to the default:
//   options=$ChangeSFLOptionAttributes(optDs:'1':'');
Dcl-Pr $ChangeSFLOptionAttributes Char(131) ExtProc;
  optDs likeds(optDs);
  Option like(APLDCT.option) CONST;
  newAttributes Varchar(50) CONST;
End-Pr;


// Tests if a SFL option is valid

// Parameters
//   1. options, the entered SFL option
//   2. optDs, SFL Options Data Structure

// Returns true if the option is valid, otherwise false
Dcl-Pr $ValidSFLOption Ind ExtProc;
  Option like(APLDCT.option) const;
  optDs LikeDs(optDs);
End-Pr;


// Toggles SFL Mode bewteen 1 and 0
Dcl-Pr $ToggleSFLMode ExtProc;
  sflMode Char(1);
End-Pr;


// Validate an Enumerated Value Description

// Parameters
//   1. Value to test
//   2. Dictionary
//   3. Field Name

// Returns true if the value is valid, otherwise false
Dcl-Pr $ValidEnmDes Ind ExtProc;
  EnmDes like(APLDCT.EnmDes) Const;
  DctNme like(APLDCT.DctNme) Const;
  FldNme like(APLDCT.FldNme) Const;
End-Pr;


// Validate an Enumerated Value Value

// Parameters
//   1. Value to test
//   2. Dictionary
//   3. Field Name

// Returns true if the value is valid, otherwise false
Dcl-Pr $ValidEnmVal Ind ExtProc;
  EnmVal like(APLDCT.EnmVal) Const;
  DctNme like(APLDCT.DctNme) Const;
  FldNme like(APLDCT.FldNme) Const;
End-Pr;


// Validate an SQL Alias

// Parameters
//   1. SQL Alias

// Returns message if invalid, otherwise nothing

// Rules
//   1. Has to start with a character
//   2. Cannot have imbedded spaces
//   3. Can only contian letters, numbers and underscore
Dcl-Pr $ValidSQLAlias  Varchar(100) ExtProc;
  SQLAlias like(APLDCT.FldNmeSql) Const;
End-Pr;


// Builld or clean an SQL Alias

// Parameters
//   1. Column Text or existing SQL alias
//   2. ColHdg, Optional

// Returns generated SQL Alias Name
Dcl-Pr $BuildSQLAlias Like(APLDCT.FldNmeSql) ExtProc;
  ColTxt Like(APLDCT.ColTxt) const;
  ColHdg Like(APLDCT.ColHdg) const options(*nopass);
End-Pr;


// Builds search parameter comparisons for where clause in an SQL statement

// This procedure works just like #$BLDSCH, except that it gets the field names
// from the screen. This prevents the need to hardcode all the screen names in the
// new template list programs.

// Parameters
//   1. Program name
//   2. Search string

// Returns generated SQL Alias Name
Dcl-Pr $BuildSearch Varchar(10000) ExtProc;
  pgmNme Char(10) const;
  schVal Varchar(1000) const;
End-Pr;


// Builds message string for the bottom of a SFL screen
Dcl-Pr $BuildSFLMessage  Varchar(132) ExtProc;
  numberOfRows Packed(9) Value;
  totalNumberOfRows Packed(9) Value;
  sflPage Packed(9) Value;
  currentRow Packed(9) Value;
  rrn1 Packed(9) Value;
End-Pr;


// Gets an attribute field for the user from the User Defaults system
// The key has to be setup in UDFMSTD1. See INVINQD2 for example use.
// Decapricated, use $GetUserAttrbiutes going forward.
Dcl-Pr $GetUserAttribute Char(1) ExtProc;
  usr like(APLDCT.Usr) Const;
  pgmNme like(APLDCT.pgmNme) Const;
  UDFKey like(APLDCT.UDFKey) Const;
  AdditionalAttribute like(APLDCT.UDFVal) Const options(*nopass);
End-Pr;

// Gets an attribute field for the user from the User Defaults system
// The key has to be setup in UDFMSTD1. See INVINQD2 for example use.
Dcl-Pr $GetUserAttributes ExtProc;
  atrFld char(1);
  user like(APLDCT.Usr) Const;
  pgmNme like(APLDCT.pgmNme) Const;
  UDFKey like(APLDCT.UDFKey) Const;
  AdditionalAttribute like(APLDCT.UDFVal) Const options(*omit:*nopass);
  lblAtrFld char(1) options(*omit:*nopass);
End-Pr;
