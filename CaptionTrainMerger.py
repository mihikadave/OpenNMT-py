import json
import argparse

# pred_file = "multi30k.test2016.pred_2brnn_0.3_nbest.atok" #args.pred
# gold_file = "test_2016_fixed.de.lc.norm.tok" #args.gold
#
# merged_train_file = "test2016_caption_train" #args.caption_train
# n_best = 4 #args.n_best

def main():
	mergeFiles()
	# convertToJson()

def mergeFiles():
    parser = argparse.ArgumentParser(description='obtain file locations')
    # parser.add_argument('-pred', type=str, default=None, required=True, help='predicted translation file')
    # parser.add_argument('-gold', type=str, default=None, required=True, help='gold translations file')
    # parser.add_argument('-caption_train', type=str, default=None, required=True, help='file for caption generator training data')
    # parser.add_argument('-n_best', type=int, default=1, required=True, help='number of predicted translations per source')

    parser.add_argument('-pred', type=str, default=None, help='predicted translation file')
    parser.add_argument('-gold', type=str, default=None, help='gold translations file')
    parser.add_argument('-caption_train', type=str, default=None, help='file for caption generator training data')
    parser.add_argument('-n_best', type=int, default=1, help='number of predicted translations per source')


    args = parser.parse_args()

    pred_file = args.pred
    gold_file = args.gold
    merged_train_file = args.caption_train
    n_best = args.n_best
    n_captions = n_best + 1


    pred_data = []
    gold_data = []
    caption_train_data = []

    with open(pred_file) as file:
        pred_data = file.readlines()

    with open(gold_file) as file:
        gold_data = file.readlines()

	print(len(pred_data))
	print(len(gold_data))
    assert(len(pred_data) == 4 * len(gold_data))

    pred_counter = 0
    for gold in gold_data:
        caption_train_data.append(gold)
        for n in range(n_best):
            caption_train_data.append(pred_data[pred_counter + n])
        pred_counter += n_best


    with open(merged_train_file, "w+") as out_file:
        out_file.writelines(caption_train_data)
	print(len(caption_train_data))

if __name__ == '__main__':
	main()
