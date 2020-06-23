# Extend from the official Elixir image
# Use an official Elixir runtime as a parent image
FROM elixir:1.6.6
MAINTAINER Luis Mario Urrea-Murillo <sinourain@gmail.com>

RUN apt-get update && \
  apt-get install -y postgresql-client

RUN mix local.hex --force \
 && mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new-1.3.3.ez \
 && apt-get update \
 && curl -sL https://deb.nodesource.com/setup_8.x | bash \
 && apt-get install -y apt-utils \
 && apt-get install -y nodejs \
 && apt-get install -y build-essential \
 && apt-get install -y inotify-tools \
 && apt-get install -y make \
 && apt-get install -y gcc \
 && apt-get install -y libc-dev \
 && mix local.rebar --force

RUN apt-get install libfontenc1 libxfont1 xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils
RUN wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb
RUN dpkg -i wkhtmltox_0.12.5-1.stretch_amd64.deb

ENV TZ=America/Bogota
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create app directory and copy the Elixir projects into it
ENV APP_HOME /app
RUN mkdir -p $APP_HOME
COPY . $APP_HOME
WORKDIR $APP_HOME

RUN chmod +x $APP_HOME/entrypoint.sh

CMD ["/app/entrypoint.sh"]