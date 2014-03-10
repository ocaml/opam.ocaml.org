# opam.ocaml.org maintenance scripts

opam.ocaml.org is hosted on a Debian VM ; @avsm, @samoht and @AltGr have accounts there, but everything of interest is in an 'opam' account:
```
 ~opam
 |-- git
 |   |-- opam     (auto-updated, reset, complied and installed every night)
 |   |-- opam2web (auto-updated, reset, complied and installed every night)
 |   `-- scripts  (version-controlled but without a master upstream atm. No auto-update)
 |-- local        (where the above are installed)
 |   |-- bin
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
* Update the server config:
```
cp nginx.conf /etc/nginx/sites-available/default
kill -HUP $(cat /var/run/nginx.pid)
```
* Update the crontab:
```
crontab crontab
```
