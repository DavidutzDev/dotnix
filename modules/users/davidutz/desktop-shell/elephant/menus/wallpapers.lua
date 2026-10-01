Name = "wallpapers"
NamePretty = "Wallpapers"
Icon = ""
HideFromProviderlist = false
Cache = false
Action = "awww img '%VALUE%'"

local function sanitize(filename)
	local name = filename:gsub("%.[^%.]+$", "")
	name = name:gsub("-", " ")
	name = name:gsub("%S+", function(word)
		return word:sub(1, 1):upper() .. word:sub(2):lower()
	end)
	return name
end

function GetEntries()
	local entries = {}
	local wallpaper_dir = os.getenv("HOME") .. "/Pictures/Wallpapers"
	local cmd = "find -L '"
		.. wallpaper_dir
		.. "' -maxdepth 1 -type f "
		.. [[\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' ]]
		.. [[-o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) 2>/dev/null]]
	local handle = io.popen(cmd)
	if handle then
		for line in handle:lines() do
			local filename = line:match("([^/]+)$")
			if filename then
				table.insert(entries, {
					Text = sanitize(filename),
					Subtext = "wallpaper",
					Value = line,
					Icon = line,
				})
			end
		end
		handle:close()
	end
	return entries
end
