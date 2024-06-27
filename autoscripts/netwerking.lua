
local base64 = require("libraries.base64inator")
local matUtil = require("libraries.util_mat")

local history = {}
local cube_data = {}
local model = models:newPart("physics_blocks","WORLD")
local cube_models = {}

local avarage_time_samples = {}
local last_sample_time = client:getSystemTime()
local delta_since_last_sample = 1
local avarage_wait = 0
local waiting = false

if host:isHost() then
   local http = require("libraries.httpRequest")
   
   events.WORLD_RENDER:register(function ()
      delta_since_last_sample = client:getSystemTime()-last_sample_time
      if delta_since_last_sample > 200 and not waiting then
         local body = data:createBuffer()
         body:clear()
         body:setPosition(0)
         body:writeString(toJson({type=0}))
         body:setPosition(0)
         waiting = true
         ---@param result HttpResponse
         http.request("http://127.0.0.1:80",body,function (result)
            body:close()
            local buffer = data:createBuffer()
            buffer:readFromStream(result:getData())
            buffer:setPosition(0)
            local string = buffer:readString()
            buffer:close()
            local cmd = 'minecraft:player_head{extra:"'..base64.stringToBase64(string)..'",SkullOwner:{Id:[I;-457632696,995642399,-2093362161,1978444996]}}'
            host:setActionbar("Data Size: "..#cmd)
            host:setSlot("hotbar.8", cmd)
            waiting = false
            
            table.insert(avarage_time_samples,1,delta_since_last_sample)
            last_sample_time = client:getSystemTime()
            
            if #avarage_time_samples > 3 then
               avarage_time_samples[#avarage_time_samples] = nil
               
               avarage_wait = 0
               for i = 1, #avarage_time_samples, 1 do
                  avarage_wait = avarage_wait + avarage_time_samples[i]
               end
               avarage_wait = avarage_wait / #avarage_time_samples
            end
         end)
      end
   end)
end

local last_hash = ""

events.WORLD_RENDER:register(function (delta)
   if player:isLoaded() then
      local item = player:getHeldItem()
      if item.id == "minecraft:player_head" and item.tag.extra then
         local snapshot = {}
         local hash = item.tag.extra
         cube_data = parseJson(base64.base64ToString(hash))
         for i = 2, #cube_data, 1 do
            local mat = matrices.mat4()
            mat:translate(-8,-8,-8)
            mat:rotateZ(cube_data[i][3])
            mat:rotateY(cube_data[i][2])
            mat:rotateX(cube_data[i][1])
            mat:translate(cube_data[i][4]*16,cube_data[i][5]*16,cube_data[i][6]*16)
            snapshot[#snapshot+1] = mat
         end
         if last_hash ~= hash then
            last_hash = hash
            table.insert(history,1,snapshot)
         end
         if history[4] then
            history[4] = nil
         end
         
         if history[3] then
            local snaphshot = history[1]
            for i = 2, #snaphshot, 1 do
               if cube_models[i] then
                  cube_models[i]:setMatrix(matUtil.matrix.lerp(history[2][i],history[1][i],delta_since_last_sample/avarage_wait))
               else
                  local cube = model:newBlock("cube"..i):block("minecraft:melon")
                  cube_models[i] = cube
               end
            end
            for i = #snaphshot+1, #cube_models, 1 do
               cube_models[i]:remove()
               cube_models[i] = nil
            end
         end
      end
   end
end)