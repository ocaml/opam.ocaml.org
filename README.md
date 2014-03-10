# opam.ocaml.org maintenance scripts

opam.ocaml.org is hosted on a Debian VM ; @avsm, @samoht and @AltGr have accounts there, but everything of interest is in an 'opam' account:
```
 ~opam
 |-- git
 |   |-- opam     (auto-updated, reset, compiled and installed every night)
 |   |-- opamfu   (auto-updated, reset, compiled and installed every night)
 |   |-- opam2web (auto-updated, reset, compiled and installed every night)
 |   `-- scripts  (no auto-update: git pull manually)
 |-- local        (where the above are installed)
 |   |-- bin      (contains the binaries and symlinks to the scripts)
 |   `-- share
 |-- var
 |   `-- log      (holds both the apache logs and cron logs)
 |-- www          (currently deployed opam web. Rebuilt every hour)
 |-- www-bak      (previous version)
 `-- www-new      (version currently being built by the scripts, swapped with www once done)
```

The scripts include:
* `cron-wrapper.sh` fills the logs and reports failures by mail to opam-commits@
* `update-from-git.sh` synchronises sources in `git/` with git remotes
* `update-opam-repo.sh` synches the opam repo and web page (runs `opam-admin make` and `opam2web`)

## What is done manually
* Update these scripts:
```
cd git/scripts && git pull
```
* Update the server config:
```
cp nginx.conf /etc/nginx/sites-available/default
kill -HUP $(cat /var/run/nginx.pid)
```
* Update the crontab:
```
crontab crontab
```
