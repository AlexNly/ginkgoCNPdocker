# GinkgoWhale

**GinkgoWhale** is a fork of [Ginkgo](https://github.com/robertaboukhalil/ginkgo)—a cloud-based single-cell copy-number variation analysis tool—packaged in a Docker container for easy deployment and troubleshooting.

---

## Current Status (January 2026)

**Web Interface: Working** - The Docker container builds and runs successfully.

**Analysis: Blocked** - The CSHL genome data servers are down, preventing analysis from running.

### Known Issue: Genome Data Unavailable

The hg19 genome binning data required for CNV analysis is hosted on Cold Spring Harbor Laboratory servers that are currently unavailable:
- `https://labshare.cshl.edu/shares/schatzlab/www-data/ginkgo/genomes/hg19.tgz` → 404 Not Found
- `http://qb.cshl.edu/ginkgo/uploads/hg19.original.tar.gz` → 503 Service Unavailable

This is a [known issue on the upstream repository](https://github.com/robertaboukhalil/ginkgo/issues/50) (opened October 2025, unresolved).

**Workarounds:**
- Wait for CSHL servers to come back online
- Contact CSHL/Schatz Lab for alternative data access
- Use alternative CNV tools: [SCOPE](https://github.com/WangLabCornell/SCOPE), [copyKAT](https://github.com/navinlabcode/copykat), [inferCNV](https://github.com/broadinstitute/inferCNV)

---

## Usage

GinkgoWhale provides a web-based interface with the following workflow:
1. **Step 0:** Upload your `.bed` files.
2. **Step 1:** Choose analysis parameters.
3. **Step 2:** Compute Copy Number Profiles and a Phylogenetic Tree.
4. **Step 3:** Analyze Individual Cells.

---

## Setup GinkgoWhale on Your Own Server Using Docker

### Requirements

- Docker installed on your machine or server.
- A system that supports Docker (Linux, macOS, Windows).

### Building the Docker Image

In the root directory of your **GinkgoWhale** fork (where the Dockerfile is located), run:

```bash
docker build -t ginkgo .
```

This command builds the Docker image and installs all required system libraries, R, and the necessary R packages (including our fixed version of **gplots** from GitHub).

### Running the Container Locally

To run the container locally (mapping port 80 to your host):

```bash
docker run -d -p 80:80 ginkgo
```

Then, open your browser and navigate to `http://localhost/ginkgo` (or your host’s IP address) to access the GinkgoWhale web interface.

### Running the Container on a Server

On a remote server:
1. **Build the image** (as above).
2. **Run the container** mapping the container port 80 to the server’s public port (e.g., 80 or another port if needed):

   ```bash
   docker run -d -p 80:80 ginkgo
   ```

3. Ensure your server’s firewall allows incoming traffic on the chosen port.
4. Access the web interface by browsing to `http://<server_ip>`.

---

## Advanced: Interactive Shell & Troubleshooting

Sometimes you may wish to enter the container interactively—for example, to install additional software, download reference genomes, or troubleshoot issues.

### Entering an Interactive Shell

Run the container with an interactive shell by overriding the entrypoint:

```bash
docker run -it --entrypoint /bin/bash ginkgo
```

This will drop you into a bash shell inside the container.

### Installing Additional Software

Once inside the shell, you can install new packages using `apt-get` or R commands. For example, to install a package via apt:

```bash
apt-get update && apt-get install -y <package-name>
```

Or, to install an R package interactively:

```bash
Rscript -e "install.packages('somePackage', repos='https://cloud.r-project.org')"
```

### Downloading the Reference Genome

GinkgoWhale requires binning data (e.g., for hg19). To download and prepare the reference genome:

1. Download the hg19 binning data:

   ```bash
   wget https://labshare.cshl.edu/shares/schatzlab/www-data/ginkgo/genomes/hg19.tgz
   ```

2. Create the target directory and extract the files:

   ```bash
   mkdir -p ginkgo/genomes/hg19
   tar -xzvf hg19.tgz -C ginkgo/genomes/hg19
   ```

> **Note:** Ensure that the directory structure matches what GinkgoWhale expects.

---

## Configuration of the Server in the container

After deployment, you may need to adjust configuration settings:

- **PHP Configuration:**  
  Edit `/etc/php.ini` to set:
  - `upload_tmp_dir`: Ensure this directory is writable.
  - `upload_max_filesize`: Set this to >2G (since .bam files can be large).

- **Ginkgo Configuration Files:**  
  Modify the following files within the GinkgoWhale source code:
  - `ginkgo/includes/fileupload/server/php/UploadHandler.php`:  
    Update lines 43 and 44 with your full path to the uploads directory.
  - `ginkgo/bootstrap.php`:  
    Change `DIR_ROOT`, `DIR_UPLOADS`, and `URL_ROOT` to suit your deployment.
  - `ginkgo/scripts/analyze.sh`:  
    Update the `home` variable to point to your GinkgoWhale folder.
  - `ginkgo/scripts/process.R`, `ginkgo/scripts/reclust.R`, `ginkgo/scripts/analyze-subset.R`:  
    Adjust the `main_dir` variables as necessary.
- **Uploads Directory:**  
  Ensure the `ginkgo/uploads` directory has correct write permissions.

- **Genomes Directory:**  
  Create the directory (e.g., `ginkgo/genomes/hg19`) and extract the downloaded binning data there.

---

## Summary

- **GinkgoWhale** is deployed via Docker and can run locally or on a server.
- **Building:** Use `docker build -t ginkgo .`
- **Running:** Use `docker run -d -p 80:80 ginkgo`
- **Interactive Shell:** Use `docker run -it --entrypoint /bin/bash ginkgo`
- **Customizations:** Update PHP and Ginkgo configuration files and download necessary reference data.

This README now serves as a complete guide for setting up, running, and troubleshooting your GinkgoWhale Docker deployment.
