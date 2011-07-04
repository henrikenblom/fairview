var fairviewLanguage = {

    // Set a unique name for the language
    languageName: "fairview",

    // List of node types definition
    modules: [

        {
            "name": "Start",
            "container": {
                "close" : false,
                "xtype":"WireIt.ImageContainer",
                "className": "WireIt-Container WireIt-ImageContainer Start",
                "icon": "/wireit/images/icons/gnome-globe.png",
                "image": "/wireit/images/gnome-globe.png",
                "terminals": [
                    {
                        "name": "ROOT",
                        "direction": [0,0],
                        "offsetPosition": {"left": 8, "top": 8 },
                        "ddConfig": {
                            "type": "UNIT_OUT",
                            "allowedTypes": ["UNIT_IN"]
                        },
                        "alwaysSrc": true
                    }
                ]
            }
        },

        {
            "name": "Enhet",
            "container": {
                "width" : 260,
                "xtype": "WireIt.NodeContainer",
                "icon": "/wireit/images/icons/stock_people.png",
                "fields": [
                    {
                        "inputParams": {"label": "ID", "name": "id", "readonly": true, "size": 4 }
                    },
                    {
                        "inputParams": {"label": "Namn", "name": "name", "required": true}
                    },
                    {
                        "inputParams": {"label": "Telefon", "name": "phone"}
                    },
                    {
                        "inputParams": {"label": "Beskrivning", "name": "description"}
                    }
                ],
                "terminals": [
                    {
                        "name": "PARENT",
                        "direction": [0,-1],
                        "offsetPosition": {"left": 130, "top": -15 },
                        "nMaxWires" : 1,
                        "ddConfig": {
                            "type": "UNIT_IN",
                            "allowedTypes": ["UNIT_OUT"]
                        }
                    },
                    {
                        "name": "CHILD",
                        "direction": [0,1],
                        "offsetPosition": {"left": 130, "bottom": -15},
                        "ddConfig": {
                            "type": "UNIT_OUT",
                            "allowedTypes": ["UNIT_IN"]
                        },
                        "alwaysSrc": true
                    },
                    {
                        "name": "ADDRESS",
                        "direction": [1,0],
                        "offsetPosition": {"right": -15, "top": 40},
                        "ddConfig": {
                            "type": "ADDRESS_IN",
                            "allowedTypes": ["ADDRESS_OUT"]
                        },
                        "alwaysSrc": true
                    }
                ]
            }
        },

        {
            "name": "Adress",
            "container": {
                "width" : 260,
                "xtype": "WireIt.NodeContainer",
                "icon": "/wireit/images/icons/stock_contact.png",
                "fields": [
                    {
                        "inputParams": {"label": "ID", "name": "id", "readonly": true, "size": 4 }
                    },
                    {
                        "inputParams": {"width": 200, "label": "Adress", "name": "address", "required": true }
                    },
                    {
                        "inputParams": {"label": "Postnummer", "name": "postalcode", "required": true, "size":6 }
                    },
                    {
                        "inputParams": {"label": "Stad", "name": "city", "required": true }
                    },
                    {
                        "inputParams": {"label": "Land", "name": "country", "required": true }
                    },
                    {
                        "inputParams": {"label": "Beskrivning", "name": "description", "required": true }
                    }
                ],
                "terminals": [
                    {
                        "name": "ADDRESS",
                        "direction": [-1,0],
                        "offsetPosition": {"left": -15, "top": 60},
                        "ddConfig": {
                            "type": "ADDRESS_OUT",
                            "allowedTypes": ["ADDRESS_IN"]
                        }
                    }
                ]

            }
        }

    ]

};