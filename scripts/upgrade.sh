#! /bin/bash

# Fully upgrade a Python environment.
#
# Usage: cd /path/to/pythonENV
#        ./path/to/upgrade.sh

FILE="requirements.txt"
PIP=$(find bin/ -type f -iname pip* | sort --version-sort --reverse | head --lines=1)

eval ./$PIP install --upgrade pip

if [ ! -f $FILE ]; then
  eval ./$PIP list --format freeze > ${FILE}
  if [ "$(uname)" = "Darwin" ]; then
    sed -i '' 's/==/>=/g' $FILE
  else
    sed --in-place 's/==/>=/g' ${FILE}
  fi
fi

eval ./$PIP install --upgrade --requirement ${FILE}
