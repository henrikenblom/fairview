package com.fairviewiq.utils;

/**
 * Created by IntelliJ IDEA.
 * User: danielwallerius
 * Date: 2011-09-05
 * Time: 14.15
 * To change this template use File | Settings | File Templates.
 */
public class MultiSelectFunctionMember {

    private String functionName;
    private long functionId;
    private Boolean selected;

    public MultiSelectFunctionMember(String fname, long fId){
        this.functionName = fname;
        this.functionId = fId;
    }

    public Boolean getSelected() {
        return selected;
    }

    public void setSelected(Boolean selected) {
        this.selected = selected;
    }
}