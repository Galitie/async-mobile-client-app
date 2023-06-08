
// Add event listeners
document.body.addEventListener("requestJoin", onJoinRequest)
//elem.AddEventListener("refuseJoin", onJoinRefuse(packet))


function onJoinRequest(packet) {
  console.log("I got your join request")
}

// **************** Submit Button Functionality ****************** //

function onClick() {
  // let [smallInput, smallInputValue] = getInput('smallInput')
  // let [bigInput, bigInputValue] = getInput('bigInput')
 
  // Send packet
  // const packet = {
  //   "action": "join",
  //   "name": smallInputValue,
  //   "role": "user"
  // }
  // sendMessage(JSON.stringify(packet))
}


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


// **************** Web Socket stuff ****************** //
let playerServerStatus = document.querySelector('h4')

// Create a WebSocket connection
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
  const message = event.data;
  console.log('Received message:', message)
  let parsedMessage = JSON.parse(message)
  if (parsedMessage['message'] == "requestJoin"){
    const packet = {
    "action": "messageHost",
    "message": "createCharacter",
    "name": "Galit",
    "catchphrase": "Cowabunga Dude, pepepeepe doo doo eat gobblygook"
    }
  sendMessage(JSON.stringify(packet))
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



// make a class for packets?
// class Packet
// class JoinPacket extends Packet
// class InputPacket extends Packet
// class ExitPacket extends Packet

// enableElements(elements)
// or toggle


// *************** Timer ****************//
let timer = document.getElementById("timer-display")

function startCountdown(duration, displayElement) {
  let timer = duration, minutes, seconds;
  
  let countdown = setInterval(function() {
    minutes = parseInt(timer / 60, 10);
    seconds = parseInt(timer % 60, 10);

    minutes = minutes < 10 ? "0" + minutes : minutes;
    seconds = seconds < 10 ? "0" + seconds : seconds;

    displayElement.textContent = minutes + ":" + seconds;

    if (timer > 0 && timer < 10){
      --timer
      displayElement.classList.add("pulsate")
    }

    else if(--timer < 0) {
      clearInterval(countdown);
      displayElement.classList.remove("pulsate")
      displayElement.textContent = "Time's up!";
    }
  }, 1000);
}


const DOMElements = []
addInput(['smallInput', 'bigInput'])
addButtons(['catchphrase', 'submit'])
console.log(DOMElements)

function clearDOM() {
  let rootElement = document.body;

  while (rootElement.firstChild) {
    rootElement.removeChild(rootElement.firstChild);
  }
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

function addButtons(buttonClasses){
  buttonClasses.forEach((button) => {
    let newButton = document.createElement("BUTTON");
    let newButtonText = document.createTextNode(capitalize(button));
    newButton.appendChild(newButtonText);
    newButton.classList.add(`${button}`)
    let gameSection = document.querySelector('#game')
    gameSection.appendChild(newButton)
    document.querySelector(`.${button}`).addEventListener('click', onClick())
    DOMElements.push(button)
  })
}



function capitalize(word){
  return word.charAt(0).toUpperCase()
  + word.slice(1)}

// Remove all elements from the DOM
// Add in elements that I want for each screen
// Elements: Prompt, small input, large input, timer, emoteButtons, submitButton
// Elements need to be customizable (innerText, color, placeholder)
// Elements need to be within certain sections?
