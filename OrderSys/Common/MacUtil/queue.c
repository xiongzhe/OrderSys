/*
 * queue.c
 *
 *  Created on: 2015-7-19
 *      Author: Administrator
 */


#include "queue.h"
#include <pthread.h>
#include <stdio.h>

pthread_mutex_t gIdleSendQueueMutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t gRecvIdleQueueMutex = PTHREAD_MUTEX_INITIALIZER;

pthread_mutex_t gStandbySendQueueMutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t gStandbyRecvQueueMutex = PTHREAD_MUTEX_INITIALIZER;

QUEUE_HEADER gIdleRecvQueueHeader={0};
QUEUE_ITEM * gIdleRecvQueueTail=NULL;

QUEUE_HEADER gIdleSendQueueHeader={0};
QUEUE_ITEM * gIdleSendQueueTail=NULL;

QUEUE_HEADER gStandbySendHeader={0};
QUEUE_ITEM * gStandbySendTail=NULL;

QUEUE_HEADER gStandbyRecvHeader={0};
QUEUE_ITEM * gStandbyRecvTail=NULL;


struct QUEUE_ITEM * aquireQueue(int bufferLen,QUEUE_HEADER*pHeader,QUEUE_ITEM **pTail,pthread_mutex_t *pMutex) {
	struct QUEUE_ITEM * ret=NULL;
		if (pHeader->pointerHeader==NULL){
			if (bufferLen>0){
				ret=(QUEUE_ITEM *)malloc(sizeof(  QUEUE_ITEM));
				ret->BufferLength=(bufferLen+63)/64*64;
				ret->DataLength=bufferLen;
				ret->PeerAddressLength = sizeof(struct sockaddr_in);
				ret->Buffer=(char*)malloc( ret->BufferLength );
				ret->pNext=NULL;
			}
			return ret;
		}

		pthread_mutex_lock(pMutex);
		ret=pHeader->pointerHeader;
		pHeader->pointerHeader=ret->pNext;
		pHeader->queueLength--;
		ret->pNext=NULL;
		if (pHeader->pointerHeader==NULL){
			*pTail=NULL;
		}

		if (bufferLen>0 ){
			if ( bufferLen>ret->BufferLength){
				ret->BufferLength=(bufferLen+63)/64*64;
				ret->Buffer=(char*)realloc(ret->Buffer, ret->BufferLength );
			}
			ret->DataLength=bufferLen;
		}


		pthread_mutex_unlock(pMutex);
		return ret;
}

void release(struct QUEUE_ITEM * pItem, QUEUE_HEADER*pHeader,
		QUEUE_ITEM **pTail, pthread_mutex_t *pMutex) {
	if (pItem == NULL) {
		return;
	}

	pthread_mutex_lock(pMutex);
	pItem->pNext = NULL;
	if (*pTail == NULL) {
		*pTail = pItem;

	} else {
		(*pTail)->pNext = pItem;
		*pTail = pItem;

	}

	if ( pHeader->pointerHeader == NULL) {
		pHeader->pointerHeader= pItem;

	}
	pHeader->queueLength++;
	pthread_mutex_unlock(pMutex);
}

struct QUEUE_ITEM * aquireIdleSendQueue(int bufferLen) {
	return aquireQueue(  bufferLen,&gIdleSendQueueHeader,&gIdleSendQueueTail,&gIdleSendQueueMutex);
}
struct QUEUE_ITEM * aquireIdleRecvQueue(int bufferLen){
	 return aquireQueue(  bufferLen,&gIdleRecvQueueHeader,&gIdleRecvQueueTail,&gRecvIdleQueueMutex);
}
struct QUEUE_ITEM * aquireStandbyRecvQueue(){
	return aquireQueue(0,&gStandbyRecvHeader,&gStandbyRecvTail,&gStandbyRecvQueueMutex) ;
}
struct QUEUE_ITEM * aquireStandbySendQueue(){
	return aquireQueue(0,&gStandbySendHeader,&gStandbySendTail,&gStandbySendQueueMutex) ;
}

void releaseIdleRecvQueue(struct QUEUE_ITEM * pItem){

	release( pItem, &gIdleRecvQueueHeader,&gIdleRecvQueueTail,&gRecvIdleQueueMutex);
}

void releaseIdleSendQueue(struct QUEUE_ITEM * pItem){
	release( pItem, &gIdleSendQueueHeader,&gIdleSendQueueTail,&gIdleSendQueueMutex);
}

void releaseStandbyRecvQueue(struct QUEUE_ITEM * pItem){
	release( pItem, &gStandbyRecvHeader,&gStandbyRecvTail,&gStandbyRecvQueueMutex);
}

void releaseStandbySendQueue(struct QUEUE_ITEM * pItem){
	release( pItem, &gStandbySendHeader,&gStandbySendTail,&gStandbySendQueueMutex);
}


void destoryQueue(QUEUE_HEADER *pHeader){
	if (pHeader==NULL)
		return ;
	if (pHeader->pointerHeader==NULL){
		return ;
	}
	QUEUE_ITEM * pItem = pHeader->pointerHeader;
	while (pItem){
		if(pItem->Buffer ){
			printf("begin free(pItem->Buffer);\r\n");
			free(pItem->Buffer);
			printf("end free(pItem->Buffer);\r\n");
			pItem->Buffer=NULL;
		}

		QUEUE_ITEM * next= pItem->pNext;
		printf("begin free(pItem);\r\n");
		free(pItem);
		printf("end free(pItem);\r\n");
		pItem = next;
	}
}
void destoryAllQueue(){

	printf("begin mutex_destroy\r\n");
	pthread_mutex_destroy(&gIdleSendQueueMutex);
	pthread_mutex_destroy(&gRecvIdleQueueMutex);
	pthread_mutex_destroy(&gStandbySendQueueMutex);
	pthread_mutex_destroy(&gStandbyRecvQueueMutex);
	printf("end mutex_destroy\r\n");

	printf("begin destoryQueue gIdleRecvQueueHeader\r\n");
	destoryQueue(&gIdleRecvQueueHeader);
	printf("begin destoryQueue gIdleSendQueueHeader\r\n");
	destoryQueue(&gIdleSendQueueHeader);
	printf("begin destoryQueue gStandbySendHeader\r\n");
	destoryQueue(&gStandbySendHeader);
	printf("begin destoryQueue gStandbyRecvHeader\r\n");
	destoryQueue(&gStandbyRecvHeader);
	printf("end destoryQueue\r\n");

}
