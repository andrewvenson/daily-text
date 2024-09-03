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
		rows_handler:close()
	end

	if cols_handler then
		terminal_cols = cols_handler:read("*a")
		cols_handler:close()
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

	local file = io.open("scriptures", "r")

	local scriptures = {}

	if file then
		local scripture_block = 0
		local scripture_name = ""
		for x in file:lines() do
			if x == "###" then
				scripture_block = scripture_block + 1
			end
			if scripture_block == 0 then
				scripture_name = x
			end
			if scripture_block == 1 then
				scriptures[scripture_name] = x
			end
			if scripture_block ~= 0 and scripture_block % 2 == 0 then
				scripture_block = 0
				scripture_name = ""
			end
		end
		file:close()
	end

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
