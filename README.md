# Two-step-low-res-NMT

# Bilingual Text Translation and Evaluation Pipeline

This repository provides a script to perform bilingual text translation and evaluation using a pre-trained multilingual language model, XLM-RoBERTa. The script includes steps for setup, BPE encoding, data binarization, translation generation, and evaluation.

---

## Table of Contents
1. [Requirements](#requirements)
2. [Setup Instructions](#setup-instructions)
3. [Pipeline Steps](#pipeline-steps)
    - [Step 1: Environment Setup](#step-1-environment-setup)
    - [Step 2: BPE Conversion](#step-2-bpe-conversion)
    - [Step 3: Data Binarization](#step-3-data-binarization)
    - [Step 4: Translation Generation](#step-4-translation-generation)
    - [Step 5: Post-processing and Evaluation](#step-5-post-processing-and-evaluation)
4. [Outputs](#outputs)

---

## Requirements

Ensure the following are installed before running the script:

- Python 3.6
- `pip` (Python package installer)
- Required Python packages (installed in the script):
  - `sentencepiece`
  - `fairseq`
- A pre-trained XLM-R model and its SentencePiece BPE model file.

---

## Setup Instructions

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>

  2-stage Model : [HI-KN Model](https://huggingface.co/sujeetkgp/bhasini_hi-kn-model)

  XLM-R Model : [XLM-R](https://dl.fbaipublicfiles.com/fairseq/models/xlmr.large.tar.gz)

  Download the 2-stage and XLM-R large models and place them in the repo.

2. Please paste the path of the XLM-R sentencepiece.bpe.model at line 23 of acl22-sixtp/fairseq/data/encoders/sentencepiece_bpe.py file.

3. Run `infer.sh`





