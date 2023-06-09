let packageContext = "";
let timerRunning = true;
let timerCooldown = false;
let timerCooldownAmount = 0;
// ************************* Screens *************************** //

// If player is not connected
function notConnectedScreen() {
  console.log("Host or Server not connected");
  clearIDGameInDOM();
  addPrompt(`TYLERPG`);
  addDescription(`Click below to join or re-join the game!`);
  addButtons(["connect"]);
}

// Game already started screen
function gameAlreadyStartedScreen() {
  console.log("Game already started");
  clearIDGameInDOM();
  addPrompt(`TYLERPG`);
  addDescription(`Game has already started! Can't join.`);
}

// Prompt screen
function promptScreen(
  prompt,
  timerAmount,
  timerType,
  includeEmojiTray,
  inputs
) {
  clearIDGameInDOM();
  addPrompt(prompt);

  if (timerAmount > 0 && timerType == "countdown") {
    addTimer(timerAmount, timerType);
  }

  if (inputs.small) {
    addInput(["smallInput"]);
    document
      .querySelector(".smallInput")
      .setAttribute("placeholder", inputs.small);
  }

  if (inputs.big) {
    addInput(["bigInput"]);
    document.querySelector(".bigInput").setAttribute("placeholder", inputs.big);
  }

  if (inputs.big || inputs.small) {
    addButtons(["submit"]);
  }

  if (timerAmount > 0 && timerType == "cooldown") {
    timerCooldown = true;
    timerCooldownAmount = timerAmount;
  } else {
    timerCooldown = false;
  }

  if (includeEmojiTray == true) {
    console.log("added emoji tray");
    addEmojiTray();
  }
}

// ****************** Button Functionality ******************** //
function onClickSubmit() {
  let textboxes;
  let packet = {
    action: "messageHost",
    message: "sendText",
    context: `${packageContext}`,
  };

  if (
    document.querySelector(".bigInput") &&
    document.querySelector(".smallInput")
  ) {
    let [smallInput, smallInputValue] = getInputAndValue("smallInput");
    let [bigInput, bigInputValue] = getInputAndValue("bigInput");
    textboxes = [smallInput, bigInput];

    if (validateInputs(textboxes) == false) {
      return;
    }

    packet.smallInputValue = smallInputValue;
    packet.bigInputValue = bigInputValue;
  } else if (document.querySelector(".bigInput")) {
    let [bigInput, bigInputValue] = getInputAndValue("bigInput");
    textboxes = [bigInput];

    if (validateInputs(textboxes) == false) {
      return;
    }

    packet.bigInputValue = bigInputValue;
  } else {
    let [smallInput, smallInputValue] = getInputAndValue("smallInput");
    textboxes = [smallInput];

    if (validateInputs(textboxes) == false) {
      return;
    }

    packet.smallInputValue = smallInputValue;
  }

  if (timerCooldown == true) {
    addTimer(timerCooldownAmount, "cooldown");
  }
  removeCountdownTimer();
  cleanUpInput(textboxes);
  sendMessage(JSON.stringify(packet));
}

function onClickEmoji(emojiStr) {
  const packet = {
    action: "messageHost",
    message: "emote",
    emoji: emojiStr,
  };
  sendMessage(JSON.stringify(packet));
}

// this is only for the not connected screen
function onClickConnect() {
  location.reload(true);
}

//********************* Screen Pieces ************************//

function clearIDGameInDOM() {
  let rootElement = document.querySelector("#game");

  while (rootElement.firstChild) {
    rootElement.removeChild(rootElement.firstChild);
  }
}

function addTimer(duration, type) {
  let timer = duration,
    minutes,
    seconds;
  let element = "";
  let parentElement = "";

  if (type == "countdown") {
    element = "h5";
    timerRunning = true;
    parentElement = "#game";
  } else {
    element = "h6";
    makeElementsReadOnly(["submit"]);
    parentElement = ".submit";
  }

  let displayElement = document.createElement(element);
  let displayElementText = document.createTextNode("");
  displayElement.appendChild(displayElementText);
  let parent = document.querySelector(parentElement);
  parent.appendChild(displayElement);

  let countdown = setInterval(function () {
    minutes = parseInt(timer / 60, 10);
    seconds = parseInt(timer % 60, 10);

    minutes = minutes < 10 ? "0" + minutes : minutes;
    seconds = seconds < 10 ? "0" + seconds : seconds;

    displayElement.textContent = minutes + ":" + seconds;

    if (type == "countdown") {
      if (!timerRunning) {
        clearInterval(countdown);
      }

      if (timer > 0 && timer < 6) {
        --timer;
        displayElement.classList.add("pulsate");
      } else if (--timer < 0) {
        clearInterval(countdown);
        displayElement.classList.remove("pulsate");
        if (document.querySelector("textarea")) {
          let textareas = document.querySelectorAll("textarea");
          for (let i = 0; i < textareas.length; i++) {
            if (textareas[i].value == "") {
              textareas[i].value = "*blushes*";
            }
          }
          onClickSubmit();
        }
      }
    } else {
      if (timer > 0 && timer < 6) {
        --timer;
        displayElement.classList.add("pulsate");
      } else if (--timer < 0) {
        clearInterval(countdown);
        displayElement.classList.remove("pulsate");
        parent.removeChild(displayElement);
        enableElements(["submit"]);
      }
    }
  }, 1000);
}

function removeCountdownTimer() {
  timerRunning = false;
  if (document.querySelector("h5")) {
    let timer = document.querySelector("h5");
    console.log(`removed ${timer}`);
    timer.remove();
  }
}

function addPrompt(str) {
  let newPrompt = document.createElement("h1");
  let newPromptText = document.createTextNode(str);
  newPrompt.appendChild(newPromptText);
  let gameSection = document.querySelector("#game");
  gameSection.appendChild(newPrompt);
}

function addDescription(str) {
  let newDes = document.createElement("h2");
  let newDesText = document.createTextNode(str);
  newDes.appendChild(newDesText);
  let gameSection = document.querySelector("#game");
  gameSection.appendChild(newDes);
}

function addInput(inputClasses) {
  inputClasses.forEach((input) => {
    let newInput = document.createElement("TEXTAREA");
    newInput.classList.add(`${input}`);
    if (input === "bigInput") {
      newInput.setAttribute("rows", "3");
      newInput.setAttribute("placeholder", "Type something and press submit!");
      newInput.setAttribute("maxlength", "50");
    } else if (input === "smallInput") {
      newInput.setAttribute("placeholder", "Type something!");
      newInput.setAttribute("maxlength", "15");
    }
    let gameSection = document.querySelector("#game");
    gameSection.appendChild(newInput);
  });
}

function addButtons(buttonClasses) {
  let buttonMap = {
    submit: onClickSubmit,
    connect: onClickConnect,
  };

  buttonClasses.forEach((button) => {
    let newButton = document.createElement("BUTTON");
    let newButtonText = document.createTextNode(capitalize(button));
    newButton.appendChild(newButtonText);
    newButton.classList.add(`${button}`);
    document.querySelector("#game").appendChild(newButton);
    let getElementButton = document.querySelector(`.${button}`);
    getElementButton.addEventListener("click", buttonMap[button]);
  });
}

function addEmojiTray() {
  let emojiMap = {
    love: "❤️",
    sad: "😭",
    bee: "🐝",
    wow: "❗",
  };

  let newSection = document.createElement("SECTION");
  newSection.setAttribute("id", "emojiContainer");
  document.querySelector("#game").appendChild(newSection);

  Object.keys(emojiMap).forEach((emoji) => {
    let newButton = document.createElement("BUTTON");
    let newButtonText = document.createTextNode(emojiMap[emoji]);
    newButton.appendChild(newButtonText);
    newButton.classList.add(`emoji`);
    newButton.setAttribute("id", `${emoji}`);
    newSection.appendChild(newButton);
    document.getElementById(`${emoji}`).addEventListener("click", function () {
      onClickEmoji(emoji);
    });
  });
}

//************Helper Functions *******************/

function capitalize(word) {
  return word.charAt(0).toUpperCase() + word.slice(1);
}

function enableElements(elementClasses) {
  elementClasses.forEach((element) => {
    document.querySelector(`.${element}`).disabled = false;
    document.querySelector(`.${element}`).classList.remove("disabled");
    document.querySelector(`.${element}`).innerText = capitalize(
      `${elementClasses}`
    );
  });
}

function makeElementsReadOnly(elementClasses) {
  elementClasses.forEach((element) => {
    document.querySelector(`.${element}`).disabled = true;
    document.querySelector(`.${element}`).classList.add("disabled");
    document.querySelector(`.${element}`).innerText = "Submitted";
  });
}

function getInputAndValue(elementClass) {
  let input = document.querySelector(`.${elementClass}`);
  let inputValue = input.value;
  return [input, inputValue];
}

function cleanUpInput(textboxes) {
  textboxes.forEach((textbox) => {
    textbox.value = "";
    textbox.classList.remove("missedInput");
  });
}

function validateInputs(inputs) {
  let inputValid = true;
  inputs.forEach((input) => {
    if (input.value == "") {
      input.classList.add("missedInput");
      inputValid = false;
    }
  });
  return inputValid;
}
