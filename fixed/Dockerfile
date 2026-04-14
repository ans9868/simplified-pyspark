FROM bitnamilegacy/spark:4.0.0

WORKDIR /app

USER root

RUN groupadd -g 1001 spark && \
    useradd -u 1001 -g spark -m -s /bin/bash -d /opt/bitnami/spark spark || true

RUN mkdir -p /opt/bitnami/spark/tmp && \
    chmod 1777 /tmp && \
    chown -R spark:spark /opt/bitnami/spark && \
    chmod -R 755 /opt/bitnami/spark/tmp

RUN echo "spark:x:1001:1001:Spark User:/opt/bitnami/spark:/bin/bash" > /opt/bitnami/spark/tmp/nss_passwd && \
    echo "root:x:0:0:Root User:/root:/bin/bash" >> /opt/bitnami/spark/tmp/nss_passwd && \
    echo "spark:x:1001:" > /opt/bitnami/spark/tmp/nss_group && \
    echo "root:x:0:" >> /opt/bitnami/spark/tmp/nss_group && \
    chmod 666 /opt/bitnami/spark/tmp/nss_passwd && \
    chmod 666 /opt/bitnami/spark/tmp/nss_group

COPY shared/app.py /app/app.py
COPY shared/jobs.py /app/jobs.py
COPY fixed/session_builder.py /app/session_builder.py
COPY --chmod=755 fixed/entrypoint.sh /entrypoint.sh

ENV LD_PRELOAD=/opt/bitnami/common/lib/libnss_wrapper.so
ENV NSS_WRAPPER_PASSWD=/opt/bitnami/spark/tmp/nss_passwd
ENV NSS_WRAPPER_GROUP=/opt/bitnami/spark/tmp/nss_group

USER spark

ENTRYPOINT ["/entrypoint.sh"]
CMD ["spark-submit", "--conf", "spark.jars.ivy=/tmp/.ivy2", "/app/app.py", "--job", "all"]
