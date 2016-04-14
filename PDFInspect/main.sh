#!/bin/bash
# Matheus Viana, IBM | Research Brazil, 14.04.2016

SEP="/"
PDFEXT=".pdf"
TXTEXT=".txt"

DIR=${1%/}
FILENAME=$2

# *****************************************************************
# Step 1.	Poppler library: pdftotext
# *****************************************************************

pdftotext $DIR$SEP$FILENAME$PDFEXT
echo -e ‘\n’ >> $DIR$SEP$FILENAME$TXTEXT

echo 25%

# *****************************************************************
# Step 2.	Rscript: Text parsing to get ready for AlchemyAPI
# *****************************************************************

Rscript --vanilla TextParser1.R $DIR $FILENAME

echo 50%

# *****************************************************************
# Step 3.	Python: Call AlchemyAPI for keyword detection
# *****************************************************************

python TextKeywordExtractor.py $DIR$SEP$FILENAME$TXTEXT

echo 75%

# *****************************************************************
# Step 4.	Rscript: Text parsing to make output more user friendly
# *****************************************************************

Rscript --vanilla TextParser2.R $DIR $FILENAME

echo 100%