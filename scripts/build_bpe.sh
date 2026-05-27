#!/bin/bash

VOCAB_SIZE=$1

if [ -z "$VOCAB_SIZE" ]; then
  echo "Error: Please provide a vocabulary size."
  echo "Usage: ./scripts/build_bpe.sh 2000"
  exit 1
fi

echo "Starting BPE pipeline for vocabulary size: ${VOCAB_SIZE}..."

# 1. Combine source and target tokenized data to learn a joint BPE model
cat data/train.100k.tok.SRC data/train.100k.tok.TRG > data/train.100k.tok.joint

# 2. Learn the BPE rules (using --total-symbols as required)
subword-nmt learn-bpe -s $VOCAB_SIZE --total-symbols < data/train.100k.tok.joint > data/bpe${VOCAB_SIZE}.codes

# 3. Apply BPE to the training data to generate the BPE-formatted text
subword-nmt apply-bpe -c data/bpe${VOCAB_SIZE}.codes < data/train.100k.tok.SRC > data/train.100k.bpe${VOCAB_SIZE}.SRC
subword-nmt apply-bpe -c data/bpe${VOCAB_SIZE}.codes < data/train.100k.tok.TRG > data/train.100k.bpe${VOCAB_SIZE}.TRG

# 4. Extract the vocabulary with frequency counts from the BPE-applied data
cat data/train.100k.bpe${VOCAB_SIZE}.SRC data/train.100k.bpe${VOCAB_SIZE}.TRG | subword-nmt get-vocab > data/vocab${VOCAB_SIZE}.counts.txt

# 5. Strip the counts out so JoeyNMT just gets the raw tokens
cut -f1 -d ' ' data/vocab${VOCAB_SIZE}.counts.txt > data/vocab${VOCAB_SIZE}.txt

echo "Success! BPE codes saved to: data/bpe${VOCAB_SIZE}.codes"
echo "JoeyNMT Vocabulary saved to: data/vocab${VOCAB_SIZE}.txt"
