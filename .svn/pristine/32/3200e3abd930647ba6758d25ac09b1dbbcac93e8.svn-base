/*
 * queue.h
 *
 *  Created on: 2015-7-19
 *      Author: Administrator
 */

#ifndef QUEUE_H_
#define QUEUE_H_
#include <pthread.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdlib.h>
typedef struct QUEUE_ITEM
{
	struct sockaddr_in PeerAddress;
	socklen_t PeerAddressLength;
	unsigned short BufferLength;
	unsigned short DataLength;
	unsigned char *Buffer;
	struct QUEUE_ITEM *pNext;
}QUEUE_ITEM;

typedef struct QUEUE_HEADER
{
	struct QUEUE_ITEM *pointerHeader;
	int queueLength;
}QUEUE_HEADER;

struct QUEUE_ITEM * aquireIdleSendQueue(int bufferLen);
struct QUEUE_ITEM * aquireIdleRecvQueue(int bufferLen);
struct QUEUE_ITEM * aquireStandbyRecvQueue();
struct QUEUE_ITEM * aquireStandbySendQueue();

void releaseIdleSendQueue(struct QUEUE_ITEM * pItem);
void releaseStandbySendQueue(struct QUEUE_ITEM * pItem);

void releaseIdleRecvQueue(struct QUEUE_ITEM * pItem);
void releaseStandbyRecvQueue(struct QUEUE_ITEM * pItem);

void destoryAllQueue();
#endif /* QUEUE_H_ */
