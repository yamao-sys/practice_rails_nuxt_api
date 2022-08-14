FROM ruby:2.7.1-alpine

ARG WORKDIR
ARG RUNTIME_PACKAGES="nodejs tzdata postgresql-dev postgresql git"
ARG DEV_PACKAGES="build-base curl-dev"

ENV HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# $HOME = /app
WORKDIR ${HOME}

COPY Gemfile* ./

# apk: Alpine linuxのパッケージ管理コマンド
# apk update: パッケージの最新リストを取得
# --no-cache: パッケージをキャッシュしない: why Dockerイメージの軽量化
# --virtual: 名前(任意) = 仮想パッケージ
# bundle install後にパッケージを削除: why bundle installすると不要になるため、削除してDockerイメージを軽量にする
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    bundle install -j4 && \
    apk del build-dependencies

COPY . ./

# -b: バインド。プロセスを指定したIPにバインドする
# why コンテナ内で起動したrailsは外部のブラウザからアクセス不可
CMD ["rails", "server", "-b", "0.0.0.0"]

# ホスト(PC)    : コンテナ
# ブラウザ(外部) : Rails
# コンテナで起動したRailsはブラウザからすると、IPわからず。→IPを指定することでブラウザからコンテナのアドレスがわかるように
