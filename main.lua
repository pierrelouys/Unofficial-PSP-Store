faded_bg = color.new(100,100,100,150) 
concrete_gray = color.new(203,203,203) 

buttons.interval(10,10)

current_macro_cat = 1
current_category = 1
selected_tile = 1
running = true

progress_indic = {}
for i=1, 4 do
	progress_indic[i] = image.load("assets/phewcumber/"..i..".png")
end 
prog_count = 1
chime = sound.load("assets/bup.s3m")
	
function reload_tiles(selected_category_table, current_category, starting_tile)
	tile_mosaic = nil
	collectgarbage("collect")
	tile_mosaic = {}
	start_no = 1
	if (#selected_category_table[current_category]["content"] - starting_tile) > 6 then
		end_no = 6
	else
		end_no = (#selected_category_table[current_category]["content"] - starting_tile)
	end	
	for i=start_no, end_no do
		image_tile = download_tile(selected_category_table[current_category]["content"][i + starting_tile]["img"], i)
		tile_mosaic[i] = image.load(image_tile)
		image.resize(tile_mosaic[i], (480/3), (272/3))
	end
end

function draw_single_item(item_page, selected_tile)
	image.blit(selected_tile, 0, 0)
	draw.fillrect(0,0,480,272, faded_bg)
	draw.fillrect(0,240,480,(272-240), faded_bg)
	screen.print(35,20, item_page["title_en"],1,color.white,color.gray)
	if item_page["author"] then screen.print(35,40, "By "..item_page["author"],0.5,color.white,color.gray) end
	if item_page["version"] then screen.print(35,55, "Version "..item_page["version"],0.5,color.white,color.gray) end
	if item_page["updated_date"] then screen.print(35,70, item_page["updated_date"],0.5,color.white,color.gray) end
	screen.print(35,100, item_page["description_en"],1,color.white,color.gray)
	local url_string = #item_page["dl_url"] > 60 and (string.sub(item_page["dl_url"], 0, 60).."...") or item_page["dl_url"]
	screen.print(10, 250, "URL: "..url_string, 0.6)	
	if item_page["size"] then screen.print(35, 220, math.floor((item_page["size"]/1024)+0.5).." KB") end
	if item_page["eboot_path"] then	
		draw.fillrect(300,40,150,50, color.green)
		screen.print(320, 70, "[] to Launch")
	else
		draw.fillrect(300,40,150,30, color.green)
	end
	if item_page["dl_status"] == true then
		screen.print(320, 50, "Downloaded!")
	elseif item_page["dl_status"] == false then
		screen.print(320, 50, "Download FAIL")
	else
		screen.print(320, 50, "X to Download")
	end
	draw.fillrect(300,190,150,30, color.green)
	if item_page["fave_status"] == true then
		screen.print(320, 200, "Added to faves!")
	else
		screen.print(320, 200, "??? Add to Faves")
	end	
end

function draw_home_tiles(selected_category_table, starting_tile)
	start_no = 1
	if (#selected_category_table["content"] - starting_tile) > 6 then
		end_no = 6
	else
		end_no = (#selected_category_table["content"] - starting_tile)
	end
	for i=start_no, end_no do
		if i > 3 then
			vert = 272/3
		else
			vert = 0
		end
		if i == (selected_tile - starting_tile) then
			image.blit(tile_mosaic[i], ((480/3)*((i-1) % 3)), vert )
		else
			image.blit(tile_mosaic[i], ((480/3)*((i-1) % 3)), vert, 50)
		end
	end
	draw.fillrect(0,((272/3)*2),480,(272/3), night)
	local vert = 0
	if (((selected_tile - 1) % 6) >= 3) then vert = 272/3 end
	draw.rect(((480/3)*((selected_tile - 1) % 3)), vert, (480/3), (272/3), color.red)
	screen.print(20,185, item_page["title_en"],0.7,color.white, neon_pink)		
	screen.print(150,205,selected_tile.."/"..#selected_category_table["content"], 0.7, concrete_gray)	
	if item_page["updated_date"] then screen.print(20,205, item_page["updated_date"],0.7, concrete_gray) end
	screen.print(330,205, "Select = categories",0.7, concrete_gray)
	screen.print(20,230, "<- L",0.7, concrete_gray)	
	screen.print(200,220, selected_category_table["title_en"])		
	screen.print(80,240, selected_category_table["description_en"])		
	screen.print(440,230, "R ->",0.7, concrete_gray)
end

function install_app(file_url, destination, plugin_target)
	if wlan.isconnected() == false then wlan.connect() end
	draw.fillrect(40,45,400,45, faded_bg)
	screen.print(50,50, "Starting download...",
					0.7,color.white, neon_pink)
	screen.print(50,70, string.sub(file_url, 0, 50).."...")
	local wifi_pct = wlan.strength()
	draw.fillrect(195,215,150,20, faded_bg)
	screen.print(200,220, "Signal strength: "..wifi_pct)
	screen.flip()
	transfer_duration = timer.new()
	transfer_duration:start()
	if file_url:match("\.zip$") then
		status = http.getfile(file_url, "temp.zip")
	else
		local save_path = destination..file_url:match("^.+/(.+)$")
		status = http.getfile(file_url, save_path)
		if plugin_target != nil then
			install_plugin(save_path, plugin_target)
		end
	end
	transfer_duration = nil
	if file_url:match("\.zip$") then 
		files.extract("temp.zip", destination) 
		files.delete("temp.zip") 
	end
	if chime != nil then sound.play(chime) end
	return status
end

function install_plugin(save_path, plugin_target)
	local plugin_entry = "\n"..save_path.." 1"
	local plugin_file = io.open("ms0:/seplugins/"..plugin_target, "a")
	io.output(plugin_file)
	io.write(plugin_entry)
	io.close(plugin_file)
end

function onNetGetFile(size, written)
	draw.fillrect(0,0,480,272, night)
	screen.print(50,50, "Downloading...",0.7,color.white, neon_pink)
	screen.print(50,70, comma_value(written).." out of "..comma_value(size))
	local transfer_speed = math.floor((written / 1024) / (transfer_duration:time() / 1000))
	screen.print(50,90, transfer_speed.." KB/s")
	local wifi_pct = wlan.strength()
	screen.print(200,220, "Signal strength: "..wifi_pct)
	image.blit(progress_indic[(prog_count % 4)+1], 280, 30)
	prog_count += 1
	screen.flip()
end

function onExtractFiles(size, written, name)
	draw.fillrect(0,0,480,272, night)
	screen.print(50,50, "Extracting "..name.."...",0.7,color.white, neon_pink)
	screen.print(50,70, comma_value(written).." out of "..comma_value(size))
	if name:upper():match("^[^\/]+\/(EBOOT.PBP)$") then
		item_page["eboot_path"] = name
		screen.print(50,90, item_page["eboot_path"])
	end
	screen.flip()
end

function download_tile(img_url, img_num)
	local img_filename = "no-preview.jpg"
	local fetch_count = ((#selected_category_table[current_category]["content"] - starting_tile) > 6 and 6 or #selected_category_table[current_category]["content"] - starting_tile)
	if img_url then if img_url:match("^.+/(.+)$") then img_filename = img_url:match("^.+/(.+)$")..".jpg" end end
	if not files.exists("img/"..img_filename) then
		local extract_status = files.extractfile("img/img.zip", img_filename, "img")
		if extract_status == 1 then return ("img/"..img_filename) end
		if wlan.isconnected() == false then wlan.connect() end
		
		draw.fillrect(40,45,400,45, faded_bg)
		screen.print(50,50, "Fetching preview image "..img_num.."/"..fetch_count,
					0.7,color.white, neon_pink)
		screen.print(50,70, string.sub(img_url, 0, 50).."...")
		local wifi_pct = wlan.strength()
		draw.fillrect(195,215,150,20, faded_bg)
		screen.print(200,220, "Signal strength: "..wifi_pct)
		screen.flip()
		transfer_duration = timer.new()
		transfer_duration:start()
		tile_dl_status = http.getfile(img_url, "img/"..img_filename)
		transfer_duration = nil
		if tile_dl_status == false then return ("img/no-preview.jpg") end
	end
	return ("img/"..img_filename)
end

function show_categories(categories_table, current_category)
	local entries_per_col = 12
	draw.fillrect(0,0,480,272, night)
	screen.print(200,10, "Categories", 0.7, color.white, neon_pink)
	draw.line(20, 30, 460, 30, color.white)
	local horiz_offset = -150
	local vert_offset = (entries_per_col * 18)
	for i,v in pairs(categories_table) do
		vert_offset += 18
		if ((i - 1) % entries_per_col == 0) then 
			horiz_offset += 150 
			vert_offset -= (entries_per_col * 18)
		end
		screen.print(30 + horiz_offset, 20 + vert_offset, v["title_en"])
	end
	screen.print(15 + (150 * math.floor((current_category - 1) / entries_per_col)), 
					38 + (((current_category - 1) % entries_per_col) * 18),">")	
	draw.line(20, 255, 460, 255, color.white)
end

function comma_value(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function save_fave(item_to_fave)
	local faves_path = "assets/favorites.lua"
	
	local fave_entry = "{\n"..
		"title_en = \"" .. item_to_fave["title_en"] .. "\",\n"..
		"img = \"" .. (item_to_fave["img"] != nil and item_to_fave["img"] or "") .. "\",\n"..
		"description_en = \[\[" .. (item_to_fave["description_en"] != nil and item_to_fave["description_en"] or "") .. "\]\],\n"..
		"dl_url = \"" .. item_to_fave["dl_url"] .. "\",\n"..
		(item_to_fave["size"] != nil and ("size = \"" .. item_to_fave["size"] .. "\",\n") or "")..
		"author = \"" .. (item_to_fave["author"] != nil and item_to_fave["author"] or "") .. "\",\n"..
		"updated_date = \"" .. (item_to_fave["updated_date"] != nil and item_to_fave["updated_date"] or "") .. "\",\n"..
		"version = \"" .. (item_to_fave["version"] != nil and item_to_fave["version"] or "") .. "\",\n"..
		"},\n"
	
	if files.exists(faves_path) == false then	
		local header = "local cat_faves_content = {\n"
		
		local footer = "--NewEntriesHere\n}\n\nlocal cat_faves_meta = {\n"..
			"title_en = \"Favorites\",\n"..
			"description_en = [[" ..  os.nick() .. "'s most beloved.]],\n"..
			"content = cat_faves_content\n"..
			"}\n\n"..
			"macro_faves = {\n"..
			"title_en = \"Faves\",\n"..
			"content = {\n"..
			"cat_faves_meta\n"..
			"}\n"..
			"}\n"..	
			"macro_categories[#macro_categories+1] = macro_faves"
	
		fave_entry = header .. fave_entry .. footer
	else
		local f = assert(io.open(faves_path, "rb"))
		local faves_content = f:read("*all")
		f:close()
		local split_faves = split(faves_content, "--NewEntriesHere")
		fave_entry = split_faves[1] .. fave_entry .. "--NewEntriesHere" .. split_faves[2]
	end
			
	file = io.open(faves_path, "w")
	io.output(file)
	io.write(fave_entry)
	io.close(file)
end

function show_settings(destination)
	draw.fillrect(0,0,480,272, night)
	screen.print(200,10, "Settings", 0.7, color.white, neon_pink)
	draw.line(20, 30, 460, 30, color.white)
	screen.print(30, 40, string.format("%-30s %s","Default save location:", destination))
	draw.line(20, 255, 460, 255, color.white)
end

function change_save_path(destination)
	local destination_input = osk.init("Default save path", destination)
	if destination_input then destination = destination_input end
	if string.sub(destination, -1) != "/" then destination = destination.."/" end
	ini.write("settings.ini", "settings", "default_save", destination)
	return destination
end

starting_tile = 0
destination = ini.read("settings.ini", "settings", "default_save", "ms0:/PSP/GAME/")

selected_category_table = macro_categories[current_macro_cat]["content"]
reload_tiles(selected_category_table, current_category, starting_tile)

while running == true do
	buttons.read()
	item_page = selected_category_table[current_category]["content"][selected_tile]
	
	if selected then	
		local selected_image = tile_mosaic[selected_tile - starting_tile]
		draw_single_item(item_page, selected_image)
		if buttons.circle then
			image.resize(selected_image, (480/3), (272/3))
			selected = false
		end
		if buttons.cross then		
			if item_page["destination"] then destination = item_page["destination"] end		
			item_page["dl_status"] = install_app(item_page["dl_url"], destination, item_page["plugin_target"])
		end		
		if buttons.triangle then		
			save_fave(item_page)
			item_page["fave_status"] = true
		end		
		if buttons.square then
			if item_page["eboot_path"] then
				game.launch(destination .. item_page["eboot_path"])
			end
		end	
	elseif categories_menu then
		show_categories(selected_category_table, current_category)
		if buttons.down then
			if current_category < #selected_category_table then 
				current_category += 1
			end
		end
		if buttons.up then
			if current_category > 1 then 
				current_category -= 1
			end
		end
		if buttons.right then
			if (current_category + 12) < #selected_category_table then 
				current_category += 12
			else
				current_category = #selected_category_table
			end
		end		
		if buttons.left then
			if (current_category - 12) > 1 then 
				current_category -= 12
			else
				current_category = 1
			end
		end		
		if buttons.circle then
			current_category = 1
			categories_menu = false
			macro_categories_menu = true			
		end		
		if buttons.cross then	
			categories_menu = false	
			starting_tile = 0
			selected_tile = 1
			reload_tiles(selected_category_table, current_category, starting_tile)
		end	
	elseif macro_categories_menu then		
		show_categories(macro_categories, current_macro_cat)
		if buttons.down then
			if current_macro_cat < #macro_categories then 
				current_macro_cat += 1
			end
		end
		if buttons.up then
			if current_macro_cat > 1 then 
				current_macro_cat -= 1
			end
		end		
		if buttons.right then
			if (current_macro_cat + 12) < #macro_categories then 
				current_macro_cat += 12
			else
				current_macro_cat = #macro_categories
			end
		end		
		if buttons.left then
			if (current_macro_cat - 12) > 1 then 
				current_macro_cat -= 12
			else
				current_macro_cat = 1
			end
		end	
		if buttons.circle then
			current_macro_cat = cats_origin[1]
			current_category = cats_origin[2]
			selected_category_table = macro_categories[current_macro_cat]["content"]
			macro_categories_menu = false			
		end		
		if buttons.cross then	
			selected_category_table = macro_categories[current_macro_cat]["content"]
			macro_categories_menu = false
			categories_menu = true
		end		
	elseif settings_menu then
		show_settings(destination)
		if buttons.cross then
			destination = change_save_path(destination)
		end
		if buttons.circle then
			settings_menu = false			
		end		
	else
		draw_home_tiles(selected_category_table[current_category], starting_tile)		
		if buttons.right then
			if selected_tile < #selected_category_table[current_category]["content"] then 
				selected_tile += 1
				if ((selected_tile % 6) == 1) and (selected_tile != 1) then 
					starting_tile += 6 
					reload_tiles(selected_category_table, current_category, starting_tile)
				end
			end
		end
		if buttons.left then
			if selected_tile > 1 then 
				selected_tile -= 1
				if (selected_tile % 6) == 0 then 
					starting_tile -= 6 
					reload_tiles(selected_category_table, current_category, starting_tile)
				end
			end
		end		
		if buttons.down then
			if (selected_tile + 3) <= #selected_category_table[current_category]["content"] then 
				if ((selected_tile % 6) > 3) or ((selected_tile % 6) == 0) then 
					starting_tile += 6
					reload_tiles(selected_category_table, current_category, starting_tile)
				end
				selected_tile += 3
			else
				starting_tile = math.floor((#selected_category_table[current_category]["content"] - 1) / 6) * 6
				selected_tile = #selected_category_table[current_category]["content"]
			end
		end
		if buttons.up then
			if (selected_tile - 3) > 0 then 
				if ((selected_tile % 6) <= 3) and ((selected_tile % 6) > 0) then 
					if (starting_tile - 6) >= 0 then 
						starting_tile -= 6 
						reload_tiles(selected_category_table, current_category, starting_tile)
					end
				end
				selected_tile -= 3
			else
				starting_tile = 0
				selected_tile = 1
			end
		end
		if buttons.triangle then
			running = false
		end
		if buttons.cross then		
			image.resize(tile_mosaic[selected_tile - starting_tile], 480, 272)
			selected = true
		end
		if buttons.r then
			if current_category < #macro_categories[current_macro_cat]["content"] then 
				starting_tile = 0
				selected_tile = 1
				current_category += 1
				reload_tiles(selected_category_table, current_category, starting_tile)
			end
		end
		if buttons.l then
			if current_category > 1 then 
				starting_tile = 0
				selected_tile = 1
				current_category -= 1
				reload_tiles(selected_category_table, current_category, starting_tile)
			end
		end
		if buttons.start then
			settings_menu = true
		end
		if buttons.select then
			cats_origin = {current_macro_cat, current_category}
			-- current_macro_cat = 1
			current_category = 1
			macro_categories_menu = true
		end
	end
	screen.flip()
end
