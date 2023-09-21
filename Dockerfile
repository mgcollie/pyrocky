FROM rockylinux:9 as base

WORKDIR $HOME

# Copy the cleanup script and make it executable
COPY scripts/cleanup.sh /bin/cleanup
RUN chmod 7777 /bin/cleanup

### Install some common tools
RUN dnf -y install epel-release \
    && dnf -y update \
    && dnf -y install mailcap sudo git terminator xauth dbus dbus-x11 vim wget \
    which net-tools bzip2 findutils procps dbus-glib psmisc \
    && cleanup

### Install xfce UI
FROM base as xfce
RUN dnf --enablerepo=epel -y -x gnome-keyring --skip-broken groups install "Xfce" \
  && dnf -y groups install "Fonts" \
  && dnf erase -y *power* *screensaver* \
  && dnf clean all \
  && rm /etc/xdg/autostart/xfce-polkit* \
  && cleanup

### Install Nomachine
FROM xfce as nomachine
RUN dnf clean all && dnf update \
    && wget https://download.nomachine.com/download/8.8/Linux/nomachine_8.8.1_1_x86_64.rpm \
    && rpm -i nomachine_8.8.1_1_x86_64.rpm \
    && rm nomachine_8.8.1_1_x86_64.rpm \
    && cleanup

# Goto https://www.nomachine.com/download/download&id=10 and change for the latest NOMACHINE_PACKAGE_NAME and MD5 shown in that link to get the latest version.
FROM nomachine as pycharm
ARG PYCHARM_VERSION

RUN wget -c "https://download-cf.jetbrains.com/python/pycharm-community-${PYCHARM_VERSION}.tar.gz" -O - | tar -xz -C /opt/ \
    && ln -s "/opt/pycharm-community-${PYCHARM_VERSION}/bin/pycharm.sh" /usr/bin/pycharm \
    && dnf clean all \
    && dnf install -y libXtst thunar firefox at-spi2-core \
    && cp /opt/pycharm-community-${PYCHARM_VERSION}/bin/pycharm.png /usr/bin/pycharm.png \
    && cleanup

RUN ln -sf /usr/bin/terminator /usr/bin/xfce4-terminal

ADD scripts/nxserver.sh /
ADD scripts/filter_warnings.py /
COPY ./launchers/ launchers/
RUN chmod +x ./nxserver.sh
CMD ["./nxserver.sh"]