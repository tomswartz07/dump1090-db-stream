FROM python:3.12.3-alpine
LABEL org.opencontainers.image.source=https://github.com/tomswartz07/dump1090-db-stream
LABEL org.opencontainers.image.authors="tom+docker@tswartz.net"
LABEL description="Docker container to ingest ADS/B data via Dump1090 streams and store it in a PostgreSQL database."

ENV DUMP1090HOST=""
ENV DUMP1090PORT="30003"
ENV PGHOST="localhost"
ENV PGPORT="5432"
ENV PGDATABASE="adsb"
ENV PGSCHEMA="adsb"
ENV PGTABLE="adsb_messages"
ENV PGUSER="postgres"
ENV PGPASSWORD=""
ENV BUFFER_SIZE="10000"
ENV BATCH_SIZE="1"
ENV CONNECT_ATTEMPT_LIMIT="10"
ENV CONNECT_ATTEMPT_DELAY="5.0"

RUN apk update && apk add --no-cache postgresql-client
COPY create_schema.sql .
COPY dump1090-postgres.py .
COPY requirements.txt .
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python", "/dump1090-postgres.py"]
HEALTHCHECK CMD ps aux | grep '[d]ump1090' || exit 1
