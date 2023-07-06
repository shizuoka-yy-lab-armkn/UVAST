#!/usr/bin/env bash
set -euo pipefail

scriptDir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

if [[ $# -lt 3 ]]; then
  echo >&2 "[ERR] Missing arguments."
  echo >&2 "Usage: $0 {dataDirPath} {modelName} [splitID]..."
  echo >&2 "Example: $0 /path/to/50salads epoch-300 1 2 3 4 5"
  exit 1
fi

dataDirPath="$1"
modelName="$2"
shift 2
splitIDs="$@"

dataName=$(basename "$dataDirPath")
resultCsvPath="$scriptDir/stage2/logs/$dataName/f1_labelwise.csv"

echo "[INFO] dataDirPath=$dataDirPath"
echo "[INFO] dataName=$dataName"
echo "[INFO] modelName=$modelName"
echo "[INFO] resultCsvPath=$(realpath --relative-base="$PWD" "$resultCsvPath")"

rm -fv "$resultCsvPath"
for sid in $splitIDs; do
  echo "---------- split $sid ------------"
  ./infer_only.sh "$dataDirPath" "split${sid}" "stage2/model/$dataName/split_${sid}/${modelName}.model" "$resultCsvPath"
done
