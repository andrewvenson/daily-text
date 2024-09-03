SCRIPTURES = {}

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

local function print_scripture()
	local length = get_length_of_table(SCRIPTURES)
	local random_index = math.random(0, length - 1)
	local random_scripture = get_random_scripture(SCRIPTURES, random_index)
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

local function load_scriptures_from_file()
	-- Clear screen
	os.execute("clear")

	local file = io.open("scriptures", "r")

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
				SCRIPTURES[scripture_name] = x
			end
			if scripture_block ~= 0 and scripture_block % 2 == 0 then
				scripture_block = 0
				scripture_name = ""
			end
		end
		file:close()
	end
end

local function main()
	local args = arg
	load_scriptures_from_file()

	local arg_count = 0
	for index in pairs(args) do
		if arg_count > 3 then
			print("Invalid number of arguments")
			print('e.g. lua main.lua create "John 3:16" "For God loved the world..."')
			print("e.g. lua main.lua print")
			return
		end
		if index == -1 then
			break
		end
		arg_count = arg_count + 1
	end

	if args[1] == "print" then
		print_scripture()
	end
	if args[1] == "create" then
		if args[2] and args[3] then
			print(args[2], args[3])
		else
			print("Missing args to create scripture")
			print('e.g. lua main.lua create "John 3:16" "For God loved the world..."')
		end
	end
end

main()
