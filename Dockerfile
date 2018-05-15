FROM openjdk:8-jdk

MAINTAINER Mickael VILLERS <mickael@keyops.tech>

ENV PATH "$PATH:$PWD/.android/platform-tools/"
ENV ANDROID_HOME "$PWD/.android"
ENV ANDROID_COMPILE_SDK "26"
ENV ANDROID_BUILD_TOOLS "27.0.3"
ENV ANDROID_SDK_TOOLS "3859397"

RUN apt-get update && apt-get install -y \
        wget \
        tar \
        unzip \
        lib32stdc++6 \
        lib32z1 \
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

# Allow double wildcard for bash
RUN shopt -s globstar
