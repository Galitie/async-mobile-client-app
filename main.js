const DOMElements = []


// *********************** Screens *************************** //
// Character Screen
function onJoinRequest() {
  console.log("I got your join request")

  clearDOM()
  addPrompt("Create a new Character:")
  addInput(['smallInput', 'bigInput'])
  addButtons(['create'])

}

// Overworld Screen
function overWorldMenu(){
  console.log("Switched to overworld menu")

  clearDOM()
  addPrompt("Say some stuff to Tyler or press the catchphrase button!")
  addInput(['bigInput'])
  addButtons(['catchphrase', 'submit'])
}

// ****************** Button Functionality ******************** //

function onClickSubmit() {
  let [bigInput, bigInputValue] = getInput('bigInput')

  const packet = {
    "action": "messageHost",
    "message": "chat",
    "content": bigInputValue
    }
  sendMessage(JSON.stringify(packet))
  addAndStartCountdown(15, 'submit')
  bigInput.innerText = ""

}

function onClickCatchphrase(){
  // add cool-down timer for catchphrase

  console.log("You said your catchphrase!")
  const packet = {
  "action": "messageHost",
  "message": "sayCatchphrase"
  }
  sendMessage(JSON.stringify(packet))
  addAndStartCountdown(15, 'catchphrase')

}


function onClickCharacterCreation(){
  let [smallInput, smallInputValue] = getInput('smallInput')
  let [bigInput, bigInputValue] = getInput('bigInput')
  
  const packet = {
    "action": "messageHost",
    "message": "createCharacter",
    "name": smallInputValue,
    "catchphrase": bigInputValue
    }
  sendMessage(JSON.stringify(packet))
  
  overWorldMenu()
  


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

  // Character Creation Screen
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

function clearDOM() {
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
    

    if (timer > 0 && timer < 11){
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

  DOMElements.push(`countdown-${duration}`)
}

function addPrompt(str){
  console.log(str)
  let newPrompt = document.createElement("h1")
  let newPromptText = document.createTextNode(str);
  newPrompt.appendChild(newPromptText);
  let gameSection = document.querySelector('#game')
  gameSection.appendChild(newPrompt)
  DOMElements.push("prompt")
}

function addInput(inputClasses){
  inputClasses.forEach(input => {
    let newInput = document.createElement("TEXTAREA")
    newInput.classList.add(`${input}`)
    if(input === "bigInput"){
      newInput.setAttribute("rows", "4")
      newInput.setAttribute("cols", "50")
      newInput.setAttribute("placeholder", "Type something and press submit!")
      newInput.setAttribute("maxlength", "50")
    } else if (input === "smallInput"){
      newInput.setAttribute("placeholder", "Type something and press submit!")
      newInput.setAttribute("maxlength", "15")
    }
    let gameSection = document.querySelector('#game')
    gameSection.appendChild(newInput)
    DOMElements.push(input)
  })
}

// add emoji buttons
function addButtons(buttonClasses){
  buttonClasses.forEach((button) => {
    //Create new button with text
    let newButton = document.createElement("BUTTON");
    let newButtonText = document.createTextNode(capitalize(button));
    newButton.appendChild(newButtonText);
    newButton.classList.add(`${button}`)

    //Append it to the "game" section of the screen
    let gameSection = document.querySelector('#game')
    gameSection.appendChild(newButton)

    //Attach the correct function to it
    if (button == "submit"){
      document.querySelector(`.${button}`).addEventListener('click', onClickSubmit)
    } else if (button == "create") {
      document.querySelector(`.${button}`).addEventListener('click', onClickCharacterCreation)
    }
    else if (button == "catchphrase"){
      document.querySelector(`.${button}`).addEventListener('click', onClickCatchphrase)
    }

    DOMElements.push(button)
  })
}

function capitalize(word){return word.charAt(0).toUpperCase() + word.slice(1)}


function enableElements(elementClasses){
  elementClasses.forEach(element => {
    document.querySelector(`.${element}`).disabled = false
    document.querySelector(`.${element}`).classList.remove("disabled")
    document.querySelector(`.${element}`).innerText = capitalize(`${elementClasses}`)
  })
}

function makeElementsReadOnly(elementClasses){
  elementClasses.forEach(element => {
    document.querySelector(`.${element}`).disabled = true
    document.querySelector(`.${element}`).classList.add("disabled")
    document.querySelector(`.${element}`).innerText = "Submitted"
  })
}

function getInput(elementClass){
  let input = document.querySelector(`.${elementClass}`)
  let inputValue = input.value
  return [input, inputValue]
 
}

// Add in elements that I want for each screen
// Elements: Prompt, small input, large input, timer, emoteButtons, submitButton
// Elements need to be customizable (innerText, color, placeholder)
