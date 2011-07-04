cometMap = {

    settings: {
        doComet: true,
        position: {
            lat: 59.334229,
            lon: 18.071350,
            z: 14
        }
    },

    init: function() {

        if (!GBrowserIsCompatible()) {
            alert("Browser not compatible");
            return;
        }

        cometMap.map = new GMap2($("#gmap")[0]);
        cometMap.map.setCenter(new GLatLng(cometMap.settings.position.lat, cometMap.settings.position.lon), cometMap.settings.position.z);

        cometMap.map.addMapType(G_SATELLITE_3D_MAP);
        cometMap.map.addControl(new GHierarchicalMapTypeControl());
        cometMap.map.addControl(new GLargeMapControl());

        GEvent.addListener(cometMap.map, "click", function(overlay, latlng) {
            if (latlng.lat() && latlng.lng()) {
                $.comet.publish("/map/newpoint", { lat: latlng.lat(), lng: latlng.lng(), msg: "Click!" });
            }
        });

        if (cometMap.settings.doComet) {

            $.comet.init("/cometd");

            $.comet.subscribe("/map/newpoint", this.addPoints);

            $.comet.subscribe("/employee/absence", this.absence);

            $(document).unload(function() {
                $.comet.disconnect();
            });

        }

    },

    absence: function (message) {
        $.get("/edit/components/absence.do", {id:message.data}, function(data) {
            $("#log").append(data);
        }, "html");
    },

    addPoints: function (message) {

        var points = {};

        if (!message.data["0"]) {
            points["0"] = message.data;
        } else {
            points = message.data;
        }

        var lastPoint;
        var lastMarker;
        for (var i in points) {
            var point = new GLatLng(points[i].lat, points[i].lng);
            marker = new GMarker(point, { title:point });
            cometMap.map.addOverlay(marker);
            lastPoint = points[i];
            lastMarker = marker;
        }

        cometMap.map.setCenter(new GLatLng(lastPoint.lat, lastPoint.lng));
        lastMarker.openInfoWindowHtml('<b>Latitude:</b>' + lastPoint.lat + '<br/>' +
                                      '<b>Longitude:</b>' + lastPoint.lng + '<br/>' +
                                      '<b>Message:</b>' + lastPoint.msg + '<br/>');

    }

};