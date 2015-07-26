var loginForm = document.getElementById('aspnetForm')

var username = document.getElementById('Etuile_MainContent_LoginControl_LoginForm_UserName')
var password = document.getElementById('Etuile_MainContent_LoginControl_LoginForm_Password')
var submitButton = document.getElementById('Etuile_MainContent_LoginControl_LoginForm_LoginButton')

username.value = "##USERNAME##"
password.value = "##PASSWORD##"

submitButton.click()
