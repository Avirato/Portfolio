// Small progressive enhancements. Every page works without this file.
(function () {
  'use strict';

  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // Solid nav background once the page is scrolled (project pages start solid).
  var nav = document.querySelector('.site-nav');
  if (nav && !nav.hasAttribute('data-solid')) {
    var onScroll = function () { nav.classList.toggle('is-solid', window.scrollY > 24); };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  // YouTube: swap the thumbnail for the real player only when clicked.
  document.querySelectorAll('.yt-lite[data-yt]').forEach(function (button) {
    button.addEventListener('click', function () {
      if (button.classList.contains('is-playing')) return;
      var id = button.getAttribute('data-yt');
      var iframe = document.createElement('iframe');
      iframe.src = 'https://www.youtube-nocookie.com/embed/' + id + '?autoplay=1&rel=0&playsinline=1';
      iframe.title = button.getAttribute('aria-label') || 'YouTube video';
      iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen';
      iframe.allowFullscreen = true;
      button.appendChild(iframe);
      button.classList.add('is-playing');
    });
  });

  // Looping clips play while on screen and pause when scrolled away.
  var loops = document.querySelectorAll('video[data-loop]');
  if (reduceMotion) {
    loops.forEach(function (video) { video.controls = true; });
  } else if ('IntersectionObserver' in window) {
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        var video = entry.target;
        if (entry.isIntersecting) {
          video.preload = 'auto';
          var playing = video.play();
          if (playing && playing.catch) playing.catch(function () { video.controls = true; });
        } else {
          video.pause();
        }
      });
    }, { threshold: 0.35 });
    loops.forEach(function (video) { observer.observe(video); });
  } else {
    loops.forEach(function (video) { video.controls = true; });
  }

  // Lightbox for full-size images.
  var zoomLinks = document.querySelectorAll('a.zoom');
  if (!zoomLinks.length) return;

  var box = document.createElement('div');
  box.className = 'lightbox';
  box.setAttribute('role', 'dialog');
  box.setAttribute('aria-modal', 'true');
  box.setAttribute('aria-label', 'Image viewer');
  box.innerHTML = '<img alt=""><button class="lightbox-close" type="button" aria-label="Close">&times;</button>';
  document.body.appendChild(box);

  var boxImg = box.querySelector('img');
  var closeBtn = box.querySelector('.lightbox-close');
  var lastFocus = null;

  function open(link) {
    var thumb = link.querySelector('img');
    boxImg.src = link.getAttribute('href');
    boxImg.alt = thumb ? thumb.alt : '';
    lastFocus = link;
    box.classList.add('is-open');
    document.documentElement.style.overflow = 'hidden';
    void box.offsetWidth; // apply the open styles before moving focus
    closeBtn.focus();
  }

  function close() {
    box.classList.remove('is-open');
    document.documentElement.style.overflow = '';
    if (lastFocus) lastFocus.focus();
  }

  zoomLinks.forEach(function (link) {
    link.addEventListener('click', function (event) {
      if (event.metaKey || event.ctrlKey || event.shiftKey) return;
      event.preventDefault();
      open(link);
    });
  });

  box.addEventListener('click', close);
  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' && box.classList.contains('is-open')) close();
  });
})();
