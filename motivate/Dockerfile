FROM golang:1.19.5-alpine3.17
RUN mkdir /app
WORKDIR /app
COPY ./application ./application
EXPOSE 8080
CMD ["/app/application"]