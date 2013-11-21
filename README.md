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

The crontab is as follows:
```
 # m h  dom mon dow   command
   0 2  *   *   *     /home/opam/local/bin/cron-wrapper.sh update-opam update-from-git.sh opam
   0 3  *   *   *     /home/opam/local/bin/cron-wrapper.sh update-opam2web update-from-git.sh opam2web
  15 *  *   *   *     /home/opam/local/bin/cron-wrapper.sh update-opam-repo update-opam-repo.sh
```
