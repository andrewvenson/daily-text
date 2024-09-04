SCRIPTURES = {}
ARGS = arg
-- ("27[39m\\033[49m                 - Reset color")
-- ("\27[2K                          - Clear Line")
-- ("\27[<L>;<C>H or \\033[<L>;<C>f  - Put the cursor at line L and column C.")
-- ("\27[<N>A                        - Move the cursor up N lines")
-- ("\27[<N>B                        - Move the cursor down N lines")
-- ("\27[<N>C                        - Move the cursor forward N columns")
-- ("\27[<N>D                        - Move the cursor backward N columns\n")
-- ("\27[2J                          - Clear the screen, move to (0,0)")
-- ("\27[K                           - Erase to end of line")
-- ("\27[s                           - Save cursor position")
-- ("\27[u                           - Restore cursor position\n")
-- ("\27[4m                          - Underline on")
-- ("\27[24m                         - Underline off\n")
-- ("\27[1m                          - Bold on")
-- ("\27[21m                         - Bold off")
-- reset = "\27[0m",
-- red = "\27[31m",
-- green = "\27[32m",
-- yellow = "\27[33;40m",
-- blue = "\27[34m",
-- magenta = "\27[35m",
-- cyan = "\27[36m",
-- white = "\27[37m",

local function get_length_of_table(table)
	local length = 0
	for _ in pairs(table) do
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
	local scrip = "\27[3;31;4m" .. scripture .. "\27[0m"
	local txt = text
	local rows = terminal_rows
	local cols = terminal_cols
	local txt_length = string.len(txt)
	local texts_to_print = {}
	local texts_to_print_length = 0
	local x = 0
	local y = 0

	while x <= txt_length do
		local last_char_is_empty = false
		if x ~= 0 and x % terminal_cols == 0 then
			local new_y = y
			-- removes leading space if there is one from the line of text
			if string.sub(txt, y, y) == " " then
				print("txt is empty", y)
				new_y = y + 1
			end

			-- last character of the current line of text to be proccessed
			local last_char = string.sub(string.sub(txt, new_y, x), string.len(string.sub(txt, new_y, x)))

			if last_char ~= " " then
				local lc_inc = x
				-- this will increment to the end of the word so it doesn't show up broken on 2 lines
				while last_char ~= " " and lc_inc < string.len(txt) do
					last_char = string.sub(string.sub(txt, new_y, lc_inc), string.len(string.sub(txt, new_y, lc_inc)))
					if
						string.sub(string.sub(txt, new_y, lc_inc + 1), string.len(string.sub(txt, new_y, lc_inc + 1)))
						== " "
					then
						break
					end
					lc_inc = lc_inc + 1
				end
				x = lc_inc
			else
				-- this should remove trailing space
				last_char_is_empty = true
				x = x - 1
			end

			local txt_to_set = "\27[3;33;40m" .. string.sub(txt, new_y, x) .. "\27[0m"
			-- adds padding to left of scripture text to center horizontally in console
			while cols ~= 0 + math.floor(string.len(string.sub(txt, new_y, x)) / 2) do
				txt_to_set = " " .. txt_to_set
				cols = cols - 1
			end
			cols = terminal_cols
			table.insert(texts_to_print, txt_to_set .. "\n")
			texts_to_print_length = texts_to_print_length + 1
			y = x + 1
		end
		if last_char_is_empty then
			-- we make sure we include the word after trailing space at the start of next iteration
			x = x + 2
		else
			x = x + 1
		end
	end

	-- adds left padding to last line of scripture text
	if txt_length % cols ~= 0 then
		if string.sub(txt, y, y) == " " then
			local txt_to_set = "\27[3;33;40m" .. string.sub(txt, y + 1) .. "\27[0m"
			while cols ~= 0 + math.floor(string.len(string.sub(txt, y + 1)) / 2) do
				-- adds padding to left of scripture text to center horizontally in console
				txt_to_set = " " .. txt_to_set
				cols = cols - 1
			end
			table.insert(texts_to_print, txt_to_set)
		else
			local txt_to_set = "\27[3;33;40m" .. string.sub(txt, y) .. "\27[0m"
			while cols ~= 0 + math.floor(string.len(string.sub(txt, y)) / 2) do
				-- adds padding to left of scripture text to center horizontally in console
				txt_to_set = " " .. txt_to_set
				cols = cols - 1
			end
			table.insert(texts_to_print, txt_to_set)
		end
		texts_to_print_length = texts_to_print_length + 1
	end

	cols = terminal_cols

	-- centers scripture name in console horizontally
	while cols ~= 0 + string.len(scripture) do
		scrip = " " .. scrip
		cols = cols - 1
	end

	-- centers scripture name in console vertically
	-- Adds padding to bottom of last line of text
	while rows ~= 0 do
		scrip = "\n" .. scrip
		texts_to_print[texts_to_print_length] = texts_to_print[texts_to_print_length] .. "\n"
		rows = rows - 1
	end

	local new_text = ""
	-- appends all scripture text together to be printed
	for _, text_to_print_value in pairs(texts_to_print) do
		new_text = new_text .. text_to_print_value
	end

	return { scrip, new_text }
end

local function print_random_scripture(scripture, text, terminal_rows, terminal_cols)
	local formatted_scripture = add_formatting(scripture, text, terminal_rows, terminal_cols)
	print(formatted_scripture[1] .. "\n\n")
	print(formatted_scripture[2])
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
	-- Clear screen
	os.execute("clear")

	local length = get_length_of_table(SCRIPTURES)
	local random_index = math.random(0, length - 1)
	local random_scripture = get_random_scripture(SCRIPTURES, random_index)
	if random_scripture then
		-- 1 indexes are crazy
		local scripture = random_scripture[1]
		local text = random_scripture[2]
		local success, data = pcall(get_and_split_terminal_rows_and_cols)
		if success then
			local terminal_rows = data[1]
			local terminal_cols = data[2]
			print_random_scripture(scripture, text, terminal_rows, terminal_cols)
		else
			error("Error: Failed to get_and_split_terminal_rows_and_cols")
		end
		return
	end
	error("Error: Couldn't find a scripture")
end

local function load_scriptures_from_file()
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

local function create_scripture(scripture, text)
	print("creating scripture", scripture, text)
	local file = io.open("scriptures", "a+")
	if file then
		file:write("###\n")
		file:write(scripture .. "\n")
		file:write("###\n")
		file:write(text .. "\n")
		file:close()
	end
	local success, data = pcall(load_scriptures_from_file)
	if success then
		print("Successfully loaded scriptures from file")
	else
		error("Failed to load scriptures from file", data)
	end
	return "success"
end

local function validate_arg_count()
	local arg_count = 0
	for index in pairs(ARGS) do
		if arg_count > 3 then
			print('e.g. lua main.lua create "John 3:16" "For God loved the world..."')
			print("e.g. lua main.lua print")
			error("Error: Invalid number of arguments")
		end
		if index == -1 then
			break
		end
		arg_count = arg_count + 1
	end
end

local function main()
	local load_success, load_data = pcall(load_scriptures_from_file)
	if load_success then
		print("Successfully loaded scriptures from file")
	else
		print("Failed to load scriptures from file", load_data)
		return
	end

	local validate_arg_count_success, validate_arg_count_data = pcall(validate_arg_count)
	if validate_arg_count_success then
		print("Successfully validated argument count")
	else
		print(validate_arg_count_data)
		return
	end

	if ARGS[1] == "print" then
		local success, data = pcall(print_scripture)
		if success == false then
			print("Failed to print scripture", data)
			return
		end
	end

	if ARGS[1] == "create" then
		if ARGS[2] and ARGS[3] then
			local success, data = pcall(create_scripture, ARGS[2], ARGS[3])
			if success then
				print("Successfully created scripture")
			else
				print(data)
			end
		else
			print("Missing args to create scripture")
			print('e.g. lua main.lua create "John 3:16" "For God loved the world..."')
		end
	end
end

main()
