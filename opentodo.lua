-- OpenTODO
-- A simple program that lets you keep a list of TODO's with checkboxes next to them
-- Allows adding/deleting entries, checking/unchecking entries
-- Saves entries to file on quit and reads on start
-- Made by Forecaster

local c = require("component")
local term = require("term")
local cereal = require("serialization")
local gpu = c.gpu
local color = require("colors")
local event = require("event")
local fs = require("filesystem")

fs.makeDirectory("/usr/share/opentodo/")

local file = io.open("/usr/share/opentodo/save.tbl","r")
local entries
if file ~= nil then
  local contents = file:read("*a")
  if contents ~= "" then
    entries = cereal.unserialize(contents)
  else
    entries = {}
  end
  file:close()
else
  entries = {}
end
local selected = 1

local function count(table)
  local counter = 0
  for _ in pairs(table) do
    counter = counter + 1
  end
  return counter
end

local function drawEntries()
  term.clear()
  for key, value in pairs(entries) do
    if selected == key then
      gpu.setBackground(0x4B4B4B)
    end
    if value[1] == true then
      print("[x] " .. value[2])
    else
      print("[ ] " .. value[2])
    end
    gpu.setBackground(0x000000)
  end
  if selected == count(entries) + 1 then
    gpu.setBackground(0x4B4B4B)
  end
  print("New entry (Press Enter)")
  gpu.setBackground(0x000000)
  print("Left Arrow: Delete Entry, Right Arrow: Toggle Checked, ctrl + c: Exit")
end

local function incrementSelection()
  selected = selected + 1
  if  selected > count(entries) + 1 then
    selected = count(entries) + 1
  end
end

local function decrementSelection()
  selected = selected - 1
  if selected == 0 then
    selected = 1
  end
end

local function deleteEntry()
  if entries[selected] ~= nil then
    entries[selected] = nil
	drawEntries()
  end
end

local function toggleChecked()
  if entries[selected] ~= nil then
    entries[selected][1] = not entries[selected][1]
  end
  drawEntries()
end

drawEntries()

local run = true
while run do
  local event, _, _, data = event.pull()
  if event == "interrupted" then
    run = false
  elseif event == "key_down" then
    if data == 200 then
      decrementSelection()
      drawEntries()
    elseif data == 208 then
      incrementSelection()
      drawEntries()
    elseif data == 205 then
      toggleChecked()
      drawEntries()
    elseif data == 203 then
      deleteEntry()
    elseif data == 28 then
      if selected == count(entries) + 1 then
		term.write("New entry: ")
        local input = term.read()
        if input ~= "" then
          table.insert(entries, {false, input})
          drawEntries()
        end
      end
    end
  end
end

term.clear()

local file = io.open("/usr/share/opentodo/save.tbl","w")
if file == nil then
  error("Couldn't open file '/usr/share/opentodo/save.tbl'")
end
local cerealEntries = cereal.serialize(entries)
local result, message = file:write(cerealEntries)
file:close()

if result == nil then
  error(message)
end

print("Successfully saved and quit")
