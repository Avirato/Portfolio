# Portfolio — Liam Berg

Statisk portfolio-sida (HTML/CSS, lite JavaScript) som publiceras med GitHub Pages:

- Engelska: `https://avirato.github.io/Portfolio/`
- Svenska: `https://avirato.github.io/Portfolio/sv/`

Adressen är skiftlägeskänslig: `Portfolio` med stort P.

Spelsidan med privacy policies och `app-ads.txt` ligger i ett **annat** repo (`Avirato.github.io`). Den ska inte flyttas hit, eftersom Google Play och annonsnätverken läser filerna där.

## Struktur

```
index.html              Startsida på engelska (redigeras för hand)
sv/index.html           Startsida på svenska (redigeras för hand)
work/<projekt>.html     Projektsidor på engelska   } byggs av tools/build.sh,
sv/work/<projekt>.html  Projektsidor på svenska    } ändra inte för hand
tools/build.sh          Alla projektsidor, med engelsk och svensk text sida vid sida
css/style.css           All styling
js/main.js              YouTube-inbäddningar, videoloopar och bildvisare
assets/work/<projekt>   Bilder och videoklipp (cover.jpg = bilden på startsidan)
assets/games/<spel>     Ikoner och skärmdumpar
assets/youtube/         Miniatyrer för Shorts
```

## Ändra eller lägga till ett projekt

1. Lägg bilderna i `assets/work/<projekt>/`, plus en `cover.jpg` i 16:9 (t.ex. 1280×720) för nya projekt.
2. Ändra eller lägg till projektet i `tools/build.sh`, med text på båda språken.
3. Kör `bash tools/build.sh` från repots rot.
4. Nytt projekt: lägg till ett kort i både `index.html` och `sv/index.html`.

## Efter ändringar i css/style.css eller js/main.js

Öka versionsnumret (`?v=`) i `tools/build.sh`, `index.html` och `sv/index.html` och kör bygget igen. Annars kan besökare få en gammal version från webbläsarens cache.

## Bilder i ett publikt repo

Allt som laddas upp hit blir offentligt och ligger kvar i Git-historiken, även om filen byts ut eller tas bort senare. Vattenmärk därför bilderna innan de läggs in, och spara originalen utanför repot.
