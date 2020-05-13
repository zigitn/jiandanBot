# 引入golang编译环境
FROM golang as gobuilder
# 修改默认的GOPATH
ENV GOPATH=/GOPATH
# 复制go mod 文件至容器内
COPY go.mod go.sum ./
# 单独下载所需mod为一层,避免每次编译重复拉取依赖
RUN go mod download
# 复制源文件进入容器
COPY ./bot ./bot
COPY ./main.go .
COPY ./channel ./channel
COPY ./crawler ./crawler
COPY ./maker ./maker
COPY ./types ./types
#编译
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o main .


# 第二层,引入scratch环境
FROM scratch
# 添加证书
COPY --from=gobuilder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
# 从第一层中复制已经编译好的二进制文件
COPY --from=gobuilder /go/main .
# 运行
CMD ["/main"]
