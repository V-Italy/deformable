#!/bin/bash

if [ $# != 1 ]
then
echo "Usage: $0 type_root_dir"
exit -1
fi

IDEN=$(which identify)

type_root_dir=$1
cur_dir=$PWD

cd $type_root_dir
for file in *
do
if [ -d $file ]
then
nImages=$(ls $file | wc -l)
if [ -e $file/image1.jpg ]
then
imW=$($IDEN -verbose $file/image1.jpg | grep Geometry | awk '{print $2}' | cut -d'x' -f1)
imH=$($IDEN -verbose $file/image1.jpg | grep Geometry | awk '{print $2}' | cut -d'x' -f2)
echo "$file $nImages $imW $imH"
else
echo "$file $nImages"
fi
fi
done

cd $cur_dir
