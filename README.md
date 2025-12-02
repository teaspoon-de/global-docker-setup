# Globale Docker-Umgebung TeaSpoon Deployment

Dieses Repository enthält die globale Docker-Ebene des Produktions-Servers

- Reverse Proxy mit **NGINX** (`nginx-proxy`)  
- **LetsEncrypt** SSL Companion (`nginx-letsencrypt`)  
- **MySQL** Datenbank (`mysql`)  
- **Deployment-Skript** für GitHub Container Registry (`deploy.sh`)

---

## Inhaltsverzeichnis

- [Voraussetzungen](#voraussetzungen)  
- [Wichtigste Dateien](#wichtigste-dateien-im-repo)  
- [Einrichtung](#einrichtung)  
- [Deployment](#deployment)  

---

## Voraussetzungen

- Linux-Server mit **Docker** und **Docker Compose v2+**  
- Zugang zu **GitHub Container Registry (GHCR)**  
- Docker-Mounts `/etc/nginx/certs` und `/usr/share/nginx/html`  

---

## Wichtigste Dateien im Repo

| Datei | Beschreibung |
|-------|-------------|
| `docker-compose.yaml` | Konfiguration globale Services: NGINX-Proxy, LetsEncrypt Companion, MySQL |
| `deploy.sh` | Deployment-Skript: Login bei GHCR, Images pullen, Container starten, Cleanup |
| `nginx/dhparam_setup.sh` | Script zum Erstellen von `dhparam.pem` für TLS Perfect Forward Secrecy |
| `.env` (nicht enthalten) | Enthält geheime Variablen für MySQL und GHCR |

---

## Einrichtung

1. **DH-Parameter erstellen**  
   Wenn `nginx/dhparam.pem` noch nicht existiert, ausführen:

   ```bash
   sh nginx/dhparam_setup.sh
   ```

   Erstellt eine 4096-Bit `dhparam.pem` für sichere TLS-Verbindungen

2. **.env Datei anlegen**  
   Erstelle eine `.env` im Root-Verzeichnis mit folgendem Inhalt:

   ```bash
   MYSQL_ROOT_PASSWORD=<passwort>
   GHCR_TOKEN_FILE=<Pfad_zum_GHCR_Token_File>
   GHCR_USERNAME=<GitHub_Username>
   ```

   > GHCR Token über GitHub → Settings → Developer settings → Personal access tokens (classic) → `write:packages` erstellen.  
   > Datei mit Token sollte nur lokal liegen und Berechtigung 600 haben:

   ```bash
   echo "<token>" > $HOME/.ghcr_token
   chmod 600 $HOME/.ghcr_token
   ```

3. **Ordnerrechte prüfen**  
   - `/etc/nginx/certs` → NGINX kann die Zertifikate lesen/schreiben  
   - `/usr/share/nginx/html` → Volumes für HTML-Dateien  

---

## Deployment

Deployment über `deploy.sh`:

```bash
./deploy.sh
```

Schritte im Script:

1. `.env` laden und Variablen exportieren  
2. GHCR Login durchführen  
3. Docker Images aktualisieren (`docker compose pull`)  
4. Container starten (`docker compose up -d --remove-orphans`)  
5. Cleanup alter Ressourcen (`docker system prune -af --volumes`)  

---

## Konfiguration

- **MySQL**: Root-Passwort über `.env`  
- **NGINX-Proxy**:  
  - Zertifikate in `/etc/nginx/certs`  
  - Vhost-Konfigurationen in `/etc/nginx/vhost.d`  
  - DH-Parameter in `nginx/dhparam.pem`  
- **LetsEncrypt Companion**: Automatische Zertifikatserneuerung  
- **Docker-Netzwerke**:  
  - `webnet` → für global-NGINX, inner-NGINX (einzelne Websites), [PHP](https://github.com/teaspoon-de/prod-php)  
  - `dbnet` → für MySQL und [PHP](https://github.com/teaspoon-de/prod-php)

> Die einzelnen Webseiten werden in separaten Docker-Compose-Umgebungen definiert (bestehend aus NGINX, [PHP](https://github.com/teaspoon-de/prod-php)), die sich an diese Netzwerke anhängen.

---

## Zusammenfassung

Dieses Repo liefert die **globale Infrastruktur** für Deployment:

- Sichere HTTPS-Verbindungen  
- Automatische Zertifikate  
- Zentrale MySQL-Datenbank  
- GHCR Deployment für Container-Images  

`deploy.sh` automatisiert Updates und startet Container sauber.

