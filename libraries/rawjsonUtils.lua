local api = {}

local function copyTable(tbl)
   local copy = {}
   for k,v in pairs(tbl) do
      copy[k] = v
   end
   return copy
end

---@param component table
---@param pattern string
---@param filter fun(component: table)
function api.fragment(component,pattern,filter)
   if component[1] then -- is an array
      for i = 1, #component, 1 do
         api.fragment(component[i],pattern,filter)
      end
   else
      -- recursion
      if component.extra then
         api.fragment(component.extra,pattern,filter)
      end
      
      -- component processing
      local a, b = component.text:find(pattern)
      if a then -- split found
         local ca,cb,cc = component.text:sub(1,a-1),component.text:sub(a,b),component.text:sub(b+1,-1)
         local ta,tb,tc = copyTable(component),copyTable(component),copyTable(component)
         ta.text = ca
         tb.text = cb
         tc.text = cc
         if filter then
            filter(tb)
         end
         for key, value in pairs(component) do
            component[key] = nil
         end
         component.extra = {{text=""},ta,tb,tc}
         component.text = ""
         api.fragment(tc,pattern,filter)
      end
   end
   return component
end

return api