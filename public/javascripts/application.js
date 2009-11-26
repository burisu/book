// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function insertion0(input, repdeb, repfin) {
    /*var input = document.forms['formulaire'].elements['saisie'];*/
    input.focus();
    /* pour l'Explorer Internet */
    if(typeof document.selection != 'undefined') {
	/* Insertion du code de formatage */
	var range = document.selection.createRange();
	var insText = range.text;
	range.text = repdeb + insText + repfin;
	/* Ajustement de la position du curseur */
	range = document.selection.createRange();
	if (insText.length == 0) {
	    range.move('character', -repfin.length);
	} else {
	    range.moveStart('character', repdeb.length + insText.length + repfin.length);
	}
	range.select();
    }
    /* pour navigateurs plus récents basés sur Gecko*/
    else if(typeof input.selectionStart != 'undefined')	{
	/* Insertion du code de formatage */
	var start = input.selectionStart;
	var end = input.selectionEnd;
	var insText = input.value.substring(start, end);
	input.value = input.value.substr(0, start) + repdeb + insText + repfin + input.value.substr(end);
	/* Ajustement de la position du curseur */
	var pos;
	if (insText.length == 0) {
	    pos = start + repdeb.length;
	} else {
	    pos = start + repdeb.length + insText.length + repfin.length;
	}
	input.selectionStart = pos;
	input.selectionEnd = pos;
    }
    /* pour les autres navigateurs */
    else {
	/* requête de la position d'insertion */
	var pos;
	var re = new RegExp('^[0-9]{0,3}$');
	while(!re.test(pos)) {
	    pos = prompt("Insertion à la position (0.." + input.value.length + "):", "0");
	}
	if(pos > input.value.length) {
	    pos = input.value.length;
	}
	/* Insertion du code de formatage */
	var insText = prompt("Veuillez entrer le texte à formater:");
	input.value = input.value.substr(0, pos) + repdeb + insText + repfin + input.value.substr(pos);
    }
}



function insertion(input, repdeb, repfin, middle) {
    if(middle=='undefined') {middle='';}
    input.focus();
    /* pour l'Explorer Internet */
    if(typeof document.selection != 'undefined') {
	/* Insertion du code de formatage */
	var range = document.selection.createRange();
	var insText = range.text;
        if (insText.length <= 0) { insText = middle; }
	range.text = repdeb + insText + repfin;
	/* Ajustement de la position du curseur */
	range = document.selection.createRange();
	if (insText.length == 0) {
	    range.move('character', -repfin.length);
	} else {
	    range.moveStart('character', repdeb.length + insText.length + repfin.length);
	}
	range.select();
    }
    /* pour navigateurs plus récents basés sur Gecko*/
    else if(typeof input.selectionStart != 'undefined')	{
	/* Insertion du code de formatage */
	var start = input.selectionStart;
	var end = input.selectionEnd;
	var insText = input.value.substring(start, end);
        if (insText.length <= 0) { insText = middle; }
	input.value = input.value.substr(0, start) + repdeb + insText + repfin + input.value.substr(end);
	/* Ajustement de la position du curseur */
	var pos;
	if (insText.length == 0) {
	    pos = start + repdeb.length;
	} else {
	    pos = start + repdeb.length + insText.length + repfin.length;
	}
	input.selectionStart = pos;
	input.selectionEnd = pos;
    }
    /* pour les autres navigateurs */
    else {
	/* requête de la position d'insertion */
	var pos;
	var re = new RegExp('^[0-9]{0,3}$');
	while(!re.test(pos)) {
	    pos = prompt("Insertion à la position (0.." + input.value.length + ") :", "0");
	}
	if(pos > input.value.length) {
	    pos = input.value.length;
	}
	/* Insertion du code de formatage */
	var insText = prompt("Veuillez entrer le texte à formater :");
        if (insText.length <= 0) { insText = middle; }
	input.value = input.value.substr(0, pos) + repdeb + insText + repfin + input.value.substr(pos);
    }
}

