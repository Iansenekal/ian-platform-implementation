# landing-ui systemd user service

## Install
1. Copy `deploy/systemd/landing-ui.service` to `~/.config/systemd/user/landing-ui.service`.
2. Run `systemctl --user daemon-reload`.
3. Run `systemctl --user enable --now landing-ui`.
4. Run `sudo loginctl enable-linger $USER`.

## Update deployment
1. Pull latest code.
2. Run `npm install` if dependencies changed.
3. Run `npm run build`.
4. Run `systemctl --user restart landing-ui`.
5. Check with `systemctl --user status landing-ui --no-pager`.
