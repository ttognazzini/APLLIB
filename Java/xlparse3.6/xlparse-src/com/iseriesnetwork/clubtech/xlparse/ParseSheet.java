package com.iseriesnetwork.clubtech.xlparse;

import org.apache.poi.hssf.eventusermodel.HSSFEventFactory;
import org.apache.poi.hssf.eventusermodel.HSSFListener;
import org.apache.poi.hssf.eventusermodel.HSSFRequest;
import org.apache.poi.hssf.record.*;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.io.FileOutputStream;

class ParseSheet {

    /**
     * Read an excel file and spit out what we find.
     *
     * @param filename      /path/to/your/excel/file.xls
     * @throws IOException  When there is an error processing the file.
     */
    public static void parse201003(byte filename[])
          throws IOException
    {
        FileInputStream fin = new FileInputStream(new String(filename));
        POIFSFileSystem poifs = new POIFSFileSystem(fin);
        InputStream din = poifs.createDocumentInputStream("Workbook");
        HSSFRequest req = new HSSFRequest();
        req.addListenerForAllRecords(new ParseSheetListener());
        HSSFEventFactory factory = new HSSFEventFactory();
        factory.processEvents(req, din);
        fin.close();
        din.close();

    }
}
