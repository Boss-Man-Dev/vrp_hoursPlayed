--##########	VRP Main	##########--
-- init vRP server context
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP()

local pvRP = {}
-- load script in vRP context
pvRP.loadScript = module
Proxy.addInterface("vRP", pvRP)

local cfg = module("vrp_hoursPlayed", "cfg/cfg")
local Hours = class("Hours", vRP.Extension)

function Hours:__construct()
    vRP.Extension.__construct(self)
	
	Citizen.CreateThread(function()
		while true do
			Wait(cfg.timer)
			self.remote._updateHours(cfg.hours)	
		end
	end)
end

vRP:registerExtension(Hours)