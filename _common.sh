# shellcheck shell=bash

experiment_path=my_experiment
common_train_stage1_args="
  --use_cuda --split_segments --use_pe_tgt
  --step_size 400
  --do_timing
  --do_framewise_loss
  --do_framewise_loss_g
  --framewise_loss_g_apply_nothing
  --do_segwise_loss
  --do_segwise_loss_g
  --segwise_loss_g_apply_logsoftmax
  --do_crossattention_action_loss_nll
  --experiment_path $experiment_path
"
common_train_stage2_args="
  --use_cuda --split_segments --use_pe_tgt
  --do_timing
  --use_alignment_dec
  --do_crossattention_dur_loss_ce
  --aug_rnd_drop
  --experiment_path $experiment_path
"
