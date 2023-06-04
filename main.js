console.log("This code is linked to the html")

let input = document.querySelector('input')
document.querySelector('button').addEventListener('click', collectInput)

function collectInput(){
  let userInputValue = input.value
  console.log("You pressed the submit button!")
  console.log(userInputValue)
  
}

// **************** Web Socket stuff ****************** //
const socket = new WebSocket('ws://192.168.0.77:9999'); // input these later

// fired when the server is connected
socket.addEventListener('open', () => {
  console.log('Connected to the server.');
});

// fires when a message is recieved from the server
socket.addEventListener('message', (event) => {
  const message = event.data;
  console.log('Received message from the server:', message);
});

// Receiving data from the server
socket.addEventListener('message', (event) => {
  const message = event.data;
  console.log('Received message from the server:', message);
});

// fires when the connection to the server closes
socket.addEventListener('close', () => {
  console.log('Connection closed.');
});

// test message to the server
socket.send('Hello, server!');



