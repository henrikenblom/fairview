<%@page pageEncoding="UTF-8" %>

<script type="text/javascript">

    function showGoalDialog(id, nodeClass, existingGoalId) {

        if (existingGoalId > 0) {

            alert("e-goal");

        }

        if (id == organizationNodeId) {

            $('#super_task_chooser-box').hide();

        } else {

            $('#assigned_to-field option').removeAttr('disabled');
            $('#assigned_to-field option[value="' + id + '"]').attr('disabled', 'disabled');

            $.getJSON("fairview/ajax/get_assigned_tasks.do", {_nodeId:id }, function(data) {

                $('#super_task-field').html('<option value="0">Välj...</option>');

                for (var i = 0; i < data.list['org.neo4j.kernel.impl.core.NodeProxy'].length; i++) {

                    $('#super_task-field').append(new Option(data.list['org.neo4j.kernel.impl.core.NodeProxy'][i].properties.title.value, data.list['org.neo4j.kernel.impl.core.NodeProxy'][i].id));

                }

                try {

                    if (typeof(data.list['org.neo4j.kernel.impl.core.NodeProxy'].properties.title.value) != "undefined") {

                        $('#super_task-field').append(new Option(data.list['org.neo4j.kernel.impl.core.NodeProxy'].properties.title.value, data.list['org.neo4j.kernel.impl.core.NodeProxy'].id));

                    };

                } catch (ex) {

                }

            });

            $('#title-box').hide();
            $('#super_task_chooser-box').show();

        }

        if (nodeClass == 'function') {

            //$('#assigned_to-field').val(id);
            //$('#assigned_to-field').attr("disabled", "disabled");
            $('#assigned_to-box').hide();

        } else {

            $('#assigned_to-box').show();

        }

        $('#modalizer').fadeTo(200, 0.5);
        $('#newGoalDialog').fadeIn(200, function() {

            $('#title-field').focus();
            $('#goalOwnerId').val(id);

        });

    }

    function hideGoalDialog() {

        $('#newGoalDialog').fadeOut(200, function() {

            $('#title-box').show();

            $('#title-field').val("");
            $('#descr-field').val("");
            $('#focus-field').val("");
            $('#measurement-field').val("");
            $('#assigned_to-field').val(0);
            $('#super_goal-field').val(0);

        });

        $('#modalizer').fadeOut(200);

    }

    function validateNewGoalForm() {

        if ($('#super_task-field').val() != 0) {


            $('#title-field').val($('#super_task-field :selected').text());

        }

        if ($('#title-field').val().length > 0
                && $('#measurement-field').val().length > 0
                && $('#focus-field').val().length > 0
                //&& $('#assigned_to-field').val() != 0
                ) {

            $('#saveButton').removeAttr('disabled');

        } else {

            $('#saveButton').attr('disabled', 'disabled');

        }

    }

    function saveNewGoal() {

        $('#newGoalForm').ajaxSubmit({

            success: function(data) {

                $.getJSON("fairview/ajax/set_task.do", {_nodeId:data['org.neo4j.kernel.impl.core.RelationshipProxy'].endNode, title: $('#task_title-field').val(), assigned_to: $('#assigned_to-field').val() }, function(data) {

                    hideGoalDialog();

                });

            }

        });

    }

</script>

<div id="newGoalDialog" class="popup" style="display: none">
    <div class="popup-header">
        <div class="popup-header-text">Nytt mål</div>
        <div class="popup-header-close-box"><a href="#" onclick="hideGoalDialog(event)" class="close">
            <img src="images/close.gif"></a></div>
    </div>
    <div class="list-body profile-list" id="credentials-list">
        <div class="field-box goals_tasks_dialog_segment">
            <form method="post" action="fairview/ajax/set_goal.do" id="newGoalForm">
                <fieldset>
                    <input name="_nodeId" type="hidden" id="goalOwnerId"/>
                    <input name="_strict" type="hidden" value="false"/>
                    <input name="_username" type="hidden" value="<%=currentUserName%>"/>

                    <div id="super_task_chooser-box" style="display: none">
                        <div class="field-label-box">Kopplad till uppgift</div>
                        <div id="super_goal-field-box" class="field-input-box">
                            <select class="dialog-field" onchange="validateNewGoalForm()" name="super_task"
                                    id="super_task-field">
                                <option value="0">Välj...</option>
                            </select>
                        </div>
                    </div>
                    <div id="title-box">
                        <div class="field-label-box">Benämning</div>
                        <div id="username-field-box" class="field-input-box">
                            <input type="text" onchange="validateNewGoalForm()" value="" autocomplete="off"
                                   name="title"
                                   class="text-field dialog-field" id="title-field">
                        </div>
                    </div>

                    <div class="field-label-box">Beskrivning</div>
                    <div id="description-field-box" class="field-input-box">
                        <input type="text" value="" autocomplete="off" name="description"
                               class="text-field dialog-field" id="descr-field">
                    </div>

                    <div class="field-label-box">Mätbarhet</div>
                    <div id="measurement-field-box" class="field-input-box">
                        <input type="text" onchange="validateNewGoalForm()" value="" autocomplete="off"
                               name="measurement" class="text-field dialog-field" id="measurement-field">
                    </div>

                    <div class="field-label-box">Fokus (procent)</div>
                    <div id="focus-field-box" class="field-input-box">
                        <input type="text" onchange="validateNewGoalForm()" value="" autocomplete="off" name="focus"
                               class="text-field dialog-field" id="focus-field">
                    </div>

                </fieldset>
            </form>
            <div id="saveButtonBox">
                <button disabled="disabled" onclick="saveNewGoal()" id="saveButton" class="dialog-button">Spara</button>
            </div>
        </div>
        <div class="field-box goals_tasks_dialog_segment">
            <div class="field-label-box">Uppgift</div>
            <div class="field-input-box">
                <input type="text" onchange="validateNewGoalForm()" value="" autocomplete="off" name="task_title"
                       class="text-field dialog-field" id="task_title-field">
            </div>
            <div id="assigned_to-box">
                <div class="field-label-box">Tilldelad</div>
                <div id="assigned_to-field-box" class="field-input-box">
                    <select class="dialog-field" onchange="validateNewGoalForm()" name="assigned_to"
                            id="assigned_to-field">
                        <option value="0">Välj...</option>
                        <optgroup label="Enheter">
                            <%
                                for (Node entry : unitListGenerator.getSortedList(UnitListGenerator.ALPHABETICAL, false)) {
                            %>

                            <option value="<%=entry.getId()%>"><%=entry.getProperty("name", "Namnlös enhet")%>
                            </option>

                            <%
                                }
                            %>
                        </optgroup>
                        <optgroup label="Funktioner">
                            <%

                                for (Node entry : functionListGenerator.getSortedList(FunctionListGenerator.ALPHABETICAL, false)) {

                            %>

                            <option value="<%=entry.getId()%>"><%=entry.getProperty("name", "Namnlös funktion")%>
                            </option>

                            <%

                                }

                            %>
                        </optgroup>
                    </select>
                </div>
            </div>
            <br>
            <a href="#" onclick=""><img src="images/plus.png"></a>
        </div>

    </div>
    <div id="credentials-footer" class="list-footer">&nbsp;</div>
</div>