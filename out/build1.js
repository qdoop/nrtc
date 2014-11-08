(function() {
  var createAPeerConnection, done, fail;

  done = function(x) {
    return console.log('__done');
  };

  fail = function(x) {
    return console.error('__fail', x);
  };

  createAPeerConnection = function() {
    var IS_CHROME, RTCIceCandidate, RTCPeerConnection, RTCSessionDescription, pc;
    IS_CHROME = !!window.webkitRTCPeerConnection;
    RTCPeerConnection = null;
    RTCIceCandidate = null;
    RTCSessionDescription = null;
    if (IS_CHROME) {
      RTCPeerConnection = webkitRTCPeerConnection;
      RTCIceCandidate = window.RTCIceCandidate;
      RTCSessionDescription = window.RTCSessionDescription;
    } else {
      RTCPeerConnection = mozRTCPeerConnection;
      RTCIceCandidate = mozRTCIceCandidate;
      RTCSessionDescription = mozRTCSessionDescription;
    }
    pc = {};
    pc.options = {};
    pc.options.ice = {
      iceServers: [
        {
          "urls": "stun:stun.l.google.com:19302"
        }
      ]
    };
    pc.connection = new RTCPeerConnection(pc.options.ice);
    pc.cleanupConnection = function() {
      return console.log('cleanup:');
    };
    pc.connection.onsignalingstatechange = function(ev) {
      return console.log('signalingState:', pc.connection.signalingState);
    };
    pc.connection.oniceconnectionstatechange = function(ev) {
      console.log('iceConnectionState:', pc.connection.iceConnectionState);
      if ('disconnected' === pc.connection.iceConnectionState) {
        return pc.cleanupConnection();
      }
    };
    pc.connection.onnegotiationneeded = function(ev) {
      return console.log('negotiationNeed:', ev);
    };
    pc.connection.onicecandidate = function(ev) {
      return console.log('onicecandidate:', ev);
    };
    pc.connection.onaddstream = function(ev) {
      return console.log('got remote stream:>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    };
    pc.connection.ondatachannel = function(ev) {
      console.log('ondatachannel:', ev);
      pc.dataChannel = ev.channel;
      pc.dataChannel.onmessage = function(ev) {
        return console.log(ev.data);
      };
      pc.dataChannel.onopen = function(ev) {
        return console.log(ev);
      };
      return pc.dataChannel.onclose = function(ev) {
        return console.log(ev);
      };
    };
    pc.setRemoteOfferHelper = function(offer) {
      var remoteDone;
      remoteDone = function() {
        var answerDone;
        answerDone = function(description) {
          var localDone;
          localDone = function() {
            console.log(description);
            return window.ws0.send(JSON.stringify(description));
          };
          return pc.connection.setLocalDescription(description, localDone, fail);
        };
        return pc.connection.createAnswer(answerDone, fail);
      };
      return pc.connection.setRemoteDescription(new RTCSessionDescription(offer), remoteDone, fail);
    };
    pc.createAnOfferHelper = function() {
      var dc, offerDone;
      dc = pc.connection.createDataChannel('text0', {});
      pc.connection.addStream(window.localMediaStream0);
      offerDone = function(description) {
        var localDone;
        localDone = function() {
          var offerSDP;
          offerSDP = JSON.stringify(description);
          localStorage.setItem("offerSDP", offerSDP);
          console.log('---SAMPLE OFFER---------------------------');
          console.log(offerSDP);
          return alert('Sample Offer Created!');
        };
        return pc.connection.setLocalDescription(description, localDone, fail);
      };
      return pc.connection.createOffer(offerDone, fail);
    };
    return pc;
  };

  window.localMediaStream0 = null;

  window.startWebrtc = function() {
    var doneMedia, failMedia, getUserMediaAAA;
    getUserMediaAAA = null;
    if (navigator.mozGetUserMedia) {
      getUserMediaAAA = navigator.mozGetUserMedia.bind(navigator);
    }
    if (navigator.webkitGetUserMedia) {
      getUserMediaAAA = navigator.webkitGetUserMedia.bind(navigator);
    }
    failMedia = function(error) {
      return alert(error);
    };
    doneMedia = function(localMediaStream) {
      var player, setNodeSideCandidates, setNodeSideOffer;
      window.localMediaStream0 = localMediaStream;
      player = document.getElementById('player0');
      if (player) {
        player.src = window.URL.createObjectURL(localMediaStream);
      }
      window.pc0 = createAPeerConnection();
      window.pc0.connection.addStream(window.localMediaStream0);
      setNodeSideOffer = function() {
        var fx1, lines, sdp;
        sdp = localStorage.getItem("offerSDP");
        console.log('---STORED OFFER-------------------------');
        console.log(sdp);
        fx1 = 'a=fingerprint:sha-256 81:80:FC:02:FD:62:E8:E9:41:5C:01:73:56:6B:D3:AD:21:D9:97:0B:C8:1C:80:67:55:B7:31:27:9D:E9:19:4F';
        lines = sdp.split('\\r\\n');
        lines.map(function(x, i) {
          if (0 === x.indexOf('a=fingerprint')) {
            return lines[i] = fx1;
          }
        });
        sdp = lines.join('\\r\\n');
        return window.pc0.setRemoteOfferHelper(JSON.parse(sdp));
      };
      setTimeout(setNodeSideOffer, 1000);
      setNodeSideCandidates = function() {
        var c0, c1;
        c0 = '{"sdpMLineIndex":0,"sdpMid":"audio","candidate":"candidate:211156821 1 udp 2122194687 192.168.1.5 50001 typ host generation 0"}';
        c1 = '{"sdpMLineIndex":1,"sdpMid":"data","candidate":"candidate:211156821 1 udp 2122194687 192.168.1.5 50001 typ host generation 0"}';
        window.pc0.connection.addIceCandidate(new RTCIceCandidate(JSON.parse(c0)), done, fail);
        return window.pc0.connection.addIceCandidate(new RTCIceCandidate(JSON.parse(c1)), done, fail);
      };
      return setTimeout(setNodeSideCandidates, 2000);
    };
    return getUserMediaAAA({
      audio: true,
      video: false
    }, doneMedia, failMedia);
  };

  window.startWebrtc();

}).call(this);

(function() {
  var ws;

  ws = new WebSocket('ws://localhost:3000/');

  console.log(ws);

  ws.onopen = function(ev) {
    return console.log('ws open:', ev);
  };

  ws.onclose = function(ev) {
    return console.log('ws close:', ev);
  };

  ws.onerror = function(ev) {
    return console.log('ws error:', ev);
  };

  ws.onmessage = function(ev) {
    return console.log('ws message:', ev);
  };

  window.ws0 = ws;

}).call(this);
