
// Make submit button clickable
document.querySelector('button').addEventListener('click', collectInput)

function collectInput(){
  // Update this to actually send the message to the server
  let input = document.querySelector('textarea')
  let userInputValue = input.value
  console.log("You pressed the submit button!")
  console.log(`The input from the user was: ${userInputValue}`)
  input.value = ""
  input.placeholder = "no takebacksies"
  input.readOnly = true
  input.style.background = "lightgray"

  // User feedback on button that their text was submitted
  let submitButton = document.querySelector('button')
  submitButton.innerText = "Submitted!"
  submitButton.disabled = true

  
}
//


// **************** Web Socket stuff ****************** //
let playerServerStatus = document.querySelector('h4')



// Create a WebSocket connection
const websocketUrl = 'wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/stage/';
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










