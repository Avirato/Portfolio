# Portfolio — Liam Berg

Statisk portfolio-sida (HTML/CSS, lite JavaScript) som publiceras med GitHub Pages på `https://avirato.github.io/Portfolio/`.

Spelsidan med privacy policies och `app-ads.txt` ligger i ett **annat** repo (`Avirato.github.io`). Den ska inte flyttas hit, eftersom Google Play och annonsnätverken läser filerna där.

## Struktur

```
index.html            Startsida: projekt, spel, YouTube, om mig, kontakt
work/<projekt>.html   En breakdown-sida per projekt
css/style.css         All styling
js/main.js            YouTube-inbäddningar, videoloopar och bildvisare
assets/work/<projekt> Bilder och videoklipp (cover.jpg = bilden på startsidan)
assets/games/<spel>   Ikoner och skärmdumpar
assets/youtube/       Miniatyrer för Shorts
```

## Lägga till ett projekt

1. Skapa en mapp i `assets/work/` och lägg bilderna där, plus en `cover.jpg` i 16:9 (t.ex. 1280×720).
2. Kopiera en befintlig sida i `work/`, byt text, bilder och ArtStation-länk.
3. Lägg till ett kort i `index.html` och uppdatera länkarna "Previous/Next" längst ner på sidorna bredvid.

## Förhandsvisa lokalt

Öppna `index.html` i webbläsaren.
