
// **************** Submit Button Functionality ****************** //

// Make submit button clickable
let submitButton = document.querySelector('button')
submitButton.addEventListener('click', onClick)

// addButtons(['Catchphrase'], 'catchphrase')

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
    "role": "user" // dunno if this works
  }
  sendMessage(JSON.stringify(packet))
}

// function addButtons(buttonNames, addClass){
//   buttonNames.forEach(button => {
//     let x = document.createElement("BUTTON");
//     let text = document.createTextNode(`${button}`);
//     x.appendChild(text);
//     x.classList.add(`${addClass}`)
//     document.body.appendChild(x);
//   })
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
    "action": "checkForHost"
  }
  sendMessage(JSON.stringify(packet))

};

// Message received event
socket.onmessage = function (event) {
  const message = event.data;
  console.log('Received message:', message);

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
