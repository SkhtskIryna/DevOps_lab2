FROM alpine
WORKDIR /home/app
COPY ./program .
RUN apk add libstdc++
RUN apk add libc6-compat
ENTRYPOINT ["./program"]
