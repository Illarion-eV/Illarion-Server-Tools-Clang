FROM debian:buster AS build
WORKDIR /src
RUN \
    apt-get -qq update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y -qq install git g++ cmake make python3

RUN git clone https://github.com/llvm/llvm-project.git llvm && \
    cd llvm && git checkout e39d7884a1f5c5c7136ba2e493e9ac313ccc78ed && cd ..

RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;" -G "Unix Makefiles" ../llvm/llvm && \
    cmake --build . -j $(nproc)

RUN cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/tmp/llvm -P cmake_install.cmake && \
    cmake --build . --target install

FROM debian:buster
COPY --from=build /tmp/llvm/ /usr/local/
VOLUME /src
WORKDIR /src
RUN apt-get -qq update && \                                                                                              
    export DEBIAN_FRONTEND=noninteractive && \                                                                           
    apt-get -y -qq install python3 && \
    apt-get -qq clean
