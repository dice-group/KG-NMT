#!/usr/bin/env bash
OPEN_NMT_PATH=OpenNMT-py
DATA_PATH=data
SRC_LAN=$1
TGT_LAN=$2
TRAIN_PATH=$DATA_PATH/$SRC_LAN-$TGT_LAN
MODEL_PATH=$DATA_PATH/models
TEST_PATH=$DATA_PATH/$SRC_LAN-$TGT_LAN/testsets

if !([[ "$SRC_LAN" == "en" ]] && [[ "$TGT_LAN" == "de" ]]) && !([[ "$SRC_LAN" == "de" ]] && [[ "$TGT_LAN" == "en" ]]); then
  echo "Currently, only a combination of German('de') and English('en') is supported."
  exit 1;
fi
#mkdir -p $DATA_PATH/nmt_model $TRAIN_PATH/preprocessed


# Pre-processing
echo "Pre-processing"
python3 $OPEN_NMT_PATH/preprocess.py \
    -train_src $TRAIN_PATH/training_data/train/source.$SRC_LAN \
    -train_tgt $TRAIN_PATH/training_data/train/target.$TGT_LAN \
    -valid_src $TRAIN_PATH/training_data/dev/source.$SRC_LAN \
    -valid_tgt $TRAIN_PATH/training_data/dev/target.$TGT_LAN \
    -src_seq_length 80 -tgt_seq_length 80 \
    -save_data $TRAIN_PATH/preprocessed/training-data-$SRC_LAN-$TGT_LAN
echo "Pre-processing done"
# KGE 
echo "Generating KGE"
./SemKGE_creation.sh $SRC_LAN
./SemKGE_creation.sh $TGT_LAN

python3 $OPEN_NMT_PATH/embeddings_to_torch.py -emb_file_enc KGE/$SRC_LAN/all_"$SRC_LAN"_model.vec -emb_file_dec KGE/$TGT_LAN/all_"$TGT_LAN"_model.vec -type word2vec -dict_file $TRAIN_PATH/preprocessed/training-data-"$SRC_LAN-$TGT_LAN".vocab.pt -output_file $TRAIN_PATH/preprocessed/all_kge_"$SRC_LAN-$TGT_LAN"_emb

echo "KGE Generation done"

# Training
echo "Training"

python3  $OPEN_NMT_PATH/train.py -data $TRAIN_PATH/preprocessed/training-data-"$SRC_LAN-$TGT_LAN" -save_model $TRAIN_PATH/models/"$SRC_LAN-$TGT_LAN"+graph -word_vec_size 500 -pre_word_vecs_enc $TRAIN_PATH/preprocessed/all_kge_"$SRC_LAN-$TGT_LAN"_emb.enc.pt -pre_word_vecs_dec $TRAIN_PATH/preprocessed/all_kge_"$SRC_LAN-$TGT_LAN"_emb.dec.pt -feat_merge concat -encoder_type brnn -decoder_type rnn -gpu_rank 0 -train_steps 410000 

# Testing
echo "Testing"
python3 $OPEN_NMT_PATH/translate.py  -gpu 0 -model $TRAIN_PATH/models/$SRC_LAN-$TGT_LAN+graph_step_410000.pt -src $TRAIN_PATH/training_data/test/source.$SRC_LAN  -tgt $TRAIN_PATH/training_data/test/target.$TGT_LAN -replace_unk -output $TRAIN_PATH/training_data/test/hypo.$SRC_LAN-$TGT_LAN.test.output

# MT automatic
echo "BLEU + METEOR + CHRF"

#BLEU - most used metric for MT, word overlap	
perl mt_metrics/multi-bleu.perl  $TRAIN_PATH/training_data/test/hypo.$SRC_LAN-$TGT_LAN.test.output < $TRAIN_PATH/training_data/test/target.$TGT_LAN
	
#METEOR - kind of stem overlap	
java -Xmx2G -jar mt_metrics/meteor-1.5/meteor-1.5.jar $TRAIN_PATH/training_data/test/hypo.$SRC_LAN-$TGT_LAN.test.output $TRAIN_PATH/training_data/test/target.$TGT_LAN -norm -l de	
	
#chrF - character based metric	
python3 mt_metrics/chrF/chrF.py -b 3 -H $TRAIN_PATH/training_data/test/hypo.$SRC_LAN-$TGT_LAN.test.output -R $TRAIN_PATH/training_data/test/target.$TGT_LAN
