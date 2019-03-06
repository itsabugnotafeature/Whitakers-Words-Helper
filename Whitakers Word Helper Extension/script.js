document.addEventListener("DOMContentLoaded", function(event) {
                          var pop_up_div = document.createElement("DIV");
                          pop_up_div.id = "WWH_pop_up_div";
                          var internal_div = document.createElement("DIV");
                          internal_div.id = "WWH_internal_div"
                          var pre_text = document.createElement("PRE");
                          internal_div.appendChild(pre_text);
                          pop_up_div.appendChild(internal_div);
                          
                          $( "body" ).append(pop_up_div);
});

document.addEventListener("click", function(event) {
                          document.getElementById("WWH_pop_up_div").style.display = 'none';
});

document.addEventListener("dblclick", function(event) {
    if (window.getSelection()) {
        var text = window.getSelection().toString();
        if (text != "") {
            $( "#WWH_pop_up_div" ).css({'display' : 'inline-block'});
            $( "#WWH_pop_up_div" ).offset({left:event.pageX,top:event.pageY});
            $( "#WWH_pop_up_div #WWH_internal_div pre" ).text("");
            safari.extension.dispatchMessage(text);
        }
    }
});

safari.self.addEventListener("message", extensionMessageHandler);

function extensionMessageHandler(event) {
    if (event.name === "queryResponse") {
        $( "#WWH_pop_up_div #WWH_internal_div pre" ).text(event.message["responseText"]);
        var pop_up_div = document.getElementById("WWH_pop_up_div");
        var div_rect = pop_up_div.getBoundingClientRect();
        if (div_rect.x + div_rect.width > document.documentElement.clientWidth) {
            pop_up_div.style.left = (document.documentElement.clientWidth - div_rect.width - 5).toString() + "px";
        }
        if (div_rect.y + div_rect.height > document.documentElement.clientHeight) {
            pop_up_div.style.top = (document.documentElement.clientHeight - div_rect.height + window.scrollY - 5).toString() + "px";
        }
    }
}
