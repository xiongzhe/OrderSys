/*
 * client.h
 *
 *  Created on: 2015-7-18
 *      Author: Administrator
 */

#ifndef CLIENT_H_
#define CLIENT_H_

#include <stdbool.h>
#include "MessageDef.h"
#include <pthread.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <semaphore.h>

#ifdef IN_JNI
#include <jni.h>
extern JavaVM *gJvm ;
extern jclass gJavaClass ;
extern jmethodID onRecieveMessageMethodId;
extern jmethodID onRecieveBroadcastMessageId;
#include<android/log.h>
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "native-activity", __VA_ARGS__))
#define LOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, "native-activity", __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "native-activity", __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, "native-activity", __VA_ARGS__))
#else
#define LOGI printf
#define LOGW printf
#define LOGE printf
#define LOGD printf

#endif

void printHex(unsigned char *buffer,int len);

typedef int(*DataHanderFunc)(unsigned char *readBuffer,int bufferLength,struct sockaddr_in *pSockName);


#ifdef __cplusplus
extern "C" {
#endif


typedef struct _COMMAND_HANDLER
{
	const char * CommandName;
	unsigned short CommandCode;
	DataHanderFunc Func;
	const char * CommandDesc;
}COMMAND_HANDLER;

bool start(const char * pRemoteHost,unsigned short nRemotePort);
void stop();
void attach();
void ping();


int onAttachResponse(unsigned char *readBuffer,int bufferLength,struct sockaddr_in *pSockName);
int onPingResponse(unsigned char *readBuffer,int bufferLength,struct sockaddr_in *pSockName);
int onDelieverJsonMessage(unsigned char *readBuffer,int bufferLength,struct sockaddr_in *pSockName);
int onBroadcastMessage(unsigned char *readBuffer,int bufferLength,struct sockaddr_in *pSockName);
void sendBroadcastMessage(unsigned char * pMsg,int nMsgLen);


extern unsigned char gSecretKey[16];
#ifdef __cplusplus
}
#endif

#endif /* CLIENT_H_ */
