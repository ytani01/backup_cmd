# Backup commands

``rsync --link-dest`` を使ったインクリメンタル・バックアップ・スクリプト

## Install

### copy files

```bash
$ git clone git@github.com:ytani01/backup_cmd.git
$ cd backup_cmd
$ ./install.sh
```

### edit ``backup_src.txt``

```bash
$ cd /conf/etc
$ cp backup_src.txt.sample backup_src.txt
$ vi backup_src.txt
```

## Scripts usage

### backup_dirs.sh

```bash
backup_dirs.sh [-f backup_src_file] backup_top1 [backup_top2 ..]
```

### backup_inc.sh

```bash
backup_inc.sh src_dir .. backup_top
```

### backup_clean_incomplete.sh

```bash
backup_clean_incomplete.sh backup_top
```
