package com.iseriesnetwork.clubtech.xlparse;

class ParseSheetCallback {

     static {
        System.loadLibrary("XLPARSER4");
     }

     native static void callbackStringCell (byte sheet[], int row,
            short col, byte value[]);
     native static void callbackNumericCell (byte sheet[], int row,
            short col, double value);
     native static void callbackFormulaCell (byte sheet[], int row,
            short col, double value, short Nan, byte formula[]);

}
