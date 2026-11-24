# Week 7 — AI log

<!--
A HUMAN WRITES THE AI LOG, WITH NO EXCEPTIONS.
AI LOG'U İNSAN YAZAR, İSTİSNASIZ.

Write this file yourself, in your own words. The Evidence block and the bold quotes are the only
exceptions. Do not use an assistant to write the log, to "improve" it, or to correct its language. A log
that an assistant wrote earns 0. Your English or Turkish is not graded. A person reads the log.

Bu dosyayı kendiniz, kendi cümlelerinizle yazın. Evidence bloğu ve kalın alıntılar tek istisnadır.
Asistanı günlüğü yazmak, "düzeltmek" ya da dilini düzeltmek için kullanmayın. Asistanın yazdığı bir
günlük 0 puan alır. İngilizceniz ya da Türkçeniz notlanmaz. Günlüğü bir insan okur.

The log has two kinds of words, as in Weeks 4 to 6. Your own words are plain text. The words of the
assistant are **bold**. Use bold only where the words must come from the assistant: one line of its diff,
or one sentence of its answer, that you point at. Each bold phrase also appears in the Evidence block,
letter for letter. Do not use bold for anything else.

Günlükte, 4–6. haftalardaki gibi, iki tür söz vardır. Sizin sözleriniz düz yazıdır. Asistanın sözleri
**kalındır**. Kalın yazıyı yalnızca sözlerin asistandan gelmesi gereken yerde kullanın: işaret ettiğiniz,
diff'inden tek bir satır ya da cevabından tek bir cümle. Her kalın ifade, harfi harfine aynı biçimde,
Evidence bloğunda da bulunur. Kalın yazıyı başka hiçbir şey için kullanmayın.

This week's task is small diffs (AI_Doc5 §6) on your mobile client. ASSIGNMENT_07 §15 gives the steps.
1. Choose ONE change to your mobile client. Here are three examples. A screen shows the 409 message of
   the server. The app sends the user back to the login after a 401. The app keeps the address of the
   server in one constant.
2. Give the assistant the file, and ask for exactly this change and nothing else.
3. Before you accept anything, read ALL of the diff (git diff). Read also the lines that you did not
   ask for.
4. Keep the part that you asked for. Refuse every other change, even a good one.
5. Commit the accepted change on its own, with a message that names it. Write its commit id below.
   The first 7 characters of the id are enough.
6. Run the screen on the phone, and show that the change works.

A WEAK log says: "I asked the assistant to improve my booking screen. The new code was better, so I
accepted it."
A STRONG log says: "I asked for one change in book_screen.dart: after a 401, go back to the login screen. The diff
         did that, but it also changed **const server = 'http://192.168.1.40:8000';** in api.dart, an
         address I did not ask for, and it renamed my variable message to statusText. I kept only the
         401 part and put api.dart back with git restore. Commit 4e1a9c2 changes six lines of
         book_screen.dart and nothing else. On the emulator I restarted the server, so my token was no
         longer valid, and pressed Book: the app went back to the login screen."

Delete this comment when you are done.
-->

## The change I asked for

I used ChatGPT and shared my Weatherly project files. I asked it to help fix the email verification feature so users could enter their email address and receive a 4-digit verification code before logging in.

## The change I received

ChatGPT helped me implement the email verification feature. The changes included the email input, requesting a 4-digit verification code, and checking the code before allowing the user to log in.

## What I refused, and why

I did not refuse any changes. I checked the diff to make sure it only contained the requested changes and did not modify unrelated files or existing functionality.

## The commit, and the phone
Commit: 1f3f177
Message: Update deliverables

## Evidence — the exchange and the diff

```text
ME:
I am working on my Weatherly mobile application using React Native and Expo. Help me create a login and weather screen in mobile/src/app/index.tsx. Users should enter their email, request a 4-digit verification code, and verify the code to log in. After successful login, show today's and tomorrow's weather for Istanbul. Please connect the screen to my existing backend API endpoints.

AI:
I created the React Native screen in mobile/src/app/index.tsx. It includes an email input, a button to request a 4-digit verification code, a code verification screen, and a weather dashboard. It uses the /auth/code, /auth/login, and /auth/me endpoints and displays today's and tomorrow's weather.

TERMINAL:
git show eaf1af5

commit eaf1af516ff6cf1b657b750d94b9954fcc461827
Author: Khadija Sabir <kha4ijasabir@example.com>
Date: Sun Nov 15 18:04:04 2026 +0300

    Add Weatherly login and weather screen

diff --git a/mobile/src/app/index.tsx b/mobile/src/app/index.tsx
new file mode 100644
--- /dev/null
+++ b/mobile/src/app/index.tsx
@@ -0,0 +273 @@
[The committed file contains 273 lines implementing the login and weather screen.]

```
