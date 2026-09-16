#!/usr/bin/env bash
# Builds the project pages in English (work/) and Swedish (sv/work/).
#
# Every project is defined once below, with English and Swedish text side by side,
# so both languages always show the same images in the same order.
#
#   bash tools/build.sh          (run from the repository root)
#
# Don't edit work/*.html or sv/work/*.html by hand: change this file and rebuild.
# The two home pages (index.html and sv/index.html) are edited by hand.
set -eo pipefail

V=4                                          # bump when css/style.css or js/main.js change (also in both index.html files)
SITE='https://avirato.github.io/Portfolio'
FONTS='https://fonts.googleapis.com/css2?family=Archivo:wght@700;800;900&amp;family=IBM+Plex+Mono:wght@400;500&amp;family=IBM+Plex+Sans:wght@400;500;600&amp;display=swap'

# t "English" "Svenska" prints the text for the language being built.
t() { if [ "$L" = sv ]; then printf '%s' "$2"; else printf '%s' "$1"; fi; }

# ---------------------------------------------------------------------------
# Page frame

# page_head "Title" "Meta description"
page_head() {
  local title="$1" desc="$2" locale other other_lang other_label
  EAGER=1
  if [ "$L" = sv ]; then
    locale=sv_SE; other="../../work/$S.html"; other_lang=en; other_label="In English"
  else
    locale=en_US; other="../sv/work/$S.html"; other_lang=sv; other_label="På svenska"
  fi
  cat <<EOF
<!doctype html>
<html lang="$L">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title $(t — –) Liam Berg</title>
<meta name="description" content="$desc">
<meta name="theme-color" content="#0e0e10">
<meta property="og:type" content="article">
<meta property="og:locale" content="$locale">
<meta property="og:title" content="$title $(t — –) Liam Berg">
<meta property="og:description" content="$desc">
<meta property="og:image" content="$SITE/assets/work/$S/cover.jpg">
<meta name="twitter:card" content="summary_large_image">
<link rel="alternate" hreflang="en" href="$SITE/work/$S.html">
<link rel="alternate" hreflang="sv" href="$SITE/sv/work/$S.html">
<link rel="alternate" hreflang="x-default" href="$SITE/work/$S.html">
<link rel="icon" href="$R/favicon.svg" type="image/svg+xml">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="$FONTS">
<link rel="stylesheet" href="$R/css/style.css?v=$V">
</head>
<body>

<a class="skip-link" href="#main">$(t 'Skip to content' 'Hoppa till innehållet')</a>

<header class="site-nav is-solid" data-solid>
  <div class="wrap">
    <a class="brand" href="../index.html">Liam Berg</a>
    <nav aria-label="$(t Main Huvudmeny)">
      <ul class="nav-links">
        <li><a href="../index.html#work" aria-current="true">$(t Work Arbete)</a></li>
        <li class="nav-hide-xs"><a href="../index.html#games">$(t Games Spel)</a></li>
        <li class="nav-wide"><a href="../index.html#youtube">YouTube</a></li>
        <li class="nav-optional"><a href="../index.html#about">$(t About 'Om mig')</a></li>
        <li class="nav-cta"><a href="../index.html#contact">$(t Contact Kontakt)</a></li>
        <li class="nav-lang"><a href="$other" hreflang="$other_lang" lang="$other_lang" aria-label="$other_label">${other_lang^^}</a></li>
      </ul>
    </nav>
  </div>
</header>

<main id="main">
EOF
}

# intro_open "Eyebrow" "Title"
intro_open() {
  cat <<EOF

  <header class="project-head">
    <div class="wrap">
      <a class="back-link" href="../index.html#work">← $(t 'All work' 'Alla arbeten')</a>
      <p class="eyebrow">$1</p>
      <h1 class="project-title">$2</h1>
      <div class="project-intro">
EOF
}

# lede "Paragraph" ["Paragraph" ...]
lede() {
  printf '        <div class="project-lede">\n'
  local p
  for p in "$@"; do printf '          <p>%s</p>\n' "$p"; done
  printf '        </div>\n'
}

# facts "Label" "Value" ["Label" "Value" ...]
facts() {
  printf '        <dl class="facts">\n'
  while [ $# -gt 1 ]; do printf '          <dt>%s</dt><dd>%s</dd>\n' "$1" "$2"; shift 2; done
  printf '        </dl>\n'
}

links_open()  { printf '        <div class="project-links">\n'; }
links_close() { printf '        </div>\n'; }

# link_btn URL "Label" [accent]
link_btn() {
  printf '          <a class="btn btn--sm%s" href="%s" target="_blank" rel="noopener">%s <span class="arrow" aria-hidden="true">↗</span></a>\n' \
    "${3:+ btn--accent}" "$1" "$2"
}
artstation() { link_btn "https://www.artstation.com/artwork/$1" "$(t 'View on ArtStation' 'Visa på ArtStation')"; }
note() { printf '          <p class="project-note">%s</p>\n' "$1"; }

intro_close() {
  cat <<EOF
      </div>
    </div>
  </header>

  <section class="project-body">
    <div class="wrap">
EOF
}

# page_foot PREV_SLUG "Previous title" NEXT_SLUG "Next title"
page_foot() {
  cat <<EOF

    </div>
  </section>

  <nav class="pager" aria-label="$(t 'More projects' 'Fler projekt')">
    <div class="wrap">
      <a href="$1.html"><small>← $(t Previous Föregående)</small><strong>$2</strong></a>
      <a href="$3.html"><small>$(t Next Nästa) →</small><strong>$4</strong></a>
    </div>
  </nav>

</main>

<footer class="site-footer">
  <div class="wrap">
    <span>© 2026 Liam Berg</span>
    <span><a href="mailto:liamberg16@gmail.com">liamberg16@gmail.com</a></span>
  </div>
</footer>

<script src="$R/js/main.js?v=$V" defer></script>
</body>
</html>
EOF
}

# ---------------------------------------------------------------------------
# Media blocks. Files live in assets/work/<slug>/.

_caption() { [ -n "$1" ] && printf '\n          <figcaption>%s</figcaption>' "$1"; }

# img FILE WIDTH HEIGHT "Alt text" ["Caption"] [extra figure class]
# The first image on a page loads right away; the rest load lazily.
img() {
  local file="$1" w="$2" h="$3" alt="$4" cap="${5:-}" cls="${6:-}" loading
  local src="$R/assets/work/$S/$file"
  if [ "$EAGER" = 1 ]; then EAGER=0; loading='fetchpriority="high"'; else loading='loading="lazy" decoding="async"'; fi
  printf '        <figure class="shot%s">\n          <a class="zoom" href="%s"><img src="%s" alt="%s" width="%s" height="%s" %s></a>%s\n        </figure>\n' \
    "${cls:+ $cls}" "$src" "$src" "$alt" "$w" "$h" "$loading" "$(_caption "$cap")"
}

# loop BASENAME WIDTH HEIGHT ["Caption"] [extra figure class]
# Muted clip that plays while it is on screen. Expects BASENAME.mp4 and BASENAME-poster.jpg.
loop() {
  local p="$R/assets/work/$S/$1" cap="${4:-}" cls="${5:-}"
  EAGER=0
  printf '        <figure class="shot%s">\n          <video src="%s.mp4" poster="%s-poster.jpg" width="%s" height="%s" muted loop playsinline preload="none" data-loop></video>%s\n        </figure>\n' \
    "${cls:+ $cls}" "$p" "$p" "$2" "$3" "$(_caption "$cap")"
}

# vid BASENAME WIDTH HEIGHT ["Caption"]   (click to play, with controls)
vid() {
  local p="$R/assets/work/$S/$1" cap="${4:-}"
  EAGER=0
  printf '        <figure class="shot">\n          <video src="%s.mp4" poster="%s-poster.jpg" width="%s" height="%s" controls playsinline preload="none"></video>%s\n        </figure>\n' \
    "$p" "$p" "$2" "$3" "$(_caption "$cap")"
}

# yt THUMBNAIL_FILE VIDEO_ID "Video name" ["Caption"]   (YouTube player loads on click)
yt() {
  local cap="${4:-}"
  printf '        <figure class="shot">\n          <button class="yt-lite" type="button" data-yt="%s" aria-label="%s: %s">\n            <img src="%s/assets/work/%s/%s" alt="" width="1280" height="720" loading="lazy" decoding="async">\n            <span class="yt-play" aria-hidden="true"></span>\n          </button>%s\n        </figure>\n' \
    "$2" "$(t 'Play video' 'Spela video')" "$3" "$R" "$S" "$1" "$(_caption "$cap")"
}

# block "Heading" ["Subheading"]
block() {
  local sub="${2:-}"
  printf '\n      <div class="block-title"><h2>%s</h2>%s</div>\n\n' "$1" "${sub:+<p>$sub</p>}"
}

open_stack() { printf '      <div class="stack">\n'; }
open_grid()  { printf '      <div class="grid%s">\n' "${1:+ $1}"; }
close_div()  { printf '      </div>\n'; }

# ---------------------------------------------------------------------------
# Projects

p_casino() {
  page_head "Casino Environment" \
    "$(t 'A casino room built from optimized modular assets in Blender, Substance Painter and Unreal Engine 5, using only seven materials.' \
         'Ett casinorum byggt av optimerade, modulära assets i Blender, Substance Painter och Unreal Engine 5, med bara sju material.')"
  intro_open "$(t 'Personal project · 2026' 'Eget projekt · 2026')" "Casino Environment"
  lede \
    "$(t 'After playing the new Resident Evil game, I loved the atmosphere of its casino room and wanted to create one of my own.' \
         'Efter att ha spelat det nya Resident Evil-spelet gillade jag stämningen i casinorummet så mycket att jag ville göra ett eget.')" \
    "$(t 'The focus was on optimized, modular assets: the whole scene uses only seven materials. Every model was made in Blender, textured in Substance Painter, then assembled and lit in Unreal Engine 5. UI elements and table graphics were made in Affinity.' \
         'Fokus låg på optimerade, modulära assets: hela scenen använder bara sju material. Alla modeller gjordes i Blender, texturerades i Substance Painter och sattes sedan ihop och ljussattes i Unreal Engine 5. UI-element och grafiken på borden gjordes i Affinity.')" \
    "$(t 'The environment is also released as an asset pack on Fab.' \
         'Miljön finns också som asset pack på Fab.')"
  facts \
    "$(t Type Typ)" "$(t 'Personal project' 'Eget projekt')" \
    "$(t Engine Motor)" "Unreal Engine 5" \
    "$(t Tools Verktyg)" "$(t 'Blender, Substance 3D Painter &amp; Designer, Affinity' 'Blender, Substance 3D Painter och Designer, Affinity')" \
    "$(t Focus Fokus)" "$(t 'Modular kit, material budget, lighting' 'Modulärt kit, materialbudget, ljussättning')" \
    "$(t Release Släpp)" "$(t 'Asset pack on Fab' 'Asset pack på Fab')"
  links_open
  link_btn "https://www.fab.com/listings/900ee715-290c-4f6e-9cac-11f587422f37" "$(t 'View on Fab' 'Visa på Fab')" accent
  artstation V2Pz8b
  note "$(t 'Fab marks the listing as mature content, so you may need to sign in to view it.' \
            'Fab markerar sidan som mature-innehåll, så du kan behöva logga in för att se den.')"
  links_close
  intro_close

  open_stack
  img 01-casino-environment-0001.jpg 1920 1080 "$(t 'Casino hall with a roulette table under a candle chandelier, marble floor and wood-panelled walls' 'Casinosal med ett roulettebord under en ljuskrona, marmorgolv och träpanel på väggarna')"
  img 02-casino-environment-0002.jpg 1920 1080 "$(t 'View through an archway into a private card room with a lattice-patterned wall' 'Vy genom en valvbåge in i ett privat kortrum med rutmönstrad vägg')"
  img 03-casino-environment-0004.jpg 1920 1080 "$(t 'Close-up of two blackjack tables with chip trays' 'Närbild på två blackjackbord med markerbrickor')"
  img 04-casino-environment-0005.jpg 1920 1080 "$(t 'Roulette table with wheel and chip stacks in a dim corner of the casino' 'Roulettebord med hjul och högar av marker i ett mörkt hörn av casinot')"
  img 05-casino-environment-0003.jpg 1920 1080 "$(t 'Wide view of the blackjack area with chandeliers and a knocked-over chair' 'Översikt över blackjackdelen med ljuskronor och en omkullvält stol')"
  loop 06-casino-environment-wheel-0001-0224 1920 1080 "$(t 'Roulette wheel animation' 'Animation av roulettehjulet')"
  close_div

  block "Breakdown" "$(t 'Modular kit, props and wireframes' 'Modulärt kit, props och wireframes')"
  open_stack
  img 07-casino-environment-viewport.jpg 1920 1080 \
    "$(t 'The modular kit laid out: wall panels, pillars, trims, floor tiles, tables, chairs, chandelier and plant' 'Det modulära kitet utlagt: väggpaneler, pelare, lister, golvplattor, bord, stolar, ljuskrona och växt')" \
    "$(t '<b>Modular kit</b> — wall panels, trims, floor tiles and props, textured with wireframe' '<b>Modulärt kit</b> – väggpaneler, lister, golvplattor och props, texturerade med wireframe')"
  close_div
  open_grid
  img 08-casino-environment-viewport2.jpg 1920 1080 "$(t 'Viewport breakdown of the casino assets' 'Breakdown av casinots assets i viewporten')" "$(t 'Viewport breakdown' 'Breakdown i viewporten')"
  img 09-casino-environment-viewport3.jpg 1920 1080 "$(t 'Viewport breakdown of the casino assets' 'Breakdown av casinots assets i viewporten')" "$(t 'Viewport breakdown' 'Breakdown i viewporten')"
  img 11-casino-environment-viewport4.jpg 1920 1080 "$(t 'Viewport breakdown of the casino assets' 'Breakdown av casinots assets i viewporten')" "$(t 'Viewport breakdown' 'Breakdown i viewporten')"
  img 10-chips.webp 1920 1080 "$(t 'Clay render with wireframe of a chip tray on a blackjack table' 'Clay-rendering med wireframe av en markerbricka på ett blackjackbord')" "$(t 'Chip tray, wireframe in Blender' 'Markerbricka, wireframe i Blender')"
  img 12-roulette-chips.webp 1920 1080 "$(t 'Roulette wheel and chip stacks, wireframe' 'Roulettehjul och högar av marker, wireframe')" "$(t 'Roulette wheel and chips, wireframe' 'Roulettehjul och marker, wireframe')"
  img 13-roulette-chips-color.webp 1920 1080 "$(t 'Textured roulette wheel and chip stacks with wireframe overlay' 'Texturerat roulettehjul och marker med wireframe ovanpå')" "$(t 'Roulette wheel and chips, textured' 'Roulettehjul och marker, texturerade')"
  close_div

  page_foot cgi-integration "CGI Integration" project-solar "Project Solar"
}

p_solar() {
  page_head "Project Solar" \
    "$(t 'Environment props and buildings for Project Solar, a stylized solarpunk co-op game by Imperial Playgrounds, made during an environment art internship.' \
         'Props och byggnader till Project Solar, ett stiliserat solarpunk-spel med co-op från Imperial Playgrounds, gjorda under min praktik som environment artist.')"
  intro_open "$(t 'Internship · 2026' 'Praktik · 2026')" "Project Solar"
  lede \
    "$(t 'Environment props and buildings for Project Solar, a stylized solarpunk co-op puzzle adventure by Imperial Playgrounds, coming to Steam.' \
         'Props och byggnader till Project Solar, ett stiliserat solarpunk-äventyr med pussel och co-op från Imperial Playgrounds som kommer till Steam.')" \
    "$(t "During the internship I focused on hard-surface modeling and asset optimization, and built every asset around the project's established trim sheet." \
         'Under praktiken fokuserade jag på hard surface-modellering och optimering, och byggde alla assets utifrån projektets befintliga trim sheet.')"
  facts \
    "$(t Role Roll)" "$(t 'Environment art intern' 'Praktikant, environment art')" \
    "$(t Game Spel)" "$(t 'Project Solar by Imperial Playgrounds' 'Project Solar av Imperial Playgrounds')" \
    "$(t Tools Verktyg)" "Blender, Unreal Engine" \
    "$(t Focus Fokus)" "$(t 'Hard-surface props &amp; buildings, trim sheets, optimization' 'Props och byggnader i hard surface, trim sheets, optimering')"
  links_open
  link_btn "https://store.steampowered.com/app/3071810/Project_Solar/" "$(t 'Wishlist on Steam' 'Önskelista på Steam')" accent
  artstation XJZg3L
  links_close
  intro_close

  open_stack
  img 15-highresscreenshot00016.webp 1873 1185 "$(t 'Two weathered blue solarpunk buildings with rust details on a grassy hill' 'Två slitna blå solarpunk-byggnader med rostdetaljer på en gräsbevuxen kulle')"
  img 25-assets2.webp 1920 1080 "$(t 'Overview of the props and buildings made for Project Solar' 'Översikt över props och byggnader som jag gjorde till Project Solar')" "$(t 'Asset overview' 'Översikt över assets')"
  close_div
  open_grid
  local f n=0
  for f in 01-highresscreenshot00000 02-highresscreenshot00001 03-highresscreenshot00002 04-highresscreenshot00003 \
           05-highresscreenshot00004 06-highresscreenshot00006 07-highresscreenshot00007 08-highresscreenshot00008 \
           09-highresscreenshot00009 10-highresscreenshot00011 11-highresscreenshot00012 12-highresscreenshot00013 \
           13-highresscreenshot00014 14-highresscreenshot00015 16-highresscreenshot00017 17-highresscreenshot00018 \
           18-highresscreenshot00019 19-highresscreenshot00020 20-highresscreenshot00021 21-highresscreenshot00022 \
           22-highresscreenshot00023 23-highresscreenshot00026; do
    n=$((n + 1))
    img "$f.webp" 1873 1185 "$(t "Project Solar in-engine screenshot $n" "Skärmdump från Project Solar i motorn, bild $n")"
  done
  close_div

  block "$(t Details Detaljer)"
  open_stack
  loop 24-elevator-test 1920 2400 "$(t 'Elevator test' 'Hisstest')" "shot--narrow"
  close_div

  page_foot casino-environment "Casino Environment" waterpark-level "Indoor Waterpark"
}

p_waterpark() {
  page_head "Indoor Waterpark" \
    "$(t 'Environment art and level design for an eerie indoor waterpark inspired by Eriksdalsbadet in Stockholm, built in Unreal Engine 5.5.' \
         'Environment art och leveldesign för ett obehagligt inomhusbad inspirerat av Eriksdalsbadet i Stockholm, byggt i Unreal Engine 5.5.')"
  intro_open "$(t 'Final exam project · 2025' 'Examensprojekt · 2025')" "Indoor Waterpark"
  lede \
    "$(t 'A level for my six-week final exam project: an eerie, semi-realistic indoor waterpark inspired by Eriksdalsbadet in Stockholm.' \
         'En bana till mitt sex veckor långa examensprojekt: ett obehagligt, halvrealistiskt inomhusbad inspirerat av Eriksdalsbadet i Stockholm.')" \
    "$(t "It's a first-person exploration game where the player searches the environment for a hidden code that unlocks the exit. My focus was environment design, procedural modeling and simulations." \
         'Det är ett utforskningsspel i förstaperson där spelaren letar efter en gömd kod i miljön för att låsa upp utgången. Mitt fokus låg på miljödesign, procedurell modellering och simuleringar.')"
  facts \
    "$(t Role Roll)" "$(t 'Environment art &amp; level design' 'Environment art och leveldesign')" \
    "$(t Engine Motor)" "Unreal Engine 5.5" \
    "$(t Tools Verktyg)" "$(t 'Blender, Substance 3D Designer (tiling materials), Substance 3D Painter (unique props)' 'Blender, Substance 3D Designer (tiling-material), Substance 3D Painter (unika props)')" \
    "$(t Length Längd)" "$(t '6 weeks' '6 veckor')"
  links_open
  artstation WX6KD2
  links_close
  intro_close

  local shot
  shot="$(t 'Indoor waterpark screenshot' 'Skärmdump från inomhusbadet')"
  open_stack
  img 02-highresscreenshot00000.webp 1587 893 "$(t 'Indoor waterpark in the dark, lit by blue lights along a winding water slide' 'Inomhusbadet i mörker, upplyst av blå lampor längs en slingrande vattenrutschkana')"
  img 03-highresscreenshot00001.webp 1587 893 "$shot"
  close_div
  open_grid
  img 05-highresscreenshot00002.webp 1587 893 "$shot"
  img 08-highresscreenshot00005.webp 1587 893 "$shot"
  img 10-highresscreenshot00003.webp 1587 893 "$shot"
  img 11-highresscreenshot00004.webp 1587 893 "$shot"
  img 04-highresscreenshot00009.webp 1587 1146 "$shot"
  img 06-highresscreenshot00008.webp 1587 1146 "$shot"
  img 07-highresscreenshot00006.webp 1587 1146 "$shot"
  img 09-highresscreenshot00007.webp 1587 1146 "$shot"
  close_div

  block "Gameplay"
  open_stack
  yt 13-youtube-4fAlrEE-0FU.jpg 4fAlrEE-0FU "Indoor Waterpark gameplay" "$(t 'Gameplay walkthrough (work in progress)' 'Genomspelning (pågående arbete)')"
  close_div

  block "Breakdown" "$(t 'Reference, procedural modeling and simulation' 'Referens, procedurell modellering och simulering')"
  open_grid
  img 01-reference-waterpark.jpg 908 1167 "$(t 'Reference photos of a waterpark' 'Referensbilder från ett badhus')" "$(t Reference Referens)"
  printf '        <div class="stack">\n'
  loop 16-waterslide-3600001-0350 1920 1080 "$(t 'Water slide' 'Vattenrutschkana')"
  loop 18-ballpitsimulation 1920 1080 "$(t 'Ball pit simulation' 'Simulering av bollhav')"
  printf '        </div>\n'
  close_div
  open_stack
  vid 17-procedural-waterslide 1920 1080 "$(t 'Procedural water slide' 'Procedurell vattenrutschkana')"
  close_div
  open_grid grid--3
  loop 12-fx-light 1920 1080 "$(t 'FX: flickering light' 'FX: flimrande lampa')"
  loop 14-fx-waterdrop 1920 1080 "$(t 'FX: water dripping from the slide' 'FX: vatten som droppar från rutschkanan')"
  loop 15-fx-waterslide 1920 1080 "$(t 'FX: running water' 'FX: rinnande vatten')"
  close_div

  page_foot project-solar "Project Solar" souls-like-level "Souls-like Level"
}

p_souls() {
  page_head "Souls-like Level" \
    "$(t 'A dark fantasy game level inspired by Dark Souls, built in Unity with trim sheets and optimized modular assets.' \
         'En dark fantasy-bana inspirerad av Dark Souls, byggd i Unity med trim sheets och optimerade, modulära assets.')"
  intro_open "$(t 'Game project · 2025' 'Spelprojekt · 2025')" "Souls-like Level"
  lede \
    "$(t 'A dark fantasy game level inspired by games like Dark Souls. It was my first time working in Unity, creating optimized assets and using trim sheets, and I also explored Substance Designer for material creation.' \
         'En dark fantasy-bana inspirerad av spel som Dark Souls. Det var första gången jag jobbade i Unity, gjorde optimerade assets och använde trim sheets, och jag testade också Substance Designer för att skapa material.')" \
    "$(t 'The project took three to four weeks over Christmas and New Year, and taught me a lot about asset management, Unity workflows and Git.' \
         'Projektet tog tre till fyra veckor över jul och nyår och lärde mig mycket om asset management, arbetsflöden i Unity och Git.')"
  facts \
    "$(t Engine Motor)" "Unity" \
    "$(t Tools Verktyg)" "Blender, Substance 3D Designer" \
    "$(t Length Längd)" "$(t '3–4 weeks' '3–4 veckor')" \
    "$(t Focus Fokus)" "$(t 'Modular assets, trim sheets, level design' 'Modulära assets, trim sheets, leveldesign')"
  links_open
  artstation nJ6La4
  links_close
  intro_close

  open_stack
  img 01-recorderclip-003-0000.jpg 1920 1080 "$(t 'Gothic cathedral at the end of a stone bridge between snowy cliffs at night' 'Gotisk katedral i slutet av en stenbro mellan snöiga klippor på natten')"
  close_div
  open_grid
  yt 02-youtube-ZT87ZAhZ9Xc.jpg ZT87ZAhZ9Xc "Souls-like Level showreel" "Showreel"
  yt 03-youtube-iFakPQWga5k.jpg iFakPQWga5k "Souls-like Level gameplay" "Gameplay"
  close_div

  block "Breakdown" "$(t 'From blockout to final scene' 'Från blockout till färdig scen')"
  open_stack
  vid 04-breakdown 1920 1080 "$(t 'Breakdown in Unity' 'Breakdown i Unity')"
  close_div
  open_grid grid--3
  img 05-bridge-1.jpg 1920 1080 "$(t 'Early blockout of the bridge in Blender' 'Tidig blockout av bron i Blender')" "$(t 'Bridge blockout in Blender' 'Blockout av bron i Blender')"
  img 06-church-1.jpg 1920 1080 "$(t 'Early blockout of the church in Blender' 'Tidig blockout av kyrkan i Blender')" "$(t 'Church blockout in Blender' 'Blockout av kyrkan i Blender')"
  img 07-church-2.jpg 1920 1080 "$(t 'Early blockout of the church in Blender' 'Tidig blockout av kyrkan i Blender')" "$(t 'Church blockout in Blender' 'Blockout av kyrkan i Blender')"
  img 09-churchfirst.jpg 1920 1080 "$(t 'First version of the church' 'Första versionen av kyrkan')" "$(t 'Church, version 1' 'Kyrkan, version 1')"
  img 10-churchfirst2.jpg 1920 1080 "$(t 'Second version of the church' 'Andra versionen av kyrkan')" "$(t 'Church, version 2' 'Kyrkan, version 2')"
  img 11-chuch.jpg 1920 1080 "$(t 'Third version of the church' 'Tredje versionen av kyrkan')" "$(t 'Church, version 3' 'Kyrkan, version 3')"
  close_div
  open_stack
  img 08-image-sequence-001-0000.jpg 1920 1080 "$(t "The level's first import into Unity" 'Banans första import till Unity')" "$(t 'First import into Unity' 'Första importen till Unity')"
  close_div

  block "$(t Church Kyrkan)"
  open_grid grid--3
  img 14-churchfinal.jpg 1920 1080 "$(t 'Final church model' 'Färdig modell av kyrkan')" "$(t 'Church — 71,352 triangles' 'Kyrkan – 71&nbsp;352 trianglar')"
  img 12-church-wireframe.jpg 1920 1080 "$(t 'Wireframe of the church kit pieces' 'Wireframe av delarna i kyrkans kit')" "$(t 'Church kit wireframe — 5,754 triangles' 'Kyrkans kit, wireframe – 5&nbsp;754 trianglar')"
  img 13-church.jpg 1920 1080 "$(t 'Textured church kit pieces' 'Texturerade delar i kyrkans kit')" "$(t 'Church kit, textured' 'Kyrkans kit, texturerat')"
  close_div

  block "$(t Bridge Bron)"
  open_grid grid--3
  img 17-churchversions.jpg 1920 1080 "$(t 'Bridge variations and the final bridge' 'Varianter av bron och den färdiga bron')" "$(t 'Variations and final bridge — 42,382 triangles' 'Varianter och färdig bro – 42&nbsp;382 trianglar')"
  img 15-bridgewireframe.jpg 1920 1080 "$(t 'Wireframe of the bridge kit pieces' 'Wireframe av delarna i brons kit')" "$(t 'Bridge kit wireframe — 10,384 triangles' 'Brons kit, wireframe – 10&nbsp;384 trianglar')"
  img 16-bridgestair.jpg 1920 1080 "$(t 'Textured bridge and stair pieces' 'Texturerade delar till bro och trappa')" "$(t 'Bridge kit, textured' 'Brons kit, texturerat')"
  close_div

  block "Dungeon"
  open_grid grid--3
  img 22-startingareaevery.jpg 1920 1080 "$(t 'The assembled dungeon starting area' 'Startområdet i dungeon-delen, ihopsatt')" "$(t 'Dungeon scene — 120,205 triangles' 'Dungeon-scenen – 120&nbsp;205 trianglar')"
  img 20-startingarea-wireframe.jpg 1920 1080 "$(t 'Wireframe of the dungeon kit pieces' 'Wireframe av delarna i dungeon-kitet')" "$(t 'Dungeon kit wireframe — 34,665 triangles' 'Dungeon-kitet, wireframe – 34&nbsp;665 trianglar')"
  img 21-startingarea.jpg 1920 1080 "$(t 'Textured dungeon kit pieces' 'Texturerade delar i dungeon-kitet')" "$(t 'Dungeon kit, textured' 'Dungeon-kitet, texturerat')"
  close_div

  block "$(t Technical Teknik)" "$(t 'Trim sheets, effects and setup in Unity' 'Trim sheets, effekter och uppsättning i Unity')"
  open_grid
  img 24-image-2025-01-09-192017050.jpg 1211 1157 "$(t 'Four trim sheets used across the level' 'Fyra trim sheets som används i hela banan')" "$(t 'Four trim sheets used for everything' 'Fyra trim sheets som används till allt')"
  img 23-image-2025-01-09-192823691.jpg 1807 1334 "$(t 'Fog particle system settings in Unity' 'Inställningar för dimpartiklar i Unity')" "$(t 'Fog particle system in Unity' 'Partikelsystem för dimma i Unity')"
  img 18-image-2025-01-09-192536273.jpg 1522 1041 "$(t 'Unity project folder structure and barrel collision setup' 'Mappstruktur i Unity-projektet och kollision för tunnor')" "$(t 'Folder structure and barrel collision in Unity' 'Mappstruktur och kollision för tunnor i Unity')"
  loop 19-barreldestroy-0001-0200 1920 1080 "$(t 'Breakable barrel' 'Tunna som går sönder')"
  close_div

  page_foot waterpark-level "Indoor Waterpark" winter-road "Winter Road"
}

p_winter() {
  page_head "Winter Road" \
    "$(t 'Environment modeling, Niagara effects and procedural power lines built with Blueprints for a stylized winter game scene in Unreal Engine.' \
         'Miljömodellering, Niagara-effekter och procedurella elledningar byggda med Blueprints för en stiliserad vinterscen i Unreal Engine.')"
  intro_open "$(t 'Game project · 2025' 'Spelprojekt · 2025')" "Winter Road"
  lede \
    "$(t 'A stylized, snowbound game scene where my main focus was modeling the environment assets.' \
         'En stiliserad, snöig spelscen där mitt huvudfokus var att modellera miljöns assets.')" \
    "$(t 'I also contributed to the game with smaller effects in Niagara and procedural power lines built with Blueprints, which let me grow on both the artistic and the technical side.' \
         'Jag bidrog också till spelet med mindre effekter i Niagara och procedurella elledningar byggda med Blueprints, vilket lät mig utvecklas både konstnärligt och tekniskt.')"
  facts \
    "$(t Engine Motor)" "Unreal Engine" \
    "$(t Tools Verktyg)" "Blender, Substance 3D Painter" \
    "$(t Focus Fokus)" "$(t 'Environment modeling, Niagara FX, Blueprints' 'Miljömodellering, Niagara-effekter, Blueprints')"
  links_open
  artstation BkVNWA
  links_close
  intro_close

  open_stack
  img 02-rox.jpg 1848 1038 "$(t 'Stylized snowy forest road at night with a fallen power line and a street light' 'Stiliserad snöig skogsväg på natten med en nedfallen elledning och en gatlykta')"
  close_div
  open_grid
  img 01-highress.jpg 1183 888 "$(t 'Snowy roadside at night with a stop sign, electrical cabinets and a bench' 'Snöig vägkant på natten med en stoppskylt, elskåp och en bänk')"
  loop 03-car-scene-v001 1920 1080 "$(t 'Car scene' 'Bilscen')"
  close_div

  block "Breakdown" "$(t 'Blueprints, effects and assets' 'Blueprints, effekter och assets')"
  open_grid
  vid 04-proceduralblueprint 1920 1080 "$(t 'Procedural power lines built with Blueprints' 'Procedurella elledningar byggda med Blueprints')"
  loop 05-fx-sparks 1920 1080 "$(t 'Spark effect in Niagara' 'Gnisteffekt i Niagara')"
  close_div
  open_stack
  img 09-assets.jpg 1920 1080 "$(t 'All the environment assets made for the scene' 'Alla miljö-assets som jag gjorde till scenen')" "$(t 'All assets I made' 'Alla assets jag gjorde')"
  close_div
  open_grid grid--3
  img 06-barrel.jpg 1164 440 "$(t 'Textured barrel assets' 'Texturerade tunnor')" "$(t 'Textured assets' 'Texturerade assets')"
  img 07-electric.jpg 749 441 "$(t 'Textured electrical cabinet assets' 'Texturerade elskåp')" "$(t 'Textured assets' 'Texturerade assets')"
  img 08-pole.jpg 856 548 "$(t 'Textured power line pole' 'Texturerad elstolpe')" "$(t 'Power line pole' 'Elstolpe')"
  close_div

  page_foot souls-like-level "Souls-like Level" cyberpunk-music-video "Cyberpunk Music Video"
}

p_cyberpunk() {
  page_head "Cyberpunk Music Video" \
    "$(t 'A three-week group project: a stylized cyberpunk music video. Modeling, texturing, lighting and set dressing of the apartment, rooftop and bus station.' \
         'Ett grupprojekt på tre veckor: en stiliserad cyberpunk-musikvideo. Modellering, texturering, ljussättning och set dressing av lägenheten, taket och busshållplatsen.')"
  intro_open "$(t 'Group project · 2025' 'Grupprojekt · 2025')" "Stylized Cyberpunk Music Video"
  lede \
    "$(t 'A three-week group project where we made a stylized music video inspired by cyberpunk visuals and atmosphere.' \
         'Ett grupprojekt på tre veckor där vi gjorde en stiliserad musikvideo inspirerad av cyberpunkens estetik och stämning.')" \
    "$(t 'I modeled and textured assets, lit several scenes and set-dressed the apartment, rooftop and bus station. I also contributed to material creation, a small amount of animation (a liquid time-lapse) and simulated the broken bottle.' \
         'Jag modellerade och texturerade assets, ljussatte flera scener och gjorde set dressing av lägenheten, taket och busshållplatsen. Jag bidrog också med material, lite animation (en time-lapse med vätska) och simulerade flaskan som går sönder.')"
  facts \
    "$(t Role Roll)" "$(t 'Modeling, texturing, lighting, set dressing' 'Modellering, texturering, ljussättning, set dressing')" \
    "$(t Tools Verktyg)" "Blender, Substance 3D Painter" \
    "Team" "$(t 'Group project, 3 weeks' 'Grupprojekt, 3 veckor')"
  links_open
  artstation XJzmoL
  links_close
  intro_close

  open_stack
  img 01-newest.jpg 1920 1080 "$(t 'Cyberpunk apartment with neon ring lights, a red couch, a pizza box and moving boxes' 'Cyberpunk-lägenhet med neonringar i taket, en röd soffa, en pizzakartong och flyttkartonger')"
  img 02-glassview.jpg 1920 1080 "$(t 'Cyberpunk music video still' 'Stillbild från cyberpunk-musikvideon')"
  img 03-last-bs9.jpg 1920 1080 "$(t 'Cyberpunk music video still' 'Stillbild från cyberpunk-musikvideon')"
  close_div

  block "Breakdown" "$(t 'Set dressing progression and assets' 'Set dressing steg för steg och assets')"
  open_grid
  loop 07-ap-progression 1920 1096 "$(t 'Apartment progression' 'Lägenheten steg för steg')"
  loop 08-rf-progression-v002 1920 1092 "$(t 'City progression' 'Staden steg för steg')"
  close_div
  open_stack
  img 04-apt-assets-min.jpg 1920 1080 "$(t 'Apartment assets' 'Assets till lägenheten')" "$(t 'Apartment assets — modeling &amp; texturing' 'Assets till lägenheten – modellering och texturering')"
  close_div
  open_grid
  img 05-couch.jpg 1920 1080 "$(t 'Couch asset' 'Soffa')" "$(t 'Couch — modeling &amp; texturing' 'Soffa – modellering och texturering')"
  img 06-city-assets.jpg 1920 1080 "$(t 'City assets' 'Assets till staden')" "$(t 'City assets — modeling &amp; texturing' 'Assets till staden – modellering och texturering')"
  close_div
  open_stack
  img 09-objecsts.jpg 1218 728 "$(t 'City props' 'Props till staden')" "$(t 'City props — modeling &amp; texturing' 'Props till staden – modellering och texturering')" "shot--narrow"
  close_div

  page_foot winter-road "Winter Road" death-of-an-explorer "The Death of an Explorer"
}

p_explorer() {
  page_head "The Death of an Explorer" \
    "$(t 'A collaborative trailer for a short film: modeling, texturing and set dressing of detailed props and atmospheric environments.' \
         'En trailer till en kortfilm som vi gjorde i grupp: modellering, texturering och set dressing av detaljerade props och stämningsfulla miljöer.')"
  intro_open "$(t 'Group project · 2024' 'Grupprojekt · 2024')" "The Death of an Explorer"
  lede \
    "$(t 'A collaborative school project to create a trailer for a short film.' \
         'Ett grupprojekt i skolan där vi gjorde en trailer till en kortfilm.')" \
    "$(t 'My main roles were modeling, texturing and set dressing, focusing on detailed props and atmospheric environments that support the story.' \
         'Mina huvuduppgifter var modellering, texturering och set dressing, med fokus på detaljerade props och stämningsfulla miljöer som stöttar berättelsen.')"
  facts \
    "$(t Role Roll)" "$(t 'Modeling, texturing, set dressing' 'Modellering, texturering, set dressing')" \
    "$(t Tools Verktyg)" "Blender, Unreal Engine, Substance 3D Painter" \
    "Team" "$(t 'School group project' 'Grupprojekt i skolan')"
  links_open
  artstation bgrk8d
  links_close
  intro_close

  open_stack
  vid 01-anadventuredeath-2 1920 1080 "Trailer"
  close_div

  block "$(t Pre-production Förproduktion)"
  open_grid
  img 02-moodboard.jpg 1312 644 "$(t 'Mood and lighting board' 'Moodboard för stämning och ljus')" "$(t 'Mood and light board' 'Moodboard för stämning och ljus')"
  img 03-ref.jpg 1287 591 "$(t 'Reference images' 'Referensbilder')" "$(t Reference Referenser)"
  close_div

  block "Assets" "$(t 'Modular buildings and props' 'Modulära byggnader och props')"
  open_grid grid--3
  loop 04-house-10001-0200 1920 1080 "$(t 'Modular house' 'Modulärt hus')"
  loop 05-asset0001-0310 1920 1080 "$(t 'Prop turntable' 'Turntable av en prop')"
  loop 06-candle0001-0200 1920 1080 "$(t Candle Ljus)"
  loop 07-candlelabra0001-0200 1920 1080 "$(t Candelabra Kandelaber)"
  loop 08-bread0001-0120 1920 1080 "$(t Bread Bröd)"
  loop 09-ropepulley0001-0200 1920 1080 "$(t 'Rope pulley system' 'Block och talja med rep')"
  close_div

  block "$(t Materials Material)" "$(t 'Ship interior' 'Skeppets interiör')"
  open_grid grid--3
  img 10-candlefire.jpg 414 408 "$(t 'Candle fire material' 'Material för ljuslåga')" "$(t 'Candle fire material' 'Material för ljuslåga')"
  img 11-candlematerial.jpg 1198 575 "$(t 'Node graph for the candle fire material' 'Nodträd för ljuslågans material')" "$(t 'Candle fire material nodes' 'Noder för ljuslågans material')"
  img 12-glassmaterial.jpg 1155 633 "$(t 'Glass material' 'Glasmaterial')" "$(t 'Glass material' 'Glasmaterial')"
  close_div

  page_foot cyberpunk-music-video "Cyberpunk Music Video" procedural-logo-intro "Procedural Logo Intro"
}

p_logo() {
  page_head "Procedural Logo Intro" \
    "$(t 'A fully procedural movie-studio-style logo intro in Houdini, using RBD destruction, Vellum grain simulation and a USD workflow.' \
         'Ett helt procedurellt logga-intro i filmbolagsstil i Houdini, med RBD-destruktion, Vellum grain-simulering och ett USD-arbetsflöde.')"
  intro_open "$(t 'Houdini course · 2025' 'Houdinikurs · 2025')" "Procedural Logo Intro"
  lede \
    "$(t 'My final project for a Houdini course: a movie-studio-style intro where objects spill out of a cup and seamlessly transition into the Visual Magic logo.' \
         'Mitt slutprojekt i en Houdinikurs: ett intro i filmbolagsstil där föremål väller ut ur en kopp och smidigt övergår i Visual Magics logga.')" \
    "$(t 'The setup is fully procedural, so both the objects and the logo can easily be swapped. The project explores procedural modeling, RBD destruction, Vellum grain simulation and a USD workflow.' \
         'Upplägget är helt procedurellt, så både föremålen och loggan går lätt att byta ut. Projektet utforskar procedurell modellering, RBD-destruktion, Vellum grain-simulering och ett USD-arbetsflöde.')"
  facts \
    "$(t Tools Verktyg)" "Houdini" \
    "$(t Focus Fokus)" "$(t 'Procedural setup, RBD, Vellum grains, USD' 'Procedurellt upplägg, RBD, Vellum grains, USD')"
  links_open
  artstation K3LQD9
  links_close
  intro_close

  open_stack
  vid 01-intro-video-liam-berg 1920 1080
  close_div

  block "Breakdown"
  open_grid
  loop 02-breakingcupsim 1920 1080 "$(t 'Breaking cup simulation' 'Simulering av en kopp som går sönder')"
  loop 03-grainsim 1920 1080 "$(t 'Vellum grain simulation' 'Vellum grain-simulering')"
  close_div
  open_grid grid--3
  img 04-sceneviewport.jpg 862 644 "$(t 'Houdini scene layout' 'Scenens upplägg i Houdini')" "$(t 'Houdini scene layout' 'Scenens upplägg i Houdini')"
  img 05-objects.jpg 1099 993 "$(t 'Simulated objects' 'Simulerade föremål')" "$(t 'Simulated objects' 'Simulerade föremål')"
  img 06-capture.jpg 1483 625 "$(t 'Objects used in the simulation' 'Föremål som används i simuleringen')" "$(t Objects Föremål)"
  close_div

  page_foot death-of-an-explorer "The Death of an Explorer" houdini-simulation "Houdini Simulation"
}

p_houdini() {
  page_head "Houdini Simulation" \
    "$(t 'Vellum and particle simulations in Houdini, composited in Nuke: bouncy balls guided by a magical trail through the streets of San Francisco.' \
         'Vellum- och partikelsimuleringar i Houdini, kompositerade i Nuke: studsbollar som leds av ett magiskt spår genom San Franciscos gator.')"
  intro_open "$(t 'School assignment · 2024' 'Skoluppgift · 2024')" "Houdini Simulation"
  lede \
    "$(t 'The task was to create a piece in Houdini that uses at least two different simulations.' \
         'Uppgiften var att skapa ett verk i Houdini som använder minst två olika simuleringar.')" \
    "$(t 'I used a Vellum cloth simulation for the bouncy balls, and a particle simulation for the magical trail that guides them through the streets of San Francisco. The background is a photo sourced online, composited with the render in Nuke.' \
         'Jag använde en Vellum-simulering av tyg för studsbollarna och en partikelsimulering för det magiska spåret som leder dem genom San Franciscos gator. Bakgrunden är ett foto från nätet som jag kompositerade ihop med renderingen i Nuke.')"
  facts \
    "$(t Tools Verktyg)" "Houdini, Nuke" \
    "$(t Focus Fokus)" "$(t 'Vellum, particles, compositing' 'Vellum, partiklar, compositing')"
  links_open
  artstation x3qGeW
  links_close
  intro_close

  open_stack
  vid 01-bouncyballs2-1 1920 1080
  close_div

  block "Breakdown" "$(t 'Houdini and Nuke setup' 'Uppsättning i Houdini och Nuke')"
  open_grid
  img 02-viewportsim.jpg 996 618 "$(t 'Simulation in the Houdini viewport' 'Simuleringen i Houdinis viewport')" "$(t 'Viewport in Houdini' 'Viewport i Houdini')"
  img 03-nuke.jpg 834 709 "$(t 'Nuke compositing node graph' 'Nodträd för compositing i Nuke')" "$(t 'Nuke nodes' 'Noder i Nuke')"
  close_div
  open_grid grid--3
  img 05-node-balls.jpg 1202 1046 "$(t 'Houdini nodes for the bouncy ball Vellum simulation' 'Noder i Houdini för Vellum-simuleringen av studsbollarna')" "$(t 'Bouncy balls — Vellum simulation' 'Studsbollar – Vellum-simulering')"
  img 06-node-particleline.jpg 718 1016 "$(t 'Houdini nodes for the particle trail' 'Noder i Houdini för partikelspåret')" "$(t 'Particle simulation' 'Partikelsimulering')"
  img 04-render.jpg 571 994 "$(t 'Houdini render nodes' 'Rendernoder i Houdini')" "$(t 'Render nodes' 'Rendernoder')"
  close_div

  page_foot procedural-logo-intro "Procedural Logo Intro" cgi-integration "CGI Integration"
}

p_cgi() {
  page_head "CGI Integration" \
    "$(t 'Integrating a photorealistic 3D model into live-action footage: marker cleanup, 3D camera tracking and compositing in Nuke.' \
         'En fotorealistisk 3D-modell integrerad i filmat material: borttagning av markörer, 3D-kameratrackning och compositing i Nuke.')"
  intro_open "$(t 'School assignment · 2024' 'Skoluppgift · 2024')" "CGI Integration"
  lede \
    "$(t 'An assignment about combining 3D with live-action footage.' \
         'En uppgift om att kombinera 3D med filmat material.')" \
    "$(t 'The first part was cleaning up the footage by removing tracking markers and solving a 3D camera track. The second part was creating a photorealistic 3D model and integrating it into the shot, finished with compositing in Nuke.' \
         'Första delen var att städa upp materialet genom att ta bort trackingmarkörer och göra en 3D-kameratrackning. Andra delen var att skapa en fotorealistisk 3D-modell och integrera den i klippet, med compositing i Nuke som sista steg.')"
  facts \
    "$(t Tools Verktyg)" "Blender, Substance 3D Painter, Nuke" \
    "$(t Focus Fokus)" "$(t 'Cleanup, camera tracking, look development, compositing' 'Städning av material, kameratrackning, look development, compositing')"
  links_open
  artstation L4kBOK
  links_close
  intro_close

  open_stack
  loop 01-liam-berg-composition-v001 1920 1080 "$(t 'Final composite' 'Färdig komposit')"
  close_div

  block "Breakdown"
  open_grid
  loop 02-liam-berg-render-flat-v001-mp4 1920 1080 "$(t 'Render, untextured' 'Rendering utan texturer')"
  loop 03-liam-berg-render-textured-v001-mp4 1920 1080 "$(t 'Render, textured' 'Rendering med texturer')"
  close_div
  open_stack
  loop 04-breakdown1 1920 1080 "$(t 'Shot breakdown' 'Breakdown av klippet')"
  img 05-nodes.jpg 1342 1035 "$(t 'Node setup for the shot' 'Noduppsättning för klippet')" "$(t 'Node setup' 'Noduppsättning')" "shot--narrow"
  close_div

  page_foot houdini-simulation "Houdini Simulation" casino-environment "Casino Environment"
}

# ---------------------------------------------------------------------------

for L in en sv; do
  if [ "$L" = sv ]; then OUT=sv/work; R=../..; else OUT=work; R=..; fi
  mkdir -p "$OUT"
  for entry in casino-environment:p_casino project-solar:p_solar waterpark-level:p_waterpark \
               souls-like-level:p_souls winter-road:p_winter cyberpunk-music-video:p_cyberpunk \
               death-of-an-explorer:p_explorer procedural-logo-intro:p_logo houdini-simulation:p_houdini \
               cgi-integration:p_cgi; do
    S="${entry%%:*}"
    { "${entry##*:}"; } > "$OUT/$S.html"
  done
done

echo "Built $(ls work/*.html | wc -l) English and $(ls sv/work/*.html | wc -l) Swedish project pages."
