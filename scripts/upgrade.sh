#! /bin/bash

# Fully upgrade a python3 environment.
#
# Usage: cd /path/to/python3.N
#        ./path/to/upgrade.sh

FILE="requirements.txt"

./bin/pip3 install --upgrade pip

if [ ! -f $FILE ]; then
  ./bin/pip3 list --format freeze > $FILE
  sed --in-place 's/==/>=/g' $FILE
fi

./bin/pip3 install --upgrade -r $FILE
