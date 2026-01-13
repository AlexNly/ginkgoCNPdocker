# Use an official PHP Apache base image (PHP >=5.2 is required)
FROM php:7.4-apache

# Install system dependencies, R, build tools, and additional libraries
RUN apt-get update && apt-get install -y \
    r-base \
    r-base-dev \
    build-essential \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev \
    git \
    wget \
    libgit2-dev \
    pkg-config \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libicu-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    pandoc \
 && rm -rf /var/lib/apt/lists/*

# Install required R packages (except gplots) from CRAN
RUN Rscript -e "install.packages(c('ctc','DNAcopy','inline','scales','plyr','ggplot2','gridExtra','fastcluster','heatmap3'), repos='https://cloud.r-project.org')"

# Install devtools and then install ChristophH's fixed version of gplots from GitHub.
RUN Rscript -e "install.packages('devtools', repos='https://cloud.r-project.org'); \
                devtools::install_github('ChristophH/gplots')"

# Set working directory to the location where Ginkgo will be deployed
WORKDIR /var/www/html/ginkgo

# Copy the entire Ginkgo source code into the container
COPY . /var/www/html/ginkgo

# Run the build process as required by Ginkgo (e.g., running 'make')
RUN make

# ---- Server Configuration: Update configuration files as per README ----

# 1. Update UploadHandler.php: Replace hardcoded paths with Docker paths.
RUN sed -i "s#/local1/work/ginkgo#/var/www/html/ginkgo#g" includes/fileupload/server/php/UploadHandler.php && \
    sed -i "s#http://qb.cshl.edu/ginkgo#http://localhost/ginkgo#g" includes/fileupload/server/php/UploadHandler.php

# 2. Update bootstrap.php: Set DIR_ROOT, DIR_UPLOADS, and URL_ROOT.
# Update bootstrap.php: Set DIR_ROOT, DIR_UPLOADS, and URL_ROOT (include semicolons)
RUN sed -i "s#^define('DIR_ROOT'.*;#define('DIR_ROOT','/var/www/html/ginkgo');#g" bootstrap.php && \
    sed -i "s#^define('DIR_UPLOADS'.*;#define('DIR_UPLOADS','/var/www/html/ginkgo/uploads');#g" bootstrap.php && \
    sed -i "s#^define('URL_ROOT'.*;#define('URL_ROOT','http://localhost/ginkgo');#g" bootstrap.php

# 3. Update scripts configuration:
#    - In scripts/analyze.sh, set the home variable.
RUN sed -i "s#^home=.*#home='/var/www/html/ginkgo'#g" scripts/analyze.sh

#    - In scripts/process.R and scripts/reclust.R, set main_dir to the scripts folder.
RUN sed -i "s#^main_dir=.*#main_dir='/var/www/html/ginkgo/scripts'#g" scripts/process.R && \
    sed -i "s#^main_dir=.*#main_dir='/var/www/html/ginkgo/scripts'#g" scripts/reclust.R

#    - In scripts/analyze-subset.R, set the folder to the scripts and genomes directories.
RUN sed -i "s#^home=.*#home='/var/www/html/ginkgo/scripts'#g" scripts/analyze-subset.R && \
    sed -i "s#^genome_dir=.*#genome_dir='/var/www/html/ginkgo/genomes'#g" scripts/analyze-subset.R

# 4. Ensure the uploads directory exists and is writable.
RUN mkdir -p /var/www/html/ginkgo/uploads && chmod -R 777 /var/www/html/ginkgo/uploads

# 5. Download data files:
#    Download binning data for hg19 and extract it into the appropriate folder.
# RUN mkdir -p /var/www/html/ginkgo/genomes/hg19 && \
#    wget -O hg19.tgz https://labshare.cshl.edu/shares/schatzlab/www-data/ginkgo/genomes/hg19.tgz && \
#    tar -xzvf hg19.tgz -C /var/www/html/ginkgo/genomes/hg19 && \
#    rm hg19.tgz

# --------------------------------------------------------------------------

# Expose port 80 to access the web interface
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
