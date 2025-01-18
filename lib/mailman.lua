--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Mailman.
/ /_/ / /|  / a communication system for avatars. v1.0
\____/_/ |_/ Source: link]]

-- DEPENDENCIES
local eventLib = require("./eventLib")

-- CONFIG
local VERBOSE = false -- whether to print debug actions

local ACCENT = host:isHost() and "red" or "blue"

---@param uuid stringUUID
---@return string
local function dispUUID(uuid)
	if uuid then
		return uuid:sub(1,3) .. "..." .. uuid:sub(-3,-1)
	end
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
---
---@field content table
---@field onRecive fun(id:stringUUID,content:table)?

---@alias ParcelType string
---| "SEND" -- 1st packet
---| "BACK" -- 2nd packet
---| "CONF" -- 3rd packet

-->====================[ Peer ]====================<--

---@type Mailman.Peer[]
local peers = {}

---@class Mailman.Peer
---@field package __index table
---@field username string
---@field owner stringUUID # the UUID of the Entity
---@field id integer # the unique id of the Peer
---@field RECIVED EventLib # Gets called when the peer recives a packet. Parameters: `metadata: table`,`callbackData: table`, `packetData: ...`
---@field SENT EventLib
--- -- Syncronization tables
---@field package waitingRecive table<string,{config:table,onRecive:fun(id:stringUUID,content:table)?}>
---@field package waitingConfirm table<string,{content:table,confirm:fun()?}>
---@field package waitingForBack table<string,table>
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
      waitingRecive = {},
		waitingConfirm = {},
		waitingForBack = {},
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
---@return Mailman.Peer
function Peer:recive(parcelData)
   if VERBOSE then
      printJson(toJson({{text="-----"},
         {text="[RECIVE]\n",color=ACCENT},
         {text="F:",color=ACCENT},
         {text=" H"},{text=" : "},{text=dispUUID(parcelData.senderUUID),color="gray"},
         {text=" P"},{text=" : "},{text=parcelData.senderPeerID,color="gray"},
         {text="\nT:",color=ACCENT},
         {text=" H"},{text=" : "},{text=dispUUID(parcelData.reciverUUID),color="gray"},
         {text=" P"},{text=" : "},{text=parcelData.reciverPeerID,color="gray"},
         {text="\nPacket:",color=ACCENT},
         {text="\n  ID:"},{text=" : "},{text=dispUUID(parcelData.parcelUUID),color="gray"},
         {text="\n  Data:"},{text=" : "},{text=toJson(parcelData.content),color="gray"},
         {text="\n"}}))
   end
   local parcelUUID = parcelData.parcelUUID
	
   if parcelData.type == "SEND" then
      self:send({
         target = parcelData.senderUUID,
         targetID = parcelData.senderPeerID,
         uuid = parcelUUID,
         sendType = "BACK",
      })
		local content = parcelData.content
		self.waitingConfirm[parcelUUID] = {
			confirm = function ()
				self.RECIVED:invoke(content)
				self.waitingConfirm[parcelUUID] = nil
			end
		}
	elseif parcelData.type == "BACK" then
		if self.waitingForBack[parcelUUID] then
			self.SENT:invoke(self.waitingForBack[parcelUUID])
			self.waitingForBack[parcelUUID] = nil
		end
	elseif parcelData.type == "CONF" then
		local confirmingParcel = self.waitingConfirm[parcelUUID]
		if confirmingParcel then
			confirmingParcel.confirm()
		end
   end
   
   if self.waitingRecive[parcelUUID] then
		self:send({
			target = parcelData.senderUUID,
			targetID = parcelData.senderPeerID,
			uuid = parcelUUID,
			sendType = "CONF",
		})
		if self.waitingRecive[parcelUUID].onRecive then
			self.waitingRecive[parcelUUID].onRecive(parcelUUID,parcelData.content)
		end
      self.waitingRecive[parcelUUID] = nil
   end
   return self
end

function pings.MAILMANSEND(data)
   local senderUUID,senderPeerID,reciverUUID,reciverPeerID,parcelUUID,parcelType,parcelContent = table.unpack(data)
   senderUUID = unpackUUID(senderUUID)
   senderPeerID = senderPeerID
   reciverUUID = unpackUUID(reciverUUID)
   reciverPeerID = reciverPeerID
   parcelUUID = unpackUUID(parcelUUID)
	
	peers[reciverPeerID].waitingForBack[parcelUUID] = parcelContent
   
	if VERBOSE then
      printJson(toJson({{text="-----"},
         {text="[SEND]\n",color=ACCENT},
         {text="F:",color=ACCENT},
         {text=" H"},{text=" : "},{text=dispUUID(senderUUID),color="gray"},
         {text=" P"},{text=" : "},{text=senderPeerID,color="gray"},
         {text="\nT:",color=ACCENT},
         {text=" H"},{text=" : "},{text=dispUUID(reciverUUID),color="gray"},
         {text=" P"},{text=" : "},{text=reciverPeerID,color="gray"},
         {text="\nPacket:",color=ACCENT},
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
---@param config {unsafe?:boolean,target:stringUUID,targetID:integer?,onRecive:fun(id:string,content:table)?,id:stringUUID,content:table}
function Peer:send(config)
   local uuid = config.uuid or UUID()
	local percelData = {
		packUUID(self.owner),
      self.id,
      packUUID(config.target),
      config.targetID or 1,
      packUUID(uuid),
---@diagnostic disable-next-line: undefined-field
      config.sendType or "SEND",
      config.content,
   }
	if (not config.unsafe) or config.onRecive then
		config.uuid = uuid
		self.waitingRecive[uuid] = {config = config, onRecive = config.onRecive}
	end
   pings.MAILMANSEND(percelData)
end

do
	local timer = 20
	local peer,peerID
	local packetCfg,packetID
	
	events.WORLD_TICK:register(function ()
		if timer > 20 and #peers > 0 then timer = 0
			if peer and next(peer.waitingRecive) then
				while not packetCfg do
					packetID,packetCfg = next(peer.waitingRecive,packetID)
				end
				peer:send(packetCfg.config)
			end
			while not peer do
				peerID,peer = next(peers,peerID)
			end
		end
		timer = timer + 1
	end)
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
---@param uuid string
---@param reciverPeerID integer
---@param type ParcelType
---@param content table
function MAILMAN.request(senderUUID,senderPeerID,reciverPeerID,uuid,type,content)
   if VERBOSE then
      printJson(toJson({{text="-----"},
         {text="[MAILMAN]\n",color=ACCENT},
         {text="F:",color=ACCENT},
         {text=" H"},{text=" : "},{text=dispUUID(senderUUID),color="gray"},
         {text=" P"},{text=" : "},{text=senderPeerID,color="gray"},
         {text="\nT:",color=ACCENT},
         {text=" H"},{text=" : "},{text=dispUUID(hostUUID),color="gray"},
         {text=" P"},{text=" : "},{text=reciverPeerID,color="gray"},
         {text="\nPacket:",color=ACCENT},
         {text="\n  ID:"},{text=" : "},{text=dispUUID(uuid),color="gray"},
         {text="\n  Data:"},{text=" : "},{text=toJson({content}),color="gray"},
         {text="\n"}}))
   end
   ---@type Parcel
   local parcelData = {
      senderUUID = senderUUID,
      senderPeerID = senderPeerID,
      reciverUUID = hostUUID,
      reciverPeerID = reciverPeerID,
      parcelUUID = uuid,
      type = type,
		content = content,
   }
   if peers[reciverPeerID] then -- recives the parcel
      peers[reciverPeerID]:recive(parcelData)
      return true
   else
      return false
   end
end

avatar:store("Mailman",MAILMAN)

return Peer