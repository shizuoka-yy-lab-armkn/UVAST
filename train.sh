#!/usr/bin/env bash
source ./_common.sh
set -euo pipefail


#------------------------------------------------
# parse args
if [[ $# -lt 4 ]]; then
  echo "Usage: $0 {dataset_dir_path} {splitX} {stageY} {epochs} [pretrained_model_path]"
  exit 1
fi

dataset_dir_path="$1"
split="$2"
stage="$3"
epochs="$4"

data_root="$(dirname "$dataset_dir_path")"
dataset_name="$(basename "$dataset_dir_path")"

splitID="$(echo "$split" | sed -E 's/^split([0-9]+)$/\1/')"
if [[ -z $splitID ]]; then
  echo "Invalid name of split: $split"
  exit 1
fi

log_file="${stage}/logs/${dataset_name}/$split".log
mkdir -p "$(dirname "$log_file")"

case "$stage" in
  stage1)
    python run.py \
      ${common_train_stage1_args} \
      --dataset "$dataset_name" \
      --data_root "$data_root" \
      --num_epochs "$epochs" \
      --split "$splitID" \
      --exp_name "$stage" \
      | tee "$log_file"
    ;;

  stage2)
    pretrained_model_path="$5"
    if [[ -z $pretrained_model_path ]]; then
      echo "Please specify pretrained_model_path"
      exit 1
    fi
    python run.py \
      ${common_train_stage2_args} \
      --dataset "$dataset_name" \
      --data_root "$data_root" \
      --split "$splitID" \
      --exp_name "$stage" \
      --pretrained_model "$pretrained_model_path" \
      | tee "$log_file"
    ;;

  *)
    echo "Invalid name of stage: $stage"
    exit 1
esac
