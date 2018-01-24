mapboxgl.accessToken = 'pk.eyJ1IjoiYmVnaW5vciIsImEiOiJjaXQyZmQ1M24wMGIzMnlwZDhqZG5heGIyIn0.cS4xQ_IUfmYUBHdt7i9qqg';

var map = new mapboxgl.Map({
    attributionControl: false,
    style: 'mapbox://styles/mapbox/light-v9',
    center: {
        lng: 113.307649675,
        lat: 23.1200491021
    },
    zoom: 15,
    pitch: 55,
    container: 'map'
});

map.addControl(new mapboxgl.NavigationControl(), 'top-left');
map.addControl(new mapboxgl.GeolocateControl(), 'top-left');
map.addControl(new mapboxgl.FullscreenControl(), 'top-right');
map.addControl(new mapboxgl.ScaleControl(), 'bottom-left');

map.on('load', function() {
    var bins = 16;
    var maxHeight = 200;
    var binWidth = maxHeight / bins;

    // Divide the buildings into 16 bins based on their true height, using a layer filter.
    for (var i = 0; i < bins; i++) {
        map.addLayer({
            'id': '3d-buildings-' + i,
            'source': 'composite',
            'source-layer': 'building',
            'filter': ['all', ['==', 'extrude', 'true'], ['>', 'height', i * binWidth], ['<=', 'height', (i + 1) * binWidth]],
            'type': 'fill-extrusion',
            'minzoom': 15,
            'paint': {
                'fill-extrusion-color': '#aaa',
                'fill-extrusion-height-transition': {
                    duration: 0,
                    delay: 0
                },
                'fill-extrusion-opacity': .6
            }
        });
    }

    // Older browsers might not implement mediaDevices at all, so we set an empty object first
    if (navigator.mediaDevices === undefined) {
        navigator.mediaDevices = {};
    }

    // Some browsers partially implement mediaDevices. We can't just assign an object
    // with getUserMedia as it would overwrite existing properties.
    // Here, we will just add the getUserMedia property if it's missing.
    if (navigator.mediaDevices.getUserMedia === undefined) {
        navigator.mediaDevices.getUserMedia = function (constraints) {

            // First get ahold of the legacy getUserMedia, if present
            var getUserMedia = navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

            // Some browsers just don't implement it - return a rejected promise with an error
            // to keep a consistent interface
            if (!getUserMedia) {
                return Promise.reject(new Error('getUserMedia is not implemented in this browser'));
            }

            // Otherwise, wrap the call to the old navigator.getUserMedia with a Promise
            return new Promise(function (resolve, reject) {
                getUserMedia.call(navigator, constraints, resolve, reject);
            });
        };
    }

    navigator.mediaDevices.getUserMedia({audio: true})
        .then(function (stream) {
            // Set up a Web Audio AudioContext and AnalyzerNode, configured to return the
            // same number of bins of audio frequency data.
            var audioCtx = new (window.AudioContext || window.webkitAudioContext)();

            var analyser = audioCtx.createAnalyser();
            analyser.minDecibels = -90;
            analyser.maxDecibels = -10;
            analyser.smoothingTimeConstant = 0.85;

            var source = audioCtx.createMediaStreamSource(stream);
            source.connect(analyser);

            analyser.fftSize = bins * 2;

            var dataArray = new Uint8Array(bins);

            function draw(now) {
                analyser.getByteFrequencyData(dataArray);

                // Use that data to drive updates to the fill-extrusion-height property.
                var avg = 0;
                for (var i = 0; i < bins; i++) {
                    avg += dataArray[i];
                    map.setPaintProperty('3d-buildings-' + i, 'fill-extrusion-height', 10 + 4 * i + dataArray[i]);
                }
                avg /= bins;

                // Animate the map bearing and light color over time, and make the light more
                // intense when the audio is louder.
                map.setBearing(now / 500);
                map.setLight({
                    color: "hsl(" + now / 100 % 360 + "," + Math.min(50 + avg / 4, 100) + "%,50%)",
                    intensity: Math.min(1, avg / 256 * 10)
                });

                requestAnimationFrame(draw);
            }

            requestAnimationFrame(draw);
        })
        .catch(function (err) {
            console.log('The following gUM error occured: ' + err);
        });
});
