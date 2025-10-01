#!/bin/bash
set -euo pipefail

# Aggiorna i pacchetti e installa le dipendenze necessarie
if command -v apt-get >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get install -y git unzip xz-utils clang cmake ninja-build pkg-config libgtk-3-dev wget curl gnupg ca-certificates

	# Installa Google Chrome dal repository ufficiale, se non già presente
		if ! command -v google-chrome >/dev/null 2>&1; then
		sudo install -d -m 755 /usr/share/keyrings
		wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg
		if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
			echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
		fi
		sudo apt-get update
		sudo apt-get install -y google-chrome-stable
	fi
elif command -v apk >/dev/null 2>&1; then
	sudo apk update
	sudo apk add --no-cache bash curl git unzip xz tar clang cmake ninja pkgconf gtk+3.0-dev gcompat libstdc++ chromium
else
	echo "Gestore pacchetti non supportato. Installare manualmente le dipendenze richieste." >&2
	exit 1
fi

# Scarica e installa il Flutter SDK
FLUTTER_SDK_VERSION="3.22.2" # Puoi aggiornare questa versione se necessario
FLUTTER_SDK_DIR="/usr/local/flutter"
if [ ! -x "${FLUTTER_SDK_DIR}/bin/flutter" ]; then
	wget "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_SDK_VERSION}-stable.tar.xz" -O flutter.tar.xz
	sudo rm -rf "${FLUTTER_SDK_DIR}"
	sudo tar -xf flutter.tar.xz -C /usr/local/
	rm flutter.tar.xz
else
	echo "Flutter già presente in ${FLUTTER_SDK_DIR}, salto il download."
fi

# Imposta i permessi e il path
sudo chown -R "$(whoami)" "${FLUTTER_SDK_DIR}"
USER_HOME="$(getent passwd "$(whoami)" | cut -d: -f6)"
mkdir -p "${USER_HOME}"
touch "${USER_HOME}/.bashrc"
if ! grep -q '/usr/local/flutter/bin' "${USER_HOME}/.bashrc"; then
	echo 'export PATH="$PATH:/usr/local/flutter/bin"' >> "${USER_HOME}/.bashrc"
fi
if [ -n "${HOME:-}" ] && [ ! -d "${HOME}" ]; then
	sudo mkdir -p "${HOME}"
	sudo chown "$(whoami)":"$(whoami)" "${HOME}"
fi
export PATH="$PATH:/usr/local/flutter/bin"
export HOME="${USER_HOME}"

# Determina il percorso del browser e crea un alias stabile
CHROME_BIN=""
if command -v google-chrome >/dev/null 2>&1; then
	CHROME_BIN="$(command -v google-chrome)"
elif command -v chromium-browser >/dev/null 2>&1; then
	CHROME_BIN="$(command -v chromium-browser)"
elif command -v chromium >/dev/null 2>&1; then
	CHROME_BIN="$(command -v chromium)"
fi

if [ -n "${CHROME_BIN}" ]; then
	sudo ln -sf "${CHROME_BIN}" /usr/local/bin/google-chrome
	if ! grep -q 'CHROME_EXECUTABLE' "${USER_HOME}/.bashrc"; then
		echo 'export CHROME_EXECUTABLE="/usr/local/bin/google-chrome"' >> "${USER_HOME}/.bashrc"
	fi
	export CHROME_EXECUTABLE="/usr/local/bin/google-chrome"
else
	echo "ATTENZIONE: nessun browser compatibile trovato. Flutter web non sarà disponibile." >&2
fi

# Abilita il supporto web
flutter config --enable-web

# Accetta le licenze e verifica l'installazione
flutter --version
flutter doctor

echo "Configurazione Flutter completata."
