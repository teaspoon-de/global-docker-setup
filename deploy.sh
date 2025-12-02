#!/bin/bash
# ========================================================
# GHCR Deployment Script
# ========================================================

set -e  # Bricht bei Fehlern ab

# Prüfen, ob Token-Datei existiert
if [ ! -f "$GHCR_TOKEN_FILE" ]; then
  echo "❌ Token-Datei nicht gefunden: $GHCR_TOKEN_FILE"
  echo "Erstellen durch: echo '<token>' > $GHCR_TOKEN_FILE && chmod 600 $GHCR_TOKEN_FILE"
  exit 1
fi

# Login bei GHCR
echo "🔐 GitHub Container Registry Login ..."
cat "$GHCR_TOKEN_FILE" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin

# Images aktualisieren und Container starten
echo "🚀 Images aktualisieren ..."
docker compose pull

echo "🧩 Container starten ..."
docker compose up -d --remove-orphans

# Cleanup
echo "🧹 Alte Ressourcen aufräumen ..."
docker system prune -af --volumes

echo "✅ Deployment abgeschlossen!"
