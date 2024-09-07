# Cache Expiration Script for SnapRAID and MergerFS

This script automates the management of a **MergerFS** pool backed by **SnapRAID**. It moves files from a cache drive to a backing pool when they are older than a specified number of days or when the cache usage exceeds a set threshold. This helps optimize your storage by managing space effectively, leveraging **MergerFS** for combining drives and **SnapRAID** for parity-based redundancy.

## Overview

### Use Case:

In setups where **MergerFS** combines multiple drives into a single storage pool and **SnapRAID** is used for redundancy, this script:

- Moves older or less-accessed files from a faster cache drive to slower storage (backing pool).
- Helps ensure that the cache drive stays below a certain usage threshold, preventing it from filling up.
- Works well for media libraries or archival systems, where frequently accessed files remain on fast storage and older files are shifted to larger, slower drives.

### Components:

- **MergerFS**: A union filesystem that combines multiple directories into one pool.
- **SnapRAID**: A backup solution that protects data with parity across multiple drives.

## Features

- **Cache Management**: Moves files older than a specified number of days (`N=5` by default) from the cache to the backing pool.
- **Usage Monitoring**: If cache usage exceeds 85% (default), it moves the least recently accessed files to free up space.
- **Logging**: Logs all operations, including file movements and script activity, to `/var/log/expire_cache.log`.

## How It Works

- **Cache Directory**: A faster drive where frequently accessed files are stored. Defined as:
  ```bash
  CACHE="/srv/disks/cache01"
  ```
