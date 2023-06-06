// **************** Submit Button Functionality ****************** //

// Make submit button clickable
document.querySelector('button').addEventListener('click', onClick)

function onClick() {
  // Update this to actually send the message to the server
  let input = document.querySelector('textarea')
  let userInputValue = input.value
  console.log("You pressed the submit button!")
  console.log(`The input from the user was: ${userInputValue}`)

  // Make the input readonly and gray so user can't use it again during this time
  input.value = ""
  input.placeholder = "no takebacksies"
  input.readOnly = true
  input.style.background = "lightgray"

  // Disable button and user feedback on button that their text was submitted
  let submitButton = document.querySelector('button')
  submitButton.innerText = "Submitted!"
  submitButton.disabled = true

  const packet = {
    "action": "join",
    "name": userInputValue
  }
  sendMessage(JSON.stringify(packet))
}

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
};

// Message received event
socket.onmessage = function (event) {
  const message = event.data;
  console.log('Received message:', message);
  document.querySelector('h1').innerText = "This worked!"
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
}










