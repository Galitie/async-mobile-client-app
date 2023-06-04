console.log("This is working!")

document.querySelector("button").addEventListener("click", postIt)

function postIt(){
fetch("https://https://galitie.github.io/tyler/", {
  method: "POST",
  body: JSON.stringify({
    userId: 1,
    title: "Fix my bugs",
    completed: false
  }),
  headers: {
    "Content-type": "application/json; charset=UTF-8"
  }
})
  .then((response) => response.json())
  .then((json) => console.log(json));
}
