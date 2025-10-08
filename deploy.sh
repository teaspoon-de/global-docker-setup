#!/bin/bash
# ========================================================
# GHCR Deployment Script
# ========================================================

set -e  # Bricht bei Fehlern ab

# Pfad zur Token-Datei
TOKEN_FILE="$HOME/.ghcr_token"
USERNAME="finnkit05"

# Prüfen, ob Token-Datei existiert
if [ ! -f "$TOKEN_FILE" ]; then
  echo "❌ Token-Datei nicht gefunden: $TOKEN_FILE"
  echo "Erstellen durch: echo '<token>' > $TOKEN_FILE && chmod 600 $TOKEN_FILE"
  exit 1
fi

# Login bei GHCR
echo "🔐 GitHub Container Registry Login ..."
cat "$TOKEN_FILE" | docker login ghcr.io -u "$USERNAME" --password-stdin

# Images aktualisieren und Container starten
echo "🚀 Images aktualisieren ..."
docker compose pull

echo "🧩 Container starten ..."
docker compose up -d --remove-orphans

# Cleanup
echo "🧹 Alte Ressourcen aufräumen ..."
docker system prune -af --volumes

echo "✅ Deployment abgeschlossen!"
