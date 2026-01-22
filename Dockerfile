FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0"

# System dependencies
RUN apt-get update && apt-get install -y \
    python3.10 python3.10-dev python3-pip \
    git libjpeg-dev libgl1-mesa-glx libglib2.0-0 libeigen3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/include/eigen3/Eigen /usr/include/Eigen

RUN ln -sf /usr/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

WORKDIR /app

# PyTorch with CUDA 12.4
RUN pip install --no-cache-dir torch==2.6.0 torchvision==0.21.0 --index-url https://download.pytorch.org/whl/cu124

# Basic dependencies
RUN pip install --no-cache-dir \
    imageio imageio-ffmpeg tqdm easydict opencv-python-headless ninja \
    trimesh transformers gradio==6.0.1 tensorboard pandas lpips zstandard \
    kornia timm pillow-simd \
    git+https://github.com/EasternJournalist/utils3d.git@9a4eb15e4021b67b12c460c7057d642626897ec8

# Flash attention
RUN pip install --no-cache-dir flash-attn==2.7.3

# nvdiffrast
RUN git clone -b v0.4.0 https://github.com/NVlabs/nvdiffrast.git /tmp/nvdiffrast && \
    pip install /tmp/nvdiffrast --no-build-isolation && \
    rm -rf /tmp/nvdiffrast

# nvdiffrec
RUN git clone -b renderutils https://github.com/JeffreyXiang/nvdiffrec.git /tmp/nvdiffrec && \
    pip install /tmp/nvdiffrec --no-build-isolation && \
    rm -rf /tmp/nvdiffrec

# CuMesh
RUN git clone --recursive https://github.com/JeffreyXiang/CuMesh.git /tmp/CuMesh && \
    pip install /tmp/CuMesh --no-build-isolation && \
    rm -rf /tmp/CuMesh

# FlexGEMM
RUN git clone --recursive https://github.com/JeffreyXiang/FlexGEMM.git /tmp/FlexGEMM && \
    pip install /tmp/FlexGEMM --no-build-isolation && \
    rm -rf /tmp/FlexGEMM

# Copy and install o-voxel (local package)
COPY o-voxel /tmp/o-voxel
RUN pip install /tmp/o-voxel --no-build-isolation && \
    rm -rf /tmp/o-voxel

# Copy TRELLIS code
COPY . /app

ENV OPENCV_IO_ENABLE_OPENEXR=1
ENV PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
