#!/bin/bash
useradd -m -G wheel -s /bin/bash agusti
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
