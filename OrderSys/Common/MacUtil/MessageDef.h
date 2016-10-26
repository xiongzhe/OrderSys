#ifndef _MESSAGEDEF_H_DEFINED_
#define _MESSAGEDEF_H_DEFINED_

#define MAX_SEND_BUFFER_SIZE 1400

#define CMD_ATTACH				0x1
#define CMD_ATTACH_RESP			0x8001

#define CMD_PING				0x2
#define CMD_PING_RESP			0x8002

#define CMD_JSON_MESSAGE		0x3
#define CMD_JSON_MESSAGE_RESP	0x8003

#define CMD_JSON_BROADCASTMESSAGE		0x4
#define CMD_JSON_BROADCASTMESSAGE_RESP	0x8004

#include <stdio.h>
#include <stdlib.h>

#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <sys/time.h>
#include <stddef.h>

#ifdef _MSC_VER
typedef __int64  int64_t;
typedef unsigned __int64  uint64_t;
typedef int int32 ;
typedef unsigned int uint32_t;
 
#define _PACKED
#define MEAN_AND_LEAN
#include <WinSock2.h>
#include <Windows.h>
#include <io.h>
#pragma pack(push)
#pragma pack(1)
#else
#include <unistd.h>
#include <stddef.h>
#include <stdbool.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/syscall.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <sys/ioctl.h>
#include <pthread.h>
#include "TEA.h"

extern void printHex(unsigned char *buffer,int len);
#define _PACKED __attribute__((packed))
#endif
#define YEAR_2010 1262275200
typedef struct _MSG_HEADER
{
	unsigned short	DataLength;//数据长度
	unsigned short	Command;//命令
	unsigned short	Seq;//包序号

	uint32_t TimeStamp;//时间戳
	uint32_t TimeStampMil;//时间戳毫秒

	unsigned short OrgCotentCheckSum;//原始内容CHECKSUM

	unsigned short	HeaderCheckSum;//包头校验
	unsigned short	ContentCheckSum;//内容校验
}_PACKED MSG_HEADER  ;

typedef struct _SVR_ADDR
{
	unsigned int ServerIP;//服务器IP
	unsigned short ServerPort;//服务器端口
}_PACKED SVR_ADDR ;

typedef struct _MSG_ATTACH_RESPONSE
{
	MSG_HEADER Header;
	short Result;
	uint64_t EnterpriseId;
	unsigned char SecretKey1[16];
	unsigned char SecretKey2[16];
	unsigned char SecretKey3[16];
	unsigned char BroadCastKey[16];
	short ServerCount;//服务器数
	SVR_ADDR ServerAddr[1];
}_PACKED MSG_ATTACH_RESPONSE  ;

typedef struct _MSG_PING
{
	MSG_HEADER Header;
	uint64_t MAC;//用户ID
	unsigned int LocalIP;//客户端IP
	unsigned short LocalPort;//客户端端口号
	unsigned short PAD;//占位，使数据包为16字节
}_PACKED MSG_PING,MSG_ATTACH  ;

typedef struct _MSG_PING_RESP
{
	MSG_HEADER Header;
	short Result;
	unsigned int ExtIP;//客户端IP
	unsigned short ExtPort;//客户端端口号
}_PACKED MSG_PING_RESP  ;


typedef struct _MESSAGE{
	unsigned short orgLength;

	unsigned char  padding[7];
	unsigned short orgCheckSum;
	unsigned char  orgMessage[1];
	//后面紧跟填充
}_PACKED MESSAGE;

typedef struct _MSG_JSON_MESSAGE
{
	MSG_HEADER Header;
	unsigned char  CryptedMessage[1];
}_PACKED MSG_JSON_MESSAGE,MSG_BROADCAST_MESSAGE;




static inline unsigned short checksum(unsigned char *pInput, int len,char printStep){
	unsigned int sum = 0;  /* assume 32 bit long, 16 bit short */
	unsigned short* pShort = (unsigned short* )pInput;
	if (len==0){
#ifndef IN_JNI
#ifdef TRACE_PACKET
		printf("checksum len==0 return 0xffff\r\n");
#endif
#endif
		return 0xffff;
	}
	while(len > 1){
		unsigned short in=*pShort;//ntohs(*pShort);
#ifndef IN_JNI
#ifdef TRACE_PACKET
		if (printStep)
			printf("%08X ",sum);
#endif
#endif
		sum +=in ;
		if(sum & 0x80000000)   /* if high order bit set, fold */
			sum = (sum & 0xFFFF) + (sum >> 16);
#ifndef IN_JNI
#ifdef TRACE_PACKET
		if (printStep)
		{
			printf("+ %04X  =%04X \r\n",in,sum);
		}
#endif
#endif
		len -= 2;
		pInput+=2;
		pShort = (unsigned short* )pInput;
	}

	if(len)       /* take care of left over byte */
	{
		unsigned short s=*pInput;
		s<<=8;
#ifndef IN_JNI
#ifdef TRACE_PACKET
		if (printStep)
			printf("%08X ",sum);
#endif
#endif
		sum += s;
#ifndef IN_JNI
#ifdef TRACE_PACKET
		if (printStep)
		{
			printf("+ %04X  =%04X \r\n",s,sum);
		}
#endif
#endif
	}

	while(sum& 0xFFFF0000)
	{
		sum = (sum & 0xFFFF) + (sum >> 16);
#ifndef IN_JNI
#ifdef TRACE_PACKET
		if (printStep)
			printf("sum& 0xFFFF0000 Sum=%04X \r\n",sum);
#endif
#endif
	}

#ifndef IN_JNI
#ifdef TRACE_PACKET
	if (printStep)
		printf("~Sum=%04X \r\n",(~sum)&0xffff);
#endif
#endif
	return ~sum;
}

/*
static inline uint64_t htonll(uint64_t v) {
	if (  __BYTE_ORDER == __BIG_ENDIAN){
		return v;
	}
    union { uint32_t lv[2]; uint64_t llv; } u;
    u.lv[0] = htonl(v >> 32);
    u.lv[1] = htonl(v & 0xFFFFFFFFULL);
    return u.llv;
}
static inline uint64_t ntohll(uint64_t v) {
	if (  __BYTE_ORDER == __BIG_ENDIAN){
			return v;
	}
    union { uint32_t lv[2]; uint64_t llv; } u;
    u.llv = v;
    return ((uint64_t)ntohl(u.lv[0]) << 32) | (uint64_t)ntohl(u.lv[1]);
}
*/
extern unsigned short getSendSequence();

static inline void fillHeader(MSG_HEADER * pHeader,unsigned short command,unsigned short bufferLen){
	struct timeval tv;
	gettimeofday(&tv,NULL);

	pHeader->Command = htons(command); //命令
	pHeader->Seq = getSendSequence(); //包序号
	pHeader->DataLength = htons(bufferLen ); //数据长度
	pHeader->HeaderCheckSum = 0; //包头校验
	pHeader->ContentCheckSum = 0; //内容校验
	pHeader->TimeStamp=tv.tv_sec - YEAR_2010;
	pHeader->TimeStampMil=tv.tv_usec/1000;
	pHeader->OrgCotentCheckSum = pHeader->ContentCheckSum = checksum(
			((unsigned char  *)pHeader) + sizeof(MSG_HEADER),
			bufferLen- sizeof(MSG_HEADER), 0);

	if (bufferLen>=sizeof(MSG_HEADER)+16){
		unsigned char * ptr=((unsigned char  *)pHeader) + sizeof(MSG_HEADER);
		tea_encrypt ((uint32_t*) (ptr+0), (uint32_t*) pHeader);
		tea_encrypt ((uint32_t*) (ptr+8), (uint32_t*) pHeader);
	}


	pHeader->ContentCheckSum = checksum(
				((unsigned char  *)pHeader) + sizeof(MSG_HEADER),
				bufferLen- sizeof(MSG_HEADER), 0);


	pHeader->HeaderCheckSum =checksum(
			((unsigned char *)pHeader) ,sizeof(MSG_HEADER),0);
}

static inline void fillHeaderWithNoCrypt(MSG_HEADER * pHeader,unsigned short command,unsigned short bufferLen){
	struct timeval tv;
	gettimeofday(&tv,NULL);

	pHeader->Command = htons(command); //命令
	pHeader->Seq = getSendSequence(); //包序号
	pHeader->DataLength = htons(bufferLen ); //数据长度
	pHeader->HeaderCheckSum = 0; //包头校验
	pHeader->ContentCheckSum = 0; //内容校验
	pHeader->TimeStamp=tv.tv_sec - YEAR_2010;
	pHeader->TimeStampMil=tv.tv_usec/1000;
	pHeader->OrgCotentCheckSum = pHeader->ContentCheckSum = checksum(
			((unsigned char  *)pHeader) + sizeof(MSG_HEADER),
			bufferLen- sizeof(MSG_HEADER), 0);

	pHeader->ContentCheckSum = checksum(
				((unsigned char  *)pHeader) + sizeof(MSG_HEADER),
				bufferLen- sizeof(MSG_HEADER), 0);


	pHeader->HeaderCheckSum =checksum(
			((unsigned char *)pHeader) ,sizeof(MSG_HEADER),0);
}

static inline unsigned short getCryptedLength(unsigned short orgLength,unsigned short *pLastFillCnt){
	unsigned short ret=0;

	ret=offsetof(MESSAGE,orgMessage);
	ret+=orgLength;
	*pLastFillCnt=ret;
	ret+=7;
	ret>>=3;
	ret<<=3;
	*pLastFillCnt=ret-*pLastFillCnt;
	return ret;
}



static inline int CryptMessage( MSG_JSON_MESSAGE *pOut,unsigned char * msg,unsigned short msgLen,unsigned char * pKey)
{
	unsigned short  ret=0;
	unsigned short fillPadCnt=0;
	unsigned char *cBuffer =pOut->CryptedMessage;

	MESSAGE * pOrg=(MESSAGE *)cBuffer;
	ret=getCryptedLength(msgLen,&fillPadCnt);
	ret+=offsetof(MSG_JSON_MESSAGE,CryptedMessage);
	if (ret>MAX_SEND_BUFFER_SIZE)
		return -1;
	gettimeofday((struct timeval *) pOrg->padding, NULL);
	pOrg->orgLength=htons(msgLen);
	pOrg->orgCheckSum=checksum(msg, msgLen,0);
	memcpy(pOrg->orgMessage,msg,msgLen);
	memcpy(pOrg->orgMessage+msgLen, &pOrg->padding,fillPadCnt);

	for (unsigned int i=0;i<ret-offsetof(struct _MSG_JSON_MESSAGE,CryptedMessage);i+=8)
		tea_encrypt ((uint32_t*) (cBuffer+i), (uint32_t*) pKey);

	return ret;
}

static inline bool  DecryptMessage( MSG_JSON_MESSAGE *pOut ,unsigned short bufferLen,unsigned char * pKey)
{
	unsigned short packetLength;

	unsigned short fillPadCnt=0;
	unsigned char *cBuffer =pOut->CryptedMessage;
	for (unsigned int i=0;i<bufferLen-offsetof(struct _MSG_JSON_MESSAGE,CryptedMessage);i+=8)
		tea_decrypt ((uint32_t*) (cBuffer+i), (uint32_t*) pKey);

	MESSAGE *pMsg =(MESSAGE *)(pOut->CryptedMessage);
	pMsg->orgLength =ntohs(pMsg->orgLength);
	packetLength=getCryptedLength(pMsg->orgLength,&fillPadCnt);
	packetLength+=offsetof(struct _MSG_JSON_MESSAGE,CryptedMessage);
	if (packetLength!=bufferLen ){
#ifndef IN_JNI
#ifdef TRACE_PACKET
		printf("\r\np packetLength!=bufferLen packetLength=%d bufferLen=%d fillPadCnt=%d\r\n"
			,packetLength
			,bufferLen
			,fillPadCnt);
#endif
#endif
		return false;
	}

	unsigned short tmpChkCum = checksum((unsigned char *)&pMsg->orgCheckSum, pMsg->orgLength+sizeof(pMsg->orgCheckSum),0);

	if (tmpChkCum){
#ifndef IN_JNI
#ifdef TRACE_PACKET
		printf("check sum error!!\r\n");
#endif
#endif
	}

#ifndef IN_JNI
#ifdef TRACE_PACKET
	printHex((unsigned char *)pOut,bufferLen);

	printf("\r\n%s\r\n", pMsg->orgMessage);
#endif
#endif
	return true;
}




#if !defined( _WIN32) && !defined( _WIN64)
#ifndef offsetof
#define offsetof(s,m)   (size_t)&(((s *)0)->m)
#endif
#endif

#define	ERR_SUCCESS			0
#define	ERR_INVALID_HEADER	1
#define	ERR_INVALID_CONTENT	2
#define	ERR_INVALID_CMD		3

#define ERR_PARTB_OFFLINE   4




#ifdef _MSC_VER
typedef int socklen_t;
#endif

#ifdef _MSC_VER
#pragma pack(pop)
#endif


#endif
