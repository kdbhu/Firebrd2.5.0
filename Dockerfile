FROM debian:bullseye-slim
LABEL maintainer="KDB"

ENV VOLUME=/firebird
ENV DEBIAN_FRONTEND noninteractive
ENV FBURL=http://sourceforge.net/projects/firebird/files/firebird-linux-amd64/2.5-Release/FirebirdSS-2.5.0.26074-0.amd64.tar.gz/download
ENV PWD="masterkey"

ADD changepwd.sh changepwd.sh

RUN apt-get update && \
    apt-get install -qy --no-install-recommends \
        curl \
        ca-certificates \
        libncurses5 \
        libtommath1 && \
    mkdir -p /home/firebird && \
    cd /home/firebird/ && \
    curl -L -o FirebirdSS.amd64.tar.gz -L "${FBURL}" && \
    tar --strip=1 -xzvf FirebirdSS.amd64.tar.gz && \
    rm FirebirdSS.amd64.tar.gz && \
    sed -i 's/InteractiveInstall=1/InteractiveInstall=0/g' install.sh && \
    sed -i 's/InteractiveInstall=1/InteractiveInstall=0/g' install.sh && \
    sed -i 's/AskQuestion "Press Enter to start installation or ^C to abort"//g' install.sh && \
    sed -i 's/AskQuestion "Please enter new password for SYSDBA user: "//g' install.sh && \
    sed -i 's/NewPasswd=$Answer/NewPasswd="${PWD}"/g'  install.sh && \
    sed -i 's/AskQuestion "Press return to continue or ^C to abort"/echo ""/g' install.sh && \
    sed -i 's/AskQuestion "Please enter new password for SYSDBA user: "//g' scripts/preinstall.sh && \
    sed -i 's/NewPasswd=$Answer/NewPasswd="${PWD}"/g'  scripts/preinstall.sh && \
    sed -i 's/AskQuestion "Please enter new password for SYSDBA user: "//g' scripts/postinstall.sh && \
    sed -i 's/NewPasswd=$Answer/NewPasswd="${PWD}"/g'  scripts/postinstall.sh && \
    ./install.sh && \
    cd /home && \
    rm -rf /home/firebird && \
    apt-get purge -qy --auto-remove \
        curl \
        ca-certificates && \
    chmod +x /changepwd.sh

RUN mkdir /data && chown firebird:firebird /data
VOLUME ["/data"]

EXPOSE 3050/tcp

ADD entrypoint.sh entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]