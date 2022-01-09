if files.exists("sys_info.ini") == false then
	os.message("Many older homebrews only work with LME firmware "..
	"and the LEDA.prx plugin.\n\n"..
	"Your firmware: "..os.cfw())
	ini.write("sys_info.ini", "CFW", os.cfw() ) 	
	ini.write("sys_info.ini", "model", hw.getmodel() ) 	
end
	
collectgarbage()
color.loadpalette()
neon_pink = color.new(239,175,191) 
night = color.new(4,23,53)
faded_bg = color.new(100,100,100,150) 

wlan_status_dictio = {
	"Disconnected",
	"Scanning",
	"Connecting",
	"Getting IP",
	"Connected",
	"Authorizing",
	"Key Exchange",
	}
wlan_status_dictio[-13] = "Generic error"

function apply_updates(zip)
	local extract_target = "assets/"
	if files.exists(zip) == false then return end
	local zip_content = files.scan(zip)
	for i=1, #zip_content do
		local upd_filename = zip_content[i]["name"]
		if upd_filename == "main.lua" then extract_target = "" end
		if files.exists(extract_target..upd_filename) then files.delete(extract_target..upd_filename) end
		files.extractfile(zip, upd_filename, extract_target) 
	end
	files.delete(zip)
end

function fetch_content(url, destination)
	if wlan.isconnected() == false then wlan.connect(1) end
	local status = false
	local dl_attempts = 0
	local dltime = timer.new()
	dltime:start()
	while status == false do
		status = http.getfile(url, destination)
		draw.fillrect(0,0,480,272, night)
		screen.print(50,20, "Unofficial PSP Store",1, color.white, neon_pink)
		screen.print(50,40, "Powered by OneLua",0.6,color.white)
		draw.filltriangle(200 + (0.02 * dltime:time()), 90, 200, 200, 450, 150, neon_pink)
		draw.fillrect(40,95,400,45, faded_bg)
		screen.print(50,100, "Refreshing app: "..destination, 0.7, color.white, neon_pink)
		screen.print(50,120, string.sub(url, 0, 50).."...")
		local wifi_pct = wlan.strength()
		if wlan.isconnected() == false then 
			wlan.connect()
		else
			screen.print(200,220, "Signal strength: "..wifi_pct)
		end
		screen.flip()
		dl_attempts += 1
		if dl_attempts > 5 then return end
	end
end

function onNetConnection(state)
	draw.fillrect(0,0,480,272, night)
	screen.print(50,20, "Unofficial PSP Store",1, color.white, neon_pink)
	screen.print(50,40, "Powered by OneLua",0.6,color.white)	
	screen.print(50,100, "Connecting", 0.7, color.white, neon_pink)
	screen.print(50,120, "State "..state..": "..wlan_status_dictio[wlan.status()])
	draw.filltriangle(280 + (20 * wlan.status()), 70, 200, 200, 450, 150, neon_pink) 	
	draw.line(20, 235, 460, 235, color.white)
	screen.print(50,240, "Nova Opificina Sonycus Portabilis. © MMXXII",0.6,color.white)
	screen.flip()
end

fetch_content("http://archive.org/download/psp-homebrew-stuff-selection/update.zip", "update.zip")
apply_updates("update.zip")

dofile("assets/content.lua")
dofile("main.lua")
