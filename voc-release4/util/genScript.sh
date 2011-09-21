#!/bin/bash

if [ $# != 2 ]
then
    echo "Usage: $0 type mainDir"
    exit -1
fi

type=$1
mainDir=$2
if [ ! -d $mainDir ]
then
    echo "$mainDir does not exist!"
    exit
fi

outDir="."
if [ ! -d $outDir ]
then
    mkdir $outDir
fi
outFile1=$outDir/batch_$type""1.m
if [ -f $outFile1 ]
then
    rm $outFile1
fi
outFile2=$outDir/batch_$type""2.m
if [ -f $outFile2 ]
then
    rm $outFile2
fi

for ((i=1;i<=5;i++))
do
    videoDir=$mainDir/data/$type/$type$i
    if [ -d $videoDir ]
    then
        if [ ! -f $outFile1 ]
        then
            touch $outFile2
        fi
        resultDir=$mainDir/out/$type/$type$i
        echo "proc_video('$videoDir', '$resultDir', 'VOC2009/$type"_"final.mat', 5)" >> $outFile1
    fi
done

for ((i=6;i<=10;i++))
do
    videoDir=$mainDir/data/$type/$type$i
    if [ -d $videoDir ]
    then
        if [ ! -f $outFile1 ]
        then
            touch $outFile2
        fi
        resultDir=$mainDir/out/$type/$type$i
        echo "proc_video('$videoDir', '$resultDir', 'VOC2009/$type"_"final.mat', 5)" >> $outFile2
    fi
done
