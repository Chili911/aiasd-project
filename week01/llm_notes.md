# Week 1 — LLM Exploration Notes

**Student:** Khadija Sabir
**Date:** 26/09/2026


## The two assistants I used

I used ChatGPT and Claude through their web interfaces. I spent around 20 minutes asking both assistants the same questions about transformers, attention, and how LLMs generate tokens. I compared how detailed and easy to understand their answers were.

---

## What a transformer is
A Transformer is a type of neural network architecture used by many modern AI models. In simple words, it helps the model understand how different words or tokens in a sentence are related to each other. One important part of a Transformer is attention, which allows it to focus more on relevant parts of the text.

For example, in a sentence where a pronoun refers to a word earlier in the sentence, attention helps the model connect those words even if they are far apart. Transformers are also useful because they can process many parts of the input efficiently instead of having to process everything strictly one word at a time.

## What problem attention solves
Attention helps solve the problem of deciding which parts of the input are important when understanding a sentence. Older sequence models such as RNNs could have difficulty remembering information when important words were far apart.

Attention allows the model to look at different tokens and give more importance to the ones that are relevant. For example, if a sentence says, "The cat drank the milk because it was thirsty," attention can help connect "it" with "cat." Claude also explained that attention helps avoid the fixed bottleneck and long-range dependency problems of older models.

## How the next token is generated
An LLM generates text one token at a time. First, the input text is broken into tokens. The tokens are converted into numbers that the model can process. The Transformer then uses the context and attention to understand the relationships between the tokens.

The model produces probabilities for possible next tokens. For example, after "The cat is," possible next tokens could include "sleeping," "hungry," or "happy." One token is selected and added to the text. The model then uses the new text to predict the next token, and this process repeats.

The output does not always have to be exactly the same because the model can use different sampling methods to choose between possible tokens.

---

## ⚓ Where one of them was vague, wrong, or better than I expected

I noticed that ChatGPT was generally easier for me to understand, while Claude often gave more technical explanations.

For example, when I asked what a Transformer is, ChatGPT said:

"Transformer = a way for AI to understand how words relate to each other"

Claude said:

"A transformer is a neural network architecture... that's become the backbone of most modern large language models"

Claude also mentioned things such as multi-head attention, positional encoding, residual connections, and encoder-only versus decoder-only models. I understood ChatGPT's explanation faster because it used simpler examples, while Claude gave me more technical information.

When I asked about attention, ChatGPT used a simple example about a cat and the word "it." Claude explained the fixed bottleneck and long-range dependency problems in older RNN-based models. I found Claude's explanation useful because it explained not only what attention does but also why it was needed.

```
<!-- Paste the exchange. Trim it to the lines that show what you mean. -->
```

<!-- Your reading of it: what was wrong or surprising, and how you could tell. -->

## ⚓ Tokens, counted on my own hello.py

I estimated that my week01/hello.py program would be around 80 tokens. This is not the same as the number of words because tokens are not always complete words. They can also include parts of words, punctuation, and programming symbols.

For example, my code contains players = ["Messi", "Ronaldo", ...], where the brackets, commas, quotation marks, and the variable name all contribute to the tokens. My f-string print(f"\n{name}'s football scouting list:") also contains several different pieces that are not normal English words. The indentation and Python syntax also make the code different from ordinary text. This showed me that counting words is not enough to know how many tokens a program contains.

## ⚓ What I still do not understand

I understand the basic idea of how an LLM works better now, especially that it breaks text into tokens and predicts the next token based on the context. However, I still do not fully understand what is happening inside the attention mechanism. I understand that it gives more importance to some tokens than others, but I do not really understand how the model decides those weights or how the calculations happen. I also found terms like logits and softmax confusing because Claude mentioned them but I have not studied them properly yet. So I understand the general process, but I still need to understand what is actually happening inside the Transformer mathematically.

---

## The same question asked twice


<!-- Vague: -->

 How does an LLM generate the next token?

ChatGPT:

An LLM generates text one token at a time. For example, if you type "The cat is," the model considers possible next tokens such as "sleeping," "hungry," or "happy." It gives each possible token a likelihood based on what it learned during training, selects one token, adds it to the sentence, and repeats the process.

Claude:

Claude explained the process as breaking the input into tokens, looking at the context, calculating possible next tokens and their likelihoods, choosing one, and repeating the process. It also explained that the model can sometimes choose a less likely option to keep the output varied.

what changed : the vague question gave me a general explanation, but the detailed question made the answers more step-by-step, beginner-friendly, and focused on the parts I specifically wanted to understand.


<!-- promt With context: -->

I am a beginner software engineering student learning about AI. Explain how an LLM generates the next token step by step. Use a simple example to make it easy to understand. Avoid mathematical formulas and advanced technical terms, and keep the explanation under 150 words.

ChatGPT:

ChatGPT explained that the model reads the context, considers possible next tokens, gives them likelihoods, chooses one, adds it to the sentence, and repeats the process. It used "The cat is" as the example.

Claude:

Claude used "The sky is" as its example. It explained that the text is split into tokens, the model looks at the context using attention, predicts possible next tokens such as "blue," chooses one, and repeats the process.

What changed: The detailed prompt made both answers more focused on a beginner level and forced them to use a simple example and avoid advanced technical explanations. The answers were also shorter and more structured.

## One thing a model got wrong

I asked both assistants the same question:

"Calculate the area of a right-angled triangle with a hypotenuse of 10 cm and an altitude (height) to the hypotenuse of 6 cm."

Chatgpt It used the area formula \(A=\frac12 bh\), treated the 10 cm hypotenuse as the base and 6 cm as the corresponding height, and answered 30 cm².


Claude simply used the triangle area formula with 10 cm as the base and 6 cm as the height and answered:

"Area = 30 cm²"

What I found: Both models gave the same answer, but the triangle described is actually impossible. For a right triangle with a 10 cm hypotenuse, the altitude to the hypotenuse cannot be 6 cm. The maximum possible altitude is 5 cm. Both models followed the area formula without checking whether the given measurements could actually form a right triangle. This surprised me because I expected at least one of them to notice the problem.