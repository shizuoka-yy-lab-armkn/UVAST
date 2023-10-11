#!/usr/bin/env bash
source ./_common.sh
set -euo pipefail

#------------------------------------------------
# parse args
if [[ $# -ne 5 ]]; then
	echo "Usage: $0 {dataset_dir_path} {splitX} {inference_model_path} {f1_labelwise_csv_path} {framewise_inference_result_dir}"
	exit 1
fi

dataset_dir_path="$1"
split="$2"
inference_model_path="$3"
f1_labelwise_csv_path="$4"
framewise_inference_result_dir="$5"

data_root="$(dirname "$dataset_dir_path")"
dataset_name="$(basename "$dataset_dir_path")"

splitID="$(echo "$split" | sed -E 's/^split([0-9]+)$/\1/')"
if [[ -z $splitID ]]; then
	echo "Invalid name of split: $split"
	exit 1
fi

python run.py \
	${common_train_stage2_args} \
	--dataset "$dataset_name" \
	--data_root "$data_root" \
	--split "$splitID" \
	--inference_only \
	--path_inference_model "$inference_model_path" \
	--f1_labelwise_csv_path "$f1_labelwise_csv_path" \
	--framewise_inference_result_dir "$framewise_inference_result_dir" \
  --debug \
  --save_frames_to_segment_assignment
