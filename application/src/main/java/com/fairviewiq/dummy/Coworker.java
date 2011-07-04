package com.fairviewiq.dummy;


import java.util.HashMap;

/**
 *
 * @author henrik
 */
public class Coworker extends HashMap<String, Object> {

    private boolean active = false;

    @Override
    public Object put(String k, Object v) {

        if (k.equals("active")) {

            active = (Boolean) v;

        }

        return super.put(k, v);
    }

    public boolean isActive() {
        return active;
    }

}
