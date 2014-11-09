
dgram = require('dgram')

endp = dgram.createSocket('udp4');
global.endp0=endp

stun=require('./node_stun.coffee')
dtls=require('./node_dtls.coffee')
sctp=require('./node_sctp.coffee')


	#             +----------------+
	#             | 127 < B < 192 -+--> forward to RTP
	#             |                |
	# packet -->  |  19 < B < 64  -+--> forward to DTLS
	#             |                |
	#             |       B < 2   -+--> forward to STUN
	#             +----------------+

endp.on 'error', (err)->
	console.log("server error:\n" + err.stack)
	endp.close()


endp.on 'listening', ()->
	address = endp.address()
	console.log("server listening " + address.address + ":" + address.port)



global.dump0=(b,w)->
	hex=b.toString('hex')
	pos=0
	w=w||32
	while pos<hex.length
		console.log hex.substring(pos,pos+w)
		pos=pos+w

global._hex=(b)->
	b.toString('hex')



global.peerData0=(dat)->
	log0 'peerData0', dat.length
	dump0 dat, 8
	


global.peerSend0=(raw)->
	rinfo=global.peerRInfo0||{address:'127.0.0.1', port:50001}
	endp.send raw, 0, raw.length, rinfo.port, rinfo.address, ()->
		# log0 'peerSend0', raw.length



endp.on 'message', (m, rinfo)->
	# console.log("server got: " + msg + " from " + rinfo.address + ":" + rinfo.port)
	# console.log {t:m.readUInt16BE(0), len:m.length, port:rinfo.port}
	# return null
	global.peerRInfo0=rinfo

	return stun.handlePacket(endp, m, rinfo) if m[0] < 2
	return dtls.handlePacket(endp, m, rinfo) if m[0] < 64

	return log0('_________________________SRTP packet')



# endp.bind(50001)
# endp.bind(50001,'127.0.0.1')
endp.bind(50001,'192.168.1.5')

module.exports={endp}