console.log("This code is linked to the html")

let input = document.querySelector('input')
document.querySelector('button').addEventListener('click', collectInput)

function collectInput(){
  let userInputValue = input.value
  console.log("You pressed the submit button!")
  console.log(`The input from the user was: ${userInputValue}`)
  
}

// **************** Web Socket stuff ****************** //
console.log("Hopefully trying to connect to the secure public IP...you should see a message when it is successful!")
const socket = new WebSocket('wss://50.4.187.55:9999'); 

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



