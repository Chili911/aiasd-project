---
marp: true
paginate: true
---

<!--
WEEK 3 — YOUR 5-MINUTE PITCH, SIX SLIDES                      3. HAFTA — 5 DAKİKALIK SUNUMUNUZ, ALTI SLAYT

This file IS your slide deck. Each "---" starts a new slide.   Bu dosya sunumunuzun kendisidir. Her "---" yeni bir slayt.
Open it in VS Code with the "Marp for VS Code" extension        VS Code'da "Marp for VS Code" eklentisiyle açın (sağ üstte
(preview button top right) and present from your own laptop.    önizleme düğmesi) ve kendi bilgisayarınızdan sunun.
Export to PDF or PPTX from the same button if you prefer.        İsterseniz aynı düğmeden PDF ya da PPTX'e aktarın.

WRITE IT YOURSELF. No AI for this file — not the text, not       KENDİNİZ YAZIN. Bu dosyada yapay zekâ yok — ne metin, ne
the structure. Everything here is about YOUR life and YOUR       yapı. Buradaki her şey SİZİN hayatınız ve SİZİN
people; an assistant cannot know it. In the group, and in        çevreniz; bir asistan bunu bilemez. Grupta ve derste
class, I will ask about any slide.                               herhangi bir slayt hakkında soru sorabilirim.

Replace every line in [brackets]. Keep each slide short:         Köşeli parantezli her satırı değiştirin. Slaytlar kısa
you are talking, the slide is only the skeleton.                 olsun: siz konuşuyorsunuz, slayt yalnızca iskelet.
Delete this comment when you are done.                           Bitince bu yorumu silin.
-->

# Weatherly

**Weatherly is for students and young adults who want quick, personalized weather information to help them plan what to wear, what to do, and where to go.**

Khadja Sabir · Software Engineering  · Week 3

---

## 1. The last time it happened — to me, or in front of me

<!-- A real moment, not a category. Yours, a friend's at the university, or
     someone's in your social circle — but one you saw. Date, place, who, what
     they were trying to do, what they did instead, what it cost. If you cannot
     name the last time, it is not your problem — change the project.
     Gerçek bir an, bir kategori değil. Sizin, üniversitedeki bir arkadaşınızın
     ya da sosyal çevrenizden birinin — ama gördüğünüz bir an. Tarih, yer, kim,
     ne yapmaya çalışıyordu, onun yerine ne yaptı, neye mal oldu. Son seferi
     söyleyemiyorsanız bu sizin sorununuz değildir — projeyi değiştirin. -->

- **When:** Around September 17, 2026 

- **Who / where / doing what:** My sister was getting ready to go out while I was at home. Before leaving, she checked the weather forecast to decide whether she should take an umbrella.

- **What they did instead:** The forecast said it would be windy but would not rain, so she left without an umbrella. It started raining heavily, and she had to stay at a restaurant until the rain became lighter.

- **What it cost:** She lost about an hour waiting, and the buses were also slower because of the rain.

---

## 2. Five people who will test it in Week 9

<!-- Real people in your reach — classmates, family, a club, a shop you use.
     Name and how you know them is enough. These are the users of your
     User Acceptance Test in Week 9; you will come back to this list.
     Erişebildiğiniz gerçek kişiler — sınıf arkadaşı, aile, kulüp, kullandığınız
     bir dükkân. Ad ve nereden tanıdığınız yeter. 9. haftadaki kullanıcı kabul
     testinin kullanıcıları bunlar; bu listeye geri döneceksiniz. -->

| # | Name | How you know them | Why they have the same problem |
|---|------|-------------------|--------------------------------|
| 1 |Fatima | Older Sister   | Because she goes out more often. |
| 2 | Sara |   Classmate     |  Because she likes dressing up but it takes time |
| 3 | Omar | Younger Brother | Because he wants to go out and play football but weather changes unexpexted and he gets sick often.  |
| 4 | Halima | Classmate    | Because she lives far she needs to know the weather and if busses will be slow or not. |
| 5 | Safia | Younger Sister | Because she enjoys drawing in nature but because of unexpected change of weather her drawing went all bad. |

---

## 3. What it does — and what it does not

<!-- Three requirements, copied from week02/requirements.json: the same id and the
     same description, word for word — the checker compares them. Then the one
     sentence from §4 on what it will NOT do — the sentence that keeps the project
     finishable.
     Üç gereksinim, week02/requirements.json'dan kopyalanmış: aynı id, aynı açıklama,
     kelimesi kelimesine — denetleyici karşılaştırır. Sonra §4'teki "yapmayacağı"
     cümle — projeyi bitirilebilir tutan cümle. -->

1. REQ-002 — The app displays the weather forecast for the user's selected location for the current day and the next day.
2. REQ-003 — The app recommends suitable clothing and accessories based on the forecast.
3. REQ-006 — Every screen is usable on a phone about 390 px wide without horizontal scrolling

**It does not:** provide weather forecasts beyond the current day and the next day.

---

## 4. The main screen

<!-- Draw it. On paper, photograph it, put the image in week03/ and link it
     here — or draw it with text boxes below. Not a tool mock-up, not AI: your
     hand, five minutes. The phone frame is 390 px wide (REQ-006).
     Çizin. Kâğıda çizip fotoğraflayın, görseli week03/ içine koyup buraya
     bağlayın — ya da aşağıya metin kutularıyla çizin. Araç taslağı değil,
     yapay zekâ değil: kendi eliniz, beş dakika. Telefon çerçevesi 390 px (REQ-006). -->

!main screen(week03/screen.jpg)


```text

+--------------------------------+
|           WEATHERLY             |
|                                |
|        📍 Istanbul              |
|                                |
|          ☀️ 22°C                |
|           Sunny                 |
|                                |
|       TODAY                    |
|   🌡️ 22°C    ☔ 10%             |
|                                |
|       TOMORROW                 |
|   🌧️ 18°C    ☔ 70%             |
|                                |
|   What should I wear? 👕       |
|   [ See Recommendations ]      |
|                                |
|   [ 👤 My Avatar ]             |
|                                |
+--------------------------------+

```

---

## 5. What I am not sure about

<!-- One honest doubt. The thing you would ask an experienced developer.
     Dürüst bir şüphe. Deneyimli bir geliştiriciye soracağınız şey. -->

*The doubt, as a question.**

Weatherly depends on accurate weather data to give useful clothing recommendations.
I am worried that incorrect or delayed weather information could make the recommendations unreliable.

---

## 6. Reviewers — answer these three, in writing

<!-- Leave this slide as it is. Each listener writes one sentence per question;
     you copy their sentences into week03/contributors_03.json after the round.
     Bu slaydı olduğu gibi bırakın. Her dinleyici soru başına bir cümle yazar;
     turdan sonra cümlelerini week03/contributors_03.json'a siz geçirirsiniz. -->

1. **Real?**  Yes, I think weather changes can affect students when planning what to wear or where to go 

2. **Usable here?** Yes, all five people could test it, but some may not have time 

3. **Too much or too little?** The avatar customization and weather features may be too much to finish by Week 11.