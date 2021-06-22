# Elasticsearch, Logstash, Kibana

ELK 是 Elastic 的數據資訊視覺化服務軟體，其服務在區域使用時並無須收費，但要使用高效率與完整服務則需付費使用 Elastic Cloud。

ELK 可分為三個主要部分：

+ Elasticsearch，No-SQL 資料庫，其特徵是可運用 Index Pattern 來檢索資訊符合的 Index 並整合為數據集
+ Kibana，數據視覺化服務網站，提供使用者介面管理資料，並提供各類表格供數據呈現
+ Logstash，記錄推送服務，提供介面與自動化程序達到 ETL ( Extract-Transform-Load ) 工作，已持續提供數據給 Elasticsearch

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

依據 Elastic 7.12.1 版本的設定過程，其需要注意以下事項：

+ Kibana 的啟動依存 Elasticsearch，若 Elasticsearch 若未啟動，Kibana 將無法啟動
+ Kibana 的 elasticsearch.hosts 需設定為正確的主機名稱與連接埠，如 "http://elasticsearch:9200"
+ Kibana 的 Server.Host 需設定為 "0.0.0.0"
+ Logstash 的配置檔內規劃對外的埠 ( Port )，需同步設定在 docker-compose.yml 中，以確保有正確的連通狀態

## Kibana

在基礎服務的運用上，僅需使用 Elasticsearch & Kibana 即可做到數據上傳、圖表設定，但由於其資料上傳繁瑣，若數據資料複雜、繁多則手動上傳並不適合用於監控，但有益於數據討論。
> 以下操作說明會連結到頁面的網址，請啟動專案服務後以點擊進入頁面

### 手動上傳

+ 回到[首頁](http://localhost:5601/app/home#/)
+ 點擊 [Upload a file](http://localhost:5601/app/ml/filedatavisualizer) 按鈕，進入上載檔案服務
+ 點擊 ```Select or drag and drop a file```，以此選擇要傳入的檔案
+ 系統分析上傳檔案，若失敗則回到上一步，若成功則自動進入 ```Data Visualizer``` 頁面
+ 透過 ```Override settings``` 設定資料轉換與欄位對應名稱等設定，若無須改變則略過此步
+ 點擊 ```Import``` 啟動匯入設定頁面
    - 設定 ```Index naem```，則此數據會以此為名稱記錄於資料庫
    - 啟用 ```Create Index pattern```，自動建立 Index Pattern 以供圖表檢索；若無需建立無用的索引樣板則可關閉此設定
    - 點擊 ```Import``` 正式匯入資料，若未設定 ```Index name``` 此按鈕不可選擇

原則上，每個上傳的檔案對 Elasticsearch 會就是一個對等的 [Index](http://localhost:5601/app/management/data/index_management/indices) 物件 ( 類似 Mongodb 的 Document )

### 管理索引樣板

+ 回到[首頁](http://localhost:5601/app/home#/)
+ 點擊 [Manage](http://localhost:5601/app/management) 按鈕，進入網站管理服務
+ 點擊 [Index Patterns](http://localhost:5601/app/management/kibana/indexPatterns) 選項，以此設定供圖表檢索用的索引樣板
    - 若匯入檔案時選擇 ```Create Index pattern```，則會自動建立對應上傳檔案的索引樣板
    - 若匯入時依據日期或相關設定分批上傳多個有相似 ```Index name``` 檔案，則可點擊 [Create index pattern](http://localhost:5601/app/management/kibana/indexPatterns/create) 按鈕建立多檔案用索引樣板
        + 輸入 ```filename-*```，以 ```*``` 為匹配字符，若有符合的項目會列於下方列表
        + 點擊 ```Next step```，選擇 ```Time field``` ，此為供數據搜訊、排序的欄位
        + 點擊 ```Create index pattern``` 建立索引樣板

索引樣板 ( Index Pattern ) 是 Elasticsearch 用來聚合多筆數據索引 ( Index ) ，並供給數據視覺化的資料來源；若沒建立索引樣板，後續的數據視覺圖表將無法選擇資料來源。

### 建立數據視覺圖表

+ 回到[首頁](http://localhost:5601/app/home#/)，並展開功能選項
+ 選擇 Analytics > [Discover](http://localhost:5601/app/discover)，檢視索引樣板的數據值
+ 選擇 Analytics > [Dashboard](http://localhost:5601/app/dashboards)，檢視或編輯應用索引樣板的數據視覺圖表
+ 需注意，資料要呈現需對應正確的時間區段，請於頁面右上選擇時間段並刷新頁面

## Logstash

在完整的 ELK 服務的運用上，需同時使用 Elasticsearch、Logstash、Kibana 三項服務，而其分別做到數據儲存、數據彙整、數據呈現。

### 範例使用

#### 1、配置檔

專案目錄 ```conf/logstash``` 中的 ```*.conf``` 皆會在 logstash 服務啟動時自動掛載於 pipeline 中；本專案範例的將使用 ```logstash.conf``` 的配置啟用。

在[配置檔結構](https://www.elastic.co/guide/en/logstash/7.13/configuration-file-structure.html)中，共有三個主要設定：

+ [input](https://www.elastic.co/guide/en/logstash/7.13/input-plugins.html)，本配置對於輸入源的設定
+ [filter](https://www.elastic.co/guide/en/logstash/7.13/filter-plugins.html)，本配置對於輸入資料的資料處理邏輯
+ [output](https://www.elastic.co/guide/en/logstash/7.13/output-plugins.html)，本配置對於資料處理完畢後，數據輸出的設定

需注意，設定中並非全部 plugin 皆預設在 logstash 的容器內，若有特殊需求則須於 ```docker/logstash/Dockerfile``` 中安裝。

#### 2、匯入測試數據

本專案範例使用 tcp 並經由 5050 埠匯入檔案。

```
docker exec -ti docker-test_infra-elk bash -l -c "nc -q 1 logstash 5050 < test.json"
```
> ```docker-test_infra-elk``` 為 docker-compose 啟動後的測試服務容器名稱
>
> ```nc -q 1 logstash 5050 < test.json``` 可選擇在 test 目錄下的檔案，例如 ```test.json```、```test.txt```、```test.csv```

需注意，執行檔案若有多行，則會逐行傳輸內容；其傳輸結果可檢視 logstash 容器的記錄檔來確認。

```
docker logs -f docker-logstassh_infra-elk
```
> ```docker-test_infra-elk``` 為 docker-compose 啟動後的 logstash 服務容器名稱

#### 3、設置索引樣板

本專案範例，會依據日期匯入名稱為 ```logstash-%{+YYYY.MM.dd}``` 的索引 ( Index ) 中；因此，若需使用數據，則應依據前述的 Kibana 的操作建立索引樣板 ( Index pattern ) 在編輯對應的數據視覺化圖表。  

## 參考

+ [Elasticsearch, Logstash, Kibana (ELK) Docker image](https://hub.docker.com/r/sebp/elk/)
+ [Elasticsearch with Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#_pulling_the_image)
    - [Elasticsearch 基本概念 & 搜尋入門](https://godleon.github.io/blog/Elasticsearch/Elasticsearch-getting-started/)
    - [Elasticsearch  Memory Usage Guide](https://opster.com/elasticsearch-glossary/elasticsearch-memory-usage/)
+ [Kibana with Docker](https://www.elastic.co/guide/en/kibana/current/docker.html#bind-mount-config)
+ [Logstash with Docker](https://www.elastic.co/guide/en/logstash/current/docker.html)
    - [Logstash Reference](https://www.elastic.co/guide/en/logstash/current/index.html)
        + [logstash configuration](https://www.elastic.co/guide/en/logstash/current/logstash-settings-file.html)
        + [logstash command line](https://www.elastic.co/guide/en/logstash/current/running-logstash-command-line.html)
        + [multiple pipelines](https://www.elastic.co/guide/en/logstash/current/multiple-pipelines.html)，在 Docker 中預設啟動服務的 pipeline，而每個 pipeline 則對等啟動一個 logstash 配置檔
            - [Configuring logstash](https://www.elastic.co/guide/en/logstash/current/configuration.html)
    - 實務記錄
        + [Day3 - logstash 輸入配置](https://ithelp.ithome.com.tw/articles/10186351)
        + [15-利用Logstash做資料整理](https://ithelp.ithome.com.tw/articles/10237356)
        + [Logstash Pattern 簡單教學](https://mmx362003.gitbooks.io/elk-stack-guide/content/logstash_grok.html)
+ [Filebeat with Docker](https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html)
    - [Elastic Logging X Filebeat 深入理解](https://linyencheng.github.io/2020/09/09/elastic-observability-logging-introduction/)
    - [Creating a New Filebeat Moduleedit](https://www.elastic.co/guide/en/beats/devguide/current/filebeat-modules-devguide.html)
