#!/bin/bash

echo "Tokenizing English (Source)..."
sacremoses -l en -j 4 tokenize < data/train.100k.SRC > data/train.100k.tok.SRC
sacremoses -l en -j 4 tokenize < data/dev.en > data/dev.tok.SRC
sacremoses -l en -j 4 tokenize < data/test.en > data/test.tok.SRC

echo "Tokenizing Italian (Target)..."
sacremoses -l it -j 4 tokenize < data/train.100k.TRG > data/train.100k.tok.TRG
sacremoses -l it -j 4 tokenize < data/dev.it > data/dev.tok.TRG
sacremoses -l it -j 4 tokenize < data/test.it > data/test.tok.TRG

echo "Tokenization complete!"
