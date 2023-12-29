## How to run
Install requirements.txt

### Dataset creation
Dataset creation is in dataset folder, in the folder there is a separate readme

### Fine-tuning
For finetuning I used axolotl, in-order to install it you have to make sure that you cloned submodule
or clone it manualy from https://github.com/OpenAccess-AI-Collective/axolotl. Then
```
cd axolotl

pip3 install packaging
pip3 install -e '.[flash-attn,deepspeed]'
```
Once that's done simply run:
`accelerate launch -m axolotl.cli.train axolotl_recipes/qlora.yml` from the root.

### Evaluation
Open the evaluation.ipynb notebook

## Design Decisions
### Base Model
I have tried using the recommended T5Code+ model in many various ways.
For the base models (most of them) I tried leveraging the unsupervised denoising task. E.g Input `(function modifiers) <extra_id_0>(params){code}` and hoped that
the the output would be `<pad><extra_id_0>function name<extra_id_1>` as the model
was trained in this way with denoising objective (decoder mask prediction). However it appears that the latter
causual LM single modal objectve have removed the models ability to denoise. Secondly I tried to use completion mode, with following prompt:
```
(modifiers) x(prams){
    code
}
// The better name for this function would be: 
```
Which somehow worked, but only for the small multimodal model (since it also contained comments during pre-training). However the performance wasn't really good.
The only capable model, was the SFT 16b one. I could then use aplaca format with

```
### Instruction:
Suggest better name for the fucntion
### Input:
obfuscated funtion code
```
