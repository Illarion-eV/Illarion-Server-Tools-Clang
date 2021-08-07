FROM debian:bullseye AS build
WORKDIR /src
RUN \
    apt-get -qq update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y -qq install git g++ cmake ninja-build python3

RUN git clone https://github.com/llvm/llvm-project.git llvm && \
    cd llvm && git checkout e39d7884a1f5c5c7136ba2e493e9ac313ccc78ed && cd ..

RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/tmp/llvm -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;" -DLLVM_DISTRIBUTION_COMPONENTS="clang;clang-resource-headers;clang-format;clang-tidy" -G "Ninja" ../llvm/llvm && \
    cmake --build .

RUN cd build && \
    cmake --build . --target install-distribution

FROM debian:bullseye
COPY --from=build /tmp/llvm/ /usr/local/
VOLUME /src
VOLUME /build
WORKDIR /src
RUN apt-get -qq update && \                                                                                              
    export DEBIAN_FRONTEND=noninteractive && \                                                                           
    apt-get -y -qq install python3 wget g++ git libboost-graph-dev libboost-system-dev lua5.2-dev && \
    apt-get -qq clean && \
    wget https://github.com/Kitware/CMake/releases/download/v3.21.1/cmake-3.21.1-linux-x86_64.sh -O cmake.sh -q && \
    sh cmake.sh --skip-license --prefix=/usr/local && rm -f cmake.sh
COPY run-clang-tidy.sh /usr/local/bin/
