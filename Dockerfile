FROM n8nio/n8n:latest

USER root
# Ensure bash is available for the entrypoint script (Alpine image does not include it by default)
RUN apk add --no-cache bash
COPY scripts/start-n8n-with-workflow.sh /docker-entrypoint-with-workflow.sh
RUN chmod +x /docker-entrypoint-with-workflow.sh

USER node
ENTRYPOINT ["/docker-entrypoint-with-workflow.sh"]
CMD ["start"]
