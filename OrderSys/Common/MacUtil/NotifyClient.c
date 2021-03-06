#include "NotifyClient.h"


#include <stddef.h>

#include <unistd.h>

#include "TEA.h"
#include "MD5.h"

#include "client.h"



unsigned long long  getCryptedWLanMAC
(IN const unsigned char *  token,IN unsigned long long iMAC,IN int timestamp)
{
    int ts = htonl(timestamp);
    
    MD5_CTX mdContext;
    MD5Init(&mdContext);
    MD5Update(&mdContext, (unsigned char *)token, 16);
    MD5Update(&mdContext, (unsigned char *)&ts, sizeof(int));
    
    MD5Final(&mdContext);
    
    unsigned long long ret=iMAC;
    
    tea_encrypt((uint32_t*) &ret, (uint32_t*) mdContext.digest);
 
    return ret;

}


unsigned long long  decryptedWLanMAC
(IN const  unsigned char *  token,IN  int  timestamp,IN  unsigned long long  cryptedMAC)
{
    int ts = htonl(timestamp);
    unsigned long long ret=0;
    
    MD5_CTX mdContext;
    MD5Init(&mdContext);
    MD5Update(&mdContext, (unsigned char *) token, 16);
    MD5Update(&mdContext, (unsigned char *) &ts, sizeof(int));
    
    MD5Final(&mdContext);
    
    ret = cryptedMAC;
    
    tea_decrypt((uint32_t*) &ret, (uint32_t*) mdContext.digest);
    return ret;
}


void createSecretKey
(OUT unsigned char * token )
{
    unsigned char buffer[16]={0};
    MD5_CTX mdContext;
    int * pInt;

    srand( (unsigned)time( NULL ) );
    pInt = (int *) buffer;
    *pInt = rand() ;
    pInt++;
    *pInt = rand() ;
    pInt++;
    *pInt = rand() ;
    pInt++;
    *pInt = rand() ;
    
    
    MD5Init(&mdContext);
    MD5Update(&mdContext, buffer, sizeof(buffer));
    
    MD5Final(&mdContext);
    
    memcpy(token,mdContext.digest,16);
    

}


void getCryptedPassword
(unsigned long long iMAC,IN const char *  userName,IN const char *  password, IN int timestamp,IN const unsigned char * token,OUT char * cryptedPasswd)
{
    MD5_CTX mdContext;
    if (userName==NULL){
        return ;
    }
    if (password==NULL){
        return ;
    }
    if (token==NULL){
        return ;
    }
    
    int ts = htonl(timestamp);
    MD5Init(&mdContext);
    MD5Update(&mdContext, (unsigned char *)userName, strlen(userName));
    MD5Update(&mdContext, ((unsigned char *)&iMAC)+2,6);
    MD5Update(&mdContext, (unsigned char *)&ts,sizeof(ts));
    MD5Update(&mdContext, (unsigned char *)password,strlen(password));
    MD5Update(&mdContext, (unsigned char *)token,16);
    ts=0;
    MD5Update(&mdContext, (unsigned char *)&ts,sizeof(ts));
    ts=htonl(0xFFFFFFFF);
    MD5Update(&mdContext, (unsigned char *)&ts,sizeof(ts));
    ts=htonl(0x55AA77EE);;
    MD5Update(&mdContext, (unsigned char *)&ts,sizeof(ts));
    
    MD5Final(&mdContext);
    
    
    char * outPtr=cryptedPasswd;
    unsigned char * inPtr= mdContext.digest;
    
    for (int i=0;i<sizeof(mdContext.digest);i++){
        int pnt = sprintf(outPtr,"%02X",*inPtr);
        inPtr++;
        outPtr+=pnt;
    }
}


uint64_t  cryptLongWithTimeStamp (unsigned char * token, int timeStamp, uint64_t data)
{
	uint64_t ret=0;
 
	MD5_CTX mdContext;
	int ts =0;
	if (token==NULL)
	{
		return 0;
  }
	ts = htonl(timeStamp);
	 
	MD5Init(&mdContext);
	MD5Update(&mdContext, token, 16);
	MD5Update(&mdContext, (unsigned char *)&ts, sizeof(int));

	MD5Final(&mdContext);
	ret=data;
	tea_encrypt((uint32_t*) &ret, (uint32_t*) mdContext.digest);
	return ret;
}


uint64_t decryptLongWithTimeStamp (unsigned char * token, int timeStamp, uint64_t cryptedData)
{
	uint64_t ret=0;
	MD5_CTX mdContext;

	int ts;
	if (token == NULL)
	{
		return 0;
	}
	 
	ts = htonl(timeStamp);
	MD5Init(&mdContext);
	MD5Update(&mdContext, token, 16);
	MD5Update(&mdContext, (unsigned char *)&ts, sizeof(int));

	MD5Final(&mdContext);

	ret=cryptedData;

	tea_decrypt((uint32_t*) &ret, (uint32_t*) mdContext.digest);

	
	return ret;

}


uint64_t  cryptLong(unsigned char * token, uint64_t data)
{
	uint64_t ret=0;
	MD5_CTX mdContext;
	 
	if (token ==  NULL)
	{
		return 0;
	}

	MD5Init(&mdContext);
	MD5Update(&mdContext, token,16);
 	MD5Final(&mdContext);

	ret=data;
	tea_encrypt((uint32_t*) &ret, (uint32_t*) mdContext.digest);
	return ret;
}

uint64_t  decryptLong(unsigned char * token, uint64_t cryptedData)
{
	uint64_t ret=0;
	MD5_CTX mdContext;
	if (token==NULL)
	{
		return 0;
	}

	MD5Init(&mdContext);
	MD5Update(&mdContext, token, 16);
 	MD5Final(&mdContext);

	ret=cryptedData;

	tea_decrypt((uint32_t*) &ret, (uint32_t*) mdContext.digest);

	return ret;

}
