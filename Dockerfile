FROM ubuntu:17.10

ENV ANDROID_HOME="/opt/android-sdk" \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

# Get the latest version from https://developer.android.com/studio/index.html
ENV ANDROID_SDK_TOOLS_VERSION="4333796"

# Set locale
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM=dumb \
    DEBIAN_FRONTEND=noninteractive

# Variables must be references after they are created
ENV ANDROID_SDK_HOME="$ANDROID_HOME"

ENV PATH="$PATH:$ANDROID_SDK_HOME/emulator:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools:$ANDROID_HOME/tools/bin"

RUN export LC_CTYPE=en_US.UTF-8
RUN export LC_ALL=en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN export LANGUAGE=en_US.UTF-8

# Installing packages
RUN apt-get update -qq > /dev/null && \
    apt-get install -qq locales > /dev/null && \
    locale-gen "$LANG" > /dev/null && \
    apt-get install -qq --no-install-recommends \
        build-essential \
        autoconf \
		curl \
        git \
        file \
        lib32stdc++6 \
        lib32z1 \
        lib32z1-dev \
        lib32ncurses5 \
        libc6-dev \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        libxslt-dev \
        libxml2-dev \
        m4 \
        ncurses-dev \
        ocaml \
        openjdk-8-jdk \
        openssh-client \
        pkg-config \
		ruby-full \
        software-properties-common \
        unzip \
        wget \
        zip \
        zlib1g-dev > /dev/null 

WORKDIR /tmp

# Install Android SDK
RUN mkdir -p ~/.android && \
    touch ~/.android/repositories.cfg

RUN echo "installing sdk tools" && \
    wget --quiet --output-document=sdk-tools.zip \
        "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip" && \
    mkdir --parents "$ANDROID_HOME" && \
    unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
    rm --force sdk-tools.zip
# Install SDKs
# Please keep these in descending order!
# The `yes` is for accepting all non-standard tool licenses.
RUN mkdir --parents "$HOME/.android/" && \
    echo '### User Sources for Android SDK Manager' > \
        "$HOME/.android/repositories.cfg" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager --licenses > /dev/null && \
    echo "installing platforms" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platforms;android-27" && \
    echo "installing platform tools " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "platform-tools" && \
    echo "installing build tools " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "build-tools;27.0.3" && \
    echo "installing extras " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "extras;android;m2repository" \
        "extras;google;m2repository" && \
    echo "installing play services " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "extras;google;google_play_services" \
        "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" && \
    echo "installing Google APIs" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "add-ons;addon-google_apis-google-22" && \
    echo "installing emulator " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager "emulator" && \
    echo "installing system images" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
        "system-images;android-22;default;armeabi-v7a"

# Copy sdk license agreement files.
RUN mkdir -p $ANDROID_HOME/licenses
COPY sdk/licenses/* $ANDROID_HOME/licenses/

# Create android emulator
RUN echo no | $ANDROID_HOME/tools/bin/avdmanager create avd --force --name arm --abi default/armeabi-v7a --package 'system-images;android-22;default;armeabi-v7a' -p $ANDROID_HOME/.android/avd/arm.avd

RUN echo "installing fastlane" && \
    gem install fastlane --quiet --no-document > /dev/null
	