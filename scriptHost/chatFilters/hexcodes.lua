local utils = require("libraries.rawjsonUtils")
return {
   ---@param message chatscript.post_data
   post = function (message)
      if message.translate == "chat.type.text" then
         local matched = false
         ---@param component table
         utils.fragment(message.post_json,"#%x%x%x%x%x%x",function (component)
            component.color = component.text
            component.clickEvent = {action = "copy_to_clipboard", value = component.text}
            component.hoverEvent = {action = "show_text", contents = {text="Copy to Clipboard"}}
            matched = true
         end)
         if not matched then
            ---@param component table
            utils.fragment(message.post_json,"#%x%x%x",function (component)
               local r,g,b = component.text:sub(2,2),component.text:sub(3,3),component.text:sub(4,4)
               component.color = "#"..r..r..g..g..b..b
               component.clickEvent = {action = "copy_to_clipboard", value = component.text}
               component.hoverEvent = {action = "show_text", contents = {text="Copy to Clipboard"}}
            end)
         end
      end
      --if message.translate == ""
   end,
}

