#!/usr/bin/env bash
# Check if the group already exists
if [ $(getent group $NOMACHINE_USER) ]; then
  echo "Group $NOMACHINE_USER already exists."
else
  groupadd -r $NOMACHINE_USER -g 433
fi

# Check if the user already exists
if [ $(getent passwd $NOMACHINE_USER) ]; then
  echo "User $NOMACHINE_USER already exists."
else
  useradd -u 431 -r -g $NOMACHINE_USER -d /home/$NOMACHINE_USER -s /bin/bash -c "$NOMACHINE_USER" $NOMACHINE_USER
  echo $NOMACHINE_USER:$PASSWORD | chpasswd
fi

# Add the user to the wheel group
usermod -aG wheel $NOMACHINE_USER

# Create and set permissions for the home directory and desktop
mkdir -p /home/$NOMACHINE_USER/Desktop
chown -R $NOMACHINE_USER:$NOMACHINE_USER /home/$NOMACHINE_USER
chmod -R +x /home/$NOMACHINE_USER/Desktop

# Set the runtime directory
export XDG_RUNTIME_DIR=/home/$NOMACHINE_USER

# Set terminator as the default terminal
export TERMINAL=terminator
# Start the D-Bus system daemon
mkdir -p /run/dbus
dbus-daemon --system  --fork

# Copy our desktop launchers
cp /launchers/* /home/$NOMACHINE_USER/Desktop \
&& chown $NOMACHINE_USER:$NOMACHINE_USER /home/$NOMACHINE_USER/Desktop/*.desktop \
&& chmod +x /home/$NOMACHINE_USER/Desktop/*.desktop

# Start the NoMachine server
/etc/NX/nxserver --startup --virtualgl

# Tail the logs to keep the container running
tail -f /usr/NX/var/log/nxserver.log  | python3 filter_warnings.py
