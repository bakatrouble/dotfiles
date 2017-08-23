#!/bin/bash

i=1;
while [ $i -lt 1816 ]
do
    wget http://xkcd.com/$i/
    url=`grep https://imgs.xkcd.com/comics/ index.html | head -1 | cut -d\" -f2`
    file=`echo $url | cut -d\" -f2 | cut -d\/ -f6`
    name=$i"_"$file
    wget $url
    mv $file $name
    rm index.html*
    echo Done $i
    i=`expr $i + 1`
done

echo Done all
