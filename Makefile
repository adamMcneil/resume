MAIN = resume

LATEX = pdflatex

INTERMEDIATE_FILES = *.aux *.log *.out *.toc

all: $(MAIN).pdf
	mv $(MAIN).pdf adam-mcneil-resume.pdf
	rm -f $(MAIN).pdf $(INTERMEDIATE_FILES)
	
$(MAIN).pdf: $(MAIN).tex
	$(LATEX) $(MAIN).tex

clean:
	rm -f $(MAIN).pdf $(INTERMEDIATE_FILES)

# Phony targets
.PHONY: all clean
