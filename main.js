console.log("This code is linked to the html")

let input = document.querySelector('input')
document.querySelector('button').addEventListener('click', collectInput)

function collectInput(){
  let userInputValue = input.value
  console.log("You pressed the submit button!")
  console.log(`The input from the user was: ${userInputValue}`)
  
}

// **************** Web Socket stuff ****************** //
console.log("Hopefully trying to connect to the secure public IP... please wait about 30 seconds, you should see a message when it is successful!")

// AWS
const websocketUrl = 'wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/stage/';

// Create a WebSocket connection
const socket = new WebSocket(websocketUrl);

// Connection opened event
socket.onopen = function (event) {
  console.log('WebSocket connection established.');
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
};

// Send a message to the WebSocket API
function sendMessage(message) {
  socket.send(message);
}










