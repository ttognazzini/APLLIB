package com.iseriesnetwork.clubtech.xlparse;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.io.PrintStream;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.poi.openxml4j.exceptions.OpenXML4JException;
import org.apache.poi.openxml4j.opc.OPCPackage;
import org.apache.poi.openxml4j.opc.PackageAccess;
import org.apache.poi.openxml4j.opc.PackagePart;
import org.apache.poi.openxml4j.opc.PackageRelationship;
import org.apache.poi.xssf.eventusermodel.XSSFReader;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFRichTextString;
import org.apache.poi.xssf.usermodel.XSSFRelation;
import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;

public class ParseSheetXssf {

    enum xssfDataType {
    	BOOL,
        ERROR,
        CACHEDFORMULA,
        INLINESTR,
        SSTINDEX,
        NUMBER,
    }

    static class LoadSharedStrings extends DefaultHandler {

        private String[] strings;

        public LoadSharedStrings(OPCPackage pkg)
                throws IOException, SAXException, ParserConfigurationException {
            ArrayList<PackagePart> parts =
                    pkg.getPartsByContentType(XSSFRelation.SHARED_STRINGS.getContentType());
            PackagePart sstPart = parts.get(0);
            readFrom(sstPart.getInputStream());
        }

        public void readFrom(InputStream is) throws IOException, SAXException, 
                   ParserConfigurationException {
            InputSource sheetSource = new InputSource(is);
            SAXParserFactory saxFactory = SAXParserFactory.newInstance();
            SAXParser saxParser = saxFactory.newSAXParser();
            XMLReader sheetParser = saxParser.getXMLReader();
            sheetParser.setContentHandler(this);
            sheetParser.parse(sheetSource);
        }

        public String getEntryAt(int idx) {
            return strings[idx];
        }

        private StringBuffer characters;
        private boolean doingT;
        private int index;

        public void startElement(String uri, String localName, String name,
                                 Attributes attributes) throws SAXException {
            if ("sst".equals(name)) {
                String uniqueCount = attributes.getValue("uniqueCount");
                int count = Integer.parseInt(uniqueCount);
                this.strings = new String[count];
                index = 0;
                characters = new StringBuffer();
            } else if ("si".equals(name)) {
                characters.setLength(0);
            } else if ("t".equals(name)) {
                doingT = true;
            }
        }

        public void endElement(String uri, String localName, String name)
                throws SAXException {
            if ("si".equals(name)) {
                strings[index] = characters.toString();            	
                ++index;
            } else if ("t".equals(name)) {
            	doingT = false;
            }
        }

        public void characters(char[] ch, int start, int length)
                throws SAXException {
            if (doingT)
                characters.append(ch, start, length);
        }

    }

    class MyXSSFSheetHandler extends DefaultHandler {

        private LoadSharedStrings sharedStringsTable;
        private boolean doingV;
        private xssfDataType nextDataType;
        private int thisColumn = -1;
        private int thisRow = -1;
        private short thisShortColumn = -1;
        private int lastColumnNumber = -1;
        private StringBuffer value;
        private String sheetName;
        private String lastFormula;
        private boolean didFormula;

        public MyXSSFSheetHandler(
                String sheetName,
                LoadSharedStrings strings) {
            this.sharedStringsTable = strings;
            this.value = new StringBuffer();
            this.nextDataType = xssfDataType.NUMBER;
            this.sheetName = sheetName;
        }

        public void startElement(String uri, String localName, String name,
                                 Attributes attributes) throws SAXException {

            if ("inlineStr".equals(name) || "v".equals(name) || "f".equals(name)) {
                doingV = true;
                // Clear contents cache
                value.setLength(0);
            }
            // c => cell
            else if ("c".equals(name)) {
                // Get the cell reference
                String r = attributes.getValue("r");
                int firstDigit = -1;
                for (int c = 0; c < r.length(); ++c) {
                    if (Character.isDigit(r.charAt(c))) {
                        firstDigit = c;
                        break;
                    }
                }
                thisColumn = nameToColumn(r.substring(0, firstDigit));
                thisShortColumn = new Integer(thisColumn).shortValue();
                thisRow    = Integer.parseInt(r.substring(firstDigit)) - 1;

                // Set up defaults.
                this.didFormula = false;
                this.nextDataType = xssfDataType.NUMBER;
                String cellType = attributes.getValue("t");
                if ("n".equals(cellType))
                	nextDataType = xssfDataType.NUMBER;
                else if ("b".equals(cellType))
                	nextDataType = xssfDataType.BOOL;
                else if ("e".equals(cellType))
                	nextDataType = xssfDataType.ERROR;
                else if ("inlineStr".equals(cellType))
                    nextDataType = xssfDataType.INLINESTR;
                else if ("s".equals(cellType))
                    nextDataType = xssfDataType.SSTINDEX;
                else if ("str".equals(cellType))
                    nextDataType = xssfDataType.CACHEDFORMULA;
            }

        }

        public void endElement(String uri, String localName, String name)
                throws SAXException {

            String thisStr = null;

            if ("f".equals(name)) {
            	this.lastFormula = value.toString();
            	this.didFormula = true;
                this.doingV = false;
            }
            
            // v => contents of a cell
            if ("v".equals(name)) {
                switch (nextDataType) {
                    case CACHEDFORMULA:
                    	short NaN = 0;
                    	double fval = 0;
                    	String sval = value.toString();
                    	try {
                    		fval = Double.parseDouble(sval);
                    		NaN = 0;
                    	}
                        catch (NumberFormatException ex) {
                            fval = 0;
                            NaN = 1;
                        }
                        if (!this.didFormula) {
                            this.lastFormula = sval;
                        }
                        ParseSheetCallback.callbackFormulaCell(
                                sheetName.getBytes(),
                                thisRow, 
                                thisShortColumn,
                                fval, NaN,
                                this.lastFormula.getBytes());
                        break;

                    case INLINESTR:
                        XSSFRichTextString rtsi = new XSSFRichTextString(
                                                         value.toString());
                        thisStr = String.valueOf(thisColumn) + ","
                                + String.valueOf(thisRow)
                                + " INLINESTR: " + rtsi.toString();
                        ParseSheetCallback.callbackStringCell(
                                sheetName.getBytes(),
                                thisRow, 
                                thisShortColumn,
                                rtsi.toString().getBytes() );
                        break;

                    case SSTINDEX:
                        String sstIndex = value.toString();
                        int idx = -1;
                        try {
                            idx = Integer.parseInt(sstIndex);
                            XSSFRichTextString rtss = new XSSFRichTextString(sharedStringsTable.getEntryAt(idx));
                            thisStr = String.valueOf(thisColumn) + ","
                                    + String.valueOf(thisRow)
                                    + " SSTINDEX: " + rtss.toString();
                            ParseSheetCallback.callbackStringCell(
                                    sheetName.getBytes(),
                                    thisRow, 
                                    thisShortColumn,
                                    rtss.toString().getBytes() );
                        }
                        catch (NumberFormatException ex) {
                            idx = -1;
                        }
                        break;

                    case NUMBER:
                        double dval = 0;
                        NaN = 0;
                        try {
                          dval = Double.parseDouble(value.toString());
                        }
                        catch (NumberFormatException ex) {
                          dval = 0;
                          NaN = 1;
                        }
                        if (this.didFormula) {
                           ParseSheetCallback.callbackFormulaCell(
                                sheetName.getBytes(),
                                thisRow, 
                                thisShortColumn,
                                dval, NaN,
                                this.lastFormula.getBytes());
                        }
                        else {
                           ParseSheetCallback.callbackNumericCell(
                                sheetName.getBytes(),
                                thisRow, 
                                thisShortColumn,
                                dval );
                        }
                        break;
                }

                this.doingV = false;
                this.didFormula = false;
            }

        }

        public void characters(char[] ch, int start, int length)
                throws SAXException {
            if (doingV)
                value.append(ch, start, length);
        }

        private int nameToColumn(String name) {
            int column = -1;
            for (int i = 0; i < name.length(); ++i) {
                int c = name.charAt(i);
                column = (column + 1) * 26 + c - 'A';
            }
            return column;
        }

    }

    private OPCPackage xlsxPackage;

    public ParseSheetXssf(OPCPackage xlsxPackage) {
        this.xlsxPackage = xlsxPackage;
    }

    public void processSheet(
            String name,
            LoadSharedStrings strings,
            InputStream sheetInputStream)
            throws IOException, ParserConfigurationException, SAXException {

        InputSource sheetSource = new InputSource(sheetInputStream);
        SAXParserFactory saxFactory = SAXParserFactory.newInstance();
        SAXParser saxParser = saxFactory.newSAXParser();
        XMLReader sheetParser = saxParser.getXMLReader();
        ContentHandler handler = new MyXSSFSheetHandler(name, strings);
        sheetParser.setContentHandler(handler);
        sheetParser.parse(sheetSource);
    }

    public void process()
            throws IOException, OpenXML4JException, 
                   ParserConfigurationException, SAXException {
        
           LoadSharedStrings strings = new LoadSharedStrings(this.xlsxPackage);
           XSSFReader xssfReader = new XSSFReader(this.xlsxPackage);
           XSSFReader.SheetIterator iter = (XSSFReader.SheetIterator) xssfReader.getSheetsData();
           int index = 0;
           while (iter.hasNext()) {
               InputStream stream = iter.next();
               String sheetName = iter.getSheetName();
               processSheet(sheetName, strings, stream);
               stream.close();
               ++index;
           }
    }

    public static void parse(byte filenameb[]) throws Exception {
       String fileName = new String(filenameb);
       OPCPackage xlsxPackage = OPCPackage.open(fileName, PackageAccess.READ);
       ParseSheetXssf parser = new ParseSheetXssf(xlsxPackage);
       parser.process();
       xlsxPackage.revert();
    }
}
