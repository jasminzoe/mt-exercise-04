# MT Exercise 4: Byte Pair Encoding, Beam Search

This repository is a starting point for the 4th and final exercise. As before, fork this repo to your own account and then clone it into your preferred directory.

---

## Requirements

- Python 3.10 must be installed. The command `python3` (or `python` on Windows) should be available from your terminal or command prompt.
- `virtualenv` must be installed. Install it with:

  ```bash
  pip install virtualenv

macOS/Linux users: No special setup needed; shell scripts should run normally.

Windows users: Either use Windows Subsystem for Linux (WSL) or a Unix-compatible shell like Git Bash.
If you're using PowerShell or Command Prompt, manual setup is required.

### Setup Instructions

## For macOS / Linux / WSL / Git Bash users

Clone your fork of the repository + Create a virtual environment:
   ```
   git clone https://github.com/[your-username]/mt-exercise-4
   cd mt-exercise-4 

   ```
    ./scripts/make_virtualenv.sh

Important: Then activate the env by executing the source command that is output by the shell script above.

Install required dependencies - Follow the instructions provided in the exercise PDF.

Download data:

       python ./scripts/download_huggingface_data.py --src en --trg it --out data

We chose `en-it`

## Preprocessing Pipeline
 
**Tokenization:** A reusable shell script `scripts/tokenize.sh` was implemented using sacremoses.
 
**BPE Pipeline:** A parameterized script `scripts/build_bpe.sh` was created to learn joint BPE models and extract raw vocabulary files (stripping frequency counts as required by JoeyNMT).
 
**Experimental Setup:**
 
- **Model A (Baseline):** Word-level model, vocabulary limit: 2000, `tied_embeddings: False`
- **Model B:** BPE-level model, vocabulary size: 2000, `tied_embeddings: True`
- **Model C:** BPE-level model, vocabulary size: 4000, `tied_embeddings: True`
**Training Configurations:**
 
- Three separate `.yaml` configuration files were created in the `configs/` directory to facilitate these experiments.
- Training was performed on GPU by setting `use_cuda: True`.
```bash
./scripts/tokenize.sh
./scripts/build_bpe.sh 2000
./scripts/build_bpe.sh 4000
```
 
**Train the model:** Ensure you have defined the correct `model_name` (e.g., `model_a_word`, `model_b_bpe2000`, or `model_c_bpe4000`) within the script.
 
```bash
./scripts/train.sh
```
 
*The training process can be interrupted at any time. The best checkpoint will always be saved automatically.*
 
**Evaluate the model:**
 
```bash
./scripts/evaluate.sh
```
 
---

# Findings
 
## Part 1: Experiments with Byte Pair Encoding (BPE)
 
We evaluated three different architectural approaches to vocabulary construction using the **en-it** (English to Italian) translation direction.
 
While the word-based model almost exclusively generates `<unk>` for unknown words, the BPE models almost always produce fluent, readable sentences, even if their grammatical correctness could still be improved.
 
### Quantitative Evaluation (BLEU Scores)
 
| Model | Vocabulary Type | Vocabulary Size | BLEU Score |
| :--- | :--- | :--- | :--- |
| **Model A** | Word-level (with Threshold) | 2,000 | **4.0** |
| **Model B** | BPE-level | 2,000 | *9.3* |
| **Model C** | BPE-level | 4,000 | *9.8* |
 
Model A achieved a low BLEU score of 4.0. Because we restricted the vocabulary size to a strict limit of 2,000 whole words to keep the training computationally manageable, an overwhelming majority of unique words in the training and testing sets were forced into the unknown token mapping (`<unk>`).


Model B/C eliminates the `<unk>` problem. Rare English terminology is segmented into subwords (marked by `@@`) and translated into matching Italian morphological subwords. Even if the resulting sequence is not a perfectly natural Italian word, it retains the root meaning, which dramatically improves the unigram, bigram, and trigram precision measured by BLEU.

### Manual Translation Analysis
**Fluency and grammatical accuracy:** BPE outputs are noticeably more fluent and grammatically closer to natural Italian. Model A frequently produces broken or truncated sentences because key content words are replaced by `<unk>`, disrupting agreement and sentence structure.
 
**Morphological handling:** Italian is a morphologically rich language with gendered nouns and inflected verb endings. BPE handles this better than the word-level model — by segmenting words into stems and suffixes, the model can generalise across inflected forms it may not have seen as whole tokens during training. Verb conjugations and noun plurals that collapse to `<unk>` in Model A are correctly produced in Models B and C.

 
### Translation Example
 
| | Text |
| :--- | :--- |
| **Source (EN)** | The arctic ice cap is , in a sense , the beating heart of the global climate system . |
| **Reference (IT)** | La calotta glaciale artica è , in un certo senso , il cuore pulsante del sistema climatico globale . |
| **Model A output** | Il `<unk>` `<unk>` è , in un certo senso , il cuore del sistema climatico . |
| **Model C output** | La calotta glaciale artica è , in un certo senso , il cuore pulsante del sistema climatico globale . |

## Part 2:  Impact of beam size on translation quality

The BLEU score already increased significantly with the beam size from 1 to 2 and kept increasing until beamsize 4. With larger beamsize than 4, the BLEU score remained more uniform with only a little decrease. The best BLEU score was achieved at Beamsize 4.
At the same time, generation time increased with larger beam sizes. While beam size 4 required around 131 seconds, beam size 10 required almost 387 seconds.

This shows that larger beam sizes can improve translation quality up to a certain point, but also increase computational cost, because the model could consider several possible translation hypotheses at the same time instead of immediately choosing the most probable next word. Based on these evaluations, beam size 4 seems to be the best balance between translation quality and runtime for this model.


## For Windows (Command Prompt / PowerShell users)
Manually create and activate a virtual environment:

        python -m venv mt_env
        mt_env\Scripts\activate

Note: The make_virtualenv.sh script will not work in native Windows shells.

Manually download the dataset

Use the Python downloader script directly, for example:

       python scripts/download_huggingface_data.py --src en --trg nl --out data

If you want a different language pair, replace `--src` and `--trg` with one of the supported directions listed above.

Modify, train, and evaluate
Once setup is complete, use the instructions in the exercise PDF to run training and evaluation (either by adapting the .sh scripts manually, or by using Git Bash/WSL).

#### Notes for Windows Users

  Using Git Bash or WSL is highly recommended for compatibility.

  If using native PowerShell or Command Prompt:

  Manual recreation of shell script steps will be necessary.

  Always activate your virtual environment before running any training or evaluation steps.

