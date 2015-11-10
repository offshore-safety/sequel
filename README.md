Forked from https://github.com/jeremyevans/sequel

## Usage

It's probably not worth installing the gem globally as it may clash with other stuff.  Just run it from the cloned folder.

**This will trash any local data in your development database**

- Ensure that Vagrant is running your SQL Server dev box
- `brew install homebrew/versions/freetds091`
- Ensure that all migrations have been run
- Execute `./db_sync` takes around 6 minutes to complete

## Custom usage

```bash
bin/sequel -s tinytds://{username}:{password}@{dbhost address}/{database name} \
              tinytds://nopsema:nopsema@192.168.50.4/rms_development
```
