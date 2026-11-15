# Week 6 — AI log

> **THE AI LOG IS WRITTEN BY A HUMAN. NO EXCEPTIONS.**
> **AI LOG KESİNLİKLE İNSAN TARAFINDAN YAZILIR. İSTİSNA YOK.**
>
> **Write this file yourself, in your own words. Outside the Evidence block and the bold
> quotes (see below), use no assistant: not to write it, not to "improve" it, not even for
> the language. A log written by an assistant earns 0.** Your English or Turkish is not
> graded.
>
> **Bu dosyayı kendiniz, kendi cümlelerinizle yazın. Evidence bloğu ve kalın alıntılar (aşağıya
> bakın) dışında asistan kullanmayın: ne yazmak için, ne "düzeltmek" için, dil için bile.
> Asistana yazdırılmış bir günlük 0 puan alır.** İngilizceniz ya da Türkçeniz notlanmaz.
>
> There are two kinds of words, as in Weeks 4 and 5. Your words are plain text: every word,
> the grammar too. The assistant's words are **bold**, and only where they must come from it:
> an attack it named, or one sentence or one line of its code that you point at. Each bold
> phrase is also in the Evidence block, under `AI:`, letter for letter. Use bold for nothing
> else.
>
> 4. ve 5. haftalardaki gibi iki tür söz var. Sizin sözleriniz düz yazıdır: her kelime, dil
> bilgisi de. Asistanın sözleri **kalındır** ve yalnızca asistandan gelmesi gereken yerdedir:
> adını koyduğu bir saldırı ya da işaret ettiğiniz tek bir cümle veya kodundan tek bir satır.
> Her kalın ifade, harfi harfine aynı biçimde, Evidence bloğunda `AI:` altında da bulunur.
> Kalın yazıyı başka hiçbir şey için kullanmayın.
>
> **Part of the 2 human-involvement points, and a person reads it.** The grade does not depend on how much you used
> AI. It depends on whether you tried each attack yourself and looked at what really
> happened. Delete these quoted instructions before you commit.

<!--
THIS WEEK'S TASK — the hostile reviewer (AI_Doc5 §3), on your own feature. Short answers, one per heading.
1. Give the assistant the routes of your own feature (your files in server/, not course_login.py),
   and the requirements they serve, with their acceptance criteria. Ask it to attack: "Give me the
   three strongest attacks on these routes, numbered. Do not fix anything, only attack."
2. Try each attack yourself: against your running server (curl, /docs or your page), or as a test
   in server/tests/. Copy the commands and their output into the Evidence block, under TERMINAL:.
   Do not change them.
3. For each attack: what your server did, with the status code.
4. The one you fixed: what you changed, and the test (with its test case id) that now catches it.
5. The one that is wrong: why it does not work against your server, and the evidence.
6. Your groupmate attacked you in the lecture (group_06.json). Where do the two agree? Which of
   the two found something that the other missed?

WEAK:   "I asked ChatGPT to attack my app. It gave three attacks. My app is secure."
STRONG: "Attack 1 was **accept a reply as a student by calling the endpoint directly**. The page hides
         the button from students, but I sent POST /replies/3/accept with a student's token and got
         403, so the server checks it too. Attack 2, **read another course by changing its id**, is
         wrong for my app: every route asks course_of_member() first, and the two calls gave 403. Attack 3
         was real: an announcement of five spaces was pinned as an empty card (201). The server now strips
         the text first and answers 422; test TC-003-02 sends five spaces too (CR-02). My groupmate found
         the spaces as well, but never tried the accept endpoint, which the assistant did."

Delete this comment when you are done.
-->

## The assistant, and what I gave it

I used Chatgpt; I provided the server/main.py file. I asked for attacks against my own Weatherly feature routes ; I tested the suggested attacks using PowerShell and curl.exe

## The three attacks, and what my server did


1. Avatar without login:
   The request returned 200 OK and the default avatar. This shows that the avatar endpoint does not currently require authentication.

2. Empty city:
   The request returned 404 Not Found. The server rejected the whitespace-only city.

3. Invalid makeup:
   The request returned 422 Unprocessable Content. The server rejected the invalid makeup value.


## The one I fixed

I did not fix any of the three attacks during Week 6. I tested them against my server, but I did not make any changes to server/main.py. Therefore, I do not have a new test case that checks a fix.



## The one that is wrong

Attack 2 , The attempted input was a city containing only spaces. The server removed the spaces using .strip().
It returned 404 instead of providing outfit recommendations. The evidence is in week6_terminal_evidence.txt 




## The assistant and my groupmate


My groupmate and I both tested whether an incorrect login code would be rejected. Both attacks were related to login security. My three attacks also checked avatar access without login, an empty city input, and invalid makeup. These tests covered different parts of the application. My avatar attack found that the endpoint returned 200 OK without requiring a login, which was something my groupmate's attack did not check.




## Evidence — the exchange and the terminal output

```text
ME:
I want you to attack my own feature routes in server/main.py with the three strongest attacks. Do not fix anything. Check for possible problems in the avatar, weather and outfits routes.

AI:
1. Access the avatar endpoint without logging in:
curl.exe -i http://127.0.0.1:8000/api/avatar

2. Send a city containing only spaces to the outfits endpoint:
curl.exe -i "http://127.0.0.1:8000/api/outfits?city=%20%20%20"

3. Send an invalid makeup option to the avatar endpoint:
curl.exe -i "http://127.0.0.1:8000/api/avatar?makeup=invalid"

TERMINAL:

PS C:\Users\USER\Documents\aiasd-project> curl.exe -i http://127.0.0.1:8000/api/avatar
HTTP/1.1 200 OK
date: Sun, 15 Nov 2026 11:42:15 GMT
server: uvicorn
content-length: 54
content-type: application/json

{"hair":"long","makeup":"natural","clothing":"casual"}
PS C:\Users\USER\Documents\aiasd-project> curl.exe -i "http://127.0.0.1:8000/api/outfits?city=%20%20%20"
HTTP/1.1 404 Not Found
date: Sun, 15 Nov 2026 11:42:24 GMT
server: uvicorn
content-length: 65
content-type: application/json

{"detail":"Outfit recommendations unavailable for this location"}
PS C:\Users\USER\Documents\aiasd-project> curl.exe -i "http://127.0.0.1:8000/api/avatar?makeup=invalid"
HTTP/1.1 422 Unprocessable Content
date: Sun, 15 Nov 2026 11:42:34 GMT
server: uvicorn
content-length: 34
content-type: application/json

{"detail":"Invalid makeup option"}
```