--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Mailman.
/ /_/ / /|  / a simple communication system for avatars.
\____/_/ |_/ Source: link]]

-- DEPENDENCIES
local eventLib = require("./event")

-- CONFIG
local VERBOSE = true -- whether to print debug actions

--

---@param uuid stringUUID
---@return string
local function dispUUID(uuid)
   return uuid:sub(1,3) .. "..." .. uuid:sub(-3,-1)
end

---@param uuid stringUUID
local function packUUID(uuid)
   uuid = uuid:gsub("-", "")
   local newUuid = ""
   for i = 1, 32, 2 do
      newUuid = newUuid..string.char(tonumber(uuid:sub(i, i + 1), 16))
   end
   return newUuid
end

local uuidDashes = {[4] = true, [6] = true, [8] = true, [10] = true}
---@param uuid stringUUID
local function unpackUUID(uuid)
   local newUuid = ""
   for i = 1, 16 do
      newUuid = newUuid..string.format("%02x", string.byte(uuid:sub(i, i)))
      if uuidDashes[i] then newUuid = newUuid.."-" end
   end
   return newUuid
end

local function UUID()
   return client.intUUIDToString(client.generateUUID())
end

-->====================[ Parcel ]====================<--
---@class stringUUID : string

---@class Parcel
---@field parcelUUID string
---@field type ParcelType
---
---@field senderUUID stringUUID
---@field senderPeerID integer
---
---@field reciverUUID stringUUID
---@field reciverPeerID integer

---@alias ParcelType string
---| "SEND"
---| "BACK"

-->====================[ Peer ]====================<--

---@type Mailman.Peer[]
local peers = {}

---@class Mailman.Peer
---@field username string
---@field owner stringUUID # the UUID of the Entity
---@field id integer # the unique id of the Peer
---@field RECIVED EventLib # Gets called when the peer recives a packet. Parameters: `metadata: table`,`callbackData: table`, `packetData: ...`
---@field SENT EventLib
---@field package waitingRecive table<string,fun(id:string,content:table)>
local Peer = {}
Peer.__index = Peer

local next_free = 0
---Creates a new Peer.
---@param username string?
---@return Mailman.Peer
function Peer.newPeer(username)
   next_free = next_free + 1
   local self = {
      username = username,
      owner = user:getUUID(),
      id = next_free,
      RECIVED = eventLib.newEvent(),
      SENT = eventLib.newEvent(),
      waitingRecive = {}
   }
   setmetatable(self,Peer)
   peers[self.id] = self
   return self
end

-->==========[ More Peers ]==========<--

---@class Mailman.ReciveData
---@field parcelData Parcel
---@field content table
---@field returnData table

---Makes the peer recive a packet
---@param parcelData Parcel
---@param content table
---@return Mailman.Peer
function Peer:recive(parcelData,content)
   if VERBOSE then
      printJson(toJson({{text="-----"},
         {text="[RECIVE]\n",color="red"},
         {text="F:",color="red"},
         {text=" H"},{text=" : "},{text=dispUUID(parcelData.senderUUID),color="gray"},
         {text=" P"},{text=" : "},{text=parcelData.senderPeerID,color="gray"},
         {text="\nT:",color="red"},
         {text=" H"},{text=" : "},{text=dispUUID(parcelData.reciverUUID),color="gray"},
         {text=" P"},{text=" : "},{text=parcelData.reciverPeerID,color="gray"},
         {text="\nPacket:",color="red"},
         {text="\n  ID:"},{text=" : "},{text=dispUUID(parcelData.parcelUUID),color="gray"},
         {text="\n  Data:"},{text=" : "},{text=toJson(content),color="gray"},
         {text="\n"}}))
   end
   local parcelUUID = parcelData.parcelUUID
   local data = {
      parcelData = parcelData,
      content = content,
      returnData = {}
   }
   self.RECIVED:invoke(data)
   if parcelData.type == "SEND" then
      self:send({
         target = parcelData.senderUUID,
         targetID = parcelData.senderPeerID,
         id = parcelUUID,
         sendType = "BACK",
         content = data.returnData
      })
   end
   
   if self.waitingRecive[parcelUUID] then
      self.waitingRecive[parcelUUID](parcelUUID,content)
      self.waitingRecive[parcelUUID] = nil
   end
   return self
end

function pings.MAILMANSEND(data)
   local senderUUID,senderPeerID,reciverUUID,reciverPeerID,parcelUUID,parcelType,parcelContent = table.unpack(data)
   if peers[senderPeerID] then
      peers[senderPeerID].SENT:invoke({
         senderUUID = senderUUID,
         senderPeerID = senderPeerID,
         reciverUUID = reciverUUID,
         reciverPeerID = reciverPeerID,
         parcelUUID = parcelUUID,
         type = parcelType,
         content = parcelContent
      })
   end
   senderUUID = unpackUUID(senderUUID)
   senderPeerID = senderPeerID
   reciverUUID = unpackUUID(reciverUUID)
   reciverPeerID = reciverPeerID
   parcelUUID = unpackUUID(parcelUUID)
   if VERBOSE then
      printJson(toJson({{text="-----"},
         {text="[SEND]\n",color="red"},
         {text="F:",color="red"},
         {text=" H"},{text=" : "},{text=dispUUID(senderUUID),color="gray"},
         {text=" P"},{text=" : "},{text=senderPeerID,color="gray"},
         {text="\nT:",color="red"},
         {text=" H"},{text=" : "},{text=dispUUID(reciverUUID),color="gray"},
         {text=" P"},{text=" : "},{text=reciverPeerID,color="gray"},
         {text="\nPacket:",color="red"},
         {text="\n  ID:"},{text=" : "},{text=dispUUID(parcelUUID),color="gray"},
         {text="\n  Data:"},{text=" : "},{text=toJson(parcelContent),color="gray"},
         {text="\n"}}))
   end
   ---@type table<string,{Mailman:Mailman?}>
   local avatarVars = world.avatarVars()
   if avatarVars[reciverUUID] and avatarVars[reciverUUID].Mailman then -- Mailman Exists
      avatarVars[reciverUUID].Mailman.request(senderUUID,senderPeerID,reciverPeerID,parcelUUID,parcelType,parcelContent)
   end
end



---Sends a parcel to a Peer with the matching host UUID and peer UUID.
---@param config {target:stringUUID,targetID:integer?,onRecive:fun(id:string,content:table)?,id:stringUUID,content:table,sendType:"SEND"|"BACK"?}
function Peer:send(config)
   local id = UUID()
   if config.onRecive then self.waitingRecive[id] = config.onRecive end
   pings.MAILMANSEND({
      packUUID(self.owner),
      self.id,
      packUUID(config.target),
      config.targetID or 1,
      packUUID(id),
      config.sendType or "SEND",
      config.content
   })
end

-->====================[ Mailman ]====================<--
local hostUUID
events.ENTITY_INIT:register(function ()
   hostUUID = user:getUUID()
end)
---@class Mailman
MAILMAN = {}
MAILMAN.__index = MAILMAN


---Returns a list of the peers in this Avatar.
---@return integer[]
function MAILMAN.getPeerUUIDList()
   local list = {}
   for i, peer in pairs(peers) do
      list[#list+1] = peer.id
   end
   return list
end

---Gives a list of every other reachable Mailman.
---@return string[]
function MAILMAN.getMailmanUUIDList()
   local avatarVars = world.avatarVars()
   local list = {}
   for uuid, value in pairs(avatarVars) do
      if uuid ~= hostUUID and value.Mailman then
         list[#list+1] = uuid
      end
   end
   return list
end

---Gives the given peer of this mailman's reach a parcel.
---@param senderUUID string
---@param senderPeerID integer
---@param id string
---@param reciverPeerID integer
---@param type ParcelType
---@param content table
function MAILMAN.request(senderUUID,senderPeerID,reciverPeerID,id,type,content)
   if VERBOSE then
      printJson(toJson({{text="-----"},
         {text="[MAILMAN]\n",color="red"},
         {text="F:",color="red"},
         {text=" H"},{text=" : "},{text=dispUUID(senderUUID),color="gray"},
         {text=" P"},{text=" : "},{text=senderPeerID,color="gray"},
         {text="\nT:",color="red"},
         {text=" H"},{text=" : "},{text=dispUUID(hostUUID),color="gray"},
         {text=" P"},{text=" : "},{text=reciverPeerID,color="gray"},
         {text="\nPacket:",color="red"},
         {text="\n  ID:"},{text=" : "},{text=dispUUID(id),color="gray"},
         {text="\n  Data:"},{text=" : "},{text=toJson({content}),color="gray"},
         {text="\n"}}))
   end
   ---@type Parcel
   local metadata = {
      senderUUID = senderUUID,
      senderPeerID = senderPeerID,
      reciverUUID = hostUUID,
      reciverPeerID = reciverPeerID,
      parcelUUID = id,
      type = type
   }
   if peers[reciverPeerID] then -- recives the parcel
      peers[reciverPeerID]:recive(metadata,content)
      return true
   else
      return false
   end
end

avatar:store("Mailman",MAILMAN)

return Peer