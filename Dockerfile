FROM r-base:3.4.1

MAINTAINER Ivan Suftin <isuftin@usgs.gov>

RUN apt-get update && \
  apt-get install -y --allow-downgrades --allow-remove-essential \
    telnet \
    libcurl3 \
    libgdal-dev \
    libxml2-dev \
    texlive-latex-base \
    texlive-xetex \
    libgmp-dev \
    libssl-dev \
    git \
    p7zip-full && \
  apt-get clean

ENV RSERVE_HOME /opt/rserve
ENV R_LIBS ${RSERVE_HOME}/R_libs
ENV PANDOC_VERSION_DEFAULT 2.2
ENV USERNAME ${USERNAME:-rserve}
ENV PASSWORD ${PASSWORD:-rserve}

RUN install.r Rserve && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN useradd rserve \
	&& mkdir ${RSERVE_HOME} \
	&& usermod -d ${RSERVE_HOME} rserve

COPY etc ${RSERVE_HOME}/etc

RUN chown -R rserve:rserve ${RSERVE_HOME}

COPY run_rserve.sh ${RSERVE_HOME}/bin/

RUN chmod 755 ${RSERVE_HOME}/bin/run_rserve.sh

# Install Pandoc
RUN wget -O /tmp/pandoc.deb https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION:-$PANDOC_VERSION_DEFAULT}/pandoc-${PANDOC_VERSION:-$PANDOC_VERSION_DEFAULT}-1-amd64.deb && \
  dpkg -i /tmp/pandoc.deb && \
  rm /tmp/pandoc.deb

RUN wget -O /tmp/oberdiek.tds.zip http://mirrors.ctan.org/install/macros/latex/contrib/oberdiek.tds.zip && \
  wget -O /tmp/ifxetex.tds.zip http://mirrors.ctan.org/install/macros/generic/ifxetex.tds.zip && \
	7z x /tmp/oberdiek.tds.zip -o/usr/share/texmf -y && \
  7z x /tmp/ifxetex.tds.zip -o/usr/share/texmf -y && \
  cd /usr/share/texmf && \
  /usr/bin/texhash && \
  rm /tmp/oberdiek.tds.zip && \
  rm /tmp/ifxetex.tds.zip

USER $USERNAME

ARG CACHE_BREAK_DATE=2018-04-26

EXPOSE 6311

HEALTHCHECK --interval=2s --timeout=3s \
 CMD sleep 1 | \
 		telnet localhost 6311 | \
		grep -q Rsrv0103QAP1 || exit 1
USER root

CMD ["/opt/rserve/bin/run_rserve.sh"]
