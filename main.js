console.log("This code is linked to the html")

let input = document.querySelector('input')
document.querySelector('button').addEventListener('click', test)

function test(){
  let userInputValue = input.value
  console.log("You pressed the submit button!")
  console.log(userInputValue)
  
}
