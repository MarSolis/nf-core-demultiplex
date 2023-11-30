FROM rockylinux:8

WORKDIR /app
RUN dnf update -y
RUN dnf install -y git cmake wget gcc gcc-c++ spax wget spax gcc libxml2-devel make \
libpng-devel rsyslog perl zlib-devel bzip2 curl cronie bc net-tools man gnuplot tcl \
libstdc++-devel chrony
RUN wget https://github.com/Illumina/interop/archive/refs/tags/v1.3.0.tar.gz
RUN tar -xvf v1.3.0.tar.gz && cd interop-1.3.0 && mkdir Build
RUN cmake /app/interop-1.3.0 -DCMAKE_INSTALL_PREFIX=/app/interop-1.3.0/Build && cmake --build . && cmake --build . --target install
RUN ln -s /app/interop-1.3.0/Build/bin/aggregate /usr/local/bin/aggregate \
&& ln -s /app/interop-1.3.0/Build/bin/dumptext /usr/local/bin/dumptext \
&& ln -s /app/interop-1.3.0/Build/bin/index-summary /usr/local/bin/index-summary \
&& ln -s /app/interop-1.3.0/Build/bin/plot_by_lane /usr/local/bin/plot_by_lane \
&& ln -s /app/interop-1.3.0/Build/bin/plot_qscore_heatmap /usr/local/bin/plot_qscore_heatmap \
&& ln -s /app/interop-1.3.0/Build/bin/plot_sample_qc /usr/local/bin/plot_sample_qc \
&& ln -s /app/interop-1.3.0/Build/bin/dumpbin /usr/local/bin/dumpbin \
&& ln -s /app/interop-1.3.0/Build/bin/imaging_table /usr/local/bin/imagin_table \
&& ln -s /app/interop-1.3.0/Build/bin/plot_by_cycle /usr/local/bin/plot_by_cycle \
&& ln -s /app/interop-1.3.0/Build/bin/plot_flowcell /usr/local/bin/plot_flowcell \
&& ln -s /app/interop-1.3.0/Build/bin/plot_qscore_histogram /usr/local/bin/plot_qscore_histogram \
&& ln -s /app/interop-1.3.0/Build/bin/summary /usr/local/bin/summary 

