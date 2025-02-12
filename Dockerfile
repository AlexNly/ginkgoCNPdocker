# Use Debian testing as base
FROM debian:testing

# Install R, Apache, PHP and other dependencies (include libgit2-dev)
RUN apt-get update && apt-get install -y \
    r-base \
    apache2 \
    php \
    libapache2-mod-php \
    php-xml \
    build-essential \
    make \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    wget \
    curl \
    tar \
    git \
    libgit2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages one by one to better handle errors
RUN R -e "install.packages('ctc', repos='https://cloud.r-project.org/')" && \
    R -e "install.packages('DNAcopy', repos='https://cloud.r-project.org/')" && \
    R -e "install.packages('inline', repos='https://cloud.r-project.org/')" && \
    R -e "install.packages('scales', repos='https://cloud.r-project.org/')" && \
    R -e "install.packages('plyr', repos='https://cloud.r-project.org/')" && \
    R -e "install.packages('ggplot2', repos='https://cloud.r-project.org/')" && \
    R -e "install.packages('gridExtra', repos='https://cloud.r-project.org/')" && \
    R -e "install.packages('fastcluster', repos='https://cloud.r-project.org/')" && \
    R -e "install.packages('heatmap3', repos='https://cloud.r-project.org/')" && \
    R -e "install.packages('devtools', repos='https://cloud.r-project.org/')" && \
    R -e "remove.packages('gplots'); library('devtools'); install_github('ChristophH/gplots')"

# Set environment variables for configuration defaults
ENV GINKGO_DIR_ROOT=/var/www/html/ \
    GINKGO_UPLOADS_DIR=/var/www/html/uploads/ \
    GINKGO_URL_ROOT=http://localhost

# Configure PHP settings
RUN echo "upload_max_filesize = 2G" > /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 2G" >> /usr/local/etc/php/conf.d/uploads.ini

# Copy Ginkgo source code 
COPY . /var/www/html/

# Create required directories and set permissions
RUN mkdir -p /var/www/html/uploads/tmp && \
    mkdir -p /var/www/html/genomes/hg19 && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 777 /var/www/html/uploads

# Download and extract genome data
RUN cd /var/www/html/genomes && \
    curl -L "https://labshare.cshl.edu/shares/schatzlab/www-data/ginkgo/genomes/hg19.tgz" -o hg19.tgz && \
    tar -xzf hg19.tgz -C hg19 && \
    rm hg19.tgz

# Build Ginkgo
RUN cd /var/www/html && make

# Expose port 80
EXPOSE 80
