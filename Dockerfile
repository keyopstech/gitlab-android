FROM openjdk:8-jdk

MAINTAINER Vincent Brison <vincent.brison@keyops.tech>

## Setup Bash ##################################################################
# Import bash config
COPY .bash* root/

# Load bash config for non interactive bash
ENV BASH_ENV "~/.bashrc"

# Use bash
SHELL ["/bin/bash", "-c"]

## Setup apt ###################################################################
RUN apt update -y

## Setup gcloud SDK ############################################################
RUN apt install -y \
  wget \
  tar

RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

## Setup Android SDK ###########################################################
RUN apt install -y \
  wget \
  unzip

# Setup env
ENV PATH "$PATH:$PWD/.android/platform-tools/"
ENV PATH "$PATH:$PWD/.android/tools/bin"
ENV ANDROID_HOME "$PWD/.android"
ENV ANDROID_COMPILE_SDK "28"
ENV ANDROID_BUILD_TOOLS "28.0.3"

RUN wget --quiet --output-document=/tmp/sdk-tools-linux.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
    && unzip /tmp/sdk-tools-linux.zip -d ${ANDROID_HOME} \
    && rm -rf /tmp/sdk-tools-linux.zip

# Install platform tools and Android SDK for the compile target
RUN ${ANDROID_HOME}/tools/bin/sdkmanager --update
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}"
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}"
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager "extras;google;m2repository"
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "extras;android;m2repository"

## Setup Ruby/Bundler ##########################################################
# Install ruby
RUN apt install -y \
  ruby-full \
  build-essential

# Install bundler
RUN gem install bundler -NV

# Install zlib as required by some ruby gems
RUN apt-get install zlib1g-dev

## Clean #######################################################################
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*
