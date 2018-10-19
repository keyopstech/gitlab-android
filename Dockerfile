FROM openjdk:8-jdk

MAINTAINER Mickael VILLERS <mickael@keyops.tech>

# Import bash config
COPY .bash* root/

ENV PATH "$PATH:$PWD/.android/platform-tools/"
ENV PATH "$PATH:$PWD/.android/tools/bin"
ENV ANDROID_HOME "$PWD/.android"
ENV ANDROID_COMPILE_SDK "28"
ENV ANDROID_BUILD_TOOLS "28.0.2"
ENV ANDROID_SDK_TOOLS "3859397"

# Load bash config for non interactive bash
ENV BASH_ENV "~/.bashrc"

# Use bash
SHELL ["/bin/bash", "-c"]

RUN apt update \
    && apt upgrade -y \
    && apt install -y \
        wget \
        tar \
        unzip \
        lib32stdc++6 \
        lib32z1 \
        ruby-full \
        build-essential \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Fetch the specified SDK tools version to build with
RUN wget --quiet --output-document=/tmp/sdk-tools-linux.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip \
    && unzip /tmp/sdk-tools-linux.zip -d ${ANDROID_HOME} \
    && rm -rf /tmp/sdk-tools-linux.zip

# Accept licence
RUN mkdir ${ANDROID_HOME}/licenses \
    && printf "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > ${ANDROID_HOME}/licenses/android-sdk-license

# Install platform tools and Android SDK for the compile target
RUN ${ANDROID_HOME}/tools/bin/sdkmanager --update \
    && ${ANDROID_HOME}/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" "build-tools;${ANDROID_BUILD_TOOLS}" "extras;google;m2repository" "extras;android;m2repository"

# Install Android emulator
# RUN sdkmanager "system-images;android-${ANDROID_COMPILE_SDK};google_apis_playstore;x86"

# Add back up emulator if kvm is not supported
# RUN sdkmanager "system-images;android-25;google_apis;arm64-v8a"

# Install fastlane
RUN gem install bundler -NV
COPY Gemfile fastlane/
COPY Gemfile.lock fastlane/
WORKDIR /fastlane
RUN bundle install
