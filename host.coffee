http    = require("http")
express = require('express')
wapp    = express()
WebSocketServer = require('ws').Server


# wapp.get '/', (req, res)->
# 	res.send('Hello World!')


# wapp.use '/wapp', express.static('out')
wapp.use '/', express.static('out')



wserver = http.createServer(wapp)
wserver.listen 3000, ()->
	host = wserver.address().address
	port = wserver.address().port
	console.log('Example app listening at http://%s:%s', host, port)


wwss = new WebSocketServer({server: wserver})
wwss.on 'connection', (ws)->	
	console.log('client connected')
	ws.send JSON.stringify({}), ()->
		# console.log 'done'
		
	ws.on 'close', ()->
		console.log('ws close:')

	ws.on 'message', (m)->
		console.log m

		a=m.split('\\r\\n')
		log0 a
		for x in a
			x=x.trim()
			continue if -1==x.indexOf('a=ice-pwd:')
			process.env.peerpass=x.replace('a=ice-pwd:','')
			log0 x, process.env.peerpass
			break


module.exports={wapp, wwss}