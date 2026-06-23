#!/bin/bash
set -e

chown -R openclaw:openclaw /data
chmod 700 /data

# OpenClaw >= 2026.6.9 HARD-BLOCKS plugins whose files are not owned by root (uid 0)
# ("suspicious ownership"). The `chown -R openclaw:openclaw /data` above makes the on-volume
# plugin dirs uid 1001, which 6.9 then refuses to load (gate + slack go down). Re-own the
# plugin dirs to root so 6.9 loads them. Guarded for existence; runs every boot (idempotent).
for d in /data/.openclaw/extensions/* /data/.openclaw/npm/projects/openclaw-slack-*; do
  [ -e "$d" ] && chown -R root:root "$d" || true
done

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

exec gosu openclaw node src/server.js

