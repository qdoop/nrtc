


ws = new WebSocket('ws://localhost:3000/')

console.log ws


ws.onopen=(ev)->
	console.log 'ws open:',ev

ws.onclose=(ev)->
	console.log 'ws close:',ev

ws.onerror=(ev)->
	console.log 'ws error:', ev

ws.onmessage=(ev)->
	console.log 'ws message:',ev



window.ws0=ws