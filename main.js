// Refactoring Event Listeners now that I know I can pass arguments
// Styling everything
// Making UI friendly to laptops (incase someone needs to use a computer?)

// make dating sim portraits square proportion
// make more rooms
// find tile sets for dating sim portion

// Need to test if this fixes issue where keyboard pushes content around!
navigator.virtualKeyboard.overlaysContent = true

// ************************* Screens *************************** //

// If player is not connected
function notConnectedScreen(){
  console.log("Host or Server not connected")
  clearIDGameInDOM()
  addPrompt(`TYLERPG`)
  addPrompt(`Click below to join or re-join the game!`)
  addButtons(['connect'])
}

// Prompt screen
function promptScreen(prompt, timerAmount, includeEmojiTray, inputs){

  clearIDGameInDOM()
  addPrompt(prompt)
  
  if (inputs.big && inputs.small){
    addInput(['smallInput', 'bigInput'])
    document.querySelector(".smallInput").setAttribute("placeholder", inputs.small)
    document.querySelector(".bigInput").setAttribute("placeholder", inputs.big)
  }
  else if (inputs.big){
    addInput(['bigInput'])
    document.querySelector(".bigInput").setAttribute("placeholder", inputs.big)
  } else {
    addInput(['smallInput'])
    document.querySelector(".smallInput").setAttribute("placeholder", inputs.small)
  }
  
  addButtons(['submit'])
  if (includeEmojiTray == true){
    addEmojiTray()}
  if (timerAmount > 0){
    addAndStartCountdown(timerAmount, 'submit')
  }
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
      "message": "sendText",
      "smallInputValue": smallInputValue,
      "bigInputValue" : bigInputValue,
      "context": `${packageContext}`
    }

    sendMessage(JSON.stringify(packet))

    // this could be a method "cleanUpInput" with arr of what to cleanup
    bigInput.value = ""
    smallInput.value = ""
    bigInput.classList.remove("missedInput")
    smallInput.classList.remove("missedInput")
    packageContext = ''
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
        "message": "sendText",
        "bigInputValue" : bigInputValue,
        "context": `${packageContext}`
      }

      sendMessage(JSON.stringify(packet))

      bigInput.value = ""
      bigInput.classList.remove("missedInput")
      packageContext = ''

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
      "message": "sendText",
      "smallInputValue": smallInputValue,
      "context": `${packageContext}`
    }

    sendMessage(JSON.stringify(packet))

    smallInput.value = ""
    smallInput.classList.remove("missedInput")
    packageContext = ''
  }

}
 

function onClickEmoji(emojiClass, emoji) {

  const packet = {
    "action": "messageHost",
    "message": "sendText",
    "content": `${emoji}`
    }
    sendMessage(JSON.stringify(packet))
}

// this is only for the not connected screen
function onClickConnect(){
  location.reload(true)
}

// ******************** Web Socket Stuff ********************** //
let playerServerStatus = document.querySelector('h4')
let hostServerStatus = document.querySelector('h3')
let packageContext = ''
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

  if (message['message'] == 'Internal server error'){
    hostServerStatus.innerText = "\u2717 Disconnected from Host"
    hostServerStatus.style.color = "red"
    notConnectedScreen()
  } else {
    promptScreen(message['header'], message['timer'], message['emojis'], message['inputs'])
    packageContext = message['context']
  }
};


// Error event
socket.onerror = function (error) {
  console.error('WebSocket error:', error);
};

// Connection closed event
socket.onclose = function (event) {
  console.log('WebSocket connection closed:', event.code, event.reason);
  playerServerStatus.innerText = "\u2717 Disconnected from Server"
  playerServerStatus.style.color = "red"
  notConnectedScreen()
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
      makeElementsReadOnly([`${parentClass}`])
      onClickSubmit()
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

