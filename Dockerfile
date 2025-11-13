FROM n8nio/n8n:latest

USER root
COPY scripts/start-n8n-with-workflow.sh /docker-entrypoint-with-workflow.sh
RUN chmod +x /docker-entrypoint-with-workflow.sh

USER node
ENTRYPOINT ["/docker-entrypoint-with-workflow.sh"]
CMD ["start"]
