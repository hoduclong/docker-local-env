# Build argument để linh hoạt chọn version
ARG ELASTICSEARCH_VERSION=8.15.3

# Base image Elasticsearch 8.x chính thức
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}

# Disable xpack security để Magento có thể kết nối mà không cần token
ENV discovery.type=single-node \
    xpack.security.enabled=false \
    xpack.security.http.ssl.enabled=false \
    ES_JAVA_OPTS="-Xms1g -Xmx1g"

# Cài các plugin cần thiết (như bạn đang làm ở ES7)
RUN bin/elasticsearch-plugin install --batch analysis-icu && \
    bin/elasticsearch-plugin install --batch analysis-phonetic

# Healthcheck – đảm bảo container chỉ healthy khi 9200 hoạt động
HEALTHCHECK --interval=30s --timeout=10s --retries=5 \
  CMD curl -s http://localhost:9200 >/dev/null || exit 1
