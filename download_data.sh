#!/usr/bin/env bash

DATADIR=data
SOURCE_LANGUAGE="$1"
TARGET_LANGUAGE="$2"


if [ ! -d "$DATADIR" ]; then
  mkdir -p $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE
  mkdir -p $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/models
  mkdir -p $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data
  mkdir -p $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/testsets
  mkdir -p $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/preprocessed 
fi


echo "Download the data used in the K-CAP paper "


if [ ! -f "$DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/train" ]; then
	echo "Downloading $1"
	wget -r --no-parent https://hobbitdata.informatik.uni-leipzig.de/KG-NMT/resources/data/general_files/#tokenized_openNMT ;
fi

mv hobbitdata.informatik.uni-leipzig.de/KG-NMT/resources/data/general_files/tokenized_openNMT/train $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/ ;

mv hobbitdata.informatik.uni-leipzig.de/KG-NMT/resources/data/general_files/tokenized_openNMT/dev $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/ ;

mv hobbitdata.informatik.uni-leipzig.de/KG-NMT/resources/data/general_files/tokenized_openNMT/test $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/ ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/train/general.tok.lc.train.en $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/train/source.en ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/train/general.tok.lc.train.de $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/train/target.de ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/dev/general.tok.lc.dev.en $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/dev/source.en ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/dev/general.tok.lc.dev.de $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/dev/target.de ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/test/general.tok.lc.test.en $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/test/source.en ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/test/general.tok.lc.test.de $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/test/target.de ;

rm -rf hobbitdata.informatik.uni-leipzig.de;
