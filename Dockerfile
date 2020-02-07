FROM scratch
EXPOSE 8080
ENTRYPOINT ["/golang-http-jxboot-2020020701"]
COPY ./bin/ /