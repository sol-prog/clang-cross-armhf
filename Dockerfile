FROM debian:stretch-slim AS cross_common

# Make sure the image is updated, install some prerequisites,
RUN apt-get update \
  && dpkg --add-architecture armhf \
  && apt-get update \
  && apt-get install -y qemu-user-static \
  && apt-get install -y build-essential subversion \
  cmake git python3-dev libncurses5-dev libxml2-dev \
  libedit-dev swig doxygen graphviz xz-utils ninja-build ssh \
  && apt-get install -y crossbuild-essential-armhf python3-dev:armhf \
  libncurses5-dev:armhf libxml2-dev:armhf libedit-dev:armhf \
  && rm -rf /var/lib/apt/lists/*

FROM cross_common AS cross_builder
# Get the LLVM sources
  RUN cd ~ && mkdir llvm_all && cd llvm_all \
  && svn co http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_800/final llvm \
  && cd llvm/tools \
  && svn co http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_800/final clang \
  && cd ../.. \
  && cd llvm/projects \
  && svn co http://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_800/final compiler-rt \
  && svn co http://llvm.org/svn/llvm-project/lld/tags/RELEASE_800/final lld \
  && svn co http://llvm.org/svn/llvm-project/polly/tags/RELEASE_800/final polly \
  && svn co http://llvm.org/svn/llvm-project/libunwind/tags/RELEASE_800/final libunwind \
  && cd ~/llvm_all \
  && svn co http://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_800/final libcxx \
  && svn co http://llvm.org/svn/llvm-project/libcxxabi/tags/RELEASE_800/final libcxxabi \
  && svn co http://llvm.org/svn/llvm-project/openmp/tags/RELEASE_800/final openmp \
# Build and install LLVM and armhf
  && cd ~/llvm_all && mkdir build_llvm && cd build_llvm \
  && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_DOCS=OFF -DCMAKE_INSTALL_PREFIX=/usr/local/cross_armhf_clang_8.0.0 -DCMAKE_CROSSCOMPILING=True -DLLVM_DEFAULT_TARGET_TRIPLE=arm-linux-gnueabihf -DLLVM_TARGET_ARCH=ARM -DLLVM_TARGETS_TO_BUILD=ARM ../llvm \
  && ninja \
  && ninja install \
  && echo 'export PATH=/usr/local/cross_armhf_clang_8.0.0/bin:$PATH' >> ~/.bashrc \
  && echo 'export LD_LIBRARY_PATH=/usr/local/cross_armhf_clang_8.0.0/lib:LD_LIBRARY_PATH' >> ~/.bashrc \
  && . ~/.bashrc \
  && cd ~/llvm_all \
  && mkdir build_libcxxabi && cd build_libcxxabi \
  && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/cross_armhf_clang_8.0.0 -DLLVM_TARGETS_TO_BUILD=ARM -DCMAKE_C_COMPILER=/usr/local/cross_armhf_clang_8.0.0/bin/clang -DCMAKE_CXX_COMPILER=/usr/local/cross_armhf_clang_8.0.0/bin/clang++ ../libcxxabi \
  && ninja \
  && ninja install \
  && cd ~/llvm_all \
  && mkdir build_libcxx && cd build_libcxx \
  && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/cross_armhf_clang_8.0.0 -DLLVM_TARGETS_TO_BUILD=ARM -DCMAKE_C_COMPILER=/usr/local/cross_armhf_clang_8.0.0/bin/clang -DCMAKE_CXX_COMPILER=/usr/local/cross_armhf_clang_8.0.0/bin/clang++ ../libcxx \
  && ninja \
  && ninja install \
  && cd ~/llvm_all \
  && mkdir build_openmp && cd build_openmp \
  && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/cross_armhf_clang_8.0.0 -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ -DLIBOMP_ARCH=arm ../openmp \
  && ninja \
  && ninja install

FROM cross_common
  COPY --from=cross_builder /usr/local/cross_armhf_clang_8.0.0 /usr/local/cross_armhf_clang_8.0.0
  RUN echo 'export PATH=/usr/local/cross_armhf_clang_8.0.0/bin:$PATH' >> ~/.bashrc \
  && echo 'export LD_LIBRARY_PATH=/usr/local/cross_armhf_clang_8.0.0/lib:LD_LIBRARY_PATH' >> ~/.bashrc \
  && . ~/.bashrc

# Start from a Bash prompt
CMD [ "/bin/bash" ]
