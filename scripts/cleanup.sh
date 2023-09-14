dnf clean all
dnf autoremove --setopt=clean_requirements_on_remove=1 -y
rm -rf /var/cache/dnf/ /var/log/dnf* /var/log/yum.log /tmp/* /etc/systemd