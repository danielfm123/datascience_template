# Ejemplo de dockerfile
FROM ubuntu:22.04

MAINTAINER Daniel Fischer "dfischer@anasac.cl"

ARG DEBIAN_FRONTEND=noninteractive

#BASELINE
RUN apt-get update \
  && apt-get install -y apt-utils \
  && apt-get -y install wget bash gnupg2 software-properties-common locales curl ssh sshpass \
  && apt install -y ssh sshpass \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

#LOCALES
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


#FreeTDS
RUN apt-get update \
    &&  apt install -y tdsodbc sqsh unixodbc-dev unixodbc \
    &&  echo "" >> /etc/odbcinst.ini \
    &&  echo "[FreeTDS]" >> /etc/odbcinst.ini \
    &&  echo "Driver = /usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so" >> /etc/odbcinst.ini \
    &&  echo "Setup = /usr/lib/x86_64-linux-gnu/odbc/libtdsS.so" >> /etc/odbcinst.ini \
    &&  echo "Port = 1433" >> /etc/odbcinst.ini \
    &&  apt clean \
    &&  rm -rf /var/lib/apt/lists/*

#Python
RUN apt-get update \
    && apt install -y python3 python3-pip \
    && pip3 install --target=/usr/local/lib/python3.10/dist-packages wheel \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

#Para forzar el upgrade a R 4.2
#RUN echo 'R.4.2'

# R
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" > /etc/apt/sources.list.d/cran.list  \
  && wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
  && yes ''| add-apt-repository ppa:c2d4u.team/c2d4u4.0+ \
  && apt update \
  && apt install -y r-base r-base-dev r-cran-tidyverse r-cran-devtools r-cran-odbc libopenblas-base libatlas3-base r-cran-reticulate r-cran-azurestor \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*
  
#Arrow parquet
RUN R -e 'options(HTTPUserAgent = \
    sprintf( \
      "R/%s R (%s)", \
      getRversion(), \
      paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])\
    )\
);install.packages("arrow", repos = "https://packagemanager.rstudio.com/all/__linux__/jammy/latest")'

  
# Paquetes basicos para libreria anasac
RUN pip3 install --target=/usr/local/lib/python3.10/dist-packages pandas pyodbc cryptography sqlalchemy click pyarrow azure-storage-blob azure-identity

# Paquete de R de daniel Fischer
#RUN R -e 'devtools::install_github("danielfm123/dftools",force=T,upgrade = "never")'

#ODBC Driver de MS y instalar PowerShell (para zeus)
#RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"  \
#   && dpkg -i packages-microsoft-prod.deb \
#   && rm packages-microsoft-prod.deb \
#   && apt-get update \
#   && ACCEPT_EULA=Y apt-get install -y --allow-unauthenticated msodbcsql17 msodbcsql18 powershell \
#   && apt install -y unixodbc-dev \
#   && apt clean \
#   && rm -rf /var/lib/apt/lists/* \
#   && pwsh -Command "Install-Module -Name Az.AnalysisServices -Force" \
#   && pwsh -Command "Install-Module -Name SqlServer -Force"\

#ODBC Driver Showflake
#RUN gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 37C7086698CB005C \
#   && wget https://sfc-repo.azure.snowflakecomputing.com/odbc/linux/2.25.4/snowflake-odbc-2.25.4.x86_64.deb \
#   && apt install ./snowflake-odbc-2.25.4.x86_64.deb \
#   && rm ./snowflake-odbc-2.25.4.x86_64.deb


#Julia
#RUN wget -O julia.tar.gz https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.0-linux-x86_64.tar.gz \
#   && tar -zxvf julia.tar.gz \
#   && mv ./julia-1.10.0 /opt/julia \
#   && ln -sf /opt/julia/bin/julia /usr/bin/julia \
#   && julia -e 'using Pkg; Pkg.add(["PyCall","IniFile","DataFrames","DataFramesMeta","StatsBase","Arrow","ODBC"]);' \
#   && rm -rf julia.tar.gz

# latex
# run apt install -y texlive-full

#java 
#  run apt-get update \
#  && apt install -y default-jdk r-cran-rjava \
#  && R CMD javareconf # java para R
#  && apt clean \
#  && rm -rf /var/lib/apt/lists/*

### Fin Baseline Anasac ######

# rclone ubuntu (recomendado)
#RUN apt-get update \
#  && apt install -y rclone \
#  && apt clean \
#  && rm -rf /var/lib/apt/lists/*

#Rclone (current, el mas nuevo, a veces cambia)
#RUN wget -O rclone.deb https://downloads.rclone.org/rclone-current-linux-amd64.deb \
#  && apt install -y ./rclone.deb
#  && rm ./rclone.deb

# otros paquetes de python desde apt (hay pocos)
# RUN apt update \
#  && apt install -y python3-xxxxx
#  && apt clean \
#  && rm -rf /var/lib/apt/lists/*

# otros paquetes python desde pip
# RUN pip3 install --target=/usr/local/lib/python3.10/dist-packages xxxxx

# otros paquees de R desde apt (recomendado)
# RUN apt update \
#  && apt install -y r-cran-xxxxx
#  && apt clean \
#  && rm -rf /var/lib/apt/lists/*

# otros paquees de R desde cran (solo usar si no esta en apt anterior)
# RUN R -e 'install.packages("highcharter")'


# instalar app
RUN mkdir /opt/app
COPY . /opt/app/
#COPY ["global.R","init.R","ui.R","server.R","main_proc.R", "/opt/app"]

WORKDIR /opt/app
CMD ["/bin/sh","./run.sh"]

# para shinyproxy
#EXPOSE 3838
#CMD ["R", "-e", "shiny::runApp('./',port=3838,host = '0.0.0.0')"]
