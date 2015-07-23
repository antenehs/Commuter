
var submitButton = document.getElementById('Etuile_Cards_show_add_card_form')
submitButton.click()

var cardNumber = document.getElementById('add_card_id')
var cardName = document.getElementById('add_card_name')


cardNumber.value = '##NEWCARDNUMBER##'
cardName.value = '##NEWCARDNAME##'

var saveButton = document.getElementById('add_card_submit')
saveButton.click()
