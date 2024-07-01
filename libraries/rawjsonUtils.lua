local api = {}

local function copyTable(tbl)
   local copy = {}
   for k,v in pairs(tbl) do
      copy[k] = v
   end
   return copy
end

---Splits a text component by a lua pattern.  
--- a filter function can be passed to modify the component thats been split.
---@param raw_json table
---@param pattern string
---@param filter fun(component: {text:string,color:string?,italic:boolean?,bold:boolean?})?
function api.fragment(raw_json,pattern,filter)
   local chunk_id = 0
   local raw_json_size = 0
   for _, _ in pairs(raw_json) do
      raw_json_size = raw_json_size + 1
   end
   while chunk_id < raw_json_size do
      chunk_id = chunk_id + 1
      local chunk
      if raw_json[1] then
         chunk = raw_json[chunk_id]
      else
         chunk = raw_json
      end
      if chunk.extra then
         api.fragment(chunk.extra,pattern,filter)
      end
      local from, to = chunk.text:find(pattern)
      if from then -- found
         local pre,mid,suf = chunk.text:sub(1,from-1),chunk.text:sub(from,to),chunk.text:sub(to+1,-1)
         table.remove(raw_json,chunk_id) -- remove the chunk that fragmented
         
         if #pre ~= 0 then
            local pre_chunk = copyTable(chunk)
            pre_chunk.text = pre
            table.insert(raw_json,chunk_id, pre_chunk)
            chunk_id = chunk_id + 1
         end
         
         local mid_chunk = copyTable(chunk)
         mid_chunk.text = mid
         if filter then filter(mid_chunk) end
         table.insert(raw_json,chunk_id, mid_chunk)
         
         if #suf ~= 0 then
            local suf_chunk = copyTable(chunk)
            suf_chunk.text = suf
            table.insert(raw_json,chunk_id+1, suf_chunk)
         end
      end
   end
   return raw_json
end


return api