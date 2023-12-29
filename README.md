## How to run
- Install requirements.txt
- Run evaluation.ipynb
- Make sure you have > 24GB GPU VRAM

### Dataset creation
Dataset creation is in dataset folder, in the folder there is a separate readme.
I have spent almost no time with that and is certainly the weakest point of the whole project. What I would do differently
- Remove abstract functions
- Remove very short functions
- Remove overrides, if they call the base function (or all overrides alltogether)
- Remove docstrings (questionable)

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
Open the `evaluation.ipynb` notebook and run the cells.

## Design Decisions
### Base Model
I have tried using the recommended T5Code+ model in many various ways.
For the base models (most of them) I tried leveraging the unsupervised denoising task. E.g Input `(function modifiers) <extra_id_0>(params){code}` and hoped that
the output would be `<pad><extra_id_0>function name<extra_id_1>` as the model
was trained in this way with denoising objective (decoder mask prediction). However it appears that the latter
causual LM single modal objective removed the model's ability to denoise. Secondly I tried to use completion mode, with following prompt:
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

However because of size, I decided to use CodeLlama, which offers 7b variant.

### Prompt choices
I decided to utilize also the system prompt, hoping that it would help the perfromance

### Hyperparametrs choices
- I have finetune model using SFT only, simply because DPO would require way more resouces and time. Secondly I didn't have a dataset
with preferences. But it would certainly be benfical.
- I have used Lora for the same reason as there is no other way to put the gradients + Adam momentum on the RTX3090, and secondly the method is way faster than the full-training. Addiontaly quantization allowed me to slightly increase batch size.
- For Q-Lora I have used the standard settings, r and alpha I have used the recommendation by [Rashka](https://magazine.sebastianraschka.com/p/practical-tips-for-finetuning-llms)
- I did half precission training with bf16, which is pretty stable and very cheap on memory
- For batch size I tried to set the max that will get on gpu, while targetting effective batch size of 32 (using grad accumulation)
- Lastly I used packing in both cases and training on inputs in case of Axoltl as it has super easy set-up there, and is super effective.

## Environment
- all the work was done on runpod with RTX3090

## Training Logs
https://wandb.ai/hynky/func_name_jetbrains?workspace=user-kydlicek-hynek
