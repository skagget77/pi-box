FROM alpine:3.24

RUN apk add --no-cache git nodejs npm emacs-nox bash openssh-client && \
    adduser -D -s /bin/bash pi

USER pi
WORKDIR /home/pi

ENV NPM_CONFIG_PREFIX=/home/pi/.local
ENV PATH=/home/pi/.local/bin:$PATH

# The pi-coding-agent is pinned for reproducibility; drop the @<version>
# suffix to track the latest release. Requires Node >= 22.19.
# --ignore-scripts is safe: installs work with it and it avoids running
# third-party postinstall scripts during the image build.
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent@1.3.0

CMD ["/bin/bash"]
