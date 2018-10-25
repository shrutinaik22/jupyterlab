FROM shrutinaik22/pythonbase:v1
# R Repo
RUN  echo 'deb http://cran.rstudio.com/bin/linux/ubuntu xenial/' > /etc/apt/sources.list.d/rstudio.list
RUN  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

RUN apt-get update && apt-get install -y \
      python3-pip sudo libnlopt-dev \
      r-base-dev  icu-devtools zlib1g-dev libncurses5-dev libsasl2-dev \
      libssl-dev libxml2-dev openjdk-8-jdk  r-cran-rjava libmariadb-client-lgpl-dev libpq-dev texlive-xetex \
      default-jre default-jdk r-base-core icu-devtools zlib1g-dev libncurses5-dev libsasl2-dev \
      libnlopt-dev libgmp3-dev libglu1-mesa-dev libssl-dev libxml2-dev openjdk-8-jdk \
      libmariadb-client-lgpl-dev r-cran-rgl libmpfr-dev libpq-dev texlive-xetex libgdal-dev libudunits2-dev \
      libmagick++-dev mesa-common-dev libcurl4-gnutls-dev \
      && \
    apt-get clean

#python 
RUN pip3 install jupyterlab numpy matplotlib pandas

# Set to use python 3 as the default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

WORKDIR /app
COPY entrypoint.sh .
RUN chmod a+x entrypoint.sh
COPY jupyter_notebook_config.py .
COPY pip.conf .

# Create and use matrix user
RUN groupadd --gid=1100 matrix && \
    useradd --create-home --uid=1100 --gid=1100 matrix && \
    echo 'matrix ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

# Somewhere to put the sqllite DB which cannot be on NFS
RUN mkdir /app/jupyter && chown matrix:matrix /app/jupyter


USER matrix
WORKDIR /home/matrix
EXPOSE 8888

ENTRYPOINT ["sh", "-c", "/app/entrypoint.sh >>/var/log/stdout.log 2>>/var/log/stderr.log"]
