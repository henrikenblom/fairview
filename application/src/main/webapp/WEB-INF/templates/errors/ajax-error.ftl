[#ftl encoding="UTF-8" attributes={'content_type' : 'text/json; charset=utf-8'}]
[#assign cause=exception.getCause()/]
{
    "exception" : {
        "type" : "${cause.getClass().getName()?js_string}",
        "message" : "${(cause.getMessage()!"")?js_string}",
        "i18n_message" : "${springMacroRequestContext.getMessage(cause.getClass().getName()?js_string, cause.getClass().getName()?js_string)?js_string}"
    }
}