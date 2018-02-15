import json
import argparse

def main():
	convertToJson()

def convertToJson():
	parser = argparse.ArgumentParser(description='obtain file locations')
	# parser.add_argument('-pred', type=str, default=None, required=True, help='predicted translation file')
	# parser.add_argument('-gold', type=str, default=None, required=True, help='gold translations file')
	# parser.add_argument('-caption_train', type=str, default=None, required=True, help='file for caption generator training data')
	# parser.add_argument('-n_best', type=int, default=1, required=True, help='number of predicted translations per source')
	parser.add_argument('-caption_train_json', type=str, default=None, help='output json file')
	# parser.add_argument('-gold', type=str, default=None, help='gold translations file')
	parser.add_argument('-caption_train_merged', type=str, default=None, help='file for caption train_merged')
	parser.add_argument('-n_captions', type=int, default=1, help='number of captions per image')


	args = parser.parse_args()

	# caption_train_json = args.caption_train_json

	# caption_train_merged = args.caption_train_merged
	# caption_val_merged = args.caption_val_merged
	# caption_test = args.caption_test

	caption_train_json = "./caption_train/CAPTION_TRAIN_JSON"

	caption_val_merged = "./caption_train/BRNN_0.3_de_2016.de_VAL_NBest_MERGED.lc.norm.tok"
	caption_train_merged = "./caption_train/BRNN_0.3_de_2016.de_NBest_MERGED.lc.norm.tok"
	caption_test = "./caption_train/TEST_NBest.lc.norm.tok"

	n_captions = args.n_captions
	train_img_list =  "./train_img_list.txt"
	val_img_list =  "./val_img_list.txt"
	test_img_list =  "./test_img_list.txt"


	with open(caption_train_merged) as file:
		train_data = file.read().splitlines()
	with open(caption_val_merged) as file:
		val_data = file.read().splitlines()
	with open(caption_test) as file:
		test_data = file.read().splitlines()
	with open(train_img_list) as file:
		train_img_list = file.read().splitlines()
	with open(val_img_list) as file:
		val_img_list = file.read().splitlines()
	with open(test_img_list) as file:
		test_img_list = file.read().splitlines()

	print(len(train_data))
	print(len(train_img_list))
	print(len(val_data))
	print(len(val_img_list))
	print(len(test_data))
	print(len(test_img_list))
	assert(len(train_data) == 5 * len(train_img_list))
	assert(len(val_data) == 5 * len(val_img_list))
	assert(len(test_data) == 5 * len(test_img_list))


	train = {}
	train["images"] = []
	train["dataset"] = "flickr30k"

	# print("images")
	# print(len(img_list))
	# print(len(train_data))


	image = {}
	n=0
	i=0
	print("Train data")
	while i < len(train_img_list):
		#read image number

		image["sentids"] = []
		image["imgid"] = i
		image["sentences"] = []
		image["split"] = "train"
		image["filename"] = train_img_list[i]

		# image["sentids"].append(i)

		for j in range(n_captions):
			# print(n)
			caption = train_data[n]
			words = caption.split()

			if "." in words:
				words.remove(".")
			sentence = {}
			sentence["tokens"] = words
			sentence["raw"] = caption
			sentence["imgid"] = i
			sentence["sentid"] = n

			image["sentids"].append(n)
			image["sentences"].append(sentence)
			n += 1

		train["images"].append(image)
		i +=1

	n=0
	i=0
	print("Val data")

	while i < len(val_img_list):
		#read image number

		image["sentids"] = []
		image["imgid"] = i + len(train_img_list)
		image["sentences"] = []
		image["split"] = "val"
		image["filename"] = val_img_list[i]

		# image["sentids"].append(i)

		for j in range(n_captions):
			# print(n)
			caption = val_data[n]
			words = caption.split()
			if "." in words:
				words.remove(".")

			sentence = {}
			sentence["tokens"] = words
			sentence["raw"] = caption
			sentence["imgid"] = i + len(train_img_list)
			sentence["sentid"] = n + len(train_img_list)

			image["sentids"].append(n + len(train_img_list))
			image["sentences"].append(sentence)
			n += 1

		train["images"].append(image)
		i +=1

	n=0
	i=0
	print("Test data")

	while i < len(test_img_list):
		#read image number

		image["sentids"] = []
		image["imgid"] = i + len(train_img_list) + len(val_img_list)
		image["sentences"] = []
		image["split"] = "test"
		image["filename"] = test_img_list[i]

		# image["sentids"].append(i+ len(train_img_list) + len(val_img_list))

		for j in range(n_captions):
			# print(n)
			caption = test_data[n]
			words = caption.split()
			if "." in words:
				words.remove(".")

			sentence = {}
			sentence["tokens"] = words
			sentence["raw"] = caption
			sentence["imgid"] = i + len(train_img_list) + len(val_img_list)
			sentence["sentid"] = n + len(train_img_list) + len(val_img_list)

			image["sentids"].append(n + len(train_img_list) + len(val_img_list))
			image["sentences"].append(sentence)
			n += 1

		train["images"].append(image)
		i +=1

	with open(caption_train_json, 'w+') as fp:
		json.dump(train, fp, indent=4)

if __name__ == '__main__':
	main()
