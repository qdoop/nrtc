
_dtls= require('./build/Release/cyassldtls')



log0 _dtls.init()

dtls={}
dtls.handlePacket=(endp, m, rinfo)->
	_dtls.spin(m)











module.exports=dtls