
Packet=require('vs-stun/lib/Packet.js')


stun={}

elapsed=0
stun.handlePacket=(endp, m, rinfo)->

		return null if m[0]   #ignore responses from peer 0x00-request / 0x01-response

		p = Packet.parse(m, {})
		# log0 p, p.doc.attribute.username, p.transactionID, p.cookie

		auth0={}
		auth0.username=p.doc.attribute.username.value.obj
		auth0.password='QOPCcOwvPWS6Ul+NKyh/YGi6'   #EXTRACT YOUR PASSWORD FROM THE offerSDP ice-pwd:QOPCcOwvPWS6Ul+NKyh/YGi6
		# log0 auth0

		response = new Packet(auth0)
		response.type = Packet.BINDING_SUCCESS
		response.transactionID = p.transactionID
		response.cookie = p.cookie
		# response.append.software('test vector', '20');
		response.append.xorMappedAddress({ host: rinfo.address, port: rinfo.port })
		response.append.messageIntegrity()
		response.append.fingerprint()

		endp.send response.raw, 0, response.raw.length, rinfo.port, rinfo.address, ()->
			# log0 'responce send'

		return null if Date.now()<(elapsed+10000)
		elapsed=Date.now()

		ufrags=(''+auth0.username).split(':')
		# log0 ufrags
		process.env.peeruser= (ufrags[1]+':'+ufrags[0])
		auth1={}
		auth1.username=process.env.peeruser
		auth1.password=process.env.peerpass
		# log0 auth1

		request = new Packet(auth1)
		request.type = Packet.BINDING_REQUEST;
		request.transactionID = 'b7e7a701bc34d686fa87dfae';
		request.cookie=p.cookie
		request.append.username(auth1.username, '33');
		request.append.iceControlling('932ff9b151263b36');
		request.append.useCandidate('')
		request.append.priority(0x6e0001ff);
		request.append.messageIntegrity();
		request.append.fingerprint();

		endp.send request.raw, 0, request.raw.length, rinfo.port, rinfo.address, ()->
			# log0 'request send'























module.exports=stun