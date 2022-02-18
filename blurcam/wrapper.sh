#!/usr/bin/env bash
cd Linux-Fake-Background-Webcam
LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:/nix/store/hisqvx32cd57apbpcsnkpx6k3549wql1-libglvnd-1.4.0/lib/:/nix/store/3gblis6mvxq4lw1j1lw0rzp9d3zz1w76-glib-2.70.1/lib:${LD_LIBRARY_PATH}" python3 fake.py -w /dev/video0 -v /dev/video10 --no-background --no-foreground --background-blur 50
