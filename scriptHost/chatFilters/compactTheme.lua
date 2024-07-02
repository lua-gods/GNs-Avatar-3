return {
   ---@param message chatscript.post_data
   post = function (message)
      
      if message.translate == "chat.type.text" then
         local json = message.post_json
         json.extra[1].text = ""
         json.extra[3] = {text = " : ",color="gray"}
      end
   end,
}

