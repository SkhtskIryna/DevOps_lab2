#ifndef HTTP_SERVER_H
#define HTTP_SERVER_H

void SendGETresponse(int fd, char* strFilePath, char* strResponse);
void SendPUTresponse(int fd, char* strFilePath, char* strBody, char* strResponse);

#endif
