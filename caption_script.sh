#! /bin/bash
#preprocess

# for l in en de fr; do for f in data/multi30k/*.$l; do perl tokenizer.perl -a -no-escape -l $l -q  < $f > $f.atok; done; done
# python preprocess.py -train_src data/multi30k/train.en.atok -train_tgt data/multi30k/train.de.atok -valid_src data/multi30k/val.en.atok -valid_tgt data/multi30k/val.de.atok -save_data data/multi30k_de.atok.low -lower

# python preprocess.py -train_src data/multi30k/train.en.atok -train_tgt data/multi30k/train.fr.atok -valid_src data/multi30k/val.en.atok -valid_tgt data/multi30k/val.fr.atok -save_data data/multi30k_fr.atok.low -lower


I=$1

echo "I is $1"
#Variables

declare -a TRAIN_DATA=(multi30k_de.atok.low multi30k_fr.atok.low)

DROPOUT=0.3
LAYERS=2
ENCODER=brnn
DECODER=rnn

MODEL_TYPE=BRNN_${DROPOUT}

declare -a OUTPUT=(2016.de 2016.fr 2017_flickr.de 2017_flickr.fr 2017_mscoco.de 2017_mscoco.fr)

MODEL_DE=${MODEL_TYPE}_de
MODEL_FR=${MODEL_TYPE}_fr

declare -a GOLD=(test_2016_fixed.de.lc.norm.tok test_2016_fixed.fr.lc.norm.tok test_2017_flickr.de.lc.norm.tok test_2017_flickr.fr.lc.norm.tok test_2017_mscoco.de.lc.norm.tok test_2017_mscoco.fr.lc.norm.tok)

declare -a SRC=(test_2016_fixed.en.lc.norm.tok test_2016_fixed.en.lc.norm.tok test_2017_flickr.en.lc.norm.tok test_2017_flickr.en.lc.norm.tok test_2017_mscoco.en.lc.norm.tok test_2017_mscoco.en.lc.norm.tok)

GPU=2
N_BEST=4
N_CAPTIONS=5

declare -a MODEL=($MODEL_DE $MODEL_FR $MODEL_DE $MODEL_FR $MODEL_DE $MODEL_FR)
declare -a TRAIN=(train.de.atok.lc train.fr.atok.lc train.de.atok.lc train.fr.atok.lc train.de.atok.lc train.fr.atok.lc)
declare -a VAL=(val.de.atok.lc val.fr.atok.lc val.de.atok.lc val.fr.atok.lc val.de.atok.lc val.fr.atok.lc)
declare -a TEST=OUTPUT


cd ~/OpenNMT-py

#Train for de, fr:
# if [[ I -eq 0 ]]; then
#   for index in 0 1
#   do
#   	python train.py -data data/${TRAIN_DATA[$index]} -save_model trained_models/${MODEL[$index]} -gpuid $GPU -encoder_type $ENCODER -decoder_type $DECODER -dropout $DROPOUT -layers $LAYERS
#   done
# fi

#Test for 6 datasets:

index=I
PRED_TRAIN=${MODEL[$index]}_${OUTPUT[$index]}_NBest
PRED_VAL=${MODEL[$index]}_${OUTPUT[$index]}_VAL_NBest
PRED_TEST=${MODEL[$index]}_${OUTPUT[$index]}_TEST_NBest

PRED=$PRED_VAL
CAPTION_TRAIN_MERGED=${PRED}_MERGED
CAPTION_TRAIN_JSON=${PRED}_JSON
SRC_TGT_PRED=overview_$PRED


echo "OVERVIEW FILE = $SRC_TGT_PRED"
echo "MODEL = ${MODEL[$index]}"
echo "SRC = ${SRC[$index]}"
echo "GOLD = ${GOLD[$index]}"
echo "OUTPUT = $PRED"

# #generate nbest for train data
# perl ../preprocessing/lowercase.perl < data/multi30k/train.en.atok > data/multi30k/train.en.atok.lc
# perl ../preprocessing/lowercase.perl < data/multi30k/train.de.atok > data/multi30k/train.de.atok.lc
# perl ../preprocessing/lowercase.perl < data/multi30k/train.fr.atok > data/multi30k/train.fr.atok.lc
#generate nbest for val data
# perl ../preprocessing/lowercase.perl < data/multi30k/val.en.atok > data/multi30k/val.en.atok.lc
# perl ../preprocessing/lowercase.perl < data/multi30k/val.de.atok > data/multi30k/val.de.atok.lc
# perl ../preprocessing/lowercase.perl < data/multi30k/val.fr.atok > data/multi30k/val.fr.atok.lc
# #generate nbest for val data
# perl ../preprocessing/lowercase.perl < data/multi30k/test2016.en.atok > data/multi30k/test2016.en.atok.lc
# perl ../preprocessing/lowercase.perl < data/multi30k/test2016.de.atok > data/multi30k/test2016.de.atok.lc
# perl ../preprocessing/lowercase.perl < data/multi30k/test2016.fr.atok > data/multi30k/test2016.fr.atok.lc


# python translate.py -gpu $GPU -model trained_models/${MODEL[$index]}_*_e13.pt -src data/multi30k/train.en.atok -tgt data/multi30k/${TRAIN[$index]} -replace_unk -verbose -output pred_files/$PRED_TRAIN -n_best $N_BEST
#
# python translate.py -gpu $GPU -model trained_models/${MODEL[$index]}_*_e13.pt -src data/multi30k/val.en.atok -tgt data/multi30k/${VAL[$index]} -replace_unk -verbose -output pred_files/$PRED_VAL -n_best $N_BEST

# python translate.py -gpu $GPU -model trained_models/${MODEL[$index]}_*_e13.pt -src data/multi30k/test2016.en.atok -tgt data/multi30k/${GOLD[$index]} -replace_unk -verbose -output pred_files/$PRED_TEST -n_best 5
# CAPTION_TRAIN_MERGED=VAL_NBest
python CaptionTrainMerger.py -pred pred_files/$PRED -gold data/multi30k/${VAL[$index]} -caption_train caption_train/$CAPTION_TRAIN_MERGED -n_best $N_BEST
#
# CAPTION_TRAIN_MERGED=TEST_NBest
# perl ../preprocessing/lowercase.perl < pred_files/$PRED_TEST > caption_train/$CAPTION_TRAIN_MERGED.lc
#
# perl ../preprocessing/normalize-punctuation.perl -l de < caption_train/$CAPTION_TRAIN_MERGED.lc > caption_train/$CAPTION_TRAIN_MERGED.lc.norm
#
# perl ../preprocessing/tokenizer.perl -l de < caption_train/$CAPTION_TRAIN_MERGED.lc.norm > caption_train/$CAPTION_TRAIN_MERGED.lc.norm.tok
perl ../preprocessing/lowercase.perl < caption_train/$CAPTION_TRAIN_MERGED > caption_train/$CAPTION_TRAIN_MERGED.lc

perl ../preprocessing/normalize-punctuation.perl -l de < caption_train/$CAPTION_TRAIN_MERGED.lc > caption_train/$CAPTION_TRAIN_MERGED.lc.norm

perl ../preprocessing/tokenizer.perl -l de < caption_train/$CAPTION_TRAIN_MERGED.lc.norm > caption_train/$CAPTION_TRAIN_MERGED.lc.norm.tok

# python CaptionTrainJSONGenerator.py -caption_train_merged caption_train/$CAPTION_TRAIN_MERGED -caption_train_json caption_train/${CAPTION_TRAIN_JSON}.json -n_captions $N_CAPTIONS

#generate nbest for test data

# python translate.py -gpu $GPU -model trained_models/${MODEL[$index]}_*_e13.pt -src data/multi30k/${SRC[$index]} -tgt data/multi30k/${GOLD[$index]} -replace_unk -verbose -output pred_files/$PRED -n_best $N_BEST

# cd ../evaluating/multieval
#
# ./multeval.sh eval --refs ../../OpenNMT-py/pred_files/$PRED.lc.norm.tok \
#                    --hyps-baseline ../../OpenNMT-py/data/multi30k/${GOLD[$index]} \
#                    --meteor.language de \
#                    > ../../OpenNMT-py/eval_results/$PRED.multeval
#
# java -Xmx2G -jar ../meteor-1.5/meteor-*.jar ../../OpenNMT-py/pred_files/$PRED.lc.norm.tok ../../OpenNMT-py/data/multi30k/${GOLD[$index]} -l de \
# 	> ../../OpenNMT-py/eval_results/$PRED.meteor

exit 0
