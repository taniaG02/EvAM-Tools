FROM rocker/verse 

RUN apt-get update && \
    apt-get install -f -y software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y libboost-all-dev && \
    apt-get install -y libgsl-dev 



## R packages
RUN R -e "install.packages('BiocManager')"
RUN R -e "BiocManager::install('TRONCO')"
RUN R -e "BiocManager::install('OncoSimulR')"
RUN R -e "install.packages('relations')"
RUN R -e "install.packages('RhpcBLASctl')"
RUN R -e "install.packages('igraph')"
RUN R -e "install.packages('inline')"
RUN R -e "install.packages('Oncotree')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('pryr')"
RUN R -e "install.packages('readr')"
RUN R -e "install.packages('data.table')"
RUN R -e "install.packages('foreach')"
RUN R -e "install.packages('stringr')"
RUN R -e "install.packages('testthat')"
RUN R -e "install.packages('plot.matrix')"
RUN R -e "install.packages('httr')"
RUN R -e "install.packages('openssl')"
RUN R -e "install.packages('xml2')"
RUN R -e "install.packages('usethids')"
RUN R -e "install.packages('credentials')"
RUN R -e "install.packages('roxygen2')"
RUN R -e "install.packages('optparse')"
RUN R -e "install.packages('rversions')"
RUN R -e "install.packages('imager')"
RUN R -e "install.packages('DT')"
RUN R -e "install.packages('shinyjs')"
RUN R -e "install.packages('markdown')"
RUN R -e "install.packages('graph')"
RUN R -e "install.packages('Rlinsolve')"
RUN R -e "install.packages('fastmatrix')"
RUN R -e "library(devtools);devtools::install_github('phillipnicol/OncoBN')"
RUN R -e "install.packages('shiny')"
RUN R -e "install.packages('Matrix')"
RUN R -e "install.packages('stringi')"
RUN R -e "install.packages('stats')"
RUN R -e "install.packages('grDevices')"
RUN R -e "install.packages('graphics')"
RUN R -e "install.packages('parallel')"
RUN R -e "install.packages('utils')"
RUN R -e "install.packages('gtools')"
# RUN R -e "library(devtools);devtools::install_github('cbg-ethz/MC-CBN')"

RUN mkdir -p /app/Sources/

RUN apt-get install -y texlive-fonts-recommended

#Install HESBCN
RUN cd /app/Sources && \
    git clone https://github.com/danro9685/HESBCN && \
    cd HESBCN && \ 
    sed -i "s/gcc-5/gcc-9/g" Makefile && \
    sed -i  "s/^LDLIBS = $/LDLIBS = -lgsl -lm -lgslcblas/g" Makefile && \ 
    make && \
    cp h-esbcn /usr/local/bin/ 

## Install MCCBN
RUN cd /app/Sources && \
    git clone https://github.com/cbg-ethz/MC-CBN && \
    cd MC-CBN  && \ 
    apt-get install -y dh-autoreconf autoconf automake autotools-dev autoconf autoconf-archive && \
    autoreconf -vif -I m4  && \
    R CMD build . && \
    R CMD INSTALL mccbn_*.tar.gz
# RUN apt-get install -y dh-autoreconf autoconf automake autotools-dev autoconf autoconf-archive
# RUN apt-get install -y libboost1.67-dev:amd64 libboost1.67-tools-dev    libboost-graph-parallel1.67-dev
# RUN apt-get remove --purge libboost1.74-tools-dev libboost1.74-dev libboost-wave1.74-dev libboost-type-erasure1.74-dev libboost-timer1.74-dev  libboost-test1.74-dev  libboost-stacktrace1.74-dev libboost-random1.74-dev  libboost-python1.74-dev libboost-program-options1.74-dev libboost-numpy1.74-dev  libboost-nowide1.74-dev  libboost-mpi1.74-dev libboost-mpi-python1.74.0  libboost-mpi-python1.74-dev  libboost-mpi-python1.67.0  libboost-math1.74-dev  libboost-log1.74-dev  libboost-locale1.74-dev libboost-graph1.74-dev libboost-iostreams1.74-dev  libboost-graph-parallel1.74-dev  libboost-filesystem1.74-dev libboost-fiber1.74-dev libboost-exception1.74-dev  libboost-date-time1.74-dev libboost-coroutine1.74-dev  libboost-context1.74-dev libboost-container1.74-dev  libboost-chrono1.74-dev libboost-atomic1.74-dev
# RUN apt-get -y --purge autoremove
# RUN apt-get install -y libboost-filesystem1.67-dev libboost-graph-parallel1.67-dev libboost-iostreams1.67-dev libboost-locale1.67-dev libboost-regex1.67-dev libboost-serialization1.67-dev libboost-system1.67-dev libboost-test1.67-dev libboost1.67-dev libboost1.67-tools-dev libboost-graph1.67-dev libboost-graph1.67.0
# #Install HyperTraPS

# #Install EvAM-tools
COPY . /app/
RUN  cd /app/evamtools && \
    echo ".First <- function() { library(evamtools); cat('Loading EvAM-tools\n');}" > .Rprofile

#Install cbn
RUN cd /app/ && \  
    cp ct-cbn-0.1.04b-RDU.tar.gz /app/Sources && \
    cd /app/Sources && \
    tar -xvzf ct-cbn-0.1.04b-RDU.tar.gz && \
    cd ct-cbn-0.1.04b-RDU && \
    ./configure && \
    make install && \
    cp -t /usr/local/bin/ ct-cbn h-cbn 

RUN cd app && \
    R --no-site-file --no-init-file CMD build evamtools && \
    R --no-site-file --no-init-file CMD INSTALL --install-tests evamtools_*.tar.gz && \
    R --no-site-file --no-init-file CMD check evamtools_*.tar.gz
# RUN ./build-test.sh
# RUN bash build-test.sh > log.txt

#Create folder to share with the outside
RUN mkdir /app/outside

WORKDIR /app/evamtools

ENTRYPOINT  ["R", "--interactive"]
# ENTRYPOINT  ["../docker/runFromImage.R", "-f"]
CMD ["NULL"]

EXPOSE 3000
# Execute typing
# sudo docker run -it --entrypoint /bin/bash evamtools 
# https://www.statmethods.net/interface/customizing.html
# LaTeX errors when creating PDF version.
# This typically indicates Rd problems.
# LaTeX errors found:
# ! Font TS1/cmr/m/n/10=tcrm1000 at 10.0pt not loadable: Metric (TFM) file not fo
# und.
# <to be read again> 
#                    relax 
# l.122 \item{
# * checking PDF version of manual without hyperrefs or index ... ERROR
# * DONE

# Status: 2 ERRORs, 1 WARNING
