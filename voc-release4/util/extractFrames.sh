#!/bin/bash

if [ $# != 1 ]
then
echo "Usage: $0 type_root_dir"
exit -1
fi

type_root_dir=$1
cur_dir=$PWD

cd $type_root_dir
for file in *mp4
do
name=$(echo $file | cut -d'.' -f1)
mkdir $name
ffmpeg -i $file $name/image%d.jpg
rm $file
done

cd $cur_dir
