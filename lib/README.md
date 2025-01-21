# Libraries
All the libraries within this folder is made by me, and are free to use. all I ask for is to keep the aweosme looking header of the libraries, in Figura, its trimmed away anyways by default, via the light compression mode.

I spend alot of time making sure each library is easy to digest if being read, while also trying to make the file size as small as it can be.

Feel free to DM me on discord `@gn8.` for help or questions about the lib.
## Layout
all my libraries are layed out in this specific order in every script, follow this map to make it easier for you to find what youre looking for inside the lib.

1. Info
```
--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / <Broader Title>
/ /_/ / /|  / <Description>
\____/_/ |_/ Source: <link to source code>]]
```
2. Imports
contains the dependencies of the library. placed at top to make it easy to find what the library needs.
```lua
local GNUI = require "GNUI.main"
local line = require "lib.line"
...
```
3. Utility Functions (optional)
contains private/utility functions that are used in the library.
```lua
local function utility(a)
  return a + 1
end
```
4. Class Declaration
contains the declaration of classes, via the [Sumneko Lua Language Server](https://github.com/LuaLS/lua-language-server/wiki/Annotations#tips). along side [GrandpaScout's Figura Rewrite VSDocs](https://github.com/GrandpaScout/FiguraRewriteVSDocs/tree/latest).
```lua
---@class MyClass
---@field public a number
---@field public b string
local MyClass = {}

```
5. Constructor
contains the function that creates an object from the class.
```lua
function MyClass.new()
  local new = {
      a = 1,
      b = "hello"
    }
    setmetatable(new, MyClass)
  return new
end
```
6. Metamethods
contains methods that the internal lua uses.
```lua
MyClass.__index = MyClass
MyClass.__type = "MyClass"
```

7. Methods
contains the methods that you can use.
```lua
---@param a number
---@return MyClass
function MyClass:setA(a)
  self.a = a
  return self
end

---@return number
function MyClass:getA()
  return self.a
end
```