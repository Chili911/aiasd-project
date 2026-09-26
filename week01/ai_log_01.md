# Week 1 — AI log

**What I used AI for**

I used ChatGPT and Claude for this week's assignment. I asked both assistants questions about Transformers, attention, and how an LLM generates the next token. I also asked both of them the same geometry question to check whether they could identify a problem in the given information.

**What it got right**

Both ChatGPT and Claude correctly explained the basic idea of how an LLM generates the next token. They explained that the text is broken into tokens, the model uses the context to predict possible next tokens, chooses one, and then repeats the process. They also correctly explained that attention helps the model focus on relevant tokens and understand relationships between them.

**What it got wrong, or what I had to correct**

When I asked both ChatGPT and Claude to calculate the area of a right-angled triangle with a 10 cm hypotenuse and a 6 cm altitude to the hypotenuse, both answered 30 cm². They used the correct area formula, but they did not check whether the given measurements were possible. A right triangle with a 10 cm hypotenuse cannot have an altitude of 6 cm to the hypotenuse. The maximum possible altitude is 5 cm, so the triangle described in the question is impossible.

**Evidence — the actual exchange**

```text
Me: Calculate the area of a right-angled triangle with a hypotenuse of 10 cm and an altitude (height) to the hypotenuse of 6 cm.

ChatGPT:

For a triangle, the area can be calculated using:

A = 1/2 × base × height

Here, the hypotenuse = 10 cm and the height to the hypotenuse = 6 cm.

A = 1/2 × 10 × 6 = 30

Area = 30 cm²

Claude:

Area = 30 cm²

Here's why: for any triangle, if you know one side (the base) and the corresponding height (the perpendicular distance to that side), the area formula is:
Area = ½ × base × height
Here, the hypotenuse (10 cm) is being used as the base, and the altitude drawn to it (6 cm) is the height.
So:
½ × 10 × 6 = 30 cm²
```

**How I noticed**

I noticed the problem because both assistants immediately used the area formula without checking whether the measurements were possible for a right-angled triangle. I knew that the altitude to the hypotenuse should not be larger than half of the hypotenuse in this case, so I checked the geometry. With a 10 cm hypotenuse, the maximum possible altitude is 5 cm, which means the given 6 cm altitude is impossible.

**What I learned this week**

I learned that I should not automatically trust an AI answer just because it looks clear and the calculation seems correct. Both ChatGPT and Claude used the correct area formula, but they did not check whether the information in the question was actually possible. I also learned that giving AI a confident answer does not mean that it has checked all the assumptions behind the answer. This week showed me that I need to question and verify AI answers instead of just accepting the first answer I get.