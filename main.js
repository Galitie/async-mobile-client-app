const DOMElements = []

addPrompt("Eat bees Raam")
addAndStartCountdown(30)
addInput(['smallInput', 'bigInput'])
addButtons(['catchphrase'])

console.log(DOMElements)


// *********************** Screens *************************** //
function onJoinRequest() {
  console.log("I got your join request")
  
  const packet = {
    "action": "messageHost",
    "message": "createCharacter",
    "name": pass,
    "catchphrase": "Get out of my swamp, ya ha!"
    }
  sendMessage(JSON.stringify(packet))
}

// ****************** Button Functionality ******************** //

function onClickSubmit() {
  // let [smallInput, smallInputValue] = getInput('smallInput')
  // let [bigInput, bigInputValue] = getInput('bigInput')

}

function onClickCatchphrase(){
  // add cool-down timer for catchphrase

  console.log("You said your catchphrase!")
  const packet = {
  "action": "messageHost",
  "message": "sayCatchphrase"
  }
sendMessage(JSON.stringify(packet))
}

function onClickCharacterCreation(){

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
  let rootElement = document.body;

  while (rootElement.firstChild) {
    rootElement.removeChild(rootElement.firstChild);
  }
}

function addAndStartCountdown(duration) {
  let timer = duration, minutes, seconds;

  let displayElement = document.createElement("h3")
  let displayElementText = document.createTextNode("");
  displayElement.appendChild(displayElementText);
  let gameSection = document.querySelector('#game')
  gameSection.appendChild(displayElement)
  

  let countdown = setInterval(function() {
    minutes = parseInt(timer / 60, 10);
    seconds = parseInt(timer % 60, 10);

    minutes = minutes < 10 ? "0" + minutes : minutes;
    seconds = seconds < 10 ? "0" + seconds : seconds;

    displayElement.textContent = minutes + ":" + seconds;

    if (timer > 0 && timer < 11){
      --timer
      displayElement.classList.add("pulsate")
    }

    else if(--timer < 0) {
      clearInterval(countdown);
      displayElement.classList.remove("pulsate")
      displayElement.textContent = "Time's up!";
    }
  }, 1000);

  DOMElements.push(`countdown-${duration}`)
}

function addPrompt(packetData){
  let newPrompt = document.createElement("h1")
  let newPromptText = document.createTextNode(packetData);
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
      newInput.setAttribute("rows", "8")
      newInput.setAttribute("cols", "50")
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


function enableElements(elements){
  elements.forEach(element => {
    element.disabled = false
    element.classList.remove("disabled")
    element.innerText = ""
  })
}

function makeElementsReadOnly(elements){
  elements.forEach(element => {
    element.disabled = true
    element.classList.add("disabled")
    element.innerText = "Submitted"
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
