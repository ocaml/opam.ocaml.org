# opam.ocaml.org maintenance scripts

opam.ocaml.org is hosted on a Debian VM ; @avsm, @samoht and @AltGr have accounts there, but everything of interest is in an 'opam' account:
```
 ~opam
 |-- git
 |   |-- opam     (branch 1.2; updated every night)
 |   |-- opam2    (branch master; updated every night)
 |   |-- opamfu   (updated, reset, compiled and installed every night)
 |   |-- opam2web (updated, reset, compiled and installed every night)
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
* `update-from-git.sh` synchronises sources in `git/` with git remotes,
  recompiles and installs, with specific instructions depending on the target
  (e.g. `opam2` installs the needed tools, e.g. opam-admin, into specific
  dir/filenames to not overlap with `opam`)
* `update-opam-repo.sh` synches the opam repo from github and upgrades. It works
  on `~/www-new/`, but keeps the `archives/` and `1.1/` subdirectories along
  from `~/www/` before updating. The archives and indexes are updated
  (`opam-admin`), version-migrated mirrors are put in place (`opam-admin.2.0`),
  the documentation is regenerated, as well as the website, including blog and
  statistics (`opam2web`). Then `www-new` is swapped for `www` if successful.

## What is updated only manually

* Update of these scripts:

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

## Pre-requirements and initialisation

Additionally to the above:

* An initialised opam 1.2.2 root with a working switch suitable for compilation
  of opam 1.3 and 2.0, and the tools is required (`ocaml.4.04.0 cmdliner.0.9.8
  cudf.0.7 dose3.5.0.1 jsonm.1.0.1 ocamlgraph.1.8.7 re.1.7.1` for opam, add
  `opam-file-format` for opam2, `hevea` for the manual, `js_of_ocaml.2.8.4
  cow.2.2.0 for opamfu/opam2web),

* The folders below `~opam/git/` need an initial clone for the update script to
  operate ; run the `update-from-git.sh` script for each of them (see crontab)
  at least once before running `update-opam-repo.sh`. Note that opamfu and
  opam2web use the forks at github.com/AltGr/

* A clone of the opam-repository git at `~opam/www` is required for
  `update-opam-repo.sh` to bootstrap. Include `archives/`, `urls.txt`,
  `index.tar.gz` to keep incremental archive rebuilds.

* Ensure `~opam/var/log` and `~/local/{bin,share}` exist.

* The computation of the statistics in `update-opam-repo.sh` assumes log files
  at `~opam/var/log/access-YEAR-MONTH.log` and `~/var/log/access.log` (as
  configured by the included nginx.conf). This takes a long time, so `opam2web`
  uses a cache at `~/.cache/opam2web/stats_cache`.
