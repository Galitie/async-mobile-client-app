


// ************************* Screens *************************** //
// Character Screen
function onJoinRequest() {
  console.log("I got your join request")

  clearIDGameInDOM()
  addPrompt("Create a new Character:")
  addInput(['smallInput', 'bigInput'])
  addButtons(['create'])
  document.querySelector(".smallInput").setAttribute("placeholder", "Your name")
  document.querySelector(".bigInput").setAttribute("placeholder", "Type in a catchphrase you'd like to use often!")
}


// Overworld Screen
function overWorldMenu() {
  console.log("Switched to overworld menu")

  clearIDGameInDOM()
  addPrompt("Say some stuff to Tyler or press the catchphrase button!")
  addInput(['bigInput'])
  addButtons(['submit', 'catchphrase'])
  addEmojiTray()
}


// ****************** Button Functionality ******************** //
function onClickSubmit() {

  if (document.querySelector('.bigInput') && document.querySelector('.smallInput')){
    let [smallInput, smallInputValue] = getInputAndValue('smallInput')
    let [bigInput, bigInputValue] = getInputAndValue('bigInput')

    if (smallInputValue !== "" && bigInputValue !== ""){
      const packet = {
        "action": "messageHost",
        "message": "chat",
        "content": smallInputValue, bigInputValue
        }
        sendMessage(JSON.stringify(packet))
        addAndStartCountdown(15, 'submit')

        bigInput.value = ""
        smallInput.value = ""
        bigInput.classList.remove("missedInput")
        smallInput.classList.remove("missedInput")
    } else if (smallInputValue == "" && bigInputValue == ""){
      smallInput.classList.add("missedInput")
      bigInput.classList.add("missedInput")
    } else if (smallInput == ""){
      smallInput.classList.add("missedInput")
    } else {
      bigInput.classList.add("missedInput")
    }
  }
  else if (document.querySelector('.bigInput'))  {
    let [bigInput, bigInputValue] = getInputAndValue('bigInput')

    if (bigInputValue !== ""){
      const packet = {
        "action": "messageHost",
        "message": "chat",
        "content": bigInputValue
        }
        sendMessage(JSON.stringify(packet))
        addAndStartCountdown(15, 'submit')
        bigInput.value = ""
        bigInput.classList.remove("missedInput")
      } else {
        bigInput.classList.add("missedInput")
    }

  } else {
    let [smallInput, smallInputValue] = getInputAndValue('smallInput')

    if (smallInput !== ""){
    const packet = {
      "action": "messageHost",
      "message": "chat",
      "content": smallInputValue
      }
      sendMessage(JSON.stringify(packet))
      addAndStartCountdown(15, 'submit')

      smallInput.value = ""
      smallInput.classList.remove("missedInput")
    } else {
      smallInput.classList.add("missedInput")
    }
  }

}


function onClickCatchphrase() {
  console.log("You said your catchphrase!")
  const packet = {
  "action": "messageHost",
  "message": "sayCatchphrase"
  }
  sendMessage(JSON.stringify(packet))
  addAndStartCountdown(15, 'catchphrase')

}


function onClickCharacterCreation() {
  let [smallInput, smallInputValue] = getInputAndValue('smallInput')
  let [bigInput, bigInputValue] = getInputAndValue('bigInput')

  if (smallInputValue !== "" && bigInputValue !== ""){
    const packet = {
      "action": "messageHost",
      "message": "createCharacter",
      "name": smallInputValue,
      "catchphrase": bigInputValue
      }
    sendMessage(JSON.stringify(packet))
    overWorldMenu()
    bigInput.classList.remove("missedInput")
    smallInput.classList.remove("missedInput")
  } else if (bigInputValue == "" && smallInputValue == "") {
    bigInput.classList.add("missedInput")
    smallInput.classList.add("missedInput")
  } else if (bigInputValue == "") {
    bigInput.classList.add("missedInput")
  } else {
    smallInput.classList.add("missedInput")
  }
  

}


function onClickEmoji(emojiClass) {
  console.log(`You pressed an ${emojiClass}`)

  const packet = {
    "action": "messageHost",
    "message": "chat",
    "content": `${emojiClass}`
    }
    sendMessage(JSON.stringify(packet))
}


// ******************** Web Socket Stuff ********************** //
let playerServerStatus = document.querySelector('h4')
const websocketUrl = 'wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/prod';
const socket = new WebSocket(websocketUrl);

// Connection opened event and check for host
socket.onopen = function (event) {
  console.log('WebSocket connection established.');
  playerServerStatus.innerText = "\u2705 Connected to server"
  playerServerStatus.style.color = "green"

  const packet = {
    "action": "messageHost",
    "message": "attemptJoin"
  }
  sendMessage(JSON.stringify(packet))

};

// Message received event
socket.onmessage = function (event) {
  const message = JSON.parse(event.data);
  console.log('Received message:', message)

  // Character Creation Screen - hardcoded until we figure out a different way
  if (message['message'] == "requestJoin"){
    onJoinRequest()
  } else if (message['message'] == 'reconnect'){
    overWorldMenu()
  }
};

// Error event
socket.onerror = function (error) {
  console.error('WebSocket error:', error);
};

// Connection closed event
socket.onclose = function (event) {
  console.log('WebSocket connection closed:', event.code, event.reason);
  playerServerStatus.innerText = "\u2717 Disconnected from server"
  playerServerStatus.style.color = "red"
};

// Send a message to the WebSocket API
function sendMessage(message) {
  socket.send(message);
  console.log('Sent message:', message)
}


//********************* Screen Pieces ************************//

function clearIDGameInDOM() {
  let rootElement = document.querySelector('#game');

  while (rootElement.firstChild) {
    rootElement.removeChild(rootElement.firstChild);
  }

}


function addAndStartCountdown(duration, parentClass) {
  let timer = duration, minutes, seconds;

  let displayElement = document.createElement("h3")
  let displayElementText = document.createTextNode("");
  displayElement.appendChild(displayElementText);
  makeElementsReadOnly([`${parentClass}`])
  let parent = document.querySelector(`.${parentClass}`)
  parent.appendChild(displayElement)
  

  let countdown = setInterval(function() {
    minutes = parseInt(timer / 60, 10);
    seconds = parseInt(timer % 60, 10);

    minutes = minutes < 10 ? "0" + minutes : minutes;
    seconds = seconds < 10 ? "0" + seconds : seconds;

    displayElement.textContent = "Cooldown: " + minutes + ":" + seconds;
    

    if (timer > 0 && timer < 6){
      --timer
      displayElement.classList.add("pulsate")
    }

    else if(--timer < 0) {
      clearInterval(countdown);
      displayElement.classList.remove("pulsate")
      parent.removeChild(displayElement)
      enableElements([`${parentClass}`])
    }
  }, 1000);
}


function addPrompt(str) {
  console.log(str)
  let newPrompt = document.createElement("h1")
  let newPromptText = document.createTextNode(str);
  newPrompt.appendChild(newPromptText);
  let gameSection = document.querySelector('#game')
  gameSection.appendChild(newPrompt)
}


function addInput(inputClasses) {
  inputClasses.forEach(input => {
    let newInput = document.createElement("TEXTAREA")
    newInput.classList.add(`${input}`)
    if(input === "bigInput"){
      newInput.setAttribute("rows", "3")
      newInput.setAttribute("placeholder", "Type something and press submit!")
      newInput.setAttribute("maxlength", "50")
    } else if (input === "smallInput"){
      newInput.setAttribute("placeholder", "Type something!")
      newInput.setAttribute("maxlength", "15")
    }
    let gameSection = document.querySelector('#game')
    gameSection.appendChild(newInput)
  })
}


function addButtons(buttonClasses) {
  buttonClasses.forEach((button) => {
    let newButton = document.createElement("BUTTON");
    let newButtonText = document.createTextNode(capitalize(button));
    newButton.appendChild(newButtonText);
    newButton.classList.add(`${button}`)
    let gameSection = document.querySelector('#game')
    gameSection.appendChild(newButton)

    if (button == "submit"){
      document.querySelector(`.${button}`).addEventListener('click', onClickSubmit)
    } 
    else if (button == "create") {
      document.querySelector(`.${button}`).addEventListener('click', onClickCharacterCreation)
    }
    else if (button == "catchphrase"){
      document.querySelector(`.${button}`).addEventListener('click', onClickCatchphrase)
    } 
  })
}


function addEmojiTray() {
  let emojiCollection = ['❤️', '😭', '🐝', '❗']

  let newSection = document.createElement("SECTION")
  newSection.setAttribute('id', 'emojiContainer')

  let gameSection = document.querySelector('#game')
  gameSection.appendChild(newSection)

  for(let i=0; i < emojiCollection.length; i++){
    let newButton = document.createElement("BUTTON");
    let newButtonText = document.createTextNode(emojiCollection[i])
    newButton.appendChild(newButtonText);
    newButton.classList.add(`emoji${i}`)
    newSection.appendChild(newButton)
    document.querySelector(`.emoji${i}`).addEventListener("click", function () {
      onClickEmoji(`emoji${i}`);
    })}
}


function capitalize(word){return word.charAt(0).toUpperCase() + word.slice(1)}


function enableElements(elementClasses) {
  elementClasses.forEach(element => {
    document.querySelector(`.${element}`).disabled = false
    document.querySelector(`.${element}`).classList.remove("disabled")
    document.querySelector(`.${element}`).innerText = capitalize(`${elementClasses}`)
  })
}


function makeElementsReadOnly(elementClasses) {
  elementClasses.forEach(element => {
    document.querySelector(`.${element}`).disabled = true
    document.querySelector(`.${element}`).classList.add("disabled")
    document.querySelector(`.${element}`).innerText = "Submitted"
  })
}


function getInputAndValue(elementClass) {
  let input = document.querySelector(`.${elementClass}`)
  let inputValue = input.value
  return [input, inputValue]
 
}