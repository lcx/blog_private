---
author: Cristian Livadaru
categories:
- linux
- sysadmin
date: "2022-05-19T07:17:25Z"
description: ""
draft: false
image: https://images.unsplash.com/photo-1631016041959-0ed99b85fea7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxMTc3M3wwfDF8c2VhcmNofDZ8fGR1cGxpY2F0ZXxlbnwwfHx8fDE2NTI5NTA3MTg&ixlib=rb-1.2.1&q=80&w=2000
slug: copying-data-between-two-seafile-servers
summary: You could just copy data between two seafile servers via seafile client or
  web, but life's to short for that.
tags:
- linux
- sysadmin
title: Copying data between two seafile servers
---


You might want to copy files between two seafile servers / accounts or maybe from some other server to seafile. You could do it manually via seafile client / Web interface but I honestly prefer the command line for this. So here are the steps you need, assuming you are copying between to Seafile accounts or servers.

## Checklist

1. Download library from first account
2. Download library from second account
3. rsync data
4. Check consistency

## Download library from first account

```bash
mkdir ~/seafile-upload/<:folder>
seaf-cli sync -l <:library_id> -s https://... -d ~/seafile-upload/<:folder> -u foo@example.com
```

Replace the `<:library_id>` and `<:folder>` with correct data.

When syncing locally just for the sake of moving data from one SF server to a second one, don't use crazy directory name like `Some Fancy FolderNäme (Foo Data)` just name the directory however you like

## Download library from second account

```bash
mkdir ~/seafile-upload/<:other_folder>
seaf-cli sync -l <:other_library_id> -s https://... -d ~/seafile-upload/<:other_folder> -u foo@example.com
```

Again, replace the placeholders.

Check if data is synced with `seaf-cli status`

```bash
cristian@backup:~/seafile-upload/$ seaf-cli status
# Name                                                  Status         
New_Library                                              synchronized
Old_Library                                              synchronized
```

## Rsync data

Run rsync in dry mode just to be sure everything is ok

```bash
$ cd ~/seafile-upload/New_Library
$ rsync -avxp -n "~/seafile-upload/Old_Library" .
```

You also don't have to sync the full library, it's fine to just sync a file / folder. If everything looks fine, rerun the command without the dry mode (remove the `-n` option)

Check the progress with `seaf-cli status`

```bash
seaf-cli status
# Name              Status                  Progress
New_LIbrary        uploading               1.0%, 1464.7KB/s
```

Once it shows the status is `synchronized` you can continue

### desync the library

It's very important that you first desync the library before deleting anything otherwise it could sync the deletion of the files which means you are deleting files from your seafile server.

```bash
seaf-cli desync -d ~/seafile-upload/New_Library/
seaf-cli desync -d ~/seafile-upload/Old_Library/
```

NO data will be deleted on the desync. It just does not sync with seafile anymore which means it's safe to remove the local copy, but continue reading before removing the data.

Check with `seaf-cli status` it should return a blank list.

## Check consistency

The rsync command just ensures that the files where synced locally, even if `seaf-cli status` says everything was uploaded, it doesn't hurt to double check.

### Remove the New Library

remove the new library from local disk, but only the new library, not the old one just yet. After that sync the library again.

```bash
$ rm -rf ~/seafile-upload/New_Library/
$ mkdir ~/seafile-upload/New_Library
$ seaf-cli sync -l <:other_library_id> -s https://... -d ~/seafile-upload/New_Library -u foo@example.com
```

check with `seaf-cli status` that everything is synced again.

### Compare data with rsync --checksum

```bash
$ cd ~/seafile-upload/New_Library
$ rsync -avxp -n --checksum "~/seafile-upload/Old_Library" .
```

and check the output, it should contain only directories, but no files.

Now you can desync everything again and remove the local copy.

