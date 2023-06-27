// Refactoring Event Listeners now that I know I can pass arguments
// Styling everything
// Making UI friendly to laptops (incase someone needs to use a computer?)

// make dating sim portraits square proportion
// make more rooms
// find tile sets for dating sim portion

// Need to test if this fixes issue where keyboard pushes content around!
navigator.virtualKeyboard.overlaysContent = true
let packageContext = ''
// ************************* Screens *************************** //

// If player is not connected
function notConnectedScreen(){
  console.log("Host or Server not connected")
  clearIDGameInDOM()
  addPrompt(`TYLERPG`)
  addPrompt(`Click below to join or re-join the game!`)
  addButtons(['connect'])
}

// Prompt screen
function promptScreen(prompt, timerAmount, includeEmojiTray, inputs){
  clearIDGameInDOM()
  addPrompt(prompt)

  if (timerAmount > 0) {
    addTimer(timerAmount)
  }

  if (inputs.small) {
    addInput(['smallInput'])
    document.querySelector('.smallInput').setAttribute('placeholder', inputs.small)
  }
  if (inputs.big) {
    addInput(['bigInput'])
    document.querySelector(".bigInput").setAttribute("placeholder", inputs.big)
  }

  addButtons(['submit'])

  if (includeEmojiTray == true) {
    addEmojiTray()
  }
}


// ****************** Button Functionality ******************** //
function onClickSubmit() {
  let textboxes
  let packet = {
    "action": "messageHost",
    "message": "sendText",
    "context": `${packageContext}`
  }

  if (document.querySelector('.bigInput') && document.querySelector('.smallInput')){
    let [smallInput, smallInputValue] = getInputAndValue('smallInput')
    let [bigInput, bigInputValue] = getInputAndValue('bigInput')
    textboxes = [smallInput, bigInput]
    
    if (validateInputs(textboxes) == false) {
      return
    }

    packet.smallInputValue = smallInputValue
    packet.bigInputValue = bigInputValue
    
  } else if (document.querySelector('.bigInput')) {
      let [bigInput, bigInputValue] = getInputAndValue('bigInput')
      textboxes = [bigInput]
    
      if (validateInputs(textboxes) == false) {
        return
      }

      packet.bigInputValue = bigInputValue

  } else {
    let [smallInput, smallInputValue] = getInputAndValue('smallInput')
    textboxes = [smallInput]

    if (validateInputs(textboxes) == false) {
      return
    }

    packet.smallInputValue = smallInputValue
  }

  sendMessage(JSON.stringify(packet))
  cleanUpInput(textboxes)
}
 

function onClickEmoji(emojiClass, emoji) {

  const packet = {
    "action": "messageHost",
    "message": "sendText",
    "content": `${emoji}`
    }
    sendMessage(JSON.stringify(packet))
}

// this is only for the not connected screen
function onClickConnect(){
  location.reload(true)
}



//********************* Screen Pieces ************************//

function clearIDGameInDOM() {
  let rootElement = document.querySelector('#game');

  while (rootElement.firstChild) {
    rootElement.removeChild(rootElement.firstChild);
  }

}


function addTimer(duration) {
  let timer = duration, minutes, seconds;

  let displayElement = document.createElement("h3")
  let displayElementText = document.createTextNode("");
  displayElement.appendChild(displayElementText);

  let parent = document.querySelector(`#game`)
  parent.appendChild(displayElement)
  

  let countdown = setInterval(function() {
    minutes = parseInt(timer / 60, 10);
    seconds = parseInt(timer % 60, 10);

    minutes = minutes < 10 ? "0" + minutes : minutes;
    seconds = seconds < 10 ? "0" + seconds : seconds;

    displayElement.textContent =  minutes + ":" + seconds;
    

    if (timer > 0 && timer < 6){
      --timer
      displayElement.classList.add("pulsate")
    }

    else if(--timer < 0) {
      clearInterval(countdown);
      displayElement.classList.remove("pulsate")
    }
  }, 1000);
}


function addPrompt(str) {
  console.log(str)
  let newPrompt = document.createElement("h1")
  let newPromptText = document.createTextNode(str);
  newPrompt.appendChild(newPromptText);
  let gameSection = document.querySelector('#game')
  gameSection.appendChild(newPrompt)
}


function addInput(inputClasses) {
  inputClasses.forEach(input => {
    let newInput = document.createElement("TEXTAREA")
    newInput.classList.add(`${input}`)
    if(input === "bigInput"){
      newInput.setAttribute("rows", "3")
      newInput.setAttribute("placeholder", "Type something and press submit!")
      newInput.setAttribute("maxlength", "50")
    } else if (input === "smallInput"){
      newInput.setAttribute("placeholder", "Type something!")
      newInput.setAttribute("maxlength", "15")
    }
    let gameSection = document.querySelector('#game')
    gameSection.appendChild(newInput)
  })
}


function addButtons(buttonClasses) {
  buttonClasses.forEach((button) => {
    let newButton = document.createElement('BUTTON')
    let newButtonText = document.createTextNode(capitalize(button))
    newButton.appendChild(newButtonText)
    newButton.classList.add(`${button}`)
    document.querySelector('#game').appendChild(newButton)
    let getElementButton = document.querySelector(`.${button}`)
    getElementButton.addEventListener('click', buttonMap[button])
  
  })
}

let buttonMap = {
  'submit': onClickSubmit,
  'connect': onClickConnect
}


function addEmojiTray() {
  let emojiCollection = ['❤️', '😭', '🐝', '❗']

  let newSection = document.createElement("SECTION")
  newSection.setAttribute('id', 'emojiContainer')

  document.querySelector('#game').appendChild(newSection)

  for(let i=0; i < emojiCollection.length; i++){
    let newButton = document.createElement("BUTTON");
    let newButtonText = document.createTextNode(emojiCollection[i])
    newButton.appendChild(newButtonText)
    newButton.classList.add(`emoji${i}`)
    newSection.appendChild(newButton)
    document.querySelector(`.emoji${i}`).addEventListener("click", function () {
      onClickEmoji(`emoji${i}`, `${newButton.innerText}`)
    })
  }
}


function capitalize(word){return word.charAt(0).toUpperCase() + word.slice(1)}


function enableElements(elementClasses) {
  elementClasses.forEach(element => {
    document.querySelector(`.${element}`).disabled = false
    document.querySelector(`.${element}`).classList.remove("disabled")
    document.querySelector(`.${element}`).innerText = capitalize(`${elementClasses}`)
  })
}


function makeElementsReadOnly(elementClasses) {
  elementClasses.forEach(element => {
    document.querySelector(`.${element}`).disabled = true
    document.querySelector(`.${element}`).classList.add("disabled")
    document.querySelector(`.${element}`).innerText = "Submitted"
  })
}


function getInputAndValue(elementClass) {
  let input = document.querySelector(`.${elementClass}`)
  let inputValue = input.value
  return [input, inputValue]
 
}

function cleanUpInput(textboxes){
  textboxes.forEach(textbox => {
    textbox.value = ""
    textbox.classList.remove("missedInput")
  })
}

function validateInputs(inputs){
  let inputValid = true
  inputs.forEach(input => {
    if (input.value == ""){
      input.classList.add("missedInput")
      inputValid = false
    }
  })
  return inputValid
}