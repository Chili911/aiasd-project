# Your clickable prototype

A prototype shows how the app will be used before any of it is built. Nothing here is real: there is no server, and the data is invented. What is real is the flow, which shows which screen comes after which, what each screen asks for, and what the user sees when something goes wrong.

**The rules**

* One HTML file for each screen, all in this folder. `index.html` is the first screen.
* It opens with a double click on `index.html`: no server, no framework, no build step.
* Use plain HTML, the shared `style.css`, and a few lines of JavaScript where a screen has to react, as in `code.html`.
* Every screen can be reached from `index.html` by clicking, and every link leads to a screen that exists. Write each link with the full file name, in lowercase and in quotes: `href="rooms.html"`.
* Every screen has a comment near the top that names the requirements it serves, for example: `<!-- serves: REQ-001, REQ-006 -->`.
* The invented data is fixed so a collaborator can follow a test case. The correct code in `code.html` is always `1234`. Write the invented values used by your screens below, under **Invented data**. Use no real names or email addresses.
* There is no server, so a screen remembers nothing. The prototype uses fixed data and only simulates the app's flow.
* When asking an assistant for a screen, specify plain HTML and CSS, one file for the screen, the shared `style.css`, and no framework. Build one screen at a time and commit it before moving to the next.
* Check every screen at a width of 390 px. In Chrome or Edge, press F12 and then the phone icon (Ctrl+Shift+M, or Cmd+Shift+M on a Mac), and choose a width of 390 px.

The three starter screens (`index.html`, `code.html`, and `home.html`) provide the shared login flow (REQ-001). The main Weatherly flow continues from `home.html`.

**Invented data**

**Login**

* Correct login code: `1234`.
* Wrong login code for testing: `1111`.
* The prototype does not send real email codes or check code expiration.

**Available locations**

* Istanbul
* Ankara

**Istanbul weather**

* Today: `22°C`, sunny, 10% chance of rain.
* Tomorrow: `18°C`, rainy, 70% chance of rain.
* Severe weather alert: none.
* Recommendation: bring an umbrella tomorrow because rain is likely.

**Ankara weather**

* Today: `16°C`, cloudy, 20% chance of rain.
* Tomorrow: `12°C`, heavy rain, 80% chance of rain.
* Severe weather alert: heavy rain expected tomorrow.
* Recommendation: bring an umbrella and wear water-resistant footwear tomorrow.

**Location search**

* Searching for `Paris` displays: `No matching locations found.`

All weather values and recommendations are invented for this prototype. They are not live forecasts.
