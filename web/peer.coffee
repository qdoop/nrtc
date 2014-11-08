

done=(x)->
	console.log('__done')

fail=(x)->
	console.error('__fail',x) 


createAPeerConnection=()->
	IS_CHROME = !!window.webkitRTCPeerConnection
	RTCPeerConnection 		=null
	RTCIceCandidate  		=null
	RTCSessionDescription   =null
	 
	if IS_CHROME 
		RTCPeerConnection 		= webkitRTCPeerConnection
		RTCIceCandidate 		= window.RTCIceCandidate
		RTCSessionDescription 	= window.RTCSessionDescription
	else
		RTCPeerConnection 		= mozRTCPeerConnection
		RTCIceCandidate 		= mozRTCIceCandidate
		RTCSessionDescription 	= mozRTCSessionDescription

	
	pc={}
	pc.options={}
	pc.options.ice={ iceServers: [ {"urls": "stun:stun.l.google.com:19302"  }] } 

	
	pc.connection = new RTCPeerConnection( pc.options.ice )

	pc.cleanupConnection=()->
		console.log 'cleanup:'

	pc.connection.onsignalingstatechange=(ev)->
		console.log 'signalingState:', pc.connection.signalingState

	pc.connection.oniceconnectionstatechange=(ev)->
		console.log 'iceConnectionState:', pc.connection.iceConnectionState
		pc.cleanupConnection() if 'disconnected'==pc.connection.iceConnectionState

	pc.connection.onnegotiationneeded=(ev)->
		console.log 'negotiationNeed:', ev

	pc.connection.onicecandidate=(ev)->
		console.log 'onicecandidate:', ev


	pc.connection.onaddstream=(ev)->
		console.log 'got remote stream:>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'


	pc.connection.ondatachannel=(ev)->
		console.log 'ondatachannel:', ev
		pc.dataChannel=ev.channel
		
		pc.dataChannel.onmessage = (ev)->
			console.log  ev.data

		pc.dataChannel.onopen = (ev)->
			console.log  ev

		pc.dataChannel.onclose = (ev)->
			console.log ev



	pc.setRemoteOfferHelper=(offer)->
		remoteDone=()->
			answerDone=(description)->
				localDone=()->

					console.log description
					#SEND TO NODE SIDE==================>
					window.ws0.send( JSON.stringify(description) )

				pc.connection.setLocalDescription(description, localDone, fail)
			pc.connection.createAnswer( answerDone, fail )
		pc.connection.setRemoteDescription( new RTCSessionDescription(offer), remoteDone, fail)



	pc.createAnOfferHelper=()->
		dc=pc.connection.createDataChannel('text0',{})
		pc.connection.addStream(window.localMediaStream0)
	
		offerDone=(description)->
			localDone=()->

				offerSDP=JSON.stringify(description)
				localStorage.setItem "offerSDP", offerSDP

				console.log '---SAMPLE OFFER---------------------------'
				console.log offerSDP
				alert 'Sample Offer Created!'
				#SEND IT TO THE OTHER SIDE=================>
				
			pc.connection.setLocalDescription(description, localDone, fail)

		pc.connection.createOffer(offerDone, fail)
			
	#return created connection		
	return pc


	
	


window.localMediaStream0=null
window.startWebrtc=()->
	getUserMediaAAA=null
	if navigator.mozGetUserMedia
		getUserMediaAAA = navigator.mozGetUserMedia.bind(navigator)

	if navigator.webkitGetUserMedia
		getUserMediaAAA = navigator.webkitGetUserMedia.bind(navigator)

	failMedia=(error)->
		alert error

	doneMedia=(localMediaStream)->
		window.localMediaStream0=localMediaStream
		player     = document.getElementById('player0')
		player.src = window.URL.createObjectURL(localMediaStream) if player

		window.pc0=createAPeerConnection()
		window.pc0.connection.addStream(window.localMediaStream0)


		#HELPER TO CREATE AN OFFER 
		#return window.pc0.createAnOfferHelper() 



		setNodeSideOffer=()->
			sdp=localStorage.getItem("offerSDP")
			console.log '---STORED OFFER-------------------------'
			console.log sdp
	
			# SAMPLE OFFER from sampleSDP.txt
			# sdp='{"sdp":"v=0\r\no=- 7310004555701929068 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE audio data\r\na=msid-semantic: WMS 5FScYXNYQQc55JHUw357rlkQVybpF7LvtHhd\r\nm=audio 1 RTP/SAVPF 111 103 104 0 8 106 105 13 126\r\nc=IN IP4 0.0.0.0\r\na=rtcp:1 IN IP4 0.0.0.0\r\na=ice-ufrag:9rb8eDnyFmbmxkSp\r\na=ice-pwd:QOPCcOwvPWS6Ul+NKyh/YGi6\r\na=ice-options:google-ice\r\na=fingerprint:sha-256 9F:34:B2:8D:EA:15:54:54:EC:3D:DA:12:7C:21:FE:2A:46:F9:1A:B9:B3:CA:68:01:BF:2B:B7:A2:09:03:26:C3\r\na=setup:actpass\r\na=mid:audio\r\na=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level\r\na=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time\r\na=sendrecv\r\na=rtcp-mux\r\na=rtpmap:111 opus/48000/2\r\na=fmtp:111 minptime=10\r\na=rtpmap:103 ISAC/16000\r\na=rtpmap:104 ISAC/32000\r\na=rtpmap:0 PCMU/8000\r\na=rtpmap:8 PCMA/8000\r\na=rtpmap:106 CN/32000\r\na=rtpmap:105 CN/16000\r\na=rtpmap:13 CN/8000\r\na=rtpmap:126 telephone-event/8000\r\na=maxptime:60\r\na=ssrc:2828072780 cname:nKTzW9giqfzWZ/sV\r\na=ssrc:2828072780 msid:5FScYXNYQQc55JHUw357rlkQVybpF7LvtHhd 69d49dbf-dd43-4dff-ad49-3c369a937c63\r\na=ssrc:2828072780 mslabel:5FScYXNYQQc55JHUw357rlkQVybpF7LvtHhd\r\na=ssrc:2828072780 label:69d49dbf-dd43-4dff-ad49-3c369a937c63\r\nm=application 1 DTLS/SCTP 5000\r\nc=IN IP4 0.0.0.0\r\na=ice-ufrag:9rb8eDnyFmbmxkSp\r\na=ice-pwd:QOPCcOwvPWS6Ul+NKyh/YGi6\r\na=ice-options:google-ice\r\na=fingerprint:sha-256 9F:34:B2:8D:EA:15:54:54:EC:3D:DA:12:7C:21:FE:2A:46:F9:1A:B9:B3:CA:68:01:BF:2B:B7:A2:09:03:26:C3\r\na=setup:actpass\r\na=mid:data\r\na=sctpmap:5000 webrtc-datachannel 1024\r\n","type":"offer"}'
			# sdp=sdp.split('\r\n').join('\\r\\n')

			#FIX NODE SIDE CERTIFICATE FINGERPRINT
			# fx0='a=fingerprint:sha-256 9F:34:B2:8D:EA:15:54:54:EC:3D:DA:12:7C:21:FE:2A:46:F9:1A:B9:B3:CA:68:01:BF:2B:B7:A2:09:03:26:C3'
			# fx1='a=fingerprint:sha-256 81:80:FC:02:FD:62:E8:E9:41:5C:01:73:56:6B:D3:AD:21:D9:97:0B:C8:1C:80:67:55:B7:31:27:9D:E9:19:4F'
			# sdp=sdp.replace(fx0,fx1)
			# sdp=sdp.replace(fx0,fx1)
			# sdp=sdp.replace(fx0,fx1)

			fx1='a=fingerprint:sha-256 81:80:FC:02:FD:62:E8:E9:41:5C:01:73:56:6B:D3:AD:21:D9:97:0B:C8:1C:80:67:55:B7:31:27:9D:E9:19:4F'
			lines=sdp.split('\\r\\n')
			lines.map (x, i)->
				lines[i]=fx1 if 0==x.indexOf('a=fingerprint')

			sdp=lines.join('\\r\\n')
			
			window.pc0.setRemoteOfferHelper( JSON.parse(sdp) )

		setTimeout setNodeSideOffer, 1000



		setNodeSideCandidates=()->
			#REPLACE IP AND PORT (192.168.1.5 50001 -> .....)
			c0='{"sdpMLineIndex":0,"sdpMid":"audio","candidate":"candidate:211156821 1 udp 2122194687 192.168.1.5 50001 typ host generation 0"}'
			c1='{"sdpMLineIndex":1,"sdpMid":"data","candidate":"candidate:211156821 1 udp 2122194687 192.168.1.5 50001 typ host generation 0"}'

			window.pc0.connection.addIceCandidate(new RTCIceCandidate( JSON.parse(c0) ) ,done, fail)
			window.pc0.connection.addIceCandidate(new RTCIceCandidate( JSON.parse(c1) ) ,done, fail)

		setTimeout setNodeSideCandidates, 2000



	#get the local media to send
	getUserMediaAAA {audio: true, video: false} , doneMedia, failMedia



window.startWebrtc()