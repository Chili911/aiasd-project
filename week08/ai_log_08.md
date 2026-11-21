# Week 8 — AI log

<!--
NO AI HELP ON THE AI LOG. IF AN ASSISTANT HELPS YOU WITH THIS LOG IN ANY WAY, THE LOG WILL EARN 0.
AI LOG'DA YAPAY ZEKA YARDIMI YOK. BU LOG'DA BİR ASİSTAN SANA HERHANGİ BİR ŞEKİLDE YARDIM EDERSE LOG 0 ALACAK.

Fill this in on Saturday, yourself. The log must tell how you used AI assistants in the whole week, in all of your
work: every real use, how you checked what you got, and what you did with it. A person will read the log and compare
it with your commits. Do not ask an assistant to write it, to improve it, to translate it or to correct its
language. Short, plain sentences are enough; your English or Turkish will not be graded.

Bunu Cumartesi günü kendin doldur. Log, bütün hafta boyunca, bütün işinde yapay zeka asistanlarını nasıl
kullandığını anlatmalı: her gerçek kullanımı, aldığını nasıl kontrol ettiğini ve onunla ne yaptığını. Bir insan
okuyacak ve commit'lerinle karşılaştıracak. Asistana yazdırma, geliştirtme, çevirtme ya da dilini düzelttirme. Kısa ve
sade cümleler yeterli; İngilizcen ya da Türkçen notlandırılmayacak.

Delete the comments when you are done. / Bitirince yorumları sil.
-->

## 1. My assistants

<!--
One row for each assistant you used this week. "Model": the model the app or the editor shows (if it shows none,
write "not shown"). "Free or paid": free / paid. "Plan": the name of the paid plan, or "-" if it is free.
Example row:
| ChatGPT | the model the app shows | paid | Plus |

Bu hafta kullandığın her asistan için bir satır. "Model": uygulamanın ya da editörün gösterdiği model (göstermiyorsa
"not shown" yaz). "Free or paid": ücretsiz (free) / ücretli (paid). "Plan": ücretli paketin adı, ücretsizse "-".
-->

| Assistant | Model    | Free or paid | Plan |
|Chatgpt    |GPT-6     | Free         | none |
| Gemeni    | Gemini   |     Free     |  Google AI Plus (Student Version)    |

## 2. Every use of an assistant this week

<!--
One row for each time an assistant really helped or was tried, in the order of the week. Write every real use,
not only the good ones.
"How I checked it": what you did before you kept the answer, for example: read all of the diff, ran the tests,
tried it on the phone, compared it with api.md, did not check.
"What I did with it": kept as it was / changed (what) / refused (why).
"Commit": the commit where the result went, or "not kept".
Example row:
| the chat route on the server | ChatGPT | a FastAPI route POST /chat that calls the Gemini API | read the diff; the route returned 500 after the limit, so I tested it with 21 messages | changed the error from 500 to 429 | a1b2c3d |

Haftanın sırasıyla, bir asistanın gerçekten yardım ettiği ya da denendiği her kullanım için bir satır. Yalnız
iyi gidenleri değil, her gerçek kullanımı yaz. "How I checked it": cevabı tutmadan önce ne yaptın (diff'in
tamamını okudum, testleri çalıştırdım, telefonda denedim, api.md ile karşılaştırdım, kontrol etmedim).
"What I did with it": olduğu gibi tuttum / değiştirdim (neyi) / reddettim (neden).
-->

| What for | Assistant | What I asked, in short  | How I checked it | What I did with it | Commit |
|Gemini API integration| ChatGPT|	How to create a Gemini API key and connect it to Weatherly.|Checked API key setup and .env configuration.|Configured Gemini API for the backend.|Check GitHub|
| Chat endpoint| ChatGPT |How to implement and test the POST /chat endpoint.  |Tested the endpoint and checked the project checker. |checked the project checker.| Implemented the chat endpoint.  |  2 commits|



## 3. How I worked with assistants this week

This week, I used ChatGPT, Gemini, and Claude to support my Weatherly project. I mainly used them to understand how to integrate the Gemini API, implement the backend chat endpoint, connect the mobile application to the backend, and troubleshoot errors. I asked questions when I was unsure about implementation steps and used the explanations to solve problems. I checked the suggestions by running the application, testing API endpoints, reviewing the output, and checking GitHub commits. I did not blindly copy the answers. I reviewed the code and tested whether the changes worked correctly in my project.

## 4. What I did without an assistant

I worked independently on my Weatherly project by reviewing the existing code, organizing project files, and making changes to the application. I tested the application myself, checked the results, reviewed errors, and made sure the implemented features worked as expected. I also managed my GitHub repository, committed my changes, and tracked my project progress.

## 5. Next week
Next week, I plan to continue developing Weatherly by improving the chat feature, testing the Gemini API integration, and fixing any remaining errors. I will focus on connecting the frontend and backend properly, testing the application on my mobile device, and improving the overall user experience. I also plan to review my code, update the project documentation, and push my completed changes to GitHub.

## 6. Before this course and now

Before this course, I mainly used AI assistants to get quick answers, generate code, and solve programming problems. Now, I understand that AI can be used as a development assistant, not just a code generator. I have learned to ask more specific questions, review the suggested code, test the results, and fix problems instead of blindly accepting AI-generated answers. I also understand the importance of checking whether the solution actually works in my project.