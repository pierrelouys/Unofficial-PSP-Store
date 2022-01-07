collectgarbage()
color.loadpalette()
neon_pink = color.new(239,175,191) 
night = color.new(4,23,53) 

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
		print(upd_filename)
		if upd_filename == "main.lua" then extract_target = "" end
		files.extractfile(zip, upd_filename, extract_target) 	
	end
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
		screen.print(50,50, "Refreshing app: "..destination, 0.7, color.white, neon_pink)
		screen.print(50,70, url)
		draw.filltriangle(200 + (0.02 * dltime:time()), 90, 200, 200, 450, 150, neon_pink)
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
	draw.line(20, 35, 460, 35, color.white)
	screen.print(50,50, "Connecting", 0.7, color.white, neon_pink)
	screen.print(50,70, "State "..state)
	screen.print(50,90, wlan_status_dictio[wlan.status()] )
	draw.filltriangle(280 + (20 * wlan.status()), 70, 200, 200, 450, 150, neon_pink) 	
	draw.line(20, 235, 460, 235, color.white)
	screen.print(50,240, "Nova Opificina Sonycus Portabilis. © MMXXII",0.6,color.white)
	screen.flip()
end

fetch_content("http://archive.org/download/psp-homebrew-stuff-selection/update.zip", "update.zip")
apply_updates("update.zip")

dofile("assets/content.lua")
dofile("main.lua")
