FROM ubuntu:18.10

MAINTAINER https://github.com/emichael/SlackLaTeXBot


# Install main dependencies first
RUN apt-get update && \
    apt-get install -y \
      python-pip \
      texlive \
      texlive-extra-utils \
      imagemagick && \
	  rm -rf /var/lib/apt/lists/*

# Verify and add Tini
ENV TINI_VERSION v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# Install app
COPY LatexServer.py error.png requirements.txt /
RUN pip install -r requirements.txt
RUN mkdir images


# Don't run as root
RUN adduser --system --shell /bin/bash --uid 724 --group \
      --no-create-home --disabled-password --disabled-login slacklatex  && \
    chown -R slacklatex:slacklatex LatexServer.py error.png requirements.txt images
USER slacklatex


# Setup app
EXPOSE 8642/tcp
ENTRYPOINT ["/tini", "--", "python", "/LatexServer.py"]
