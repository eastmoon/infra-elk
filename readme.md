# Elasticsearch & Kibana

## 指令

+ 啟動虛擬環境
```
dockerw start
```

+ 關閉虛擬環境
```
dockerw down
```

## 設定

### 初始化 Elasticsearch & Kibana ( EK )

依據 Elastic 7.12.1 版本的設定過程，其需要注意以下事項：

+ Kibana 的啟動依存 Elasticsearch，若 Elasticsearch 若未啟動，Kibana 將無法啟動
+ Kibana 的 elasticsearch.hosts 需設定為正確的主機名稱與連接埠，如 "http://elasticsearch:9200"
+ Kibana 的 Server.Host 需設定為 "0.0.0.0"

## 操作

## 議題

## 參考

+ [Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#_pulling_the_image)
    - [Elasticsearch 基本概念 & 搜尋入門](https://godleon.github.io/blog/Elasticsearch/Elasticsearch-getting-started/)
+ [Kibana with Docker](https://www.elastic.co/guide/en/kibana/current/docker.html#bind-mount-config)
+ [Elasticsearch, Logstash, Kibana (ELK) Docker image](https://hub.docker.com/r/sebp/elk/)
