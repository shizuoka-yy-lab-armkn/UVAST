#!/usr/bin/python2.7
# code from https://github.com/yabufarha/ms-tcn/blob/master/eval.py (MIT License)
# yabufarha adapted it from: https://github.com/colincsl/TemporalConvolutionalNetworks/blob/master/code/metrics.py (MIT License)

import os
import numpy as np
import argparse


def read_file(path):
    with open(path, "r") as f:
        content = f.read()
        f.close()
    return content


def get_labels_start_end_time(frame_wise_labels, bg_class=["background"]):
    labels = []
    starts = []
    ends = []
    last_label = frame_wise_labels[0]
    if frame_wise_labels[0] not in bg_class:
        labels.append(frame_wise_labels[0])
        starts.append(0)
    for i in range(len(frame_wise_labels)):
        if frame_wise_labels[i] != last_label:
            if frame_wise_labels[i] not in bg_class:
                labels.append(frame_wise_labels[i])
                starts.append(i)
            if last_label not in bg_class:
                ends.append(i)
            last_label = frame_wise_labels[i]
    if last_label not in bg_class:
        ends.append(i)
    return labels, starts, ends


def levenstein(p, y, norm=False):
    m_row = len(p)
    n_col = len(y)
    D = np.zeros([m_row + 1, n_col + 1], float)
    for i in range(m_row + 1):
        D[i, 0] = i
    for i in range(n_col + 1):
        D[0, i] = i

    for j in range(1, n_col + 1):
        for i in range(1, m_row + 1):
            if y[j - 1] == p[i - 1]:
                D[i, j] = D[i - 1, j - 1]
            else:
                D[i, j] = min(D[i - 1, j] + 1, D[i, j - 1] + 1, D[i - 1, j - 1] + 1)

    if norm:
        score = (1 - D[-1, -1] / max(m_row, n_col)) * 100
    else:
        score = D[-1, -1]

    return score


def edit_score(recognized, ground_truth, norm=True, bg_class=["background"]):
    P, _, _ = get_labels_start_end_time(recognized, bg_class)
    Y, _, _ = get_labels_start_end_time(ground_truth, bg_class)
    return levenstein(P, Y, norm)


def f_score(recognized, ground_truth, overlap, bg_class=["background"]):
    p_label, p_start, p_end = get_labels_start_end_time(recognized, bg_class)
    y_label, y_start, y_end = get_labels_start_end_time(ground_truth, bg_class)

    tp = 0
    fp = 0

    hits = np.zeros(len(y_label))

    for j in range(len(p_label)):
        intersection = np.minimum(p_end[j], y_end) - np.maximum(p_start[j], y_start)
        union = np.maximum(p_end[j], y_end) - np.minimum(p_start[j], y_start)
        IoU = (1.0 * intersection / union) * ([p_label[j] == y_label[x] for x in range(len(y_label))])
        # Get the best scoring segment
        idx = np.array(IoU).argmax()

        if IoU[idx] >= overlap and not hits[idx]:
            tp += 1
            hits[idx] = 1
        else:
            fp += 1
    fn = len(y_label) - sum(hits)
    return float(tp), float(fp), float(fn)


def accuracy(recog_content, gt_content):
    correct = sum([1 for r, g in zip(recog_content, gt_content) if r == g])
    total = len(recog_content)
    return correct / total


def main(data_root, results_path, dataset, split):
    ground_truth_path = os.path.join(data_root, dataset, "groundTruth")
    recog_path = os.path.join(results_path, dataset, "split_" + split)
    file_list = os.path.join(data_root, dataset, "splits/test.split" + split + ".bundle")

    list_of_videos = read_file(file_list).split("\n")[:-1]

    overlap = [0.1, 0.25, 0.5]
    tp, fp, fn = np.zeros(3), np.zeros(3), np.zeros(3)

    correct = 0
    total = 0
    edit = 0

    for vid in list_of_videos:
        gt_file = os.path.join(ground_truth_path, vid)
        gt_content = read_file(gt_file).split("\n")[0:-1]

        recog_file = os.path.join(recog_path, vid.split(".")[0])
        recog_content = read_file(recog_file).split("\n")[1].split()

        for i in range(len(gt_content)):
            total += 1
            if gt_content[i] == recog_content[i]:
                correct += 1

        edit += edit_score(recog_content, gt_content)

        for s in range(len(overlap)):
            tp1, fp1, fn1 = f_score(recog_content, gt_content, overlap[s])
            tp[s] += tp1
            fp[s] += fp1
            fn[s] += fn1

    print("Acc: %.4f" % (100 * float(correct) / total))
    print("Edit: %.4f" % ((1.0 * edit) / len(list_of_videos)))
    acc = 100 * float(correct) / total
    edit = (1.0 * edit) / len(list_of_videos)
    f1s = []
    for s in range(len(overlap)):
        precision = tp[s] / float(tp[s] + fp[s])
        recall = tp[s] / float(tp[s] + fn[s])

        f1 = 2.0 * (precision * recall) / (precision + recall)

        f1 = np.nan_to_num(f1) * 100
        print("F1@%0.2f: %.4f" % (overlap[s], f1))
        f1s.append(f1)
    return acc, edit, f1s


def calc_framewise_f1_score(recogs: list[str], gtruth: list[str], all_cls_names: list[str]) -> np.ndarray:
    print("- - - - - - - - - - - -")
    print(f"{len(recogs)=}, {len(gtruth)=}")
    assert type(recogs[0]) is str
    assert type(gtruth[0]) is str
    assert len(recogs) == len(gtruth)

    f1_scores = np.zeros(len(all_cls_names))

    for i, label in enumerate(all_cls_names):
        tp = sum(p == t == label for p, t in zip(recogs, gtruth))
        num_recoged_as_label = sum(p == label for p in recogs)
        num_gtruth_is_label = sum(t == label for t in gtruth)

        prec = tp / num_recoged_as_label
        recall = tp / num_gtruth_is_label

        f1_scores[i] = 2 * (prec * recall) / (prec + recall)

    return f1_scores


def update_metrics(recognition, gt_cls, metrics):
    metrics.update_acc(accuracy(recognition, gt_cls), len(recognition))
    edit_score_cur = edit_score(recognition, gt_cls)
    metrics.update_edit(edit_score_cur)
    for s in range(len(metrics.overlap)):
        tp1, fp1, fn1 = f_score(recognition, gt_cls, metrics.overlap[s])
        metrics.update_f1s(tp1, fp1, fn1, s)


if __name__ == "__main__":
    main()
