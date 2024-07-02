local utils = require("libraries.rawjsonUtils")
return {
   ---@param message chatscript.post_data
   post = function (message)
      if message.translate == "chat.type.text" then
         ---@param component table
         utils.fragment(message.post_json,"https?://[%a%d;,/?:@&=+%$-_.!~*'()#]+",function (component)
            component.color = "yellow"
            component.underlined = "true"
            component.clickEvent = {action = "open_url", value = component.text}
            component.hoverEvent = {action = "show_text", contents = {text="Open URL"}}
         end)
      end
      --if message.translate == ""
   end,
}

