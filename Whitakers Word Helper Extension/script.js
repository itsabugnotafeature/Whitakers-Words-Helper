var WWH_host_div = document.createElement("div");
WWH_host_div.id = "WWH_host_div";
var shadowRoot = WWH_host_div.attachShadow({mode: 'closed'});
shadowRoot.innerHTML = "<style>#WWH_pop_up_div {background-color: rgb(110, 110, 110);padding: 2px !important;border-radius: 10px !important;position: absolute !important;visibility: hidden;min-width: 450px;z-index: 100;opacity: 1 !important;font-family: Consolas, monospace !important;}#WWH_internal_div {background-color: rgb(255, 255, 255);border-radius: 15px !important;padding-left: 5px !important;padding-right: 5px !important;}#WWH_pop_up_div pre {font-family: Consolas, monospace !important;font-size: 14px !important;padding: 0 !important;margin: 0 !important;background-color: rgb(255, 255, 255, 0) !important;color: rgb(0, 0, 0) !important;box-shadow: none !important;line-height: 100% !important;}</style>"
var pop_up_div = document.createElement("div");
pop_up_div.id = "WWH_pop_up_div";
var internal_div = document.createElement("div");
internal_div.id = "WWH_internal_div"
var pre_text = document.createElement("pre");
internal_div.appendChild(pre_text);
pop_up_div.appendChild(internal_div);
shadowRoot.appendChild(pop_up_div);

document.addEventListener("DOMContentLoaded", function(event) {
                          document.body.appendChild(WWH_host_div);
});

document.addEventListener("click", function(event) {
                          pop_up_div.style.visibility = 'hidden';
});

document.addEventListener("dblclick", function(event) {
    if (window.getSelection() && document.activeElement.tagName.toLowerCase() != "input" && document.activeElement.tagName.toLowerCase() != "textarea") {
        var text = window.getSelection().toString();
        if (text != "") {
            pop_up_div.style.visibility = 'visible';
            pop_up_div.style.left = (event.pageX + 15).toString() + "px";
            pop_up_div.style.top = event.pageY.toString() + "px";
            pre_text.textContent = "";
            safari.extension.dispatchMessage(text);
        }
    }
});

safari.self.addEventListener("message", extensionMessageHandler);

function extensionMessageHandler(event) {
    if (event.name === "queryResponse") {
        pop_up_div.style.visibility = 'visible';
        pre_text.textContent = event.message["responseText"];
        var div_rect = pop_up_div.getBoundingClientRect();
        if (div_rect.x + div_rect.width > document.documentElement.clientWidth) {
            pop_up_div.style.left = (document.documentElement.clientWidth - div_rect.width - 5).toString() + "px";
        }
        if (div_rect.y + div_rect.height > document.documentElement.clientHeight) {
            pop_up_div.style.top = (document.documentElement.clientHeight - div_rect.height + window.scrollY - 5).toString() + "px";
        }
    }
}

document.addEventListener("contextmenu", handleContextMenu, false);
function handleContextMenu(event) {
    if (window.getSelection() && document.activeElement.tagName.toLowerCase() != "input" && document.activeElement.tagName.toLowerCase() != "textarea") {
        var selectedText = window.getSelection().toString();
        safari.extension.setContextMenuEventUserInfo(event, { "selectedText": selectedText });
        pop_up_div.style.left = (event.pageX + 15).toString() + "px";
        pop_up_div.style.top = event.pageY.toString() + "px";
        pre_text.textContent = "";
    }
}
