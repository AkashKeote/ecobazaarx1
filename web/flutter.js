// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is used to load the Flutter engine and initialize the app.
// It is loaded by the index.html file.

(function() {
  "use strict";
  
  // Flutter web entry point
  var serviceWorkerVersion = null;
  var scriptLoaded = false;
  
  function loadMainDartJs() {
    if (scriptLoaded) {
      return;
    }
    scriptLoaded = true;
    var scriptTag = document.createElement('script');
    scriptTag.src = 'main.dart.js';
    scriptTag.type = 'application/javascript';
    document.head.appendChild(scriptTag);
  }

  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      var serviceWorkerUrl = 'flutter_service_worker.js?v=' + serviceWorkerVersion;
      navigator.serviceWorker.register(serviceWorkerUrl)
        .then((reg) => {
          function waitForActivation(serviceWorker) {
            serviceWorker.addEventListener('statechange', () => {
              if (serviceWorker.state == 'activated') {
                console.log('Installed new service worker.');
                loadMainDartJs();
              }
            });
          }
          if (!reg.active && (reg.installing || reg.waiting)) {
            var serviceWorker = reg.installing || reg.waiting;
            waitForActivation(serviceWorker);
            return;
          }
          if (!reg.active) {
            loadMainDartJs();
            return;
          }
          loadMainDartJs();
        });

      // If service worker doesn't succeed in a reasonable time, fallback to
      // plain <script> tag.
      setTimeout(() => {
        if (!scriptLoaded) {
          console.warn(
            'Failed to load app from service worker. '
            + 'Falling back to plain <script> tag.',
          );
          loadMainDartJs();
        }
      }, 4000);
    });
  } else {
    // Service workers not supported. Just drop the <script> tag.
    loadMainDartJs();
  }
})();
