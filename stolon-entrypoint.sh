#!/bin/bash
set -e

if [ "$1" = "stolon-keeper" ] && [ "$(id -u)" = '0' ]; then
	if [ "$STKEEPER_DATA_DIR" ]; then
		mkdir -p "$STKEEPER_DATA_DIR"
		chmod 700 "$STKEEPER_DATA_DIR"
		chown postgres "$STKEEPER_DATA_DIR"
	else
		echo "Please specify STKEEPER_DATA_DIR"
		exit 1
	fi

	if [ "$WALE_GPG_KEY_ID" ]; then
		export GNUPGHOME="$STKEEPER_DATA_DIR/gnupg"
		mkdir -p "$GNUPGHOME"
		chmod 700 "$GNUPGHOME"
		chown postgres:postgres "$GNUPGHOME"
		gosu postgres gpg --keyserver keys.gnupg.net --recv-keys "$WALE_GPG_KEY_ID"
	fi

	if [ "$GPG_OWNERTRUST" ]; then
		gosu postgres gpg --keyserver keys.gnupg.net --recv-keys "$WALE_GPG_KEY_ID"
		gosu postgres echo "$GPG_OWNERTRUST" | gpg --import-ownertrust -
	fi
fi

case  "$1" in
	"stolonctl" | "stolon-keeper" | "stolon-proxy" | "stolon-sentinel")
		if [ "$(id -u)" = '0' ]; then
			exec gosu postgres $@
		else
			exec $@
		fi
		;;
esac

exec $@
