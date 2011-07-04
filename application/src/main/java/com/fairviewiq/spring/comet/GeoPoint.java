package com.fairviewiq.spring.comet;

import java.util.HashMap;
import java.util.Map;

public class GeoPoint {

    private final Map<Object, Map<String, Object>> points = new HashMap<Object, Map<String, Object>>();

    public int length;

    public void addPoint(Object lat, Object lng, Object msg) {
        for (Object k : points.keySet()) {
            Map<String, Object> point = points.get(k);
            if (point.get("lat").equals(lat) && point.get("lng").equals(lng))
                return;
        }
        Map<String, Object> point = new HashMap<String, Object>();
        point.put("lat", lat);
        point.put("lng", lng);
        point.put("msg", msg);
        points.put(length++, point);
    }

    public Object getPoints() {
        return points;
    }

}
