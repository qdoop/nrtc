
#include <node.h>
#include <node_buffer.h>
#include <v8.h>

#include <usrsctp.h>

using namespace v8;

extern "C"{

	char * usrsctp_dumppacket(void *, size_t, int);
	void usrsctp_freedumpbuffer(char *buf);

}

void hexdump0(const unsigned char *packet, int length) 
{
	int n = 0;

	while (length--) { 
	  if (n % 16 == 0)
	    printf("%08X ",n);

	  printf("%02x", *packet++);
	  
	  n++;
	  if (n % 8 == 0) {
	    if (n % 16 == 0)
	  printf("\n");
	    else
	  printf(" ");
	  }
	}
}
void dump(unsigned char *buf, size_t len) 
{
	while (len--) 
		printf("%02x", *buf++);
}
void hexdump(void *packet, int length)
{
	hexdump0((unsigned char *)packet, length);
}

int callbackSCTP0(char* raw, int rawlen)
{
	HandleScope scope;

	Local<Object>   gObject    = Context::GetCurrent()->Global();
	Local<Function> gCallback = Local<Function>::Cast( gObject->Get(String::New("callbackSCTP0")) );

	node::Buffer* slowBuffer = node::Buffer::New(rawlen);
	memcpy(node::Buffer::Data(slowBuffer), raw,  rawlen);
	
	Local<Function> bufferConstructor = Local<Function>::Cast(gObject->Get(String::New("Buffer")));
	Handle<Value>  constructorArgs[3] = { slowBuffer->handle_, Integer::New(rawlen), Integer::New(0) };
	Local<Object>        fastBuffer   = bufferConstructor->NewInstance(3, constructorArgs);

	const unsigned argc = 1;
  	Local<Value> argv[argc] = { fastBuffer };
  	gCallback->Call(Context::GetCurrent()->Global(), argc, argv);

  	scope.Close( Undefined() );
	return 0;
}


int connectionCb(void *addr, void *buffer, size_t length, uint8_t tos, uint8_t set_df)
{

	printf("%s %s %d %d\n", "connectionCb\n", addr, tos, set_df );
	hexdump(buffer, length);


	return 0;
}

typedef void (*DEBUGME0)(const char *format, ...);
void debug_printf0(const char *format, ...){
	printf("debug_printf0: %s\r\n", format);

	// printf(format, ...);
}

// struct socket *
// usrsctp_socket(int domain, int type, int protocol,
//                int (*receive_cb)(struct socket *sock, union sctp_sockstore addr, void *data,
//                                  size_t datalen, struct sctp_rcvinfo, int flags, void *ulp_info),
//                int (*send_cb)(struct socket *sock, uint32_t sb_free),
//                uint32_t sb_threshold,
//                void *ulp_info);

// struct sockaddr_conn {
// 	uint16_t sconn_family;
// 	uint16_t sconn_port;
// 	void *sconn_addr;
// };
int receive_cb0(struct socket *sock, union sctp_sockstore addr, void *data, size_t datalen, struct sctp_rcvinfo, int flags, void *ulp_info)
{
	printf("%s\r\n", "xxxx receive_cb0");

	return 0;
}
int send_cb0(struct socket *sock, uint32_t sb_free)
{
	printf("%s\r\n", "xxxx send_cb0");
	return 0;
}

static int sctp_init0=0;
static struct socket* s0;
static int s1;
Handle<Value> methodSCTP0(const Arguments& args) 
{
	HandleScope scope;
	int rc=0;

	Local<Object> boo  = args[0]->ToObject();
	char*         aBuf = node::Buffer::Data(boo);
	size_t        aLen = node::Buffer::Length(boo);



	if(!sctp_init0){
		usrsctp_init(50000, connectionCb, (DEBUGME0)printf);
		sctp_init0=1;

		usrsctp_sysctl_set_sctp_debug_on(SCTP_DEBUG_ALL);

		//SOCK_SEQPACKET SOCK_STREAM
		s0=usrsctp_socket(AF_CONN, SOCK_STREAM , IPPROTO_SCTP,receive_cb0,send_cb0,0,0);

		if(!s0)printf("%s\r\n", "ERROR: usrsctp_socket ");

		struct sockaddr_conn sa;
		sa.sconn_family=AF_CONN;
		sa.sconn_port=50000;
		sa.sconn_addr=NULL;

		rc=usrsctp_bind(s0, (struct sockaddr*)&sa, sizeof(sa));
		if(rc<0){ printf("%s %d\r\n", "ERROR: usrsctp_bind ", rc); }
		printf("%s %d\r\n", "xxxx usrsctp_bind ", rc);


		rc=usrsctp_listen(s0,2);
		if(rc){ printf("%s %d\r\n", "ERROR: usrsctp_listen ", rc); }
	
	}//sctp_init0

		struct sockaddr_conn sa;
		sa.sconn_family=AF_CONN;
		sa.sconn_port=0x1388;
		sa.sconn_addr="xxxx";

	// void usrsctp_conninput(void *addr, const void *buffer, size_t length, uint8_t ecn_bits)

	usrsctp_conninput(&sa, aBuf, aLen, 0);








	return scope.Close(  Integer::New(rc)  );
}



void NODE_INIT0(Handle<Object> exports) 
{
	exports->Set(String::NewSymbol(  "methodSCTP0"  ),FunctionTemplate::New(      methodSCTP0    )->GetFunction());

}
NODE_MODULE(usrsctplib, NODE_INIT0)