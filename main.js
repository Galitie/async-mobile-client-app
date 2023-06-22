// Refactoring Event Listeners now that I know I can pass arguments
// Styling everything
// Emoji needs emoji packet
// Making UI friendly to laptops (incase someone needs to use a computer?)

// make dating sim portraits square proportion
// make more rooms
// find tile sets for dating sim portion

// Need to test if this fixes issue where keyboard pushes content around!
navigator.virtualKeyboard.overlaysContent = true

// ************************* Screens *************************** //
//Splash Screen when host is not connected
function notConnectedScreen(){
  console.log("Host or Server not connected")

  clearIDGameInDOM()
  addPrompt(`TYLERPG`)
  addPrompt(`Click below to join or re-join the game!`)
  addButtons(['connect'])

}


// Player join screen
function onJoinRequestScreen() {
  console.log("I got your join request")

  clearIDGameInDOM()
  addPrompt("Add player to game:")
  addInput(['smallInput', 'bigInput'])
  addButtons(['join'])
  document.querySelector(".smallInput").setAttribute("placeholder", "Your name")
  document.querySelector(".bigInput").setAttribute("placeholder", "Type in a catchphrase!")
}


// Overworld Screen
function overWorldMenuScreen() {
  console.log("Switched to overworld menu")

  clearIDGameInDOM()
  addPrompt("Say some stuff to Tyler or tap an emoji:")
  addInput(['bigInput'])
  addButtons(['submit'])
  addEmojiTray()
}


function battleScreen(){
  clearIDGameInDOM()
  addPrompt(`Name an attack for Tyler to use:`)
  addInput(['smallInput'])
  document.querySelector(".smallInput").setAttribute("placeholder", "Type attack here")
  addButtons(['[submit]'])
  addEmojiTray()
}


function nameItemScreen(){
  clearIDGameInDOM()
  addPrompt(`Name the item that Tyler found:`)
  addInput(['smallInput'])
  document.querySelector(".smallInput").setAttribute("placeholder", "Type item name here")
  addButtons(['[submit]'])
}


// ****************** Button Functionality ******************** //
function onClickSubmit() {

  if (document.querySelector('.bigInput') && document.querySelector('.smallInput')){
    let [smallInput, smallInputValue] = getInputAndValue('smallInput')
    let [bigInput, bigInputValue] = getInputAndValue('bigInput')
    let inputValid = true // this could be a method, reusuable validateInputs([])

    if (smallInputValue == "") {
      smallInput.classList.add("missedInput")
      inputValid = false
    } 
    
    if (bigInputValue == "") {
      bigInput.classList.add("missedInput")
      inputValid = false
    }

    if (inputValid == false) {
      return
    }

    const packet = {
      "action": "messageHost",
      "message": "chat",
      "content": smallInputValue, bigInputValue
    }

    sendMessage(JSON.stringify(packet))

    // this could be a method "cleanUpInput" with arr of what to cleanup
    bigInput.value = ""
    smallInput.value = ""
    bigInput.classList.remove("missedInput")
    smallInput.classList.remove("missedInput")
  } else if (document.querySelector('.bigInput')) {
      let [bigInput, bigInputValue] = getInputAndValue('bigInput')
      let inputValid = true
    
      if (bigInputValue == ""){
        bigInput.classList.add("missedInput")
        inputValid = false
      }

      if (inputValid == false){
        return
      }

      const packet = {
        "action": "messageHost",
        "message": "chat",
        "content": bigInputValue
      }

      sendMessage(JSON.stringify(packet))

      bigInput.value = ""
      bigInput.classList.remove("missedInput")

  } else {
    let [smallInput, smallInputValue] = getInputAndValue('smallInput')
    let inputValid = true

    if (smallInputValue == ""){
      smallInput.classList.add("missedInput")
      inputValid = false
    }

    if (inputValid == false){
      return
    }

    const packet = {
      "action": "messageHost",
      "message": "chat",
      "content": smallInputValue
    }

    sendMessage(JSON.stringify(packet))

    smallInput.value = ""
    smallInput.classList.remove("missedInput")

  }

}


function onClickCatchphrase() {
  console.log("You said your catchphrase!")
  const packet = {
  "action": "messageHost",
  "message": "sayCatchphrase"
  }
  sendMessage(JSON.stringify(packet))

}


function onClickCharacterCreation() {
  let [smallInput, smallInputValue] = getInputAndValue('smallInput')
  let [bigInput, bigInputValue] = getInputAndValue('bigInput')
  let inputValid = true

  if (bigInputValue == "" && smallInputValue == "") {
    bigInput.classList.add("missedInput")
    smallInput.classList.add("missedInput")
    inputValid = false
  }

  if (bigInputValue == "") {
    bigInput.classList.add("missedInput")
    smallInput.classList.remove("missedInput")
    inputValid = false
  }

  if (smallInputValue == "") {
    smallInput.classList.add("missedInput")
    bigInput.classList.remove("missedInput")
    inputValid = false
  }

  if (inputValid == false){
    return
  }

  const packet = {
    "action": "messageHost",
    "message": "createCharacter",
    "name": smallInputValue,
    "catchphrase": bigInputValue
    }

  sendMessage(JSON.stringify(packet))
  bigInput.classList.remove("missedInput")
  smallInput.classList.remove("missedInput")
  overWorldMenuScreen()

}  
  


function onClickEmoji(emojiClass, emoji) {
  console.log(`You pressed an ${emojiClass}`)

  const packet = {
    "action": "messageHost",
    "message": "chat",
    "content": `${emoji}`
    }
    sendMessage(JSON.stringify(packet))
}


function onClickConnect(){
  location.reload(true)
}

// ******************** Web Socket Stuff ********************** //
let playerServerStatus = document.querySelector('h4')
let hostServerStatus = document.querySelector('h3')
const websocketUrl = 'wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/prod';
const socket = new WebSocket(websocketUrl);

// Connection opened event and check for host
socket.onopen = function (event) {
  console.log('WebSocket connection established.');
  playerServerStatus.innerText = "\u2705 Connected to Server"
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
  if (message['message'] == "requestJoin" && message['action'] == "respondToUser"){
    hostServerStatus.innerText = "\u2705 Connected to Host"
    hostServerStatus.style.color = "green"
    onJoinRequestScreen()

  } else if (message['message'] == 'reconnect'){
    overWorldMenuScreen()

  } else if (message['message'] == 'Internal server error'){
    hostServerStatus.innerText = "\u2717 Disconnected from Host"
    hostServerStatus.style.color = "red"
    notConnectedScreen()
  } 
};

// Error event
socket.onerror = function (error) {
  console.error('WebSocket error:', error);
};

// Connection closed event
socket.onclose = function (event) {
  console.log('WebSocket connection closed:', event.code, event.reason);
  notConnectedScreen()
  playerServerStatus.innerText = "\u2717 Disconnected from Server"
  playerServerStatus.style.color = "red"
};

// Send a message to the WebSocket API
function sendMessage(message) {
  socket.send(message);
  console.log('Sent message:', message)
}


function setConnectionStatus(serverType, color){
  // if host server or player server => change inner text and color
  // put in notConnectedScreen
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
    let newButton = document.createElement('BUTTON')
    let newButtonText = document.createTextNode(capitalize(button))
    newButton.appendChild(newButtonText)
    newButton.classList.add(`${button}`)
    document.querySelector('#game').appendChild(newButton)
    let getElementButton = document.querySelector(`.${button}`)
    getElementButton.addEventListener('click', buttonMap[button])
  
  })
}

let buttonMap = {
  'submit': onClickSubmit,
  'join': onClickCharacterCreation,
  'catchphrase': onClickCatchphrase,
  'connect': onClickConnect
}


function addEmojiTray() {
  let emojiCollection = ['❤️', '😭', '🐝', '❗']

  let newSection = document.createElement("SECTION")
  newSection.setAttribute('id', 'emojiContainer')

  document.querySelector('#game').appendChild(newSection)

  for(let i=0; i < emojiCollection.length; i++){
    let newButton = document.createElement("BUTTON");
    let newButtonText = document.createTextNode(emojiCollection[i])
    newButton.appendChild(newButtonText)
    newButton.classList.add(`emoji${i}`)
    newSection.appendChild(newButton)
    document.querySelector(`.emoji${i}`).addEventListener("click", function () {
      onClickEmoji(`emoji${i}`, `${newButton.innerText}`)
    })
  }
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