local lang = vRP.lang
local Luang = module("vrp", "lib/Luang")

local Hours = class("Hours", vRP.Extension)
local htmlEntities = module("lib/htmlEntities")

Hours.event = {}
Hours.tunnel = {}

hoursPlayed = {}

function Hours:__construct()
	vRP.Extension.__construct(self)
	
	self.cfg = module("vrp_hoursPlayed", "cfg/cfg")
	
	-- load lang
	self.luang = Luang()
	self.luang:loadLocale(vRP.cfg.lang, module("vrp_hoursPlayed", "cfg/lang/"..vRP.cfg.lang))
	self.lang = self.luang.lang[vRP.cfg.lang]
	
	-- Registers a command name.
	RegisterCommand(self.cfg.command, function(source) 
		vRP:triggerEvent("getHours", source)
	end, false --[[this command is not restricted, everyone can use this.]])
	
	async(function()
    -- init sql
    vRP:prepare("vRP/hours_tables", [[
		CREATE TABLE IF NOT EXISTS vrp_hours_played(
			user_id INTEGER AUTO_INCREMENT,
			hours_played decimal(5,2),
			CONSTRAINT pk_hours PRIMARY KEY(user_id),
			CONSTRAINT fk_hours_vrp FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
		);
    ]])

	vRP:prepare("vRP/init_hours", "INSERT IGNORE INTO vrp_hours_played(user_id, hours_played) VALUES(@user_id, 0)")
    vRP:prepare("vRP/get_base", "SELECT * FROM vrp_hours_played WHERE user_id = @user_id")
	vRP:prepare("vRP/get_hours_played", "SELECT hours_played FROM vrp_hours_played WHERE user_id = @user_id")
	vRP:prepare("vRP/update_hours", "UPDATE vrp_hours_played SET hours_played = @hours WHERE user_id = @user_id")

    vRP:execute("vRP/hours_tables")
  end)
end

function Hours.event:getHours(source)
	local user = vRP.users_by_source[source]
	local row = vRP:query("vRP/get_hours_played", {user_id = user.cid})
	local hours = row[1].hours_played
	if not hours then hours = 0 end
	
	local minutes = hours - math.floor(tonumber(hours))
	hoursPlayed[user.cid] = tonumber(hours)
	
	if hours ~= nil then
		vRP.EXT.Base.remote._notify(user.source, self.lang.hours_played({math.floor(tonumber(hours)), math.floor(minutes * self.cfg.convert)}))
	end
end

function Hours.event:updateHours(hours)
	for _, user in pairs(vRP.users) do
		local id = user.cid
		newHour = hoursPlayed[id] + hours	--update database time
		hoursPlayed[id] = newHour			-- update hoursPlayed table
		
		vRP:execute("vRP/update_hours", {user_id = user.cid, hours = newHour})
	end
end

function Hours.event:characterLoad(user)
	-- load hours played
	local id = user.cid
	local rows = vRP:query("vRP/get_base", {user_id = user.cid})
	if #rows > 0 then -- loaded
		hoursPlayed[id] = tonumber(rows[1].hours_played)
	else -- create 
		vRP:execute("vRP/init_hours", {user_id = user.cid})
	end
end

function Hours.tunnel:updateHours(hours)
	vRP:triggerEvent("updateHours", hours)
end

vRP:registerExtension(Hours)