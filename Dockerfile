FROM nvidia/cuda:8.0-cudnn5-devel

# Install dependencies
RUN apt-get -qq update           &&  \
    apt-get -qq install --assume-yes \
        "build-essential"            \
        "git"                        \
        "wget"                       \
        "pkg-config"              && \
    rm -rf /var/lib/apt/lists/*

# Miniconda.
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
# https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Install requirements before copying project files
WORKDIR /ne
COPY requirements.txt .
RUN /opt/conda/bin/conda install -q -y conda numpy scipy pip pillow
RUN /opt/conda/bin/python3.6 -m pip install -q -r "requirements.txt"

# Copy only required project files
COPY enhance.py .
RUN mkdir test
COPY test/* test/
RUN mkdir test_small
COPY test_small/* test_small/ 

# Get a pre-trained neural networks, non-commercial & attribution.
# COPY ne1x-photo-deblur-0.3.pkl.bz2 /ne/
# COPY ne1x-photo-repair-0.3.pkl.bz2 /ne/
# COPY ne2x-photo-default-0.3.pkl.bz2 /ne/
# COPY /ne4x-photo-default-0.3.pkl.bz2 /ne/

RUN wget -q "https://github.com/alexjc/neural-enhance/releases/download/v0.3/ne1x-photo-deblur-0.3.pkl.bz2"
RUN wget -q "https://github.com/alexjc/neural-enhance/releases/download/v0.3/ne1x-photo-repair-0.3.pkl.bz2"
RUN wget -q "https://github.com/alexjc/neural-enhance/releases/download/v0.3/ne2x-photo-default-0.3.pkl.bz2"
RUN wget -q "https://github.com/alexjc/neural-enhance/releases/download/v0.3/ne4x-photo-default-0.3.pkl.bz2"

# Set an entrypoint to the main enhance.py script
ENTRYPOINT ["/opt/conda/bin/python3.6", "enhance.py", "--device=gpu"]
