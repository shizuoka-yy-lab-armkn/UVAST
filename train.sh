#!/usr/bin/env bash
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

#------------------------------------------------
# constants
experiment_path=my_experiment
common_train_stage1_args="
  --use_cuda --split_segments --use_pe_tgt
  --step_size 400
  --do_framewise_loss
  --do_framewise_loss_g
  --framewise_loss_g_apply_nothing
  --do_segwise_loss
  --do_segwise_loss_g
  --segwise_loss_g_apply_logsoftmax
  --do_crossattention_action_loss_nll
  --data_root $data_root
  --experiment_path $experiment_path
"
common_train_stage2_args="
  --use_cuda --split_segments --use_pe_tgt
  --use_alignment_dec
  --do_crossattention_dur_loss_ce
  --aug_rnd_drop
  --data_root $data_root
  --experiment_path $experiment_path
"

log_file="${stage}/logs/${dataset_name}/$split".log
mkdir -p "$(dirname "$log_file")"

case "$stage" in
  stage1)
    python run.py \
      ${common_train_stage1_args} \
      --dataset "$dataset_name" \
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
      --split "$splitID" \
      --exp_name "$stage" \
      --pretrained_model "$pretrained_model_path" \
      | tee "$log_file"
    ;;

  *)
    echo "Invalid name of stage: $stage"
    exit 1
esac
