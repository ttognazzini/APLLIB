JARFILE= xlparse.jar
SUBDIR= com/iseriesnetwork/clubtech/xlparse
CLASSES= $(SUBDIR)/ParseSheet.class \
	 $(SUBDIR)/ParseSheetListener.class \
	 $(SUBDIR)/ParseSheetXssf.class \
	 $(SUBDIR)/ParseSheetCallback.class 

all: $(JARFILE)

$(JARFILE): $(CLASSES)
	jar cvMf $(JARFILE) $(SUBDIR)/*.class

$(SUBDIR)/ParseSheet.class: $(SUBDIR)/ParseSheet.java $(SUBDIR)/ParseSheetListener.class
	javac $(SUBDIR)/ParseSheet.java

$(SUBDIR)/ParseSheetXssf.class: $(SUBDIR)/ParseSheetXssf.java $(SUBDIR)/ParseSheetCallback.class
	javac $(SUBDIR)/ParseSheetXssf.java

$(SUBDIR)/ParseSheetListener.class: $(SUBDIR)/ParseSheetListener.java $(SUBDIR)/ParseSheetCallback.class
	javac $(SUBDIR)/ParseSheetListener.java

$(SUBDIR)/ParseSheetCallback.class: $(SUBDIR)/ParseSheetCallback.java
	javac $(SUBDIR)/ParseSheetCallback.java

clean:	
	rm -f $(JARFILE) $(SUBDIR)/*.class
