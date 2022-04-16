local cfg = {}

cfg.command = "time"

--(60,000 milliseconds - 1 minute)
cfg.timer = 15 * 60000	-- 15 minutes 
cfg.hours = 0.25

cfg.convert = 100 * 0.60	--gets current time to minutes with 0.25 (0.25 * 100 *0.60 = 15 minutes)

return cfg