--
---- CONFIG

--- If this is `true`, the file will not be patched and information will be printed.
local dry = false

---- CONFIG
--

local client = require("client")

local target_code = "\z
\n    if needRemove then\z
\n        local newNode = myNode:copy()\z
\n        newNode:removeNode(needRemove)\z
\n        newNode.originNode = myNode\z
\n        vm.setNode(source, newNode, true)\z
\n        if call.args then\z
\n            -- clear node caches of args to allow recomputation with the type narrowed call\z
\n            for _, arg in ipairs(call.args) do\z
\n                if vm.getNode(arg) then\z
\n                    vm.setNode(arg, vm.createNode(), true)\z
\n                end\z
\n            end\z
\n            for n in newNode:eachObject() do\z
\n                if n.type == 'function'\z
\n                or n.type == 'doc.type.function' then\z
\n                    for i, arg in ipairs(call.args) do\z
\n                        if vm.getNode(arg) and n.args[i] then\z
\n                            vm.setNode(arg, vm.compileNode(n.args[i]))\z
\n                        end\z
\n                    end\z
\n                end\z
\n            end\z
\n        end\z
\n    end\z
"

local replacement_code = "\z
\n    --#region ===== COMPILER PATCHER =====\z
\n    if needRemove then\z
\n        local newNode = myNode:copy()\z
\n        newNode:removeNode(needRemove)\z
\n        newNode.originNode = myNode\z
\n        vm.setNode(source, newNode, true)\z
\n        if call.args then\z
\n            -- recompile existing node caches of args to allow recomputation with the type narrowed call\z
\n            for _, arg in ipairs(call.args) do\z
\n                if vm.getNode(arg) then\z
\n                    vm.removeNode(arg)\z
\n                    vm.compileNode(arg)\z
\n                end\z
\n            end\z
\n        end\z
\n    end\z
\n    --#endregion ===== COMPILER PATCHER =====\z
"

local path, s_err = package.searchpath("vm.compiler", package.path)
if s_err then
  client.showMessage("Error", "Could not find [vm/compiler.lua]!")
  print("[!] ERROR:\n" .. s_err)
  return
elseif dry then
  print("Found file at: [" .. path .. "]")
end

local file, f_err = io.open(path, "r")
if f_err then
  client.showMessage("Error", "Could not open [vm/compiler.lua]!")
  print("[!] ERROR:\n" .. f_err)
  return
end

---@type string
local contents = file:read("a")
file:close()
local start, finish = contents:find(target_code, 1, true)
local new_contents

if start then
  if dry then
    print("Found target code at [" .. start .. ", " .. finish .. "]")
  end

  new_contents = contents:sub(1, start - 1) .. replacement_code .. contents:sub(finish + 1)
end

if new_contents then
  if dry then
    client.showMessage("Info", "DRY_RUN: Contents changed!")
    print("Contents changed!")
    print(new_contents)
  else
    file = io.open(path, "w")
    file:write(new_contents)
    file:close()
    client.showMessage(
      "Info",
      "LuaLS Compiler Patcher: Successfully patched [vm/compiler.lua]. You will need to reload your editor for it to take effect!"
    )
  end
elseif dry then
  client.showMessage("Info", "DRY_RUN: Contents did not change! Patch may already be applied.")
  print("Contents did not change, either patch is already applied or fixed version is being used.")
end

