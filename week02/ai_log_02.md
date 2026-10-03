# Week 2 — AI log

> **Worth 2 points, and a person reads it.** Not graded on how much or how little you
> used AI — on whether you noticed something. The Evidence block is not optional: a
> claim with nothing pasted under it earns nothing.
>
> Delete these quoted instructions before you commit.

<!--
THIS WEEK'S TASK
1. Take your PROPOSAL.md §1–§4 as they stand.
2. Give two different assistants (Claude, ChatGPT, Gemini, Copilot … any two) the SAME
   prompt, for example:
     "Here is the problem and solution of my app: <paste §3 and §4>. Write eight
      software requirements for it — five functional, three non-functional — each with
      a priority (must/should/could) and an acceptance criterion."
3. Compare the two answers with each other and with your own §4.
4. Find ONE requirement that is wrong for YOUR product and write it up below.

WHAT "WRONG" LOOKS LIKE — typical errors worth reporting:
- a feature you never mentioned and do not want ("users can pay by credit card");
- a requirement that contradicts your §4 "does NOT do" sentence;
- data you do not have ("integrates with the university student system");
- a non-functional requirement with no number ("the system shall be fast and secure");
- everything marked "must";
- an acceptance criterion nobody could test ("users are satisfied").

WEAK:   "ChatGPT was helpful and gave me good requirements. Some were not relevant."
STRONG: "Both assistants added 'the student can pay a deposit to hold a room'. StudyRoom
         takes no payments — §4 says so. Gemini also marked all eight requirements 'must'.
         I removed the deposit, kept Claude's check-in timeout as REQ-004 with my own
         acceptance test, and re-prioritised: three musts, three shoulds, two coulds."
-->

**What I used AI for**

I used ChatGPT and Gemini to get feedback on my Weatherly proposal. I gave both assistants my PROPOSAL.md Part B (§8–§12) and asked: “You are an investor deciding whether to fund this. Give me the three strongest reasons to say no. Be specific to this proposal, not generic.”


**What it got right**

The AI correctly identified that our market evidence was too limited. The proposal only planned to test Weatherly with 20 students, so this was a reasonable concern. I kept the requirement to collect feedback from students and strengthened §8 by making the survey questions more specific and adding a plan to use a public source to estimate the wider market.


**What it got wrong, or what I had to correct**

The AI said that Weatherly does not have a clear advantage over existing weather apps. I disagreed with this because §9 and §10 already explain that Weatherly combines weather forecasts with outfit suggestions, activity ideas, and place recommendations in one product. I checked AccuWeather’s features and found that it provides weather forecasts and alerts, but does not combine these features with personalized outfit and activity recommendations. Therefore, the AI’s objection did not fully match the competitor comparison in my proposal.



**Evidence — the actual exchange**

```text

prompt :do u think my app weathly has clear advanatgae over other weathering app? i need honest opinion

answer : Gemini:
No, the concept alone does not give Weatherly a unique advantage—but its execution context can. Combining weather data, outfit suggestions, daily activities, and custom avatars is not a blue-ocean feature set. Apps like Weather Fit, WeatherStyle, and Outfit Weather already combine forecasts, layered clothing advice, lifestyle activity tips, and personalized digital avatars.However, as a student project targeted specifically at a Samsung/Galaxy university ecosystem, Weatherly’s pitch is still viable—provided you frame its advantage correctly.

```


**How I noticed**

I compared the AI's objection with my proposal in §9 and §10. I noticed that the AI's claim about Weatherly not having a clear advantage needed to be checked against the actual features of the competitor apps it mentioned.

**What I learned this week**

I learned that I should ask AI for specific evidence and verify its claims instead of accepting its answer immediately. Next time, I will ask AI to name specific competitors or sources so I can check whether its claims are accurate.