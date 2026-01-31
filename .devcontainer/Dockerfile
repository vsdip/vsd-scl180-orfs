FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Create vscode user that Codespaces expects
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN groupadd --gid ${USER_GID} ${USERNAME} \
 && useradd -m -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} ${USERNAME} \
 && apt-get update && apt-get install -y --no-install-recommends sudo \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME}

# Base packages (your original set)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl unzip git make python3 python3-pip python3-numpy python3-pandas python3-matplotlib python3-jinja2 python3-xlsxwriter \
    xvfb xfce4 xfce4-session xfce4-panel xfdesktop4 xfwm4 xfce4-terminal thunar dbus-x11 x11vnc novnc websockify supervisor \
    magic ngspice gtkwave verilator iverilog \
    build-essential autoconf automake libtool m4 cmake ninja-build clang \
    tcl tcl-dev tcllib tcl-trf tclx tk tk-dev locales \
    perl libfile-which-perl ca-certificates gnupg lsb-release pkg-config \
    libcairo2-dev libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev \
    libx11-dev libxext-dev libxrender-dev libxpm-dev libxaw7-dev libfontconfig1-dev \
    libreadline-dev libncurses-dev flex bison gawk tcsh time bc vim \
    libqt5charts5 libyaml-cpp0.7 \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 libgcc-s1 zlib1g libtcl8.6 libtk8.6 \
 && rm -rf /var/lib/apt/lists/*

# OSS CAD Suite (Yosys, etc.)
RUN set -eux; \
    curl -L https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2025-10-31/oss-cad-suite-linux-x64-20251031.tgz \
      -o /tmp/oss-cad.tgz; \
    mkdir -p /opt && tar -xzf /tmp/oss-cad.tgz -C /opt; \
    ln -s /opt/oss-cad-suite /opt/oss-cad; \
    rm /tmp/oss-cad.tgz
ENV PATH="/opt/oss-cad/bin:${PATH}"

# KLayout (optional)
RUN set -eux; \
    curl -L -o /tmp/klayout.deb \
      https://www.klayout.org/downloads/Ubuntu-22/klayout_0.29.0-1_amd64.deb; \
    apt-get update && apt-get install -y --no-install-recommends /tmp/klayout.deb; \
    rm -rf /var/lib/apt/lists/* /tmp/klayout.deb

# -------- OpenROAD from repo (prebuilt binary) --------
# Put your binary at: orfs/tools/openroad/bin/openroad (tracked via Git LFS)
COPY tools/openroad/bin/openroad /usr/local/bin/openroad
RUN chmod +x /usr/local/bin/openroad \
 && command -v openroad \
 && (openroad -version || openroad -v || openroad -help | head -n 5) || true
ENV OPENROAD_EXE="/usr/local/bin/openroad"
ENV PATH="/usr/local/bin:${PATH}"

# Keep same env wiring
ENV YOSYS_PLUGIN_PATH="/opt/oss-cad-suite/share/yosys/plugins" \
    YOSYS_EXE="/opt/oss-cad-suite/bin/yosys" \
    PATH="/opt/oss-cad-suite/bin:/usr/local/bin:${PATH}"

# -----------------------------
# noVNC desktop environment
# -----------------------------
COPY supervisord.conf /etc/supervisor/conf.d/vnc.conf
EXPOSE 6080
CMD ["/usr/bin/supervisord", "-n"]


