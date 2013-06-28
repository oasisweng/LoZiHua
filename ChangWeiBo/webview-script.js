
function getInputSelection(el) {
	var start = 0, end = 0;
	
	start = el.caret().start.value;
	end =  el.caret().end.value;
	
	returnResult("storeCaretPosition",[start,end,0]);
}
 
 function offsetToRangeCharacterMove(el, offset) {
 return offset - (el.value.slice(0, offset).split("\r\n").length - 1);
 }
 
 function setInputSelection(el, startOffset, endOffset) {
 el.focus();
 NativeBridge.call("setCaretPosition",[startOffset,endOffset,1]);
 if (typeof el.selectionStart == "number" && typeof el.selectionEnd == "number") {
 el.selectionStart = startOffset;
 el.selectionEnd = endOffset;
 } else {
 var range = el.createTextRange();
 var startCharMove = offsetToRangeCharacterMove(el, startOffset);
 range.collapse(true);
 if (startOffset == endOffset) {
 range.move("character", startCharMove);
 } else {
 range.moveEnd("character", offsetToRangeCharacterMove(el, endOffset));
 range.moveStart("character", startCharMove);
 }
 range.select();
 }
 }

function createHTMLNode(htmlCode, tooltip) {
	// create html node
	var htmlNode = document.createElement('span');
	htmlNode.innerHTML = htmlCode
	htmlNode.className = 'treehtml';
	htmlNode.setAttribute('title', tooltip);
	return htmlNode;
}

 function returnResult(functionName,args){
 NativeBridge.call(functionName,args);
 }
 document.addEventListener("blur",function () {
									//getInputSelection(document.getElementById('content'));
									},false);