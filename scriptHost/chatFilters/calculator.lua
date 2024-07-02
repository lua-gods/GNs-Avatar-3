local utils = require("libraries.rawjsonUtils")
local env = {math=math}
return {
   ---@param message chatscript.post_data
   post = function (message)
      if message.translate == "chat.type.text" then
         ---@param component table
         utils.fragment(message.post_json,"%[[^]]+%]",function (component)
            local ok,result = pcall(load("return "..component.text:sub(2,-2),"meth","t",env))
            if ok and (type(result) == "number" or not result) then
               if result then
                  component.text = component.text .. " = " .. result
                  component.clickEvent = {action = "copy_to_clipboard", value = tostring(result)}
                  component.hoverEvent = {action = "show_text", contents = {text=tostring(result)}}
               end
               component.color = "gray"
            end
         end)
      end
   end,
}
