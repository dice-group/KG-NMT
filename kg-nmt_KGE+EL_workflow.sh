OPEN_NMT_PATH=$HOME/OpenNMT-py
DATA_PATH=../data
SRC_LAN=en
TGT_LAN=de
TRAIN_PATH=$DATA_PATH/training_data/$SRC_LAN-$TGT_LAN
TEST_PATH=$DATA_PATH/testsets/$SRC_LAN-$TGT_LAN

mkdir -p $DATA_PATH/nmt_model $TRAIN_PATH/preprocessed

# Tokenize


# Pre-processing
echo "Pre-processing"
python3 $OPEN_NMT_PATH/preprocess.py \
    -train_src $TRAIN_PATH/source.$SRC_LAN-$TGT_LAN.train.$SRC_LAN.atok \
    -train_tgt $TRAIN_PATH/target.$SRC_LAN-$TGT_LAN.train.$TGT_LAN.atok \
    -valid_src $TRAIN_PATH/source.$SRC_LAN-$TGT_LAN.dev.$SRC_LAN.atok \
    -valid_tgt $TRAIN_PATH/target.$SRC_LAN-$TGT_LAN.dev.$TGT_LAN.atok \
    -save_data $TRAIN_PATH/preprocessed/training-data-$SRC_LAN-$TGT_LAN.atok.low \
    -lower


# KGE 


# Training
echo "Training"
python3 $OPEN_NMT_PATH/train.py \
    -data $TRAIN_PATH/preprocessed/training-data-$SRC_LAN-$TGT_LAN.atok.low \
    -save_model $DATA_PATH/nmt_model/nmt_model \
    -gpuid 0 \
    -word_vec_size 300 \
    -pre_word_vecs_enc vectors-en-torch.enc.pt \
    -pre_word_vecs_dec vectors-en-torch.dec.pt

# Testing
echo "Testing"
python3 $OPEN_NMT_PATH/translate.py \
    -gpu 0 \
    -model $DATA_PATH/nmt_model/nmt_model_*_e13.pt \
    -src $TEST_PATH/source.$SRC_LAN-$TGT_LAN.test-a.$SRC_LAN.atok \
    -tgt $TEST_PATH/target.$SRC_LAN-$TGT_LAN.test-a.$TGT_LAN.atok \
    -replace_unk \
    -output $TEST_PATH/hypothesis.$SRC_LAN-$TGT_LAN.test.output

# MT automatic
echo "BLEU + METEOR + CHRF"

