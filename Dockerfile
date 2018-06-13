FROM openjdk:8-jdk

MAINTAINER Mickael VILLERS <mickael@keyops.tech>

# Import bash config
COPY .bash* root/

ENV PATH "$PATH:$PWD/.android/platform-tools/"
ENV PATH "$PATH:$PWD/.android/tools/bin"
ENV ANDROID_HOME "$PWD/.android"
ENV ANDROID_COMPILE_SDK "27"
ENV ANDROID_BUILD_TOOLS "27.0.3"
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
RUN sdkmanager "system-images;android-${ANDROID_COMPILE_SDK};google_apis_playstore;x86"

# Add back up emulator if kvm is not supported
RUN sdkmanager "system-images;android-25;google_apis;arm64-v8a"

# Install fastlane
RUN gem install fastlane -NV
RUN fastlane add_plugin automated_test_emulator_run
RUN fastlane add_plugin get_android_version
