#!/bin/bash
set -e

if [ "$1" = "stolon-keeper" ] && [ "$(id -u)" = '0' ]; then
	if [ "$STKEEPER_DATA_DIR" ]; then
		mkdir -p "$STKEEPER_DATA_DIR"
		chmod 700 "$STKEEPER_DATA_DIR"
		chown -R postgres "$STKEEPER_DATA_DIR"
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

		GPG_FINGERPRINT=$(gpg --fingerprint --with-colons "$WALE_GPG_KEY_ID" | grep ^fpr | tr -d 'fpr:')
		GPG_OWNERTRUST="$GPG_FINGERPRINT:6:"
		echo "$GPG_OWNERTRUST" | gosu postgres gpg --import-ownertrust -
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
