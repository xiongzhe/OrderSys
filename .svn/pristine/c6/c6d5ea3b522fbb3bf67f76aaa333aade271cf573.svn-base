/*
 * client.c
 *
 *  Created on: 2015-7-18
 *      Author: Administrator
 */

#include "client.h"
#include "queue.h"
#include "Md5.h"
#include <pthread.h>


struct pthread_t gRecvThreadHandle = { 0 };
int gRecvThreadId = 0;

pthread_t gSendThreadHandle = { 0 };
int gSendThreadId = 0;

pthread_t gWorkerThreadHandle = { 0 };
int gWorkerThreadId = 0;

void * threadRecv(void * arg);
void * threadSend(void * arg);
void * threadDataRecvWorker(void * arg);

#if  (__BYTE_ORDER == __BIG_ENDIAN)
unsigned short gListionPort=0x9626;
#else
unsigned short gListionPort = 0x2696;
#endif

uint64_t gWLan0MAC = 0;
uint32_t gLocalIP = 0;

int gListenSocket = -1;
int gEPollRecvHandle = -1;
int gEPollSendHandle = -1;

bool gExitThread = false;
#define MAXEVENTS 100
sem_t gWorkerSem;
sem_t gSendSem;

uint64_t gEnterpriseId=0;
unsigned char gBroadcastKey[16]={0};

unsigned short gSendSequence = 1;
pthread_mutex_t gSendSequenceMutex = PTHREAD_MUTEX_INITIALIZER;

COMMAND_HANDLER gResponseCommandDefine[] = {
/*	0	*/{ NULL, 0x8000, NULL, NULL }
/*	1	*/, { "CMD_ATTACH_RESP", CMD_ATTACH_RESP, onAttachResponse, NULL }
/*	2	*/, { "CMD_PING_RESP", CMD_PING_RESP, onPingResponse, NULL }
/*	3	*/, { "CMD_JSON_MESSAGE_RESP", CMD_JSON_MESSAGE_RESP, NULL, NULL }
/*	4	*/, { "CMD_JSON_BROADCASTMESSAGE_RESP", CMD_JSON_BROADCASTMESSAGE_RESP, NULL, NULL }
};

COMMAND_HANDLER gDeliverCommandDefine[] = {
/*	0	*/{ NULL, 0x8000, NULL, NULL }
/*	1	*/, { "CMD_ATTACH", CMD_ATTACH, NULL, NULL }
/*	2	*/, { "CMD_PING", CMD_PING, NULL, NULL }
/*	3	*/, { "CMD_JSON_MESSAGE", CMD_JSON_MESSAGE, onDelieverJsonMessage, NULL }
/*	4	*/, { "CMD_JSON_BROADCASTMESSAGE", CMD_JSON_BROADCASTMESSAGE, onBroadcastMessage, NULL }
};


bool bAttachGetted=false;
unsigned char gSecretKey[16]={0};

#ifdef IN_JNI
extern JavaVM *gJvm ;
#endif

unsigned short getSendSequence() {
	pthread_mutex_lock(&gSendSequenceMutex);

	unsigned short ret = gSendSequence;
	gSendSequence++;
	pthread_mutex_unlock(&gSendSequenceMutex);
	return htons(ret);
}

struct sockaddr_in gRemoteServer = { 0 };
struct sockaddr_in gBroadcastAddress = { 0 };

bool start(const char * pRemoteHost,unsigned short nRemotePort) {
	bool ret = false;
	gExitThread = false;
	char nic[20] = { 0 };
	gWLan0MAC = getWLan0Mac(NULL);
	if (getDefaultNetInterface(nic)) {
		gLocalIP = getDefaultNetInterfaceIP(nic).s_addr;
	}

	if (gWLan0MAC==0){
		gWLan0MAC = getWLan0Mac(nic);
	}

	gRemoteServer.sin_family = AF_INET;
	gRemoteServer.sin_port = htons(nRemotePort);

	gBroadcastAddress.sin_family = AF_INET;
	gBroadcastAddress.sin_port = gListionPort;
	gBroadcastAddress.sin_addr.s_addr= INADDR_BROADCAST;//INADDR_BROADCAST;//inet_addr("239.255.255.128");

	struct hostent * hEnt =gethostbyname(pRemoteHost);
	memcpy(&gRemoteServer.sin_addr.s_addr,hEnt->h_addr_list[0],hEnt->h_length);

	struct sockaddr_in saLocalServer = { 0 };
	saLocalServer.sin_family = AF_INET;
	saLocalServer.sin_port = gListionPort;
	saLocalServer.sin_addr.s_addr = 0;

	// create listen socket
	gListenSocket = socket(AF_INET, SOCK_DGRAM, 0);
	if (gListenSocket < 1) {
		printf("create socket failed\r\n");
		return false;
	} else {
		printf("create socket sucessful\r\n");
	}

	int iOptVal = 1;
	setsockopt(gListenSocket, SOL_SOCKET, SO_REUSEADDR, (const char*) &iOptVal,
			sizeof(iOptVal));

	setsockopt(gListenSocket, SOL_SOCKET, SO_BROADCAST, (char *)&iOptVal, sizeof(iOptVal));

	if (bind(gListenSocket, (const struct sockaddr *) &saLocalServer,
			sizeof(saLocalServer)) != 0) {
		printf("bind socket failed\r\n");
		close(gListenSocket);
		gListenSocket = -1;
		return false;
	} else {
		printf("bind socket sucessful\r\n");
	}

	/*设置多播*/

	int loop = 0;

	ret = setsockopt(gListenSocket,IPPROTO_IP, IP_MULTICAST_LOOP,(const char *)&loop, sizeof(loop));

	struct in_addr interface_addr;
	interface_addr.s_addr=gLocalIP;
	ret = setsockopt ( gListenSocket, IPPROTO_IP, IP_MULTICAST_IF, &interface_addr, sizeof(interface_addr) );

	struct  ip_mreq mreq;
	memset(&mreq, 0, sizeof(struct ip_mreq));
	mreq.imr_multiaddr.s_addr = inet_addr("239.255.255.128"); //组播源地址
	mreq.imr_interface.s_addr = INADDR_ANY; //本地地址
	int m=setsockopt(gListenSocket,IPPROTO_IP,IP_ADD_MEMBERSHIP,(char   *)&mreq,sizeof(mreq));
	if (m == -1) {
		printf("setsockopt error\r\n");

	}

	unsigned int nBio=1;
	ioctl (
		gListenSocket,
		FIONREAD,
	  (unsigned char *)&nBio
	);


	sem_init(&gWorkerSem, false, 0);
	sem_init(&gSendSem, false, 0);



	gRecvThreadId = pthread_create(&gRecvThreadHandle, NULL, threadRecv, NULL);


	gSendThreadId = pthread_create(&gSendThreadHandle, NULL, threadSend, NULL);
	gWorkerThreadId = pthread_create(&gWorkerThreadHandle, NULL,
			threadDataRecvWorker, NULL);


	return ret;
}
void stop() {
	gExitThread = true;
	sem_post(&gWorkerSem);
	sem_post(&gSendSem);
	if (gRecvThreadHandle != -1) {
		pthread_join(gRecvThreadHandle, NULL);
	}
	if (gSendThreadHandle != -1) {
		pthread_join(gSendThreadHandle, NULL);
	}

	if (gWorkerThreadHandle != -1) {
		pthread_join(gWorkerThreadHandle, NULL);
	}


	if (gListenSocket != -1) {
		close(gListenSocket);
	}
	gListenSocket = -1;
	destoryAllQueue();
}

MSG_ATTACH gAttachInfo={0};
void attach() {
	int bufferLen = sizeof(MSG_ATTACH);
	struct QUEUE_ITEM * pItem = aquireIdleSendQueue(bufferLen);
	if (pItem == NULL) {
		return;
	}
	pItem->DataLength = bufferLen;
	MSG_ATTACH * pAttach = (MSG_ATTACH *) pItem->Buffer;

	pAttach->MAC = gWLan0MAC;
	pAttach->LocalIP = gLocalIP;
	pAttach->LocalPort = gListionPort;
	fillHeader(&pAttach->Header,CMD_ATTACH,  bufferLen);

	pItem->PeerAddress= gRemoteServer;
	pItem->PeerAddressLength = sizeof(pItem->PeerAddress);
	memcpy(&gAttachInfo,pAttach,sizeof(gAttachInfo));
	unsigned char * ptr= ((unsigned char *) &gAttachInfo) + sizeof(MSG_HEADER);
	tea_decrypt ((uint32_t*) (ptr+0), (uint32_t*) &pAttach->Header);
	tea_decrypt ((uint32_t*) (ptr+8), (uint32_t*) &pAttach->Header);

	releaseStandbySendQueue(pItem);
	sem_post(&gSendSem);

}

int onAttachResponse(unsigned char *readBuffer,int bufferLength, struct sockaddr_in *pSockName)
{
	MSG_ATTACH_RESPONSE * pResp = (MSG_ATTACH_RESPONSE *) readBuffer;
	if (pResp->Result == 0) {
		bAttachGetted = true;
		MSG_ATTACH *pAttach = &gAttachInfo;
		MD5_CTX mdContext;
		MD5Init(&mdContext);
		MD5Update(&mdContext, pResp->SecretKey1, sizeof(pResp->SecretKey1));
		MD5Update(&mdContext, (unsigned char *) &gWLan0MAC,
				sizeof(gWLan0MAC));
		MD5Update(&mdContext, pResp->SecretKey3, sizeof(pResp->SecretKey3));
		MD5Update(&mdContext, (unsigned char *) &pAttach->Header.TimeStamp,
				sizeof(pAttach->Header.TimeStamp));
		MD5Update(&mdContext, pResp->SecretKey2, sizeof(pResp->SecretKey2));
		MD5Update(&mdContext, (unsigned char *) &pAttach->Header.TimeStampMil,
				sizeof(pAttach->Header.TimeStampMil));
		MD5Final(&mdContext);
		memcpy(gSecretKey, mdContext.digest, sizeof(gSecretKey));

		LOGE("gSecretKey \r\n");
		printHex(gSecretKey,sizeof(gSecretKey));

		tea_decrypt ((uint32_t*) &pResp->EnterpriseId, (uint32_t*)gSecretKey);
		tea_decrypt ((uint32_t*) pResp->BroadCastKey, (uint32_t*) gSecretKey);
		tea_decrypt ((uint32_t*) (pResp->BroadCastKey+8), (uint32_t*) gSecretKey);

		gEnterpriseId=ntohll(pResp->EnterpriseId);
		memcpy(gBroadcastKey,pResp->BroadCastKey,sizeof(gBroadcastKey));

		LOGE("gEnterpriseId = %lld\r\n",(long long)gEnterpriseId);
		printHex(gBroadcastKey,sizeof(gBroadcastKey));
		/*
		printf("EnterpriseId = %lld \r\ngBroadcastKey=\r\n",gEnterpriseId);

		for (int i=0;i<sizeof(gBroadcastKey);i++){
			printf("%02x ",gBroadcastKey[i]);
		}

		printf("\r\n");*/
	}
	return 0;
}

void ping() {
	int bufferLen = sizeof(MSG_PING);
	struct QUEUE_ITEM * pItem = aquireIdleSendQueue(bufferLen);
	if (pItem == NULL) {
		return;
	}
	pItem->DataLength = bufferLen;
	MSG_PING * pPing = (MSG_PING *) pItem->Buffer;

	pPing->MAC = gWLan0MAC;
	pPing->LocalIP = gLocalIP;
	pPing->LocalPort = gListionPort;
	fillHeader(&pPing->Header,CMD_PING,  bufferLen);

	pItem->PeerAddress= gRemoteServer;
	pItem->PeerAddressLength = sizeof(pItem->PeerAddress);
	releaseStandbySendQueue(pItem);
	sem_post(&gSendSem);
}


int onPingResponse(unsigned char *readBuffer,int bufferLength, struct sockaddr_in *pSockName)
{

	return 0;
}
time_t gLastPing=0;
void * threadRecv(void * arg) {
	LOGE("threadRecv begin run\r\n");
	gLastPing=0;
	attach() ;
	while (!gExitThread) {
		int n, i;
		 int canRead = 0;
        n = select(int nfds, fd_set *readfds, fd_set *writefds,
                   fd_set *exceptfds, struct timeval *timeout);
		n = epoll_wait(gEPollRecvHandle, gRecvEvents, MAXEVENTS, 2000);
		if (gExitThread){
			break;
		}
		if (n==0   ){
			//printf("n==0 \r\n");
			time_t now = time(NULL);
			if (gLastPing<now)
			{
				if (!bAttachGetted){
				//	printf("!bAttachGetted send attach \r\n");
					attach() ;
				}
				else {
					//printf(" bAttachGetted send ping \r\n");
					ping();
					gLastPing+=10;
				}

			}
			continue;
		}
		for (i = 0; i < n; i++) {
			if ((gRecvEvents[i].events & EPOLLERR)
					|| (gRecvEvents[i].events & EPOLLHUP)
					|| (!(gRecvEvents[i].events & EPOLLIN))) {
				/* An error has occured on this fd, or the socket is not
				 ready for reading (why were we notified then?) */
				fprintf(stderr, "epoll error\n");
				close(gRecvEvents[i].data.fd);
				continue;
			}

			if (gRecvEvents[i].events & EPOLLIN) {
				//read
				canRead = 0;
				ioctl(gRecvEvents[i].data.fd, FIONREAD, &canRead);

				if (canRead > 0) {
					struct QUEUE_ITEM * pItem = aquireIdleRecvQueue(canRead);

					pItem->DataLength = recvfrom(gRecvEvents[i].data.fd,
							pItem->Buffer, canRead, 0,
							(struct sockaddr *) &pItem->PeerAddress,
							&pItem->PeerAddressLength);
					if (pItem->PeerAddress.sin_addr.s_addr == gLocalIP) {
						LOGE(
								"pItem->PeerAddress.sin_addr == gLocalIP!!! IGNORE\r\n");
						releaseIdleRecvQueue(pItem);
					} else {
						unsigned short cmd =
								((MSG_HEADER*) pItem->Buffer)->Command;
						cmd = ntohs(cmd);
						if (cmd == CMD_JSON_BROADCASTMESSAGE) {

							LOGE("recv a CMD_JSON_BROADCASTMESSAGE!!! \r\n");

						} else if (cmd == CMD_JSON_BROADCASTMESSAGE_RESP) {
 							LOGE(
									"recv a CMD_JSON_BROADCASTMESSAGE_RESP!!! \r\n");
 						}

						releaseStandbyRecvQueue(pItem);
						sem_post(&gWorkerSem);
					}
				}
			}

		}
	}


	LOGE("threadRecv exit\r\n");

	return NULL;
}

void * threadSend(void * arg) {

	LOGE("threadSend begin run\r\n");

	while (!gExitThread) {
		sem_wait(&gSendSem);
		if (gExitThread)
			break;
		int n, i;
		unsigned int canRead = 0;
		n = epoll_wait(gEPollSendHandle, gSendEvents, MAXEVENTS, 3000);
		if (gExitThread)
			break;
		for (i = 0; i < n; i++) {
			if (gSendEvents[i].events & EPOLLOUT) {
				//write
				struct QUEUE_ITEM * pItem = aquireStandbySendQueue();
				if (pItem) {
					sendto(gSendEvents[i].data.fd, pItem->Buffer,
							pItem->DataLength, 0,
							(const struct sockaddr *) &pItem->PeerAddress,
							pItem->PeerAddressLength);

					releaseIdleSendQueue(pItem);
				}
			}
		}
	}



	LOGE("threadSend exit\r\n");


	return NULL;
}

void * threadDataRecvWorker(void * arg) {

	LOGE("threadDataRecvWorker begin run!\r\n");


	while (!gExitThread) {
		// get a semaphore
		sem_wait(&gWorkerSem);



		if (gExitThread)
			break;
		struct QUEUE_ITEM * pItem = aquireStandbyRecvQueue();
		if (pItem != NULL) {
			// TODO
			//pItem->PeerAddress
			MSG_HEADER *pHeader = (MSG_HEADER *) pItem->Buffer;

			unsigned short cSum=checksum( (unsigned char *) pHeader,sizeof(MSG_HEADER),0);
			if (cSum!=0)
			{

				LOGE("header check sum error\r\n");

				releaseIdleRecvQueue(pItem);
				continue;
			}

			unsigned short cntSum=checksum( (unsigned char *) pItem->Buffer+offsetof(MSG_HEADER,ContentCheckSum)
					,ntohs(pHeader->DataLength)-offsetof(MSG_HEADER,ContentCheckSum)
					,0);
			if (cntSum )
			{

				LOGE("content check sum error cntSum=%04X HeaderCHKSUM=%04X pHeader->DataLength=%d pItem->DataLength=%d\r\n"
						,cntSum
						,pHeader->ContentCheckSum
						,ntohs(pHeader->DataLength)
						,pItem->DataLength
						);

				releaseIdleRecvQueue(pItem);
				continue;
			}
			unsigned short cmd = ntohs(pHeader->Command);
			COMMAND_HANDLER *pCmdHander = NULL;
			int handlerSize = 0;
			short cmdIndex = 0xffff;
			if (cmd >= 0x8000) {
				pCmdHander = gResponseCommandDefine;
				handlerSize = sizeof(gResponseCommandDefine)
						/ sizeof(gResponseCommandDefine[0]);
				cmdIndex = cmd & 0x7fff;
			} else {
				pCmdHander = gDeliverCommandDefine;
				handlerSize = sizeof(gDeliverCommandDefine)
							/ sizeof(gDeliverCommandDefine[0]);
				cmdIndex = cmd & 0x7fff;

//				printf("threadDataRecvWorker handlerSize = %d cmdIndex=%d \r\n",handlerSize,cmdIndex);

				int respBufferLen = sizeof(MSG_HEADER);
//				printf("threadDataRecvWorker begin aquireIdleSendQueue\r\n" );
				struct QUEUE_ITEM * pRespItem = aquireIdleSendQueue(respBufferLen);
//				printf("threadDataRecvWorker pRespItem=%08X\r\n",(unsigned int)pRespItem);
				MSG_HEADER  *pResponse=  (MSG_HEADER  *) pRespItem->Buffer;
				pResponse->ContentCheckSum=0;
				pResponse->HeaderCheckSum=0;
				pResponse->Seq = pHeader->Seq;
				pResponse->DataLength=htons(sizeof(MSG_HEADER));
				pResponse->Command= htons(ntohs(pHeader->Command)|0x8000);
				pResponse->TimeStamp= pHeader->TimeStamp;
				pResponse->TimeStampMil=pHeader->TimeStampMil;
				pResponse->ContentCheckSum = checksum(
								((unsigned char  *)pResponse) + sizeof(MSG_HEADER),
								0, 0);


				pResponse->HeaderCheckSum =checksum(
							((unsigned char *)pResponse) ,sizeof(MSG_HEADER),0);

				pRespItem->PeerAddress =pItem->PeerAddress;// gRemoteServer;
				pRespItem->PeerAddressLength =pItem->PeerAddressLength;// sizeof(pRespItem->PeerAddress);
				releaseStandbySendQueue(pRespItem);
				sem_post(&gSendSem);

			}

			if (cmdIndex!=2){
				LOGE("cmdIndex =%d  handlerSize=%d \r\n",cmdIndex ,handlerSize);
			}

			if (cmdIndex < handlerSize) {

				if (cmdIndex!=2){
					LOGE("pCmdHander[cmdIndex].Func=%08X \r\n",(unsigned int)pCmdHander[cmdIndex].Func);
				}
				if ( pCmdHander[cmdIndex].Func){

					(*pCmdHander[cmdIndex].Func)(pItem->Buffer,pItem->DataLength ,&pItem->PeerAddress);

				}
			}

			releaseIdleRecvQueue(pItem);
		}
	}



	LOGE("exit threadDataRecvWorker\r\n");


	return NULL;
}


int onDelieverJsonMessage(unsigned char *readBuffer,int bufferLength,struct sockaddr_in *pSockName)

{
	MSG_JSON_MESSAGE * pJsonMsg= (MSG_JSON_MESSAGE *)readBuffer;
	if (!DecryptMessage((MSG_JSON_MESSAGE *)readBuffer ,ntohs(pJsonMsg->Header.DataLength),gSecretKey)){
		LOGE("onDelieverJsonMessage DecryptMessage ERROR\r\n");
	}
	else{
		MESSAGE *pMsg =(MESSAGE *) pJsonMsg->CryptedMessage;
		LOGE("onDelieverJsonMessage pMsg=%s\r\n",pMsg->orgMessage);
#ifdef IN_JNI

	/*public static void onRecieveMessage(java.lang.String);
		    Signature: (Ljava/lang/String;)V*/

		if (onRecieveMessageMethodId){
			JNIEnv * pEnv=NULL;
			 (*gJvm)->AttachCurrentThread(gJvm,&pEnv,NULL);   //附加到当前线程中, 生成 env
			LOGE("in onDelieverJsonMessage Before call charPointerToJString");
			LOGE( "pMsg->orgLength = %d ntohs(pMsg->orgLength) = %d",pMsg->orgLength,ntohs(pMsg->orgLength));
			const char* ptr= (const char*) pMsg->orgMessage;
			ptr+=pMsg->orgLength;
			ptr--;
			int nLen=pMsg->orgLength;
			while (*ptr==0){
				ptr--;
				nLen--;
			}
			jstring inputString = charPointerToJString(pEnv, (const char*) pMsg->orgMessage, /*pMsg->orgLength*/nLen );
			LOGE("in onDelieverJsonMessage After call charPointerToJString");
			LOGE("in onDelieverJsonMessage Before call CallStaticVoidMethod");
			(*pEnv)->CallStaticVoidMethod(pEnv,gJavaClass,onRecieveMessageMethodId,inputString);
			LOGE("in onDelieverJsonMessage After call CallStaticVoidMethod");
			(*pEnv)->DeleteLocalRef (pEnv, inputString);
			LOGE("in onDelieverJsonMessage After call DeleteLocalRef");
			(*gJvm)->DetachCurrentThread(gJvm );
		}
#endif
		return ntohs(pMsg->orgLength);
	}

	return 0;
}

int onBroadcastMessage(unsigned char *readBuffer,int bufferLength,struct sockaddr_in *pSockName)
{
	MSG_BROADCAST_MESSAGE * pJsonMsg= (MSG_BROADCAST_MESSAGE *)readBuffer;
	if (!DecryptMessage((MSG_JSON_MESSAGE *)readBuffer ,bufferLength,gBroadcastKey)){
		LOGE("onBroadcastMessage DecryptMessage ERROR\r\n");
	}
	else{
		MESSAGE *pMsg =(MESSAGE *) pJsonMsg->CryptedMessage;

		LOGE("onBroadcastMessage pMsg=%s bufferLength=%d\r\n",pMsg->orgMessage,bufferLength);
#ifdef IN_JNI

/*
	  public static void onRecieveBroadcastMessage(java.lang.String);
	    Signature: (Ljava/lang/String;)V
	    */

		if (onRecieveMessageMethodId){
			JNIEnv * pEnv=NULL;
			(*gJvm)->AttachCurrentThread(gJvm,&pEnv,NULL);   //附加到当前线程中, 生成 env

			LOGE( "pMsg->orgLength = %d ntohs(pMsg->orgLength) = %d",pMsg->orgLength,ntohs(pMsg->orgLength));
						const char* ptr= (const char*) pMsg->orgMessage;
						ptr+=pMsg->orgLength;
						ptr--;
						int nLen=pMsg->orgLength;
						while (*ptr==0){
							ptr--;
							nLen--;
						}

			jstring inputString = charPointerToJString(pEnv, (const char*) pMsg->orgMessage,nLen);
			(*pEnv)->CallStaticVoidMethod(pEnv,gJavaClass,onRecieveBroadcastMessageId,inputString);
			(*pEnv)->DeleteLocalRef (pEnv, inputString);
			(*gJvm)->DetachCurrentThread (gJvm );

		}

#endif
		return ntohs(pMsg->orgLength);
		//printf("onBroadcastMessage txt=%s\r\n",pMsg->orgMessage);
	}
	return 0;
}

void sendBroadcastMessage(unsigned char * pMsg, int nMsgLen)
{
	MSG_BROADCAST_MESSAGE * pOut;
	unsigned short lastFillCnt;
	int bufferLen = getCryptedLength(nMsgLen, &lastFillCnt);
 	LOGE("sendBroadcastMessage getCryptedLength bufferLen=%d\r\n",bufferLen);
	bufferLen+=sizeof(MSG_BROADCAST_MESSAGE)-1;
	LOGE("sendBroadcastMessage getCryptedLength++ bufferLen=%d\r\n",bufferLen);

	struct QUEUE_ITEM * pItem = aquireIdleSendQueue(bufferLen);

	if (pItem != NULL) {
		pOut = (MSG_BROADCAST_MESSAGE *) pItem->Buffer;
		int sendLength=CryptMessage(pOut, pMsg, nMsgLen, gBroadcastKey);
		fillHeaderWithNoCrypt(&pOut->Header, CMD_JSON_BROADCASTMESSAGE, sendLength);
		LOGE("sendBroadcastMessage CryptMessage sendLength=%d CONTENTCHK =%04X\r\n",sendLength,(unsigned int)pOut->CryptedMessage);

		pItem->PeerAddress = gBroadcastAddress;

		pItem->PeerAddressLength = sizeof(pItem->PeerAddress);
		releaseStandbySendQueue(pItem);
		sem_post(&gSendSem);
	}
}

void printHex(unsigned char *buffer,int len)
{
#ifdef IN_JNI
	char outBuffer[2048];
	char * pOut=outBuffer;
	for (int i=0;i<len;i++)
	{
		if ( (pOut - outBuffer)>2040){
			break;
		}
		int pLen=sprintf(pOut,"%02X ",buffer[i]);
		pOut+=pLen;
		if ( (i+1)%16==0)
			{
			pLen=printf(pOut,"\r\n");
				pOut+=pLen;
			}
	}

		sprintf(pOut,"\r\n");
		LOGE("%s",outBuffer);
#else

	for (int i=0;i<len;i++)
	{
		printf("%02X ",buffer[i]);
		if ( (i+1)%16==0)
		{
			printf("\r\n");
		}
	}
	printf("\r\n");
#endif
}

