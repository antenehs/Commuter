controlLi = document.getElementById("##NEWCARDNUMBER##");
allInputs = controlLi.getElementsByTagName('input');

var renameButton;
for(var i = 0; i < allInputs.length ; i++){
    if( allInputs[i].value == 'Name' || allInputs[i].value == 'Nimeä')
        renameButton = allInputs[i];
}

renameButton.click();

controlLi = document.getElementById("##NEWCARDNUMBER##");
allInputs = controlLi.getElementsByTagName('input');
var nameInput;
for(var i = 0; i < allInputs.length ; i++){
    if( allInputs[i].name == 'name')
        nameInput = allInputs[i];
}

allButtons = controlLi.getElementsByTagName('button');

var okButton;
for(var i = 0; i < allButtons.length ; i++){
    if( allButtons[i].title == 'Rename' || allButtons[i].title == 'Nimeä')
        okButton = allButtons[i];
}

if(nameInput){
    nameInput.value = "##NEWCARDNAME##";
    okButton.click();
}else{
    alert('Naming card failed. Please rename the card from omamatkakortti.fi');
}

