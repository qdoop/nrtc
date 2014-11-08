#include <node.h>
#include <node_buffer.h>
#include <v8.h>

#include <cyassl/ssl.h>

using namespace v8;


extern "C" {

	void CYASSL_MSG(const char* msg);

}


CYASSL_CTX* ctx=NULL;
CYASSL*     ssl=NULL;

static char* acceptBuffer=NULL;
static int   acceptLength=0;

int rdataCb(CYASSL *ssl, char *buf, int sz, void *ctx)
{
	int len;

	if(sz<acceptLength)
	{
		CYASSL_MSG("ERROR: rdataCb");
		return -1;
	}

	if( acceptLength ){
		CYASSL_MSG("__ rdataCb");
		len=acceptLength;

		memcpy(buf,acceptBuffer,len);
		acceptLength=0;

		return len;
	}

	CYASSL_MSG("__ rdataCb ___WANT_READ___");
	return CYASSL_CBIO_ERR_WANT_READ;
}

int wdataCb(CYASSL *ssl, char *buf, int sz, void *ctx)
{	
	CYASSL_MSG("__ wdataCb ");

	HandleScope scope;

	Local<Object>   gObject           = Context::GetCurrent()->Global();
	Local<Function> gCallback         = Local<Function>::Cast( gObject->Get(String::New("peerSend0")) );
	Local<Function> bufferConstructor = Local<Function>::Cast( gObject->Get(String::New("Buffer")) );

	node::Buffer* slowBuffer = node::Buffer::New(sz);
	memcpy(node::Buffer::Data(slowBuffer), buf,  sz);

	
	Handle<Value>  constructorArgs[3] = { slowBuffer->handle_, Integer::New(sz), Integer::New(0) };
	Local<Object>        fastBuffer   = bufferConstructor->NewInstance(3, constructorArgs);
	const unsigned argc = 1;
  	Local<Value> argv[argc] = { fastBuffer };
  	gCallback->Call(Context::GetCurrent()->Global(), argc, argv);

  	scope.Close( Undefined() );

	return sz;
}


Handle<Value> spinMethod(const Arguments& args) 
{
	CYASSL_MSG("__ spin CyaSSL_accept CyaSSL_read");

	HandleScope scope;
	int rc=0;


	Local<Object> boo  = args[0]->ToObject();
	acceptBuffer = node::Buffer::Data(boo);
	acceptLength = node::Buffer::Length(boo);


	if(SSL_SUCCESS != CyaSSL_accept(ssl) )
	{
		rc=CyaSSL_get_error(ssl, 0);		
	}

	Local<Object>   gObject           = Context::GetCurrent()->Global();
	Local<Function> gCallback         = Local<Function>::Cast( gObject->Get(String::New("peerData0")) );
	Local<Function> bufferConstructor = Local<Function>::Cast( gObject->Get(String::New("Buffer")) );

	char dat[10000];
	int  datlen;
	while(1)
	{
		datlen = CyaSSL_read(ssl, dat, sizeof(dat) );

		if(datlen<1) break;

		node::Buffer* slowBuffer = node::Buffer::New(datlen);
		memcpy(node::Buffer::Data(slowBuffer), dat,  datlen);
	
		Handle<Value>  constructorArgs[3] = { slowBuffer->handle_, Integer::New(datlen), Integer::New(0) };
		Local<Object>        fastBuffer   = bufferConstructor->NewInstance(3, constructorArgs);
		const unsigned argc = 1;
		Local<Value> argv[argc] = { fastBuffer };

		gCallback->Call(Context::GetCurrent()->Global(), argc, argv);
	}

	return scope.Close(  Integer::New(rc)  );
}



int cookieCb(CYASSL* ssl, unsigned char* buf, int sz, void* ctx)
{
	CYASSL_MSG("__ cookieCb ");
	memset(buf,0xff,sz);
	return sz;
}

int verifyPeerCb(int mode, CYASSL_X509_STORE_CTX* store)
{
	CYASSL_MSG("__ verifyPeerCb ");
	return 1;
}

Handle<Value> initMethod(const Arguments& args) 
{
	CYASSL_MSG("__ init Cyassl ");

	HandleScope scope;

	CyaSSL_Init();
	CyaSSL_Debugging_ON();

	////////////////////////////////////////////////////////////////////////////////__CONTEXT
	if ( NULL == (ctx = CyaSSL_CTX_new(CyaDTLSv1_server_method())) )
	{
		scope.Close( String::New("ERROR: CyaSSL_CTX_new") );
	}

	CyaSSL_SetIORecv(ctx,  &rdataCb );
	CyaSSL_SetIOSend(ctx,  &wdataCb );
	CyaSSL_CTX_SetGenCookie(ctx, &cookieCb );
	CyaSSL_CTX_set_verify(ctx, SSL_VERIFY_PEER|SSL_VERIFY_FAIL_IF_NO_PEER_CERT, &verifyPeerCb);

	// CyaSSL_CTX_set_group_messages(ctx);


	if (CyaSSL_CTX_use_certificate_file(ctx,"certs/server-cert.pem", SSL_FILETYPE_PEM) != SSL_SUCCESS)
	{
		scope.Close( String::New("ERROR: CyaSSL_CTX_use_certificate_file") );
	}

	if (CyaSSL_CTX_use_PrivateKey_file(ctx,"certs/server-key.pem",  SSL_FILETYPE_PEM) != SSL_SUCCESS) 
	{
		scope.Close( String::New("ERROR: CyaSSL_CTX_use_PrivateKey_file") );
	}

	///////////////////////////////////////////////////////////////////////////////////__SESSION
	if ( NULL == (ssl = CyaSSL_new(ctx)) ) 
	{
		scope.Close( String::New("ERROR: CyaSSL_new") );
	}
	CyaSSL_SetCookieCtx(ssl, ctx);
	CyaSSL_set_using_nonblock(ssl, 1);

	return scope.Close(String::New("ok"));
}

Handle<Value> exitMethod(const Arguments& args) 
{
	CYASSL_MSG("__ exit Cyassl ");

	HandleScope scope;
	
	CyaSSL_free(ssl);
	CyaSSL_CTX_free(ctx);
 	CyaSSL_Cleanup();

	return scope.Close(String::New("ok"));
}





void NODE_INIT0(Handle<Object> exports) {
  exports->Set(String::NewSymbol(  "init"  ),FunctionTemplate::New(  initMethod    )->GetFunction());
  exports->Set(String::NewSymbol(  "exit"  ),FunctionTemplate::New(  exitMethod    )->GetFunction());
  exports->Set(String::NewSymbol(  "spin"  ),FunctionTemplate::New(  spinMethod    )->GetFunction());
}
NODE_MODULE(cyassldtls, NODE_INIT0)