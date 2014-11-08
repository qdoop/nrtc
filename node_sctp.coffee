
_sctp= require('./build/Release/usrsctplib')

raw="""
13881388
00000000
8489e429
01000056
27a883da
00020000
03ff0800
bc7921ad
c0000004
8008000a
c180c081
820f0000
80020024
6c3d0000
d62c0000
ae720000
52690000
905f0000
49160000
f16d0000
f15a0000
80040006
00010000
80030006
80c10000
"""
raw=(raw.split('\n')).join('')
log0  raw

# _sctp.methodSCTP0(new Buffer(raw,'hex'))

# sctp.methodSCTP0(new Buffer(raw,'hex'))

# sctp.methodSCTP0(new Buffer(raw,'hex'))







module.exports={}
