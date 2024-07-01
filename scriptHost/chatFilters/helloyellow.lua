local utils = require("libraries.rawjsonUtils")
return {
   ---@param message chatscript.post_data
   post = function (message)
      if message.translate == "chat.type.text" then
         ---@param component table
         utils.fragment(message.post_json,"yellow",function (component)
            component.color = "green"
         end)
      end
      --if message.translate == ""
   end,
}