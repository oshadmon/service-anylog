# The following takes AnyLog as a base image simply start an empty node with license key (if set)
# Build: cd service-anylog/sample-docker ; docker build . -t anylog-node
# Sample command: docker run -it -e LICENSE_KEY=XXXX --network host --name anylog-node --rm anylog-node
FROM anylogco/anylog-network:latest AS anylog-node

ENV LICENSE_KEY=""

WORKDIR /app
COPY start_anylog.py /app/start_anylog.py
COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT bash /app/entrypoint.sh

