#!/bin/bash
# todo: get command names from $@ instead of $1 (for creating multiple mans at once)

MAN_LOCATION=$HOME/Dropbox/man

if [[ $# -eq 0 ]]; then
  echo "Need args"
  exit 1
fi

if [[ -f $MAN_LOCATION/pdf/$1.pdf ]]; then
  echo $1.pdf already exists
else
  manual=`man -t $1`
  man -t $1 | ps2pdf - $MAN_LOCATION/pdf/$1.pdf
fi


if [[ -f $MAN_LOCATION/html/$1.html ]]; then
  echo $1.html already exists
else
  location=`man -w $1`
  if [[ $? -ne 0 ]]; then
    exit 1
  fi
  zcat $location | groff -mandoc -Thtml > $MAN_LOCATION/html/$1.html
fi
