# ------------[ Base Image ]-------------
ARG ELASTICSEARCH_VERSION
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}

# ------------[ Environment Settings ]-------------
# Giúp ES chạy single-node, tắt security, bật GC logs
ENV discovery.type=single-node \
    cluster.name=es-docker-cluster \
    node.name=elasticsearch \
    bootstrap.memory_lock=true \
    xpack.security.enabled=false \
    xpack.security.http.ssl.enabled=false \
    ES_JAVA_OPTS="-Xms1g -Xmx1g -Dlog4j2.formatMsgNoLookups=true"

# ------------[ Plugin Installation ]-------------
# Cài plugin cần thiết – giữ “--batch” để tránh hỏi tương tác
RUN bin/elasticsearch-plugin install --batch analysis-icu && \
    bin/elasticsearch-plugin install --batch analysis-phonetic

# ------------[ Permissions & Volume Setup ]-------------
# Đảm bảo quyền ghi đúng (nếu dùng bind mount ngoài)
RUN mkdir -p /usr/share/elasticsearch/data && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch

VOLUME ["/usr/share/elasticsearch/data"]

# ------------[ Healthcheck ]-------------
# Kiểm tra Elasticsearch đang lắng nghe trên port 9200
HEALTHCHECK --interval=30s --timeout=10s --retries=5 \
  CMD curl -s http://localhost:9200 >/dev/null || exit 1

# ------------[ Default Command ]-------------
USER elasticsearch
EXPOSE 9200 9300