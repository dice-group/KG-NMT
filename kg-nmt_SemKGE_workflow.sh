OPEN_NMT_PATH=OpenNMT-py
DATA_PATH=data
SRC_LAN=en
TGT_LAN=de
TRAIN_PATH=$DATA_PATH/$SRC_LAN-$TGT_LAN
MODEL_PATH=$DATA_PATH/models
TEST_PATH=$DATA_PATH/$SRC_LAN-$TGT_LAN/testsets

#mkdir -p $DATA_PATH/nmt_model $TRAIN_PATH/preprocessed


# Pre-processing
echo "Pre-processing"
python3 $OPEN_NMT_PATH/preprocess.py \
    -train_src $TRAIN_PATH/training_data/train/source.$SRC_LAN \
    -train_tgt $TRAIN_PATH/training_data/train/target.$TGT_LAN \
    -valid_src $TRAIN_PATH/training_data/dev/source.$SRC_LAN \
    -valid_tgt $TRAIN_PATH/training_data/dev/target.$TGT_LAN \
    -save_data $TRAIN_PATH/preprocessed/training-data-$SRC_LAN-$TGT_LAN \

# KGE 

#if [ ! -f "fastText-0.9.1.zip" ]; then
#./SemKGE_creation.sh en
#if
#if [ ! -f "fastText-0.9.1.zip" ]; then
#./SemKGE_creation.sh de
#fi

python3 $OPEN_NMT_PATH/embeddings_to_torch.py -emb_file_enc KGE/$SRC_LAN/all_"$SRC_LAN"_model.vec -emb_file_dec KGE/$TGT_LAN/all_"$TGT_LAN"_model.vec -type word2vec -dict_file $TRAIN_PATH/preprocessed/training-data-"$SRC_LAN-$TGT_LAN".vocab.pt -output_file $TRAIN_PATH/preprocessed/all_kge_"$SRC_LAN-$TGT_LAN"_emb


# Training
echo "Training"

python3  $OPEN_NMT_PATH/train.py -data $TRAIN_PATH/preprocessed/training-data-"$SRC_LAN-$TGT_LAN" -save_model $TRAIN_PATH/models/"$SRC_LAN-$TGT_LAN"+graph -word_vec_size 500 -pre_word_vecs_enc $TRAIN_PATH/preprocessed/all_kge_"$SRC_LAN-$TGT_LAN"_emb.enc.pt -pre_word_vecs_dec $TRAIN_PATH/preprocessed/all_kge_"$SRC_LAN-$TGT_LAN"_emb.dec.pt -feat_merge sum -encoder_type brnn -decoder_type rnn -gpu_rank 0

# Testing
echo "Testing"
python3 $OPEN_NMT_PATH/translate.py  -gpu 0 -model $TRAIN_PATH/models/$SRC_LAN-$TGT_LAN+graph_*_e13.pt -src $TRAIN_PATH/training_data/test/source.$SRC_LAN  -tgt $TRAIN_PATH/training_data/test/target.$TGT_LAN -replace_unk -output $TRAIN_PATH/training_data/test/hypo.$SRC_LAN-$TGT_LAN.test.output

# MT automatic
#echo "BLEU + METEOR + CHRF"

BLEU - most used metric for MT, word overlap	
perl mt_metrics/scripts/multi-bleu.perl $TRAIN_PATH/training_data/test/target.$TGT_LAN < $TRAIN_PATH/training_data/test/hypo.$SRC_LAN-$TGT_LAN.test.output	
	
#METEOR - kind of stem overlap	
java -Xmx2G -jar/mt_metrics/meteor-1.5/meteor-1.5.jar $TRAIN_PATH/training_data/test/hypo.$SRC_LAN-$TGT_LAN.test.output $TRAIN_PATH/training_data/test/target.$TGT_LAN -norm -l de	
	
#chrF - character based metric	
python3 /mt_metrics/chrF/chrF.py -b 3 -H $TRAIN_PATH/training_data/test/hypo.$SRC_LAN-$TGT_LAN.test.output -R $TRAIN_PATH/training_data/test/target.$TGT_LAN
