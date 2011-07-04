var inactiveCoworkersDisplayCheckboxChecked = true;
var coworkerTextFilterLength = 0;
var coworkerId = 0;
var footerHeight = "18px";
var footerPadding = "4px";
var mainOrganisationAddressIndex = 0;
//var organisationSubUnitIndex = 0;
var organizationNodeId = 0;

function onload(oNodeId) {

    //if (id != null) {

    //    coworkerId = id;

    //}

    organizationNodeId = oNodeId;

    $(".coworker-list-entry:has(a.inactive)").hide();


}

function adjustViewPort() {

    $('#main').height($(window).height() - ($('#page-header').height() - 9));
    $('#main').width($(window).width());

}

function organizationFormSaved() {

    if ($('#name-field').val().length > 0) {
        $('#header-organization-name').html($('#name-field').val());
        $('.top-button').show();
    } else {
        $('#header-organization-name').html('Namnlös');
        $('.top-button').hide();
    }


}

function functionFormSaved() {

    //$(this).attr('title', 'Infero Quest - Funktion (' + $('#name-field').val() + ')');

}

function credentialsSaved() {

}

function functionAssignedToEmployee(event, employeeId) {

    var functionId = $('#function-field').val();

    $.getJSON("neo/ajax/create_relationship.do", {_startNodeId:employeeId, _type:"HAS_EMPLOYMENT" }, function(dataEmployment) {
        $.getJSON("fairview/ajax/assign_function.do", {employment:dataEmployment.relationship.endNode, "function:relationship":functionId, percent:100});
    });

}

function addMainOrganisationAddressFieldButtonClick(event) {

   $.getJSON("neo/ajax/create_relationship.do", {_startNodeId: organizationNodeId, _type:"HAS_ADDRESS" }, function(data) {
       addMainOrganisationAddressField(data.relationship.endNode);
    });

}

function addMainOrganisationAddressField(addressNodeId) {


    mainOrganisationAddressIndex++;

    $('<form id="organization_address_form' + mainOrganisationAddressIndex + '" action="neo/ajax/update_properties.do" method="post">\
                            <fieldset>                                                                                                \
                            <input type="hidden" name="_id" value="' + addressNodeId + '">                                    \
                            <input type="hidden" name="_type" value="node">                                                           \
                            <input type="hidden" name="_strict" value="true">                                                         \
                            <input type="hidden" name="_username" value="admin">                                                      \
                        <div class="field-box"><div class="field-label-box">Adressbenämning</div><div><input type="text" onchange="$(\'#organization_address_form' + mainOrganisationAddressIndex + '\').ajaxSubmit()" class="text-field" id="addressname-field' + mainOrganisationAddressIndex + '" name="description"></div></div>\
                        <br>                                                                                                                                                                                                                                                                                                              \
                        <div class="field-box"><div class="field-label-box">Adress</div><div><input type="text" onchange="$(\'#organization_address_form' + mainOrganisationAddressIndex + '\').ajaxSubmit()" class="text-field" id="streetaddress-field' + mainOrganisationAddressIndex + '" name="address"></div></div>               \
                        <br>                                                                                                                                                                                                                                                                                                              \
                        <div class="field-box"><div class="field-label-box">Postnummer</div><div><input type="text" onchange="$(\'#organization_address_form' + mainOrganisationAddressIndex + '\').ajaxSubmit()" class="text-field" id="zip-field' + mainOrganisationAddressIndex + '" name="postalcode"></div></div>               \
                        <br>                                                                                                                                                                                                                                                                                                              \
                        <div class="field-box"><div class="field-label-box">Ort</div><div><input type="text" onchange="$(\'#organization_address_form' + mainOrganisationAddressIndex + '\').ajaxSubmit()" class="text-field" id="city-field' + mainOrganisationAddressIndex + '" name="city"></div></div>                                 \
                        <br>                                                                                                                                                                                                                                                                                                               \
                        <div class="field-box"><div class="field-label-box">Land</div><div><input type="text" onchange="$(\'#organization_address_form' + mainOrganisationAddressIndex + '\').ajaxSubmit()" class="text-field" id="country-field' + mainOrganisationAddressIndex + '" name="country"></div></div>                       \
                        <br>\
                        </fieldset>\
                                </form>').appendTo($("#additional-adresses-box"));

}


function editField(event) {

    var value = event.target.innerHTML;
    var id = event.target.id.replace('-preview','-field');
    
    event.target.className = "hidden";
    RemoveClassName(document.getElementById(id), "hidden");

    document.getElementById(id).focus();

}

function endEditField(event) {

    var value = event.target.value;
    var id = event.target.id.replace('-field','-preview');

    event.target.blur();

    AddClassName(event.target, "hidden");
    
    document.getElementById(id).innerHTML = value;
    document.getElementById(id).className = "field-preview";

    window.location.href = "coworkerprofile.jsp?id=" + coworkerId + "&" + event.target.id + "=" + value + "&alter=true";

}

function hideCoworkerPopup(event) {

    document.getElementById("coworker-popup").className = "hidden";

}

function showCoworkerPopup(event) {

    var x = 0;
    var y = 0;
    var coworkerPopup = document.getElementById("coworker-popup");
    
    if (!document.all) {

        x = event.pageX;
        y = event.pageY;

    } else {

        x = event.x;
        y = event.y;

    }

    coworkerPopup.style.left = x + "px";
    coworkerPopup.style.top = y + "px";
    coworkerPopup.className = "popup";

}

function coworkerTextFilter(event) {

    if (event.target.value.length > 0) {

        if (coworkerTextFilterLength == 0) {

            //inactiveCoworkersDisplayCheckboxChecked = document.getElementById("inactiveCoworkersDisplayCheckbox").checked;

        }
        
        coworkerTextFilterLength = event.target.value.length;
        
        $(".coworker-list-entry:visible:not(:containsi('" + event.target.value.toLowerCase() + "'))").hide('fast');
        $(".coworker-list-entry:hidden:containsi('" + event.target.value.toLowerCase() + "')").show();

        //document.getElementById("inactiveCoworkersDisplayCheckbox").checked = false;

    } else if (coworkerTextFilterLength > 0) {

        $(".coworker-list-entry").show();
        
        //if (inactiveCoworkersDisplayCheckboxChecked == true) {

        //    $(".coworker-list-entry:has(a.inactive)").hide();
            
        //    document.getElementById("inactiveCoworkersDisplayCheckbox").checked = inactiveCoworkersDisplayCheckboxChecked;

        //}

        coworkerTextFilterLength = 0;

    } else {

        $(".coworker-list-entry").show();



    }

}

function myGroupTextFilter(event) {

    if (event.target.value.length > 0) {

        $(".mygroup-list-entry:visible:not(:containsi('" + event.target.value.toLowerCase() + "'))").hide('fast');
        $(".mygroup-list-entry:hidden:containsi('" + event.target.value.toLowerCase() + "')").show();

    } else {

        $(".mygroup-list-entry:hidden").show();

    }

}

function toggleInactiveCoworkers(event) {

    if (event.target.checked == true) {

        $(".coworker-list-entry:has(a.inactive)").hide();

    } else {

        $(".coworker-list-entry:has(a.inactive)").show();

    }

}

function companyReportTextFilter(event) {

    if (event.target.value.length > 0) {

        $(".report-list-entry:visible:not(:containsi('" + event.target.value.toLowerCase() + "'))").hide('fast');
        $(".report-list-entry:hidden:containsi('" + event.target.value.toLowerCase() + "')").show();

    } else {

        $(".report-list-entry:hidden").show();

    }


}

function companyPolicyTextFilter(event) {

    if (event.target.value.length > 0) {

        $(".policy-list-entry:visible:not(:containsi('" + event.target.value.toLowerCase() + "'))").hide('fast');
        $(".policy-list-entry:hidden:containsi('" + event.target.value.toLowerCase() + "')").show();

    } else {

        $(".policy-list-entry:hidden").show();

    }


}

function unitTextFilter(event) {

    if (event.target.value.length > 0) {

        $(".unit-list-entry:visible:not(:containsi('" + event.target.value.toLowerCase() + "'))").hide('fast');
        $(".unit-list-entry:hidden:containsi('" + event.target.value.toLowerCase() + "')").show();

    } else {

        $(".unit-list-entry:hidden").show();

    }


}

function functionTextFilter(event) {

    if (event.target.value.length > 0) {

        $(".function-list-entry:visible:not(:containsi('" + event.target.value.toLowerCase() + "'))").hide('fast');
        $(".function-list-entry:hidden:containsi('" + event.target.value.toLowerCase() + "')").show();

    } else {

        $(".function-list-entry:hidden").show();

    }


}

function contractExpand(target) {

    var targetList = target.id.split("-")[0];
	var footer = document.getElementById(targetList + "-footer");

    if (target.src.indexOf('contract') > 0) {

        target.src = "images/expand.png";

        $("#" + targetList + "-list").hide();

        footerPadding = footer.style['padding'];
        footerHeight = footer.style['height'];

        footer.style['height'] = 0;
        footer.style['padding'] = 0;

    } else {

        target.src = "images/contract.png";

        $("#" + targetList + "-list").show();

        footer.style['padding'] = footerPadding;
        footer.style['height'] = footerHeight;

    }

}

function toggleExpand(event) {

    var target = event.target;
    
    contractExpand(target);

}

$.extend($.expr[':'], {
    'containsi': function(elem, i, match, array)
    {
        return (elem.textContent || elem.innerText || '').toLowerCase()
        .indexOf((match[3] || "").toLowerCase()) >= 0;
    }
});

/* Stöldgods below */

/**
 * jQuery.placeholder - Placeholder plugin for input fields
 * Written by Blair Mitchelmore (blair DOT mitchelmore AT gmail DOT com)
 * Licensed under the WTFPL (http://sam.zoy.org/wtfpl/).
 * Date: 2008/10/14
 *
 * @author Blair Mitchelmore
 * @version 1.0.1
 *
 **/
new function($) {
    $.fn.placeholder = function(settings) {
        settings = settings || {};
        var key = settings.dataKey || "placeholderValue";
        var attr = settings.attr || "placeholder";
        var className = settings.className || "placeholder";
        var values = settings.values || [];
        var block = settings.blockSubmit || false;
        var blank = settings.blankSubmit || false;
        var submit = settings.onSubmit || false;
        var value = settings.value || "";
        var position = settings.cursor_position || 0;


        return this.filter(":input").each(function(index) {
            $.data(this, key, values[index] || $(this).attr(attr));
        }).each(function() {
            if ($.trim($(this).val()) === "")
                $(this).addClass(className).val($.data(this, key));
        }).focus(function() {
            if ($.trim($(this).val()) === $.data(this, key))
                $(this).removeClass(className).val(value)
            if ($.fn.setCursorPosition) {
                $(this).setCursorPosition(position);
            }
        }).blur(function() {
            if ($.trim($(this).val()) === value)
                $(this).addClass(className).val($.data(this, key));
        }).each(function(index, elem) {
            if (block)
                new function(e) {
                    $(e.form).submit(function() {
                        return $.trim($(e).val()) != $.data(e, key)
                    });
                }(elem);
            else if (blank)
                new function(e) {
                    $(e.form).submit(function() {
                        if ($.trim($(e).val()) == $.data(e, key))
                            $(e).removeClass(className).val("");
                        return true;
                    });
                }(elem);
            else if (submit)
                new function(e) {
                    $(e.form).submit(submit);
                }(elem);
        });
    };
}(jQuery);

// ----------------------------------------------------------------------------
// HasClassName
//
// Description : returns boolean indicating whether the object has the class name
//    built with the understanding that there may be multiple classes
//
// Arguments:
//    objElement              - element to manipulate
//    strClass                - class name to add
//
function HasClassName(objElement, strClass)
   {

   // if there is a class
   if ( objElement.className )
      {

      // the classes are just a space separated list, so first get the list
      var arrList = objElement.className.split(' ');

      // get uppercase class for comparison purposes
      var strClassUpper = strClass.toUpperCase();

      // find all instances and remove them
      for ( var i = 0; i < arrList.length; i++ )
         {

         // if class found
         if ( arrList[i].toUpperCase() == strClassUpper )
            {

            // we found it
            return true;

            }

         }

      }

   // if we got here then the class name is not there
   return false;

   }
//
// HasClassName
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// AddClassName
//
// Description : adds a class to the class attribute of a DOM element
//    built with the understanding that there may be multiple classes
//
// Arguments:
//    objElement              - element to manipulate
//    strClass                - class name to add
//
function AddClassName(objElement, strClass, blnMayAlreadyExist)
   {

   // if there is a class
   if ( objElement.className )
      {

      // the classes are just a space separated list, so first get the list
      var arrList = objElement.className.split(' ');

      // if the new class name may already exist in list
      if ( blnMayAlreadyExist )
         {

         // get uppercase class for comparison purposes
         var strClassUpper = strClass.toUpperCase();

         // find all instances and remove them
         for ( var i = 0; i < arrList.length; i++ )
            {

            // if class found
            if ( arrList[i].toUpperCase() == strClassUpper )
               {

               // remove array item
               arrList.splice(i, 1);

               // decrement loop counter as we have adjusted the array's contents
               i--;

               }

            }

         }

      // add the new class to end of list
      arrList[arrList.length] = strClass;

      // add the new class to beginning of list
      //arrList.splice(0, 0, strClass);

      // assign modified class name attribute
      objElement.className = arrList.join(' ');

      }
   // if there was no class
   else
      {

      // assign modified class name attribute
      objElement.className = strClass;

      }

   }
//
// AddClassName
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// RemoveClassName
//
// Description : removes a class from the class attribute of a DOM element
//    built with the understanding that there may be multiple classes
//
// Arguments:
//    objElement              - element to manipulate
//    strClass                - class name to remove
//
function RemoveClassName(objElement, strClass)
   {

   // if there is a class
   if ( objElement.className )
      {

      // the classes are just a space separated list, so first get the list
      var arrList = objElement.className.split(' ');

      // get uppercase class for comparison purposes
      var strClassUpper = strClass.toUpperCase();

      // find all instances and remove them
      for ( var i = 0; i < arrList.length; i++ )
         {

         // if class found
         if ( arrList[i].toUpperCase() == strClassUpper )
            {

            // remove array item
            arrList.splice(i, 1);

            // decrement loop counter as we have adjusted the array's contents
            i--;

            }

         }

      // assign modified class name attribute
      objElement.className = arrList.join(' ');

      }
   // if there was no class
   // there is nothing to remove

   }
//
// RemoveClassName
// ----------------------------------------------------------------------------
  