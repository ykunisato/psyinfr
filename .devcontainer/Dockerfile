FROM ykunisato/dev-con-r

ENV TZ=Asia/Tokyo
# Rのパッケージのインストール
COPY install_r.r install_r.r
RUN ["r", "install_r.r"]