// **************** Submit Button Functionality ****************** //

// Make submit button clickable
document.querySelector('button').addEventListener('click', onClick)

function onClick(){
  // Update this to actually send the message to the server
  let input = document.querySelector('textarea')
  let userInputValue = input.value
  let nameInput = document.querySelector('input')
  let userNameInput = nameInput.value
  console.log("You pressed the submit button!")
  console.log(`The input from the user was: '${userNameInput}' and '${userInputValue}'`)

  // Make the input readonly and gray so user can't use it again during this time
  makeElementReadOnly(nameInput)
  makeElementReadOnly(input)

  // Disable button and user feedback on button that their text was submitted
  let submitButton = document.querySelector('button')
  submitButton.innerText = "Submitted!"
  submitButton.disabled = true

  // Send packet
  const packet = {
    "action": "join",
    "msg": userInputValue, userNameInput
    }
  sendMessage(JSON.stringify(packet))
  
}

function makeElementReadOnly(element){
  element.value = ""
  element.placeholder = "donezo"
  element.readOnly = true
  element.style.background = "lightgray"
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










