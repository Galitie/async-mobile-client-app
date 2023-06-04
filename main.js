console.log("This code is linked to the html")

let input = document.querySelector('input').value
document.querySelector('button').addEventListener('click', test)

function test(){
  console.log("You pressed the submit button!")
  console.log(input)

}
