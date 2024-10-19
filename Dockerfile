# Base image from ghcr.io with VNC and Metatrader setup
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye

# Set version labels
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Metatrader Docker:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="gmartin"

# Set environment variables
ENV TITLE=Metatrader5
ENV WINEPREFIX="/config/.wine"

# Update package lists and upgrade existing packages
RUN apt-get update && apt-get upgrade -y

# Install required packages like Python3, PIP, and wget
RUN apt-get install -y \
    python3-pip \
    wget \
    && pip3 install --upgrade pip

# Add WineHQ repository key and WineHQ APT source for Debian Bullseye
RUN wget -q https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main' \
    && rm winehq.key

# Add i386 architecture support for Wine and update package lists
RUN dpkg --add-architecture i386 \
    && apt-get update

# Install WineHQ stable version and clean up temporary files
RUN apt-get install --install-recommends -y \
    winehq-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the Metatrader files and the root configuration into the image
COPY /Metatrader /Metatrader
COPY /root /

# Ensure the start script is executable
RUN chmod +x /Metatrader/start.sh

# Expose the required ports, with port 8080 for Google Cloud Run
EXPOSE 8080

# Mount a volume to /config
VOLUME /config

# Set the command to start the Metatrader service
CMD ["/Metatrader/start.sh", "--port", "8080"]
