#!/bin/bash

# # Exit on error
# set -e

# # Configuration variables
BASE_DIR="/home/aniruddha/Two-step-low-res-NMT" # repo directory
REPO_DIR="${BASE_DIR}/acl22-sixtp"
XLMR_DIR="${BASE_DIR}/xlmr.large"
DATA_DIR="${REPO_DIR}/data"
BPE_DATA_DIR="${BASE_DIR}/bpe_data"
FAIRSEQ_DATA_DIR="${BASE_DIR}/fairseqdata"

echo $REPO_DIR
cd $REPO_DIR

# # Install requirements
# echo "Installing package requirements..."
pip install -e . --user
python setup.py build_ext --inplace
pip install sentencepiece
pip install torch==1.8.1+cu111 torchvision==0.9.1+cu111 torchaudio==0.8.1 -f https://download.pytorch.org/whl/torch_stable.html

# # Step 2: BPE Conversion
# echo "Converting text to BPE..."
mkdir -p $BPE_DATA_DIR

# Assuming the model file exists at the specified location
python scripts/tools/spm_encode.py \
    --model ${BASE_DIR}/xlmr.large/sentencepiece.bpe.model \
    --inputs ${BASE_DIR}/data/test.hi \
    --outputs ${BPE_DATA_DIR}/test.hi

python scripts/tools/spm_encode.py \
    --model ${BASE_DIR}/xlmr.large/sentencepiece.bpe.model \
    --inputs ${BASE_DIR}/data/test.kn \
    --outputs ${BPE_DATA_DIR}/test.kn
    
# Step 3: Binarize Data
# echo "Binarizing data..."
python  fairseq_cli/preprocess.py  \
    -s hi -t kn --dataset-impl lazy    --workers 24 \
    --destdir ${FAIRSEQ_DATA_DIR}/data_bin_hi_kn \
    --testpref ${BPE_DATA_DIR}/test \
    --srcdict  ${XLMR_DIR}/dict.txt \
    --tgtdict ${XLMR_DIR}/dict.txt

# Step 4: Evaluation
echo "Starting evaluation..."
task='xlmr_2stage_posdrop'
final_dir="${BASE_DIR}/bhashini-hi-kn"
src="hi"
tgt="kn"
resdir="${final_dir}/genres/${src}2${tgt}"
lang_dict="hi,kn"
DATA="${FAIRSEQ_DATA_DIR}/data_bin_hi_kn"

mkdir -p $resdir

# # Generate translations
python generate.py $DATA \
    -s hi -t kn \
    --path ${final_dir}/checkpoint_best.pt \
    --same-lang-per-batch \
    --enable-lang-ids \
    --max-tokens 10000 \
    --beam 5 \
    --sacrebleu \
    --remove-bpe \
    --decoding-path $resdir \
    --mplm-type 'xlmrL' \
    --xlmr-task 'xlmr_2stage_posdrop' \
    --model-overrides "{'xlmr_modeldir':\"${XLMR_DIR}\"}" \
    --langs ${lang_dict} \
    --task translation_multi_simple_epoch 2>&1 | tee ${resdir}/gen_out

# # Post-processing
echo "Post-processing results..."
cat ${resdir}/gen_out | grep -P "^H" | sort -V | cut -f 3- > ${resdir}/decoding.txt

# # Decode and evaluate
python scripts/tools/spm_decode.py \
    --model ${XLMR_DIR}/sentencepiece.bpe.model \
    --input ${resdir}/decoding.txt > ${resdir}/decoding.detok

echo "Process completed successfully!"
