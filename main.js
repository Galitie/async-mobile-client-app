
// Add event listeners
document.body.addEventListener("requestJoin", onJoinRequest)
//elem.AddEventListener("refuseJoin", onJoinRefuse(packet))


function onJoinRequest(packet) {
  console.log("I got your join request")
}

// **************** Submit Button Functionality ****************** //
// Make submit button clickable
let submitButton = document.querySelector('button')
submitButton.addEventListener('click', onClick)

function onClick() {
  // Get name inputs element and value
  let [nameInput, nameInputValue] = getInput('input')
  let [textInput, textInputValue] = getInput('textarea')

  // Make the input readonly and gray so user can't use it again during this time
  makeElementsReadOnly([nameInput, textInput, submitButton])
 
  // Send packet
  const packet = {
    "action": "join",
    "name": nameInputValue,
    "role": "user"
  }
  sendMessage(JSON.stringify(packet))
}

// addButtons(['Catchphrase'], ['catchphrase'])

// function addButtons(buttonNamesText, addClass){
//   buttonNamesText.forEach((button, i) => {
//     let x = document.createElement("BUTTON");
//     let text = document.createTextNode(`${button}`);
//     x.appendChild(text);
//     x.classList.add(`${addClass}`)
//     let parent = document.querySelector('.submit').parentNode
//     parent.insertBefore(x, document.querySelector('.submit'))
//     document.querySelector(`.${addClass}`).addEventListener('click', test)
//     console.log(document.querySelector('button'))
//   })
// }

// function test(){
//   console.log("you pressed a button cool")
// }

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

function getInput(elementName){
  let input = document.querySelector(`${elementName}`)
  let inputValue = input.value
  return [input, inputValue]
 
}



//


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
  console.log('Received message:', message);
  document.body.dispatchEvent(message["message"], message)
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



// make a class for packets
// class Packet
// class JoinPacket extends Packet
// class InputPacket extends Packet
// class ExitPacket extends Packet

// var as nouns
// methods as verbs
// share behaviours: ex: send a packet

// enableElements(elements)
// or toggle

// maybe client has persistent states?


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


// Remove all elements from the DOM
// Add in elements that I want for each screen
// Elements: Prompt, small input, large input, timer, emoteButtons, submitButton
// Elements need to be customizable (innerText, color, placeholder)
// Elements need to be within certain sections?
