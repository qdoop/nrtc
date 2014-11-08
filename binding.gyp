{
  'targets': [


    {
      'target_name': 'cyassldtls',

      'includes': ['deps/cyassl.gypi'],

      'include_dirs': [ 'deps/cyassl' ],
     
      'sources': 
      [ 

       'node_dtls.cc' , 

      ],
     
  		'defines': [

          'DEBUG_CYASSL' ,
          'NO_SESSION_CACHE' ,
          'SINGLE_THREADED' ,
          'CYASSL_USER_IO' ,
          'HAVE_ECC' ,
          'CYASSL_DTLS'
  		]
  },


	
	{
      'target_name': 'usrsctplib',

      'includes': ['deps/usrsctplib.gypi'],

      'include_dirs': [ 'deps/usrsctplib/', 'deps/usrsctplib/netinet' ],

      'sources': [

      	'node_sctp.cc',

      ],      

      'defines': 
       [
          'SCTP_PROCESS_LEVEL_LOCKS',
          'SCTP_SIMPLE_ALLOCATOR',
          '__Userspace__',

          'SCTP_DEBUG', # Uncomment for SCTP debugging.

          # 'INET',
          # Manually setting WINVER and _WIN32_WINNT is needed because Chrome
          # sets WINVER to a newer version of  windows. But compiling usrsctp
          # this way would is incompatible  with windows XP.
          #'WINVER=0x0502',
          #'_WIN32_WINNT=0x0502',
       ],

      'conditions': [
            ['OS=="win"', 
              {
                'defines'  : [ 'LINUX_DEFINE', '__Userspace_os_Windows',   ],
                'libraries': ['-lwsock32.lib'],
            }],
      ],
	},



  ]
}