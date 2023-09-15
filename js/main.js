let packageContext = "";
let timerRunning = true;
let timerCooldown = false;
let timerCooldownAmount = 0;
let isDatingSimTime = false;
let name = "";

function setStyleDatingSim() {
  isDatingSimTime = true;
  let rootTheme = document.querySelector(":root");
  rootTheme.style.setProperty("--fontFamily", "'Lilita One', cursive");
  rootTheme.style.setProperty("--fontSize", "7vw");
  rootTheme.style.setProperty("--backgroundColor", "hotpink");
  rootTheme.style.setProperty("--buttonColor", "purple");
  rootTheme.style.setProperty("--placeholderColor", "pink");
  rootTheme.style.setProperty("--textShadowColor", "-.1em .1em purple");
  rootTheme.style.setProperty("--backgroundShadowColor", "-10px 10px purple");
  rootTheme.style.setProperty("--borderRadius", ".5em");
  rootTheme.style.setProperty("--gap", "1em");
  rootTheme.style.setProperty("--textAreaTextColor", "Purple");
  rootTheme.style.setProperty("--paddingBottom", "5%");
  rootTheme.style.setProperty("--h1FontSizeAdjustment", "xx-large");
  rootTheme.style.setProperty("--spanFontSizeAdjustment", "smaller");
}

// ************************* Screens *************************** //

// setStyleDatingSim();
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
  diceEnabled,
  dice,
  inputs,
  style
) {
  clearIDGameInDOM();
  if (style == "cute") {
    setStyleDatingSim();
  }
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

  if (diceEnabled) {
    console.log("added dice tray");
    addDiceTray(dice);
  }
}

// ****************** Button Functionality ******************** //
function onClickSubmit() {
  let textboxes;
  let packet = {
    action: "messageHost",
    message: "sendText",
    context: `${packageContext}`,
    userIP: `${name}`,
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

    if (packageContext == "user_joined") {
      name = smallInputValue.toLowerCase();
    }

    packet.smallInputValue = smallInputValue;
    packet.bigInputValue = bigInputValue;
    let typedChar2 = document.querySelector("#typed-characters-2");
    let typedChar1 = document.querySelector("#typed-characters-1");
    typedChar1.innerText = 0;
    typedChar2.innerText = 0;
  } else if (document.querySelector(".bigInput")) {
    let [bigInput, bigInputValue] = getInputAndValue("bigInput");
    textboxes = [bigInput];

    if (validateInputs(textboxes) == false) {
      return;
    }
    let typedChar2 = document.querySelector("#typed-characters-2");
    typedChar2.innerText = 0;
    packet.bigInputValue = bigInputValue;
  } else {
    let [smallInput, smallInputValue] = getInputAndValue("smallInput");
    textboxes = [smallInput];

    if (validateInputs(textboxes) == false) {
      return;
    }
    let typedChar1 = document.querySelector("#typed-characters-1");
    typedChar1.innerText = 0;
    packet.smallInputValue = smallInputValue;
  }

  if (timerCooldown == true) {
    addTimer(timerCooldownAmount, "cooldown");
  }
  removeCountdownTimer();
  cleanUpInput(textboxes);
  sendMessage(JSON.stringify(packet));
}

function onClickDice(diceNum) {
  const packet = {
    action: "messageHost",
    message: "dice",
  };
  sendMessage(JSON.stringify(packet));
  //let dice = document.getElementById(`${diceNum}`);
  //dice.remove();
}

// this is only for the not connected screen
function onClickConnect() {
  location.reload(true);
}

//********************* Screen Pieces ************************* //

function clearIDGameInDOM() {
  let rootElement = document.querySelector(".game");

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
    parentElement = ".game";
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
  if (isDatingSimTime == true) {
    newPrompt.innerText += "❤️";
  }
  let gameSection = document.querySelector(".game");
  gameSection.appendChild(newPrompt);
}

function addDescription(str) {
  let newDes = document.createElement("h2");
  let newDesText = document.createTextNode(str);
  newDes.appendChild(newDesText);
  let gameSection = document.querySelector(".game");
  gameSection.appendChild(newDes);
}

function addInput(inputClasses) {
  const smallInputAmount = 15;
  const bigInputAmount = 50;
  let gameSection = document.querySelector(".game");
  inputClasses.forEach((input) => {
    let newInput = document.createElement("TEXTAREA");
    newInput.classList.add(`${input}`);
    if (input === "bigInput") {
      newInput.setAttribute("rows", "3");
      newInput.setAttribute("placeholder", "Type something and press submit!");
      newInput.setAttribute("maxlength", `${bigInputAmount}`);
      gameSection.appendChild(newInput);
      addCharCounter(gameSection, bigInputAmount, 2);
      let textAreaElement = document.querySelector(`.${input}`);
      let characterCounterElement =
        document.querySelector(`#character-counter-2`);
      let typedCharactersElement = document.querySelector(
        "#typed-characters-2"
      );
      textAreaElement.addEventListener("keyup", (event) => {
        const typedCharacters = textAreaElement.value.length;
        if (typedCharacters > bigInputAmount) {
          return false;
        }
        typedCharactersElement.textContent = typedCharacters;
        if (typedCharacters < 45) {
          characterCounterElement.classList = "text-normal";
        }
        if (typedCharacters >= 45 && typedCharacters < 50) {
          characterCounterElement.classList = "text-warning";
        } else if (typedCharacters == 50) {
          characterCounterElement.classList = "text-danger";
        }
      });
    } else if (input === "smallInput") {
      newInput.setAttribute("placeholder", "Type something!");
      newInput.setAttribute("maxlength", `${smallInputAmount}`);
      gameSection.appendChild(newInput);
      addCharCounter(gameSection, smallInputAmount, 1);
      let textAreaElement = document.querySelector(`.${input}`);
      let characterCounterElement = document.querySelector(
        "#character-counter-1"
      );
      let typedCharactersElement = document.querySelector(
        "#typed-characters-1"
      );
      textAreaElement.addEventListener("keyup", (event) => {
        const typedCharacters = textAreaElement.value.length;
        if (typedCharacters > smallInputAmount) {
          return false;
        }
        typedCharactersElement.textContent = typedCharacters;
        if (typedCharacters < 10) {
          characterCounterElement.classList = "text-normal";
        }
        if (typedCharacters >= 10 && typedCharacters < 15) {
          characterCounterElement.classList = "text-warning";
        } else if (typedCharacters == 15) {
          characterCounterElement.classList = "text-danger";
        }
      });
    }
  });
}

function addCharCounter(parentClass, maxChars, id) {
  let div = document.createElement("DIV");
  let spanTyped = document.createElement("SPAN");
  let seperator = document.createElement("SPAN");
  let spanMax = document.createElement("SPAN");
  div.setAttribute("id", `character-counter-${id}`);
  spanTyped.setAttribute("id", `typed-characters-${id}`);
  spanMax.setAttribute("id", `maximum-characters-${id}`);
  seperator.innerText = "/";
  spanMax.innerText = maxChars;
  spanTyped.innerText = "0";
  div.appendChild(spanTyped);
  div.appendChild(seperator);
  div.appendChild(spanMax);
  parentClass.appendChild(div);
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
    if (isDatingSimTime == true) {
      newButton.innerText += "❤️";
    }
    newButton.classList.add(`${button}`);
    document.querySelector(".game").appendChild(newButton);
    let getElementButton = document.querySelector(`.${button}`);
    getElementButton.addEventListener("click", buttonMap[button]);
  });
}

// function addEmojiTray() {
//   let emojiMap = {
//     love: "❤️",
//     sad: "😭",
//     bee: "🐝",
//     wow: "❗",
//   };

//   let newSection = document.createElement("SECTION");
//   newSection.setAttribute("class", "emojiContainer");
//   document.querySelector(".game").appendChild(newSection);

//   Object.keys(emojiMap).forEach((emoji) => {
//     let newButton = document.createElement("BUTTON");
//     let newButtonText = document.createTextNode(emojiMap[emoji]);
//     newButton.appendChild(newButtonText);
//     newButton.classList.add(`emoji`);
//     newButton.setAttribute("id", `${emoji}`);
//     newSection.appendChild(newButton);
//     document.getElementById(`${emoji}`).addEventListener("click", function () {
//       onClickEmoji(emoji);
//     });
//   });
// }

function addDiceTray(amount) {
  let diceMap = {};

  for (let i = 1; i <= amount; i++) {
    diceMap[`dice${i}`] = "🔊";
  }

  let newSection = document.createElement("SECTION");
  newSection.setAttribute("class", "diceContainer");
  document.querySelector(".game").appendChild(newSection);

  Object.keys(diceMap).forEach((dice) => {
    let newButton = document.createElement("BUTTON");
    let newButtonText = document.createTextNode(diceMap[dice]);
    newButton.appendChild(newButtonText);
    newButton.classList.add(`dice`);
    newButton.setAttribute("id", `${dice}`);
    newSection.appendChild(newButton);
    document.getElementById(`${dice}`).addEventListener("click", function () {
      onClickDice(dice);
    });
  });
}

//**********************Helper Functions ******************** //

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
