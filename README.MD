# nginx-rtmps

[![Github Workflow Status](https://img.shields.io/github/actions/workflow/status/viertelwissen/nginx-rtmps/build-docker-image.yml)]()
[![Docker Pulls](https://img.shields.io/docker/pulls/viertelwissen/nginx-rtmps)](https://hub.docker.com/r/viertelwissen/nginx-rtmps)
[![Twitch Status](https://img.shields.io/twitch/status/viertelwissen?style=social)](https://twitch.tv/viertelwissen)

Dieses Docker Image soll eine einfache Möglichkeit bereitstellen, um ein Videosignal auf mehrere Ziele zu übertragen. Damit ist es möglich, auf zum Beispiel Twitch und YouTube gleichzeitig zu streamen.

Genutzt wird dafür Nginx mit RTMP-Modul und stunnel.

Derzeitig unterstützte Dienste:
- Twitch
- YouTube
- Trovo
- Instagram
- Facebook

Bei Sonderwünschen kann auch eine eigene Konfiguration genutzt werden.

## Einfacher Start
Zur Ausführung des Containers muss der Port 1935 (RTMP) geöffnet werden und der Streamkey von jedem Dienst übermittelt werden, den man nutzen möchte:
```bash
docker run -d -p 1935:1935 -e TWITCH_KEY=secretKey -e YOUTUBE_KEY=secretKey viertelwissen/nginx-rtmps
```

Die Stream-URL sieht dann folgendermaßen aus: `rtmp://$SERVER_IP:1935/live`. In OBS wird die komplette Adresse als Server eingetragen, der Streamschlüssel kann frei gewählt werden.

### URL verschleiern
Es ist empfehlenswert, die Variable "APPLICATION_NAME" mit anzugeben und einen kryptischen Wert zu nutzen, damit die URL nicht von anderen erraten werden kann. 

Beispiel: `-e APPLICATION_NAME="finisher-chubby8-possibly-sacred-patient-simplify"`. Eure URL lautet dann `rtmp://$SERVER_IP:1935/finisher-chubby8-possibly-sacred-patient-simplify`

So eine Passphrase kann leicht mit einem Passwort-Generator erstellt werden, wie zum Beispiel mit dem [Online-Tool von Bitwarden](https://bitwarden.com/password-generator/).

## docker-compose
Alternativ kann auch docker-compose genutzt werden. Eine Beispieldatei (`docker-compose.yml`) findest du hier im Github-Repository.

## Umgebungsvariablen

> **:warning: Dollar-Zeichen (\$) müssen in der docker-compose.yml gedoppelt werden.**  
> Beispiel: Streaming-Key "live_s3cre\$t1-blabla" wird zu "live_s3cre\$\$t1-blabla"

Variable | Standard | Optional | Beschreibung
-------- | -------- |--------- | ------------
TWITCH_KEY | (leer) | ja | Der Twitch Streaming Key
YOUTUBE_KEY | (leer) | ja | Der YouTube Streaming Key
TROVO_KEY | (leer) | ja | Der Trovo Streaming Key (ist sehr lang)
INSTAGRAM_KEY | (leer) | ja | Der Instagram Streaming Key
FACEBOOK_KEY | (leer) | ja | Der Facebook Streaming Key
APPLICATION_NAME | live | ja | Dieser Wert wird für die Verbindung zum RTMP-Server benötigt. Es ist empfehlenswert, hier einen kryptischen Wert zu nutzen.
RELAY_APP | (leer)) | ja | Weiterer Stream, der nur als Relay eingesetzt werden kann und nicht automatsich an einen Dienst geschickt wird.
WEB_USER | (leer) | ja | Benutzername, um die Statistikseite zu schützen. Sonst ist sie frei abrufbar.
WEB_PASSWORD | (leer) | ja | Passwort, um die Statistikseite zu schützen. Sonst ist sie frei abrufbar.
DEBUG | (leer) | ja | Auf "true" setzen, wenn nach dem Start die komplette nginx Konfiguration im Log ausgegeben werden soll (zur Kontrolle).

## Statistik
Der Webserver bietet auch eine Statistikseite an, auf der man sehen kann ob gerade ein Stream verbunden ist und wieviel Traffic bereits verursacht wurde. Dieser ist über Port `8080` erreichbar.
Um die Seite zu nutzen muss der Port ebenfalls geöffnet werden. Desweiteren empfiehlt es sich dann, die Variablen `WEB_USER` und `WEB_PASSWORD` zu setzen. Nur wenn beide Variablen gesetzt sind wird die Seite mit einem Login geschützt.

## Eigene Konfiguration
Um eine komplett eigene Nginx Konfiguration zu nutzen, muss diese einfach als Volume angegeben werden:
```bash
docker run -d -p 1935:1935 -v /home/USER/nginx.conf:/etc/nginx/nginx.conf viertelwissen/nginx-rtmps
```
In diesem Fall haben die oben genannten Umgebungsvariablen keine Wirkung mehr und es wird die angegebene Konfiguration direkt genutzt.