# Use an official PHP Apache base image (PHP >=5.2 is required)
FROM php:7.4-apache

# Install system dependencies, R, and build tools along with additional libraries
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
# This command conditionally removes any existing gplots, installs devtools if missing,
# and then installs gplots via devtools.
RUN Rscript -e "if('gplots' %in% rownames(installed.packages())) { remove.packages('gplots') } else { message('gplots not installed, proceeding...') }; \
                if(!require('devtools')) install.packages('devtools', repos='https://cloud.r-project.org'); \
                devtools::install_github('ChristophH/gplots')"

# Set working directory to the location where Ginkgo will be deployed
WORKDIR /var/www/html/ginkgo

# Copy the entire Ginkgo source code into the container
COPY . /var/www/html/ginkgo

# Run the build process as required by Ginkgo (e.g., running 'make')
RUN make

# (Optional) Ensure the uploads directory exists and is writable by the web server.
RUN mkdir -p /var/www/html/ginkgo/uploads && chmod -R 777 /var/www/html/ginkgo/uploads

# Expose port 80 to access the web interface
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]