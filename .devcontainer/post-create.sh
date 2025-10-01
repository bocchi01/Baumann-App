#!/bin/bash
set -euo pipefail

# Aggiorna i pacchetti e installa le dipendenze necessarie
sudo apt-get update
sudo apt-get install -y git unzip xz-utils clang cmake ninja-build pkg-config libgtk-3-dev

# Scarica e installa il Flutter SDK
FLUTTER_SDK_VERSION="3.22.2" # Puoi aggiornare questa versione se necessario
wget "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_SDK_VERSION}-stable.tar.xz" -O flutter.tar.xz
sudo tar -xf flutter.tar.xz -C /usr/local/
rm flutter.tar.xz

# Imposta i permessi e il path
sudo chown -R "$(whoami)" /usr/local/flutter
echo 'export PATH="$PATH:/usr/local/flutter/bin"' >> ~/.bashrc
export PATH="$PATH:/usr/local/flutter/bin"

# Accetta le licenze e verifica l'installazione
flutter --version
flutter doctor

echo "Configurazione Flutter completata."
