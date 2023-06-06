
// **************** Submit Button Functionality ****************** //

// Make submit button clickable
let submitButton = document.querySelector('button')
submitButton.addEventListener('click', onClick)

function onClick() {
  // Get name input value
  let nameInput = document.querySelector('input')
  let userNameInputValue = nameInput.value

  // Get textarea value
  let input = document.querySelector('textarea')
  let userInputValue = input.value

  // Log actions
  console.log("You pressed the submit button!")
  console.log(`The input from the user was: '${userNameInputValue}' and '${userInputValue}'`)

  // Make the input readonly and gray so user can't use it again during this time
  makeElementReadOnly(nameInput)
  makeElementReadOnly(input)
  makeElementReadOnly(submitButton)

  // Send packet
  const packet = {
    "action": "join",
    "name": userNameInputValue,
    "msg": userInputValue // dunno if this works
  }
  sendMessage(JSON.stringify(packet))
}

function makeElementReadOnly(element){
  element.readOnly = true
  element.style.background = "lightgray"
  element.innerText = "Submitted"
}




//


// **************** Web Socket stuff ****************** //
let playerServerStatus = document.querySelector('h4')

// Create a WebSocket connection
const websocketUrl = 'wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/prod';
const socket = new WebSocket(websocketUrl);

// Connection opened event
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








