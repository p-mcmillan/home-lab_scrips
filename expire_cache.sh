#!/bin/bash

/usr/bin/touch /srv/expire_cache.sh

LOG_FILE="/var/log/expire_cache.log"
TMP_MOVED_FILES=$(mktemp)  
CACHE="/srv/disks/cache01"
BACKING="/srv/disks/backing_pool"
PERCENTAGE=85
N=5

echo "$(date): Starting expire_cache.sh" >> "${LOG_FILE}"

echo "$(date): Moving files from cache to backing pool" >> "${LOG_FILE}"

set -o errexit


find "${CACHE}" -mindepth 1 -type f -atime +${N} -exec sh -c '
  for FILE; do
    DIR=$(dirname "${FILE}")
    DEST_DIR="${BACKING}/${DIR#${CACHE}}"
    mkdir -p "${DEST_DIR}"

    rsync -axqHAXWES --preallocate --remove-source-files "${FILE}" "${DEST_DIR}/"

    echo "$(date): Moved file: ${FILE}" >> "${LOG_FILE}"
    echo "${FILE}" >> "${TMP_MOVED_FILES}"  # Log moved file in the temp file
  done
' sh {} +


if [ -s "${TMP_MOVED_FILES}" ]; then  
  echo "$(date): Files moved from cache to backing pool:" >> "${LOG_FILE}"
  cat "${TMP_MOVED_FILES}" >> "${LOG_FILE}"
fi


rm -f "${TMP_MOVED_FILES}"


while [ $(df --output=pcent "${CACHE}" | awk 'NR==2 {print int($1)}') -gt ${PERCENTAGE} ]; do
  echo "$(date): Cache usage exceeds ${PERCENTAGE}%. Moving the least recently accessed file to backing pool." >> "${LOG_FILE}"

  FILE=$(find "${CACHE}" -mindepth 1 -type f -printf '%A@ %P\n' | sort -n | head -n 1 | cut -d ' ' -f2-)

  if [ -n "${FILE}" ]; then
    DIR=$(dirname "${CACHE}/${FILE}")
    DEST_DIR="${BACKING}/${DIR#${CACHE}}"
    mkdir -p "${DEST_DIR}"

    rsync -axqHAXWES --preallocate --remove-source-files "${CACHE}/${FILE}" "${DEST_DIR}/"

    echo "$(date): Moved file: ${FILE}" >> "${LOG_FILE}"
  else
    echo "$(date): No files found in the cache." >> "${LOG_FILE}"
  fi
done

echo "$(date): Script execution completed" >> "${LOG_FILE}"
