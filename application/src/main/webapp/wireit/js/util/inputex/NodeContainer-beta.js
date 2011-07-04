/**
 * Class used to build a container with inputEx forms as nodes
 * @class NodeContainer
 * @namespace WireIt
 * @extends WireIt.FormContainer
 * @constructor
 * @param {Object}   options  Configuration object (see properties)
 * @param {WireIt.Layer}   layer The WireIt.Layer (or subclass) instance that contains this container
 */
WireIt.NodeContainer = function(options, layer) {
    WireIt.NodeContainer.superclass.constructor.call(this, options, layer);
};

YAHOO.lang.extend(WireIt.NodeContainer, WireIt.FormContainer, {

    render: function() {
        WireIt.NodeContainer.superclass.render.call(this);
        /*
        var container = this;
        if (container.form.inputsNames.id.getValue() == "") {
            YAHOO.util.Connect.asyncRequest("GET", "/neo/ajax/create_node.do", {
                success: function(o) {
                    // todo: set module id to node id
                    var data = YAHOO.lang.JSON.parse(o.responseText);
                    container.form.inputsNames.id.setValue(data.node.id);
                },
                failure: function(o) {
                    // todo: show alert
                    container.form.inputsNames.id.setValue(-1);
                }
            }, null);
        }
        */
    },

    onCloseButton: function(event, args) {
        WireIt.NodeContainer.superclass.onCloseButton.call(this, event, args);
        /*
        var container = this;
        var id = container.form.inputsNames.id.getValue();
        YAHOO.util.Connect.asyncRequest("GET", "/neo/ajax/delete_node.do?_recursive=false&_nodeId=" + id, {
            success: function(o) {
                var data = YAHOO.lang.JSON.parse(o.responseText);
                WireIt.NodeContainer.superclass.onCloseButton.call(container, event, args);
            },
            failure: function(o) {
                // todo: show alert
            }
        }, null);
        */
    }

});
