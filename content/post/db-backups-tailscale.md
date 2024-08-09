---
author: Cristian Livadaru
categories:
- tech
title: "Database Backups in Docker with Tailscale"
image: /images/2024/08/20240809-backup.webp
date: 2024-08-09T10:51:26+02:00
slug: db-backups-tailscale
summary: "Running a Rails application in Docker, with a PostgreSQL is nothing new,
    the database however needs to be reachable from another site through where Tailscale
    comes in. This might make backups a bit more complicated, but it's not impossible."
tags:
- tailscale
- sysadmin
- backups
draft: false
---

Seems like I have no post of setting up tailscale in docker yet, so without going
into to much detail, here's my current setup.
For a real deep dive, check out the [blog post from tailscale](https://tailscale.com/blog/docker-tailscale-guide)
where you also have a YouTube video explaining the setup in full detail.

## The setup
### Tailscale
Let's start with the tailscale setup, as mentioned, I will not go into full detail.
The important part here is the `container_name` which you will need later.

```yaml
services:
  ts-rails-db:
    image: tailscale/tailscale:latest
    container_name: ts-rails-db
    hostname: rails-db
```

### PostgreSQL

```yaml
  db:
    image: postgres:16
    volumes:
      - /opt/docker/rails/db:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - PGUSER=${POSTGRES_USER}
      - PGHOST=db
      - PGPASSWORD=${POSTGRES_PASSWORD}
      - HISTFILE=/var/lib/postgresql/data/.bash_history
      - PSQL_HISTFILE=/var/lib/postgresql/data/.psql_history
    network_mode: service:ts-rails-db
    restart: unless-stopped
    depends_on:
      - ts-rails-db
```

As mentioned in the summary, I need the database to be reachable from another site.
The sites are connected through Tailscale and to make the database reachable through
tailscale, you need to tell docker to use the network of the tailscale container for the service.
`network_mode: service:ts-rails-db` does exactly that.

By doing so, the database is reachable from the other site, but the other containers
in the compose won't be able to reach the database anymore by using `db` as the hostname.

### Rails

This snippet is heavily cut down, but the important part is there.

```yaml
  app:
    image: rails:latest
    environment:
      - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@ts-rails-db/rails_production
    depends_on:
      - db
      - ts-rails-db
    restart:
      unless-stopped
    network_mode: service:ts-rails-db
```

The `DATABASE_URL` is set to `postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@ts-rails-db/rails_production`.
Pay attention to the host part, which is `ts-rails-db` and not `db` as one would usually expect in a compose file.
The reason for this is that the container for the database has been "pushed" into the network of the tailscale container.
Hence any service that needs something out of that container, will have to talk to the tailscale container.

## Backups
Now with this knowledge, let's set up the backups. As usual I'm using the [tiredofit/db-backup](https://github.com/tiredofit/docker-db-backup)
container to create a local backup and push it to an S3 bucket by using a self hosted Minio instance.

```yaml
  db-backup:
    container_name: if-rails-db-backup
    image: tiredofit/db-backup
    network_mode: service:ts-rails-db
    volumes:
      - /opt/docker/rails/backup:/backup
    environment:
      - TIMEZONE=Europe/Vienna
      - CONTAINER_NAME=if-rails-db-backup
      - CONTAINER_ENABLE_MONITORING=FALSE

      - BACKUP_JOB_CONCURRENCY=1     # Only run one job at a time
      - DEFAULT_CHECKSUM=NONE        # Don't create checksums
      - DEFAULT_COMPRESSION=Bzip2     # Compress all with ZSTD
      - DEFAULT_BACKUP_INTERVAL=1440   # Backup every 1440 minutes
      - DEFAULT_BACKUP_BEGIN=2100      # Start backing up at midnight
      - DEFAULT_CLEANUP_TIME=8640    # Cleanup backups after a week

      - DB01_TYPE=postgres
      - DB01_HOST=ts-rails-db
      - DB01_NAME=rails_production
      - DB01_USER=${POSTGRES_USER}
      - DB01_PASS=${POSTGRES_PASSWORD}

      - DB02_BACKUP_LOCATION=S3
      - DB02_S3_BUCKET=backup-db-rails
      - DB02_S3_KEY_ID=${BACKUP_S3_KEY_ID}
      - DB02_S3_KEY_SECRET=${BACKUP_S3_KEY_SECRET}
      - DB02_S3_PATH=backup
      - DB02_S3_HOST=backup.s3.example.com
      - DB02_S3_CERT_SKIP_VERIFY=FALSE
      - DB02_TYPE=postgres
      - DB02_HOST=ts-rails-db
      - DB02_NAME=rails_production
      - DB02_USER=${POSTGRES_USER}
      - DB02_PASS=${POSTGRES_PASSWORD}
```

The important part here is the `DB01_HOST=ts-rails-db` which tells the backup container
to use the network of the tailscale container, just like the other services.
The nice thing of using `tiredofit/db-backup` is that it can handle multiple databases
and backup locations, so you can easily add more databases or backup locations.
The first setup `DB01_` is the local backup, the second setup `DB02_` is the S3 backup.

## Test your backups
The problem with database dumps is that they are sometimes hard to monitor. You could use services
like [healthchecks.io](https://healthchecks.io/) or roll out something of your own,
but if you rely on checking backup logs, you will be in trouble in case you might need to restore
the data at some point.
A good starting point is to read the [notifications](https://github.com/tiredofit/docker-db-backup?tab=readme-ov-file#notifications)
section of the documentation.

Photo by [Jandira Sonnendeck](https://unsplash.com/@jandira_sonnendeck?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash)
on [Unsplash](https://unsplash.com/photos/a-close-up-of-a-disc-with-a-toothbrush-on-top-of-it-AcW1ZwD-qC0?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash)
