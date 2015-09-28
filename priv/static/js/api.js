


function execute_query(btn) {
    $("#error").empty();
    $("#error").hide();
    var val = editor.getValue();
    if (!val) return;

    $("#table-results").html("");

    var b = $(btn);
    b.prepend('<span id="loading" class="glyphicon glyphicon-refresh spinning"></span> ');

    var url = "/api/"+ theme + "/sql?query=" + encodeURIComponent(val);
    $.ajax({
        method: "GET",
        url: url,
        dataType: "json"
    }).done(function(object) {
        $('#loading').remove();

        if (!object.success) {
            $("#download").hide();
            $("#error").html(object.error);
            $("#error").show();
            editor.focus();
        } else {
            $("#sql-url").attr('href', host + url);
            $("#sql-url").show();

            $("#dllink").attr('href', host + url + '&format=csv')
            $("#download").show();

            var text = JSON.stringify(object.result, undefined, 2);
            console.log(text);
            $('.table-results').html(text);
            $('.table-results-container').show();
        }
    });
}

function get_content(id) {
    var url = "";
    _.each($("#" + id).contents(), function(element){
        if (element.nodeName == "#text") {
            url += element.data;
        } else {
            url += element.value;
        }
    });
    return url;
}

function filter_request(btn,id, theme, name, fmt) {
    var items = [];

    $("#" + id + " .dataelement").each(function(idx, elem){
        _.each($(elem).contents(), function(element){
            if (element.nodeName == "#text") {
                items.push(element.data.trim());
            } else {
                items.push(element.value);
            }
        });
    });

    // There are so many #text elements in the HTML, we're ending up with too
    // many elements.  We want to remove the even ones ....
    var even = true;
    var data_items = _.filter(items, function(element){
        even = !even; // flip toggle
        return !even; // return old result of toggle
    });

    var url = "/api/" + theme + "/" + name + "?";
    for (var i= 0; i < data_items.length; i+=2 ){
        url += data_items[i];
        url += "=" + data_items[i+1];
        if ( i < data_items.length - 2) {
            url += "&";
        }
    }

    if (fmt == 'csv') {
        window.location.href = url + "&_fmt=csv";
        return;
    }

    var b = $(btn);
    b.prepend('<span id="loading" class="glyphicon glyphicon-refresh spinning"></span> ');


    $.ajax({
        url: url,
        dataType: "json"
    }) .done(function( obj ) {
        var text = "";

        if (obj.success) {
            text = JSON.stringify(obj.result, undefined, 2);
        } else {
            text = "ERROR: " + obj.error;
        }
        $("#" + id + "_output").html( text );
        $("#" + id + "_container").slideDown();

        $('#loading').remove();
    }).error(function(){
        var text = "API call to " + url + " failed";
        $("#" + id + "_output").html( text );
        $("#" + id + "_container").slideDown();

        $('#loading').remove();
    });

}

function request(btn, id, fmt) {
    var c = get_content(id);

    if (fmt == 'csv') {
        window.location.href = c + "&format=csv";
        return;
    }

    var b = $(btn);
    b.prepend('<span id="loading" class="glyphicon glyphicon-refresh spinning"></span> ');

    $("#" + id + "_container").slideUp();

    $.ajax({
        url: c,
        dataType: "json"
    }) .done(function( obj ) {
        var text = "";

        if (obj.success) {
            text = JSON.stringify(obj.result, undefined, 2);
        } else {
            text = "ERROR: " + obj.error;
        }

        $("#" + id + "_output").html( text );
        $("#" + id + "_container").slideDown();
        $('#loading').remove();
    });
}

