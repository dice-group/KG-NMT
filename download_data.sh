#!/usr/bin/env bash

DATADIR=data
SOURCE_LANGUAGE="$1"
TARGET_LANGUAGE="$2"

if !([[ "$SOURCE_LANGUAGE" == "en" ]] && [[ "$TARGET_LANGUAGE" == "de" ]]) && !([[ "$SOURCE_LANGUAGE" == "de" ]] && [[ "$TARGET_LANGUAGE" == "en" ]]); then
  echo "Currently, only a combination of German('de') and English('en') is supported."
  exit 1;
fi

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

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/train/general.tok.lc.train.$SOURCE_LANGUAGE $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/train/source.$SOURCE_LANGUAGE ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/train/general.tok.lc.train.$TARGET_LANGUAGE $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/train/target.$TARGET_LANGUAGE ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/dev/general.tok.lc.dev.$SOURCE_LANGUAGE $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/dev/source.$SOURCE_LANGUAGE ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/dev/general.tok.lc.dev.$TARGET_LANGUAGE $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/dev/target.$TARGET_LANGUAGE ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/test/general.tok.lc.test.$SOURCE_LANGUAGE $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/test/source.$SOURCE_LANGUAGE ;

mv $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/test/general.tok.lc.test.$TARGET_LANGUAGE $DATADIR/$SOURCE_LANGUAGE-$TARGET_LANGUAGE/training_data/test/target.$TARGET_LANGUAGE ;

rm -rf hobbitdata.informatik.uni-leipzig.de;
