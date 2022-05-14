FROM emscripten/emsdk:2.0.32



ARG USER_ID
ARG GROUP_ID

RUN mkdir -p /install
RUN mkdir -p /install/lib


##################################################################
# git config
##################################################################
RUN git config --global advice.detachedHead false



##################################################################
# xtl
##################################################################
RUN mkdir -p /opt/xtl/build && \
    git clone --branch 0.7.2 --depth 1 https://github.com/xtensor-stack/xtl.git  /opt/xtl/src

RUN cd /opt/xtl/build && \
    emcmake cmake ../src/   -DCMAKE_INSTALL_PREFIX=/install

RUN cd /opt/xtl/build && \
    emmake make -j8 install


##################################################################
# nloman json
##################################################################
RUN mkdir -p /opt/nlohmannjson/build && \
    git clone --branch v3.9.1 --depth 1 https://github.com/nlohmann/json.git  /opt/nlohmannjson/src

RUN cd /opt/nlohmannjson/build && \
    emcmake cmake ../src/   -DCMAKE_INSTALL_PREFIX=/install -DJSON_BuildTests=OFF

RUN cd /opt/nlohmannjson/build && \
    emmake make -j8 install



##################################################################
# xpropery
##################################################################
RUN mkdir -p /opt/xproperty/build && \
    git clone --branch 0.11.0 --depth 1 https://github.com/jupyter-xeus/xproperty.git  /opt/xproperty/src

RUN cd /opt/xproperty/build && \
    emcmake cmake ../src/   \
    -Dxtl_DIR=/install/share/cmake/xtl \
    -DCMAKE_INSTALL_PREFIX=/install

RUN cd /opt/xproperty/build && \
    emmake make -j8 install


##################################################################
# xeus itself
##################################################################
# ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

RUN mkdir -p /opt/xeus &&  \
    git clone --branch 2.4.0  --depth 1   https://github.com/jupyter-xeus/xeus.git   /opt/xeus
RUN mkdir -p /xeus-build && cd /xeus-build  && ls &&\
    emcmake cmake /opt/xeus \
        -DCMAKE_INSTALL_PREFIX=/install \
        -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
        -Dxtl_DIR=/install/share/cmake/xtl \
        -DXEUS_EMSCRIPTEN_WASM_BUILD=ON
RUN cd /xeus-build && \
    emmake make -j8 install


##################################################################
# xvega
##################################################################
RUN mkdir -p /opt/xvega/build && \
    git clone --branch  0.0.10 --depth 1 https://github.com/QuantStack/xvega.git  /opt/xvega/src

RUN cd /opt/xvega/build && \
    emcmake cmake ../src/  \
    -Dxtl_DIR=/install/share/cmake/xtl \
    -Dxproperty_DIR=/install/lib/cmake/xproperty \
    -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
    -Dxeus_DIR=/install/lib/cmake/xeus \
    -DXVEGA_BUILD_SHARED=ON \
    -DXVEGA_BUILD_STATIC=ON  \
    -DCMAKE_INSTALL_PREFIX=/install \
    -DCMAKE_CXX_FLAGS="-Oz -flto"
RUN cd /opt/xvega/build && \
    emmake make -j8 install



# ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

##################################################################
# xvega-binings
##################################################################
# RUN mkdir -p /opt/xvega-bindings/build && \
#     git clone --branch  0.0.10 --depth 1 https://github.com/jupyter-xeus/xvega-bindings.git  /opt/xvega-bindings/src

RUN mkdir -p /opt/xvega-bindings/build && \
    git clone -b no_var https://github.com/DerThorsten/xvega-bindings.git  /opt/xvega-bindings/src

RUN cd /opt/xvega-bindings/build && \
    emcmake cmake ../src/  \
    -Dxtl_DIR=/install/share/cmake/xtl \
    -Dxvega_DIR=/install/lib/cmake/xvega \
    -Dxeus_DIR=/install/lib/cmake/xeus \
    -Dxproperty_DIR=/install/lib/cmake/xproperty \
    -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
    -Dxeus_DIR=/install/lib/cmake/xeus \
    -DCMAKE_INSTALL_PREFIX=/install \
    -DCMAKE_CXX_FLAGS="-Oz -flto"
RUN cd /opt/xvega-bindings/build && \
    emmake make -j8 install



##################################################################
# tabulate
##################################################################
RUN mkdir -p /opt/tabulate/build && \
    git clone --branch v1.4 --depth 1 https://github.com/p-ranav/tabulate.git  /opt/tabulate/src

RUN cd /opt/tabulate/build && \
    emcmake cmake ../src/ \
        -DCMAKE_INSTALL_PREFIX=/install \
        -DJSON_BuildTests=OFF

RUN cd /opt/tabulate/build && \
    emmake make -j8 install

##################################################################
# sqlitecpp
##################################################################
RUN mkdir -p /opt/sqlitecpp/build && \
    git clone --branch 3.1.1 --depth 1 https://github.com/SRombauts/SQLiteCpp.git  /opt/sqlitecpp/src

RUN cd /opt/sqlitecpp/build && \
    emcmake cmake ../src/ \
        -DCMAKE_INSTALL_PREFIX=/install \
        -DJSON_BuildTests=OFF\
        -DSQLITECPP_USE_STACK_PROTECTION=OFF\
        -DCMAKE_CXX_FLAGS="-fno-stack-protector -U_FORTIFY_SOURCE "\
        -DCMAKE_C_FLAGS="-fno-stack-protector -U_FORTIFY_SOURCE "

RUN cd /opt/sqlitecpp/build && \
    emmake make -j8 install





##################################################################
# xeus-sqlite
##################################################################
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

RUN mkdir -p /opt/xeus-sqlite &&  \
    git clone --branch 0.5.2  --depth 1   https://github.com/jupyter-xeus/xeus-sqlite.git   /opt/xeus-sqlite

# COPY xeus-sqlite /opt/xeus-sqlite

RUN mkdir -p /xeus-sqlite-build && cd /xeus-sqlite-build  && ls && \
    emcmake cmake  /opt/xeus-sqlite \
        -DXSQL_EMSCRIPTEN_WASM_BUILD=ON \
        -DCMAKE_INSTALL_PREFIX=/install \
        -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
        -Dxtl_DIR=/install/share/cmake/xtl \
        -Dxproperty_DIR=/install/lib/cmake/xproperty \
        -DSQLite3_LIBRARY=/install/lib/libsqlite3.a\
        -DSQLite3_INCLUDE_DIR=/install/include/\
        -Dtabulate_DIR=/install/lib/cmake/tabulate\
        -DSQLiteCpp_DIR=/install/lib/cmake/SQLiteCpp\
        -Dxvega_DIR=/install/lib/cmake/xvega \
        -Dxvega-bindings_DIR=/install/lib/cmake/xvega-bindings \
        -DXSQL_USE_SHARED_XEUS=OFF\
        -DXSQL_BUILD_SHARED=OFF\
        -DXSQL_BUILD_STATIC=ON\
        -DXSQL_BUILD_XSQLITE_EXECUTABLE=OFF\
        -Dxeus_DIR=/install/lib/cmake/xeus \
        -DCMAKE_CXX_FLAGS="-Oz -flto"

RUN cd /xeus-sqlite-build && \
    emmake make -j8

