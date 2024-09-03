local scriptures = {
	["John 3:16"] = "For God loved the world so much he gave his only begotten son so that every one excercising faith in him might not be destroyed but have everlasting life.",
	["John 17:3"] = "This means everlasting life, there coming to know you the only true God and the one whome you sent, Jesus Christ",
	["Revelations 21:3,4"] = "3 With that I heard a loud voice from the throne say: “Look! The tent of God is with mankind, and he will reside with them, and they will be his people. And God himself will be with them. 4  And he will wipe out every tear from their eyes, and death will be no more, neither will mourning nor outcry nor pain be anymore. The former things have passed away.",
}

local function get_length_of_table(table)
	local length = 0
	for k, v in pairs(table) do
		length = length + 1
	end
	return length
end

local function get_random_scripture(scripture_table, index)
	local current_index = 0
	for k, v in pairs(scripture_table) do
		if index == current_index then
			return { k, v }
		end
		current_index = current_index + 1
	end
	return nil
end

local function add_formatting(scripture, text, terminal_rows, terminal_cols)
	local scrip = scripture
	local txt = text
	local rows = terminal_rows
	local cols = terminal_cols

	while cols ~= 0 + string.len(scripture) do
		scrip = " " .. scrip
		cols = cols - 1
	end

	while rows ~= 0 do
		scrip = "\n" .. scrip
		txt = txt .. "\n"
		rows = rows - 1
	end
	return { scrip, "\n\n" .. txt }
end

local function print_random_scripture(scripture, text, terminal_rows, terminal_cols)
	local formatted_scripture = add_formatting(scripture, text, terminal_rows, terminal_cols)
	print(formatted_scripture[1], formatted_scripture[2])
end

local function get_and_split_terminal_rows_and_cols()
	local terminal_rows = 0
	local terminal_cols = 0
	local rows_handler = io.popen("tput lines")
	local cols_handler = io.popen("tput cols")

	if rows_handler then
		terminal_rows = rows_handler:read("*a")
	end

	if cols_handler then
		terminal_cols = cols_handler:read("*a")
	end

	if terminal_rows ~= 0 or terminal_rows ~= nil then
		terminal_rows = math.floor(terminal_rows / 2)
	end

	if terminal_cols ~= 0 or terminal_cols ~= nil then
		terminal_cols = math.floor(terminal_cols / 2)
	end
	return { terminal_rows, terminal_cols }
end

local function main()
	-- Clear screen
	os.execute("clear")

	local length = get_length_of_table(scriptures)
	local random_index = math.random(0, length - 1)
	local random_scripture = get_random_scripture(scriptures, random_index)
	if random_scripture then
		-- 1 indexes are crazy
		local scripture = random_scripture[1]
		local text = random_scripture[2]
		local rows_and_cols = get_and_split_terminal_rows_and_cols()
		local terminal_rows = rows_and_cols[1]
		local terminal_cols = rows_and_cols[2]
		print_random_scripture(scripture, text, terminal_rows, terminal_cols)
		return
	end
	print("Error happened. Couldn't find a scripture.")
end

main()
