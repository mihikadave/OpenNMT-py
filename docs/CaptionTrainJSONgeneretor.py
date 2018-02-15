import json

def main():
	convertToJson()

def convertToJson():

	parser = argparse.ArgumentParser(
            description='obtain file locations')
    # parser.add_argument('-pred', type=str, default=None, required=True, help='predicted translation file')
    # parser.add_argument('-gold', type=str, default=None, required=True, help='gold translations file')
    # parser.add_argument('-caption_train', type=str, default=None, required=True, help='file for caption generator training data')
    # parser.add_argument('-n_best', type=int, default=1, required=True, help='number of predicted translations per source')

    parser.add_argument('-caption_train_json', type=str, default=None, help='output json file')
    # parser.add_argument('-gold', type=str, default=None, help='gold translations file')
    parser.add_argument('-caption_train_merged', type=str, default=None, help='file for caption train_merged')
    parser.add_argument('-n_captions', type=int, default=1, help='number of captions per image')


    args = parser.parse_args()

	caption_train_json = args.caption_train_json
    caption_train_merged = args.caption_train_merged
    n_captions = args.n_captions
	train_img_list =  "./train_img_list.txt"

	with open(caption_train_merged) as file:
        train_data = caption_train_merged.readlines()
	with open(train_img_list) as file:
		img_list = train_img_list.readlines()

	train = {}
	train["images"] = []
	train["dataset"] = "flickr30k"

	n=0
	i=0
	while i < len(img_list):
		#read image number
		image = {}
		image["sentids"] = []
		image["imgid"] = i
		image["sentences"] = []
		image["split"] = "train"
		image["filename"] = img_list[i]

		image["sentids"].append(i)

		for j in range(n_captions):
			caption = train_data[n]
			words = caption.split()

			sentence = {}
			sentence["tokens"] = words
			sentence["raw"] = caption
			sentence["imgid"] = i
			sentence["sentid"] = n

			image["sentids"].append(n)
			image["sentences"].append(sentence)
			n += 1

		train["images"].append(image)

# 	i=0
# 	while i < len(train_data):
# 		#read image number
# 		image = {}
# 		image["sentids"] = []
# 		image["imgid"] = ??????
# 		image["sentences"] = []
# 		image["split"] = "train"
# 		image["filename"] = ???????
#
# 		image["sentids"].append(0)
#
# 		for j in range(n_captions):
# 			caption = train_data[i+j]
# 			words = caption.split()
# 			sentence = {}
# 			sentence["tokens"] = words
# 			sentence["raw"] = caption
# 			sentence["imgid"] = ?????
# 			sentence["sentid"] = i+j
#
# 			image["sentids"].append(i+j)
# 			image["sentences"].append(sentence)
# ,
# 		i += n_captions
# 		train["images"].append(image)

	with open(caption_train_json, 'w+') as fp:
	    json.dump(train, fp, indent=4)

if __name__ == '__main__':
	main()
