# Goatcounter on fly.io

This repository contains a template for setting up and running
[goatcounter][goatcounter-repo] on [fly.io][flyio], including
Litestream backing up our SQLite database to a S3 (compatible) bucket.
This setup runs great on the fly.io free tier (1 shared CPU, 256 MB of
memory, 1 GB of disk), at least for a small website.  You can also
make use of [Backblaze B2's][b2] free tier[^1] to store your backups.

**One important thing to note** is that this is a single node setup
using local volumes, so in case the host running our container dies we
might not be automagically migrated to a new host.  However, our data
is reasonably safe due to Litestream backups, so we should not lose
more than a few minutes of data (at most).

PRs are always welcome!

## Prerequisites

 - A fly.io account
 - An account with a S3 (compatible) storage provider, with a bucket
   already setup & credentials at hand ([see this tutorial for
   Backblaze specific instructions][litestreambackblaze])
 - flyctl CLI installed

## Usage

1. Clone or fork this repository.

   ```sh
   git clone https://github.com/oscarcarlsson/goatcounter-on-fly.git && cd goatcounter-on-fly
   ```

1. Run `flyctl launch --no-deploy` and fill in the tutorial - you
   _don't_ need Redis nor Postgres! This will generate a `fly.toml`
   but won't try to launch anything yet.

1. Create a volume for the database, change to your preferred region:

   ```sh
   flyctl volumes create goatcounter_data --region CHANGEME --size 1
   ```

1. Open `fly.toml` and add the following to the env section:

   ```toml
   [env]
     # Change these!
     GOATCOUNTER_DOMAIN = 'goatcounter.example.com'
     GOATCOUNTER_EMAIL = 'john.doe@example.com'

     # Don't change these
     GOATCOUNTER_LISTEN = '0.0.0.0:8080'
     GOATCOUNTER_DB = '/data/goatcounter.sqlite3'

     # These can be blank
     GOATCOUNTER_SMTP = ''
     GOATCOUNTER_DEBUG = ''

     # Change these for your S3 provider!
     LITESTREAM_REPLICA_ENDPOINT = ''
     LITESTREAM_REPLICA_BUCKET = ''
     LITESTREAM_REPLICA_PATH = ''
   ```

   Also make sure that the mount section looks something like this:

   ```toml
   [[mounts]]
   source = 'goatcounter_data'
   destination = '/data'
   processes = ['app']
   ```

1. Nearly done! Now, create secrets for your secrets:

   ```sh
   flyctl secrets set GOATCOUNTER_PASSWORD="changeme" LITESTREAM_ACCESS_KEY_ID="changeme" LITESTREAM_SECRET_ACCESS_KEY="changeme"
   ```

   The secret called `GOATCOUNTER_PASSWORD` will be the initial
   password for the `admin` account.

1. Now, try to deploy the application!


## Credits

This is heavily inspired by [fspoettel/linkding-on-fly][fspoettel].

[^1]: Their free tier is 10GB free, then $0.005 per GB, which is _plenty_

[goatcounter-repo]: https://github.com/arp242/goatcounter
[flyio]: https://fly.io/
[b2]: https://www.backblaze.com/cloud-storage
[fspoettel]: https://github.com/fspoettel/linkding-on-fly
[litestreambackblaze]: https://litestream.io/guides/backblaze/
