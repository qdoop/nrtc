# nrtc 
#### Thin WEBRTC endpoint for NODE 
## Usage
Run the following to install depedencies, build files, and run the program. Finally navigate with Chrome browser to `http://localhost:3000`  
```
    npm install
    node-gyp rebuild
    gulp
    
    node index.js
```
1. MAKE SURE you also fix your IP address inside peer.coffee from `192.168.1.5` to something similar
2. Check that you firewall allows access to UDP port `50001`
3. Fix `stun` password in node_stun.coffee
3. `Always rebuild if you make a change`

If everything ok you should see something like that, an INIT SCTP packet decoded, send to you from browser's side WEBRTC endpoint. (Chrome Version 38.0.2125.111 m)
```
    ...
    CyaSSL Leaving CyaSSL_read_internal(), return 100
    peerData0 100
    13881388
    00000000
    8489e429
    01000056
    ...
    80040006
    00010000
    80030006
    80c10000
    CyaSSL Entering CyaSSL_read()
    ...
```
    
####To be continued...
    
    
