MODEL_GTEA_SPLIT1_STAGE1 := pretrained_models/gtea/gtea_split1_stage1.model
MODEL_GTEA_SPLIT1_STAGE2 := pretrained_models/gtea/gtea_split1_stage2.model
DATA_ROOT := /data/k.nakamura/UVAST-data
EXPERIMENT_PATH := my_experiment

COMMON_EVAL_ARGS := --use_cuda --inference_only --split_segments --use_pe_tgt --data_root $(DATA_ROOT) --data_root_mean_duration $(DATA_ROOT)

YMC_DATASET_NAME := ymc_ab_0614
BIKE_BOTSU_DATASET_NAME := bike_master_botsu_0614

COMMON_TRAIN_STAGE1_ARGS := --use_cuda --split_segments --use_pe_tgt \
		--step_size 800 \
		--do_framewise_loss \
		--do_framewise_loss_g \
		--framewise_loss_g_apply_nothing \
		--do_segwise_loss \
		--do_segwise_loss_g \
		--segwise_loss_g_apply_logsoftmax \
		--do_crossattention_action_loss_nll \
		--data_root $(DATA_ROOT) \
		--experiment_path $(EXPERIMENT_PATH)

COMMON_TRAIN_STAGE2_ARGS := --use_cuda --split_segments --use_pe_tgt \
	--use_alignment_dec \
	--do_crossattention_dur_loss_ce \
	--aug_rnd_drop \
	--data_root $(DATA_ROOT) \
	--experiment_path $(EXPERIMENT_PATH)


pre.compute-mean-duration:
	python compute_mean_dur.py --data_root $(DATA_ROOT)

#### split1
train.bike_botsu.split1.stage1:
	@mkdir -p $(EXPERIMENT_PATH)/bike_botsu_stage1
	python run.py \
		$(COMMON_TRAIN_STAGE1_ARGS) \
		--dataset $(BIKE_BOTSU_DATASET_NAME) \
		--split 1 \
		--exp_name bike_botsu_stage1 \
		| tee $(EXPERIMENT_PATH)/bike_botsu_stage1/split1.log

train.bike_botsu.split1.stage2:
	@mkdir -p $(EXPERIMENT_PATH)/bike_botsu_stage2
	python run.py \
		$(COMMON_TRAIN_STAGE2_ARGS) \
		--dataset $(BIKE_BOTSU_DATASET_NAME) \
		--split 1 \
		--exp_name bike_botsu_stage2 \
		--pretrained_model ./bike_botsu_stage1/model/bike_master_botsu_0614/split_1/epoch-115.model \
		| tee $(EXPERIMENT_PATH)/bike_botsu_stage2/split1.log

#### split3
train.bike_botsu.split3.stage1:
	@mkdir -p $(EXPERIMENT_PATH)/bike_botsu_stage1
	python run.py \
		$(COMMON_TRAIN_STAGE1_ARGS) \
		--dataset $(BIKE_BOTSU_DATASET_NAME) \
		--split 3 \
		--exp_name bike_botsu_stage1 \
		| tee $(EXPERIMENT_PATH)/bike_botsu_stage1/split3.log

train.bike_botsu.split3.stage2:
	@mkdir -p $(EXPERIMENT_PATH)/bike_botsu_stage2
	python run.py \
		$(COMMON_TRAIN_STAGE2_ARGS) \
		--dataset $(BIKE_BOTSU_DATASET_NAME) \
		--split 3 \
		--exp_name bike_botsu_stage2 \
		--pretrained_model ./bike_botsu_stage1/model/bike_master_botsu_0614/split_3/epoch-149.model
		| tee $(EXPERIMENT_PATH)/bike_botsu_stage2/split3.log

train.ymc.split1.stage1:
	python run.py \
		$(COMMON_TRAIN_STAGE1_ARGS) \
		--dataset $(YMC_DATASET_NAME) \
		--split 1 \
		--exp_name ymc_stage1 \
		| tee $(EXPERIMENT_PATH)/ymc_stage1/split1.log

train.ymc.split2.stage1:
	python run.py \
		$(COMMON_TRAIN_STAGE1_ARGS) \
		--dataset $(YMC_DATASET_NAME) \
		--split 2 \
		--exp_name ymc_stage1 \
		| tee $(EXPERIMENT_PATH)/ymc_stage1/split2.log

train.ymc.split3.stage1:
	python run.py \
		$(COMMON_TRAIN_STAGE1_ARGS) \
		--dataset $(YMC_DATASET_NAME) \
		--split 3 \
		--exp_name ymc_stage1 \
		| tee $(EXPERIMENT_PATH)/ymc_stage1/split3.log

train.ymc.split4.stage1:
	python run.py \
		$(COMMON_TRAIN_STAGE1_ARGS) \
		--dataset $(YMC_DATASET_NAME) \
		--split 4 \
		--exp_name ymc_stage1 \
		| tee $(EXPERIMENT_PATH)/ymc_stage1/split4.log

######################################################
# stage2
train.ymc.split1.stage2:
	mkdir -p $(EXPERIMENT_PATH)/ymc_stage2
	python run.py \
		$(COMMON_TRAIN_STAGE2_ARGS) \
		--dataset $(YMC_DATASET_NAME) \
		--split 1 \
		--exp_name ymc_stage2 \
		--pretrained_model ./my_experiment/ymc_stage1/model/ymc_ab_0614/split_1/epoch-117.model \
		| tee $(EXPERIMENT_PATH)/ymc_stage2/split1.log


train.ymc.split2.stage2:
	mkdir -p $(EXPERIMENT_PATH)/ymc_stage2
	python run.py \
		$(COMMON_TRAIN_STAGE2_ARGS) \
		--dataset $(YMC_DATASET_NAME) \
		--split 2 \
		--exp_name ymc_stage2 \
		--pretrained_model ./my_experiment/ymc_stage1/model/ymc_ab_0614/split_2/epoch-137.model \
		| tee $(EXPERIMENT_PATH)/ymc_stage2/split2.log


train.ymc.split3.stage2:
	mkdir -p $(EXPERIMENT_PATH)/ymc_stage2
	python run.py \
		$(COMMON_TRAIN_STAGE2_ARGS) \
		--dataset $(YMC_DATASET_NAME) \
		--split 3 \
		--exp_name ymc_stage2 \
		--pretrained_model ./my_experiment/ymc_stage1/model/ymc_ab_0614/split_3/epoch-185.model \
		| tee $(EXPERIMENT_PATH)/ymc_stage2/split3.log


train.ymc.split4.stage2:
	mkdir -p $(EXPERIMENT_PATH)/ymc_stage2
	python run.py \
		$(COMMON_TRAIN_STAGE2_ARGS) \
		--dataset $(YMC_DATASET_NAME) \
		--split 4 \
		--exp_name ymc_stage2 \
		--pretrained_model ./my_experiment/ymc_stage1/model/ymc_ab_0614/split_4/epoch-84.model \
		| tee $(EXPERIMENT_PATH)/ymc_stage2/split4.log


eval.gtea.stage1:
	python run.py \
		$(COMMON_EVAL_ARGS) \
		--dataset gtea \
		--split 1 \
		--path_inference_model $(MODEL_GTEA_SPLIT1_STAGE1)

eval.gtea.stage1.viterbi:
	python run.py \
		$(COMMON_EVAL_ARGS) \
		--dataset gtea \
		--split 1 \
		--use_viterbi \
		--viterbi_sample_rate 1 \
		--path_inference_model $(MODEL_GTEA_SPLIT1_STAGE1)

eval.gtea.stage2.alignment-decoder:
	python run.py \
		$(COMMON_EVAL_ARGS) \
		--dataset gtea \
		--split 1 \
		--path_inference_model $(MODEL_GTEA_SPLIT1_STAGE2) \
		--use_alignment_dec

eval.gtea.stage2.fifa:
	python run.py \
		$(COMMON_EVAL_ARGS) \
		--dataset gtea \
		--split 1 \
		--use_fifa \
		--fifa_init_dur \
		--path_inference_model $(MODEL_GTEA_SPLIT1_STAGE2) \
		--use_alignment_dec
