---
author: Cristian Livadaru
categories:
- tech
date: "2024-07-19T12:39:11Z"
title: "Backing up databases to Minio S3 with Docker"
image: /images/2024/07/cigars.png
slug: db-backups-docker-minio-s3
summary: "You have lots of databases and you want to back them up to a central location.
  You could use a cloud provider, but what if you want to keep the data on your own
  server? Minio S3 is a great solution for this and with Docker it's easy to set up."
draft: false
tags:
- ssl
- letsencrypt
- nginx-proxy-manager
---

Before I start with the actual backup and setup, let me send a huge thank you to
[Dave Conroy](https://www.tiredofit.ca) for all his ['tiredofit' Docker images](https://github.com/tiredofit). They are really awesome and a huge
time saver.

## Setting up Minio S3 with Docker
I will actually not go into detail on how to set up Minio S3, if you need help with that,
reach out to me an I will add a post about that as well.
So for now I will assume you have Minio S3 running, configured and know how to create a bucket
service accounts.

## Setting up a backup
Let's assume you have a database running in Docker for a project, it would look something
like this:

```yaml
  database:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_DB: ${DB_DATABASE_NAME}
    volumes:
      - ${DB_DATA_LOCATION}:/var/lib/postgresql/data
    restart: always
```

now just add the `tiredofit/db-backup` image and enjoy automated backups to your
self hosted minio!
Make sure to set the `DB01_S3_HOST` to the URL without https, otherwise it won't work.

```yaml
  db-backup:
    container_name: db-backup
    image: tiredofit/db-backup
    volumes:
      - ${DB_DATA_LOCATION}:/backup
    environment:
      - TIMEZONE=Europe/Vienna
      - CONTAINER_NAME=db-backup
      - CONTAINER_ENABLE_MONITORING=FALSE

      - BACKUP_JOB_CONCURRENCY=1     # Only run one job at a time
      - DEFAULT_CHECKSUM=NONE        # Don't create checksums
      - DEFAULT_COMPRESSION=Bzip2     # Compress all with ZSTD
      - DEFAULT_BACKUP_INTERVAL=1440   # Backup every 1440 minutes
      - DEFAULT_BACKUP_BEGIN=2200      # Start backing up at midnight
      - DEFAULT_CLEANUP_TIME=8640    # Cleanup backups after a week

      - DB01_BACKUP_LOCATION=S3
      - DB01_S3_BUCKET=psql-backup
      - DB01_S3_KEY_ID=${BACKUP_S3_KEY_ID}
      - DB01_S3_KEY_SECRET=${BACKUP_S3_KEY_SECRET}
      - DB01_S3_PATH=backup
      - DB01_S3_HOST=backup.s3-backup.example.com
      - DB01_S3_CERT_SKIP_VERIFY=FALSE
      - DB01_TYPE=pgsql
      - DB01_HOST=database
      - DB01_NAME=${DB_DATABASE_NAME}
      - DB01_USER=${DB_USERNAME}
      - DB01_PASS=${DB_PASSWORD}
```

Something else very nice about this backup image, it supports multiple databases and you can also add multiple
configurations to the same backup container. Maybe you want a local database dump, one to minio and another to
some other S3 vendor.

## Testing the backups
Now let's make sure the backups are really working.
Enter the container:

```bhas
docker exec -ti db-backup bash
```

Then trigger the backup manually:

```bash
backup01-now
```

check your minio bucket and you should see the backup there.
