
---copies a table as a new object instead of a reference.
---@param tbl table
---@return table
utils.deepCopy = function (tbl)
   local copy = {}
  local meta = getmetatable(tbl)
  if meta then
    setmetatable(copy,meta)
  end
   for key, value in pairs(tbl) do
      if type(value) == "table" then
         value = utils.deepCopy(value)
      end
      copy[key] = value
   end
   return copy
end