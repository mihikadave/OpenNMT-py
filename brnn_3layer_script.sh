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
LAYERS=3
ENCODER=brnn
DECODER=rnn

MODEL_TYPE=${ENCODER}_${LAYERS}layer

declare -a OUTPUT=(2016.de 2016.fr 2017_flickr.de 2017_flickr.fr 2017_mscoco.de 2017_mscoco.fr)

MODEL_DE=${MODEL_TYPE}_de
MODEL_FR=${MODEL_TYPE}_fr

declare -a GOLD=(test_2016_fixed.de.lc.norm.tok test_2016_fixed.fr.lc.norm.tok test_2017_flickr.de.lc.norm.tok test_2017_flickr.fr.lc.norm.tok test_2017_mscoco.de.lc.norm.tok test_2017_mscoco.fr.lc.norm.tok)

declare -a SRC=(test_2016_fixed.en.lc.norm.tok test_2016_fixed.en.lc.norm.tok test_2017_flickr.en.lc.norm.tok test_2017_flickr.en.lc.norm.tok test_2017_mscoco.en.lc.norm.tok test_2017_mscoco.en.lc.norm.tok)

GPU=1

declare -a MODEL=($MODEL_DE $MODEL_FR $MODEL_DE $MODEL_FR $MODEL_DE $MODEL_FR)


cd ~/OpenNMT-py

#Train for de, fr:
if [[ I -eq 0 ]]; then
  for index in 0 1
  do
  	python train.py -data data/${TRAIN_DATA[$index]} -save_model trained_models/${MODEL[$index]} -gpuid $GPU -encoder_type $ENCODER -decoder_type $DECODER -dropout $DROPOUT -layers $LAYERS
  done
fi



#Test for 6 datasets:
for index in I
# for index in 3 4 5
do
	PRED=${MODEL[$index]}_${OUTPUT[$index]}
	SRC_TGT_PRED=overview_$PRED

	echo "OVERVIEW FILE = $SRC_TGT_PRED"
	echo "MODEL = ${MODEL[$index]}"
	echo "SRC = ${SRC[$index]}"
	echo "GOLD = ${GOLD[$index]}"
	echo "OUTPUT = $PRED"

	# cat output_overview/${SRC_TGT_PRED};

	python translate.py -gpu $GPU -model trained_models/${MODEL[$index]}_*_e13.pt -src data/multi30k/${SRC[$index]} -tgt data/multi30k/${GOLD[$index]} -replace_unk -verbose -output pred_files/$PRED
	# > output_overview/${SRC_TGT_PRED}

	perl ../preprocessing/lowercase.perl < pred_files/$PRED > pred_files/$PRED.lc

	perl ../preprocessing/normalize-punctuation.perl -l de < pred_files/$PRED.lc > pred_files/$PRED.lc.norm

	perl ../preprocessing/tokenizer.perl -l de < pred_files/$PRED.lc.norm > pred_files/$PRED.lc.norm.tok

	cd ../evaluating/multieval

	./multeval.sh eval --refs ../../OpenNMT-py/pred_files/$PRED.lc.norm.tok \
	                   --hyps-baseline ../../OpenNMT-py/data/multi30k/${GOLD[$index]} \
	                   --meteor.language de \
	                   > ../../OpenNMT-py/eval_results/$PRED.multeval

	java -Xmx2G -jar ../meteor-1.5/meteor-*.jar ../../OpenNMT-py/pred_files/$PRED.lc.norm.tok ../../OpenNMT-py/data/multi30k/${GOLD[$index]} -l de \
		> ../../OpenNMT-py/eval_results/$PRED.meteor

done

exit 0
