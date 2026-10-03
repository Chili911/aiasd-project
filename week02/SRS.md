# Software Requirements Specification — *Weatherly*

<!--
WHAT THIS DOCUMENT IS
The requirements of your product, written so that someone else could build it, and so
that you can test it in Week 9. PROPOSAL.md says why and what, in a few paragraphs; this
says exactly what the system must do. A page or two — not thirty.

RULES
- Keep the headings. Write under them.
- Requirement ids are the ones in requirements.json: REQ-001, REQ-002 … Every id there
  appears here, and nothing appears here that is not there. Ids never change after this
  week; design, tests and the traceability matrix all point at them.
- The examples in the comments describe one invented project, "StudyRoom" (booking a
  library study room). They show the level of detail wanted; write about your project.
  Comments are invisible on GitHub and not counted by the checker.
-->

## 1. Purpose and scope


WHAT: Weatherly is a weather planning application for users who want to prepare for the next day based on expected weather conditions. Users can check tomorrow’s forecast, receive clothing and preparation recommendations, view alerts for severe weather such as heavy rain or possible flooding, and style an avatar to preview outfit choices. Weatherly does not provide long-term weather forecasting, real-time emergency services, or professional safety advice.

EXAMPLE: Weatherly lets users check tomorrow’s weather and prepare for the day with clothing recommendations, weather alerts, and outfit styling through a personal avatar. It covers next-day weather planning only; long-term forecasting, real-time emergency services, and professional safety advice are out of scope.


## 2. Actors

WHAT: Weatherly has four main actors: the user, who checks tomorrow’s weather, receives clothing and safety recommendations, views weather alerts, and styles their avatar; the weather API, which provides forecast information such as temperature, rain, and severe weather conditions; the e-mail/OTP service, which sends login or verification codes to users; and the app store, which allows users to download and install the Weatherly application.

EXAMPLE: The main actor is the user, who checks tomorrow’s weather, receives clothing and preparation recommendations, views severe weather alerts, and styles their avatar. The weather API provides Weatherly with forecast information such as temperature, rain, and other weather conditions. The e-mail/OTP service sends login or verification codes to users, while the app store distributes the Weatherly mobile application to users.


## 3. Use cases


 UC1 — Check tomorrow’s weather 

  Actor: User. Requirements: REQ-001. 
  Main flow: The user opens Weatherly and selects tomorrow’s forecast. The app requests the forecast from the weather API and displays the expected temperature, rain, and other weather conditions. The user checks the information to understand what the weather will be like and plan their day.

  What can go wrong: If the weather API is unavailable or does not return the forecast, the app informs the user that the weather information cannot be loaded and allows them to try again. 


  UC2 — Get clothing recommendations

Actor: User. Requirements: REQ-002.

Main flow: The user opens tomorrow’s weather information. The app uses the forecast conditions to generate suitable clothing and preparation recommendations. The app may suggest wearing a jacket or rain boots when it is cold or raining, or bringing an umbrella when rain is expected. The user reviews the recommendations and uses them to prepare for the next day.

What can go wrong: If the weather information is unavailable or incomplete, the app informs the user that clothing recommendations cannot be generated.

UC3 — Receive severe weather alerts

Actor: User. Requirements: REQ-003.

Main flow: The app checks tomorrow’s weather conditions for potentially dangerous situations. If heavy rain, possible flooding, or another severe condition is expected, the app displays an alert to the user. The user reviews the alert and can consider it when planning their activities for the next day.

What can go wrong: If no severe weather is expected, no alert is shown. If the app cannot retrieve the necessary weather information, it informs the user that the alert information is unavailable.



```mermaid
flowchart LR
  US[User]
  WA[Weather API]
  EM[E-mail / OTP Service]
  AS[App Store]

  subgraph SYS[Weatherly]
    UC0([Log in with e-mail code])
    UC1([Check tomorrow's weather])
    UC2([Get clothing recommendations])
    UC3([Receive severe weather alerts])
    UC4([Style the avatar])
  end

  US --- UC0
  US --- UC1
  US --- UC2
  US --- UC3
  US --- UC4

  UC0 --- EM
  UC1 --- WA
  UC2 --- WA
  UC3 --- WA
  AS --- SYS
  ```
  
## 4. Functional requirements

REQ-001 — The user can view tomorrow’s weather forecast, including temperature and weather conditions. — must — UC1
Acceptance: when the user selects tomorrow’s forecast, the app displays the expected temperature and weather conditions for the selected location.

REQ-002 — The system provides clothing recommendations based on tomorrow’s weather conditions. — must — UC2
Acceptance: when a forecast is available, the app recommends suitable clothing such as a jacket, rain boots, or light clothes based on the conditions.

REQ-003 — The system alerts the user when severe weather conditions such as heavy rain or possible flooding are expected. — must — UC3
Acceptance: when severe weather is detected in the forecast, the app displays an alert describing the expected condition.

REQ-004 — The user can customize an avatar with different hairstyles, makeup, and clothing. — should — UC4
Acceptance: when the user selects an item, the selected hairstyle, makeup, or clothing appears on the avatar.

REQ-005 — The user can change the avatar's body size and choose from available male and female avatar options. — should — UC3
Acceptance: the user opens the avatar customization screen, selects an available avatar type, and changes its size; the avatar updates to show the selected appearance.


REQ-007 — The app sends alerts when severe weather or potentially dangerous natural weather events are expected. — should — UC4
Acceptance: when severe weather data is available for the selected location, the app displays an alert describing the event and the recommended safety action.


## 5. Non-functional requirements

REQ-006 — Every screen is usable on a phone about 390 px wide without horizontal scrolling. — must
Acceptance: every screen opened on a 390 px wide phone or browser phone view has no horizontal scroll bar, no text cut off, and every button is reachable.

REQ-008 — The app loads the weather forecast and recommendations within 3 seconds under normal network conditions. — should
Acceptance: the time from opening the weather screen to displaying the forecast and recommendations is measured under a normal network connection; the information appears within 3 seconds.

## 6. Constraints and assumptions

WHAT: Weatherly will be developed as a mobile-friendly application and tested on Android devices. The project will use free or low-cost development tools, hosting, and a weather API because of the student project budget. An internet connection is required to retrieve weather forecast data, and the accuracy of the forecast depends on the external weather API. The project must be completed within the university course term using the available student hardware and development time.
