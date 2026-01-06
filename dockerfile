FROM ros:noetic-ros-base

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

SHELL ["/bin/bash", "-c"]

# Install build tools + HybVIO dependencies
RUN apt-get -qq update && \
    apt-get install -y --no-install-recommends \
      software-properties-common \
      locales \
      git build-essential cmake clang \
      libglfw3-dev libglew-dev libxkbcommon-dev \
      libgtk-3-dev libgstreamer1.0-dev \
      libvtk7-dev \
      ffmpeg \
      wget unzip nano \
    && locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root/HybVIO_Terrence

# Copy your repo into the image
COPY . /root/HybVIO_Terrence

# Git safe.directory
RUN git config --global --add safe.directory /root/HybVIO_Terrence && \
    git config --global --add safe.directory /root/HybVIO_Terrence/3rdparty/mobile-cv-suite && \
    git config --global --add safe.directory /root/HybVIO_Terrence/3rdparty/mobile-cv-suite/suitesparse && \
    git config --global --add safe.directory /root/HybVIO_Terrence/3rdparty/mobile-cv-suite/g2o

# Init submodules and build everything
RUN cd /root/HybVIO_Terrence && \
    git submodule update --init --recursive && \
    cd 3rdparty/mobile-cv-suite && \
    CC=clang CXX=clang++ ./scripts/build.sh && \
    cd /root/HybVIO_Terrence && \
    mkdir -p target && cd target && \
    CC=clang CXX=clang++ cmake -DBUILD_VISUALIZATIONS=ON -DUSE_SLAM=ON .. && \
    make -j"$(nproc)"

ENTRYPOINT ["/bin/bash"]
