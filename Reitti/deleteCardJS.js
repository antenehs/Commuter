controlLi = document.getElementById("##CARDNUMBER##");
allButtons = controlLi.getElementsByTagName('input');

var deleteBut;
for(var i = 0; i < allButtons.length ; i++){
    if( allButtons[i].value == 'Delete' || allButtons[i].value == 'Poista')
        deleteBut = allButtons[i];
}

if(deleteBut){
    deleteBut.click()
    confirmBut = document.getElementById('card_confirm_remove_ok');
    confirmBut.click();
}else{
    alert('Deleting card failed. Please delete the card from omamatkakortti.fi');
}
