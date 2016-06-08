#!/bin/bash
# Matheus Viana, IBM | Research Brazil, 14.04.2016

SEP="/"
PDFEXT=".pdf"
TXTEXT=".txt"

DIR=${1%/}

for FILENAME in $DIR/*.pdf;
do

	FILENAME=${FILENAME##*/}
	FILENAME=${FILENAME%.*}

	echo [$FILENAME]

	# *****************************************************************
	# Step 1.	Poppler library: pdftotext
	# *****************************************************************

	pdftotext $DIR$SEP$FILENAME$PDFEXT
	echo -e ‘\n’ >> $DIR$SEP$FILENAME$TXTEXT

	echo 20%

	# *****************************************************************
	# Step 2.	Rscript: Text parsing to get ready for AlchemyAPI
	# *****************************************************************

	Rscript --vanilla TextParser1.R $DIR $FILENAME

	echo 30%

	# *****************************************************************
	# Step 3.	Python: Call AlchemyAPI for keyword detection
	# *****************************************************************

	python TextKeywordExtractor.py $DIR$SEP$FILENAME$TXTEXT

	echo 40%

	# *****************************************************************
	# Step 4.	Rscript: Text parsing to make output more user friendly
	# *****************************************************************

	Rscript --vanilla TextParser2.R $DIR $FILENAME

	echo 50%

	# *****************************************************************
	# Step 5.	Rscript: Detecting images in PDFs documents
	# *****************************************************************

	Rscript --vanilla ImageParser.R $DIR $FILENAME

	echo 75%

	#mv $DIR/$FILENAME".csv" "/Users/mviana/Documents/ProjectsIBM/PDFminer/resultsD3/pdf.csv"
	#mv $DIR/$FILENAME".json" "/Users/mviana/Documents/ProjectsIBM/PDFminer/resultsD3/pdf.json"

	# *****************************************************************
	# Step 6.	Rscript: Extracting images from PDF based on Json
	# *****************************************************************

	Rscript --vanilla ImageExtractor.R $DIR/$FILENAME

	echo 100%


done