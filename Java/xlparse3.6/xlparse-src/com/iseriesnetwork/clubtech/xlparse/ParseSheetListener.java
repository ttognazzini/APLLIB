package com.iseriesnetwork.clubtech.xlparse;

import org.apache.poi.hssf.eventusermodel.HSSFEventFactory;
import org.apache.poi.hssf.eventusermodel.HSSFListener;
import org.apache.poi.hssf.eventusermodel.HSSFRequest;
import org.apache.poi.hssf.record.*;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class ParseSheetListener
        implements HSSFListener
{

    private SSTRecord sstrec;
    private String[] sheetName = new String[256];
    private int activeSheet = -1;
    private int numSheets = -1;

    /****
     ** process a record found in an Excel spreadsheet
     **
     ****/

    public void processRecord(Record record)
    {
        switch (record.getSid())
        {
            // the BOFRecord can represent either the beginning of a sheet
            //    or the workbook

            case BOFRecord.sid:
                BOFRecord bof = (BOFRecord) record;
                if (bof.getType() == bof.TYPE_WORKSHEET)
                {
                  activeSheet++;
                }
                break;

            case BoundSheetRecord.sid:
                BoundSheetRecord bsr = (BoundSheetRecord) record;
                numSheets++;
                sheetName[numSheets] = bsr.getSheetname();
                break;

            case NumberRecord.sid:
                NumberRecord numrec = (NumberRecord) record;
                if (activeSheet != -1) {
                   ParseSheetCallback.callbackNumericCell(
                       sheetName[activeSheet].getBytes(),
                       numrec.getRow(), 
                       numrec.getColumn(), 
                       numrec.getValue());
                }
                break;

            case SSTRecord.sid:
                sstrec = (SSTRecord) record;
                break;

            case LabelSSTRecord.sid:
                LabelSSTRecord lrec = (LabelSSTRecord) record;
                if (activeSheet != -1) {
                   UnicodeString value = sstrec.getString(lrec.getSSTIndex());
		   byte[] bvalue = value.getString().getBytes();
                   ParseSheetCallback.callbackStringCell(
                       sheetName[activeSheet].getBytes(),
                       lrec.getRow(), lrec.getColumn(),
                       bvalue);

                }
                break;

  	     case FormulaRecord.sid:
		FormulaRecord frec = (FormulaRecord) record;
                if (activeSheet != -1) {
                  Double dn = new Double(frec.getValue());
		  short NaN = 0;

		   String value = frec.toString();
		   byte[] bvalue = value.getBytes();
                   if(dn.equals(new Double(Double.NaN))){
                       NaN = 1;
		   }
                   ParseSheetCallback.callbackFormulaCell(
                       sheetName[activeSheet].getBytes(),
                       frec.getRow(), frec.getColumn(),
                       frec.getValue(), NaN, bvalue);
               }
	    break;

            case DateWindow1904Record.sid:
		DateWindow1904Record drec =
		(DateWindow1904Record) record;
		break;

        }
    }

}
