# Elasticsearch, Logstash, Kibana

## 指令

+ 啟動虛擬環境
```
dockerw up
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

+ [Elasticsearch, Logstash, Kibana (ELK) Docker image](https://hub.docker.com/r/sebp/elk/)
+ [Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#_pulling_the_image)
    - [Elasticsearch 基本概念 & 搜尋入門](https://godleon.github.io/blog/Elasticsearch/Elasticsearch-getting-started/)
    - [Elasticsearch  Memory Usage Guide](https://opster.com/elasticsearch-glossary/elasticsearch-memory-usage/)
+ [Kibana with Docker](https://www.elastic.co/guide/en/kibana/current/docker.html#bind-mount-config)
+ [Logstash with Docker](https://www.elastic.co/guide/en/logstash/current/docker.html)
    - [Logstash Reference](https://www.elastic.co/guide/en/logstash/current/index.html)
    - 實務記錄
        + [Day3 - logstash 輸入配置](https://ithelp.ithome.com.tw/articles/10186351)
        + [15-利用Logstash做資料整理](https://ithelp.ithome.com.tw/articles/10237356)
        + [Logstash Pattern 簡單教學](https://mmx362003.gitbooks.io/elk-stack-guide/content/logstash_grok.html)
+ [Filebeat with Docker](https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html)
    - [Elastic Logging X Filebeat 深入理解](https://linyencheng.github.io/2020/09/09/elastic-observability-logging-introduction/)
