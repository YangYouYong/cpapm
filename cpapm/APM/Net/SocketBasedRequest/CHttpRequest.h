//
//  CHttpRequest.h
//  cpapm
//
//  Created by yangyouyong on 2018/1/29.
//  Copyright © 2018年 welltang. All rights reserved.
//

#ifndef CHttpRequest_h
#define CHttpRequest_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <unistd.h>


static inline const char *strAppend(const char *, const char *) __attribute__ ((always_inline));
static inline const char *getIpWithDomain(const char *);


void error(const char *msg)
{
    perror(msg);
    exit(1);
}

typedef void (*ResponseCallBack)(const char*, char *, int);

static void getRequest(const char* requestIdentifier, const char *protocol, const char *domain, const char *path , ResponseCallBack responseCallBack);
void getRequest(const char* requestIdentifier, const char *protocol, const char *domain, const char *path , ResponseCallBack responseCallBack) {
    
    int sockfd;
    struct sockaddr addr;
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if(sockfd < 0) {
        error("ERROR opening socket");
    }
    
    void *identifier = malloc(strlen(requestIdentifier) + 1);
    char *cId = (char *)memcpy(identifier, requestIdentifier, strlen(requestIdentifier));
    cId[strlen(requestIdentifier)] = '\0';
    
    memset((char*)&addr, 0, sizeof(addr));
    
    struct addrinfo *info;
    
    // 默认80 端口
    if (getaddrinfo(domain, "80", NULL, &info) != 0) {
        printf("get domain error");
    }
    addr = *info->ai_addr;
    
    if(connect(sockfd, &addr, sizeof addr) < 0) {
        close(sockfd);
        error("ERROR connecting to server");
    }
    
    
    // format request eg: "GET /ip HTTP/1.1\r\nContent-Type: application/x-www-form-urlencoded\r\nUser-Agent: runscope/0.1\r\nHost: httpbin.org\r\nContent-Length: 0\r\n\r\n";
    
    const char *request = strAppend(NULL,(const char *)"GET ");
    request = strAppend(request, path);    // path contains parms
    request = strAppend(request, " HTTP/1.1\r\n"); // cat protocol
    request = strAppend(request, "Host:"); // cat host
    request = strAppend(request, domain);
    request = strAppend(request, "\r\n");
    request = strAppend(request, "Connection: close\r\n\r\n");
    
    char response[1024];
    char splitResponse[1024];
    send(sockfd, request, strlen(request), 0);
    
    while(recv(sockfd, response,sizeof(response), 0) > 0) {
        // parse first line
        // parse headers
        // 倒序查找最后一组 \r\n 的位置 slice body
        printf("response: %s\n",response);
        
        ////////////////////////parse body begin/////////////////////
        
        char *pstr = NULL;
        
        strncpy(splitResponse, response, strlen(response));
        char *separator = "\r";
        int startIndex = 0;
        int endIndex = 0;
        
        char charlist[1024];
        int i = 0;
        char *substr= strtok(response, separator);
        while (substr != NULL) {
            strcpy(charlist,substr);
            startIndex += strlen(substr);
            substr = strtok(NULL,separator);
            int responseLength = strlen(response);
            if (startIndex < responseLength - 2) {
                char nextTwoString[3];
                nextTwoString[2] = '\0';
                strncpy(nextTwoString, response, startIndex);
                printf("nextTwo:%s",nextTwoString);
                if (strcmp(nextTwoString, "\r\n") == 0) {
                    printf("bodybegin");
                    strncpy(charlist, response, strlen(response) - startIndex);
                    charlist[strlen(response) - startIndex + 1] = '\0';
                }
            }
            i ++;
        }
        
        
//        pstr = strtok((char *)temp, "\r\n");
//        while (pstr != NULL) {
//
//            pstr = strtok((char *)temp, "\r\n");
//        }
        printf("finilized body:%s",charlist);
        printf("startIndex: %d",startIndex);
        printf("length: %d",strlen(splitResponse));
        i = strlen(charlist);
        while (i > 0) {
            char str = charlist[i];
            if (str == '}') {
                endIndex = i;
                break;
            }
            i --;
        }
        printf("endIndex: %d",endIndex);
        int bodyLenght = endIndex - startIndex;
        char destiny[1024];
        strncpy(destiny , charlist, strlen(splitResponse) - endIndex);
        destiny[bodyLenght + 1] = '\0';
//        strncpy(charlist, response, strlen(response) - startIndex);
//        char *ss = strstr((char *)response, "\n\r");
        
        ////////////////////////parse body end/////////////////////
        
        // 解析response header
        if (responseCallBack) {
            responseCallBack((const char *)cId, destiny, 0); // append data outside
        }
    }
    
    if (responseCallBack) {
        responseCallBack((const char *)cId, NULL, 1); // append data outside
    }
    
    close(sockfd);
    
}

const char* strAppend(const char *s1, const char *s2)
{
    if (s1 == NULL) {
        void *result = malloc(strlen(s2)+1);
        strcpy((char *)result, s2);
        return (char *)result;
    }
    void *result = malloc(strlen(s1)+strlen(s2)+1);
    if (result == NULL) exit (1);
    
    strcpy((char *)result, s1);
    strcat((char *)result, s2);
    
    return (char *)result;
}

const char *getIpWithDomain(const char *domain) {
    struct hostent *hs;
    struct sockaddr_in server;
    hs = gethostbyname(domain);
    if (hs != NULL) {
        server.sin_addr = *((struct in_addr*)hs->h_addr_list[0]);
        return inet_ntoa(server.sin_addr);
    }
    return NULL;
}
//static void syncGetRequest(const char *protocol, const char *domain, const char *path);

#endif /* CHttpRequest_h */
