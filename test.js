function proceed () {
    var form = document.createElement('form');
    form.setAttribute('method', 'post');
    form.setAttribute('action', 'http://google.com');
    form.style.display = 'hidden';
    document.body.appendChild(form)
    form.submit();
}
