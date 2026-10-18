FROM alpine:3.24

RUN apk add --no-cache git nodejs npm emacs-nox bash openssh-client && \
    adduser -D -s /bin/bash pi

USER pi
WORKDIR /home/pi

ENV NPM_CONFIG_PREFIX=/home/pi/.local
ENV PATH=/home/pi/.local/bin:$PATH

# One ssh-agent for the lifetime of the container: sourced from
# ~/.bashrc in every interactive shell; starts the agent on first use
# (prompting for the key passphrase in that shell) and reuses it after.
COPY --chown=pi:pi --chmod=0644 ssh-agent.sh /home/pi/.pi-box/ssh-agent.sh
RUN printf '%s\n' "    . ~/.pi-box/ssh-agent.sh" >> /home/pi/.bashrc

# The pi-coding-agent is pinned to 1.0.4 due a dependency issue in 1.1.0:
# No matching version found for @aws-sdk/credential-provider-node@^3.972.86.
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent@1.0.4

CMD ["/bin/bash"]
