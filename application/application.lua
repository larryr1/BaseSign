-- BaseSign system
-- Author: larryr1
peripheral.find("speaker").playNote("pling")
local function writeLine(txt)
  term.write(txt)
  local x, y = term.getCursorPos()
  term.setCursorPos(1, y+1)
end

local function getIdString()
  if (os.getComputerLabel() == nil) then
    return os.getComputerID()
  else
    return os.getComputerLabel() .. "-" .. os.getComputerID()
  end
end

local function setupRednet()
  peripheral.find("modem", rednet.open)
  rednet.host("basesign_rm", "RM-" .. getIdString())
end

local function cleanupRednet()
  rednet.unhost("basesign_rm")
  rednet.close()
end

setupRednet()

local function handleRednetCommand()
  while true do
    local senderId, message, protocol = rednet.receive("basesign_rm")
    if message.type == "reboot" then
      os.reboot()
    end

    if message.type == "id" and message.operation == "get" then
      local reply = {}
      reply.type = "id"
      reply.data = getIdString()
      os.sleep(0.1)
      rednet.send(senderId, reply, "basesign_rm")
    end

    if message.type == "id" and message.operation == "set" then
      os.setComputerLabel(message.data)
      local reply = {}
      reply.type = "operation_result"
      reply.success = true
      os.sleep(0.1)
      rednet.send(senderId, reply, "basesign_rm")
      peripheral.find("speaker").playNote("pling")
    end

    if message.type == "config_file" and message.operation == "get" then
      os.sleep(0.1)
      local reply = {}
      reply.type = "config_file"
      reply.data = fs.open("bs_config.lua", "r").readAll()
      rednet.send(senderId, reply, "basesign_rm")
    end

    if message.type == "config_file" and message.operation == "set" then
      fs.open("bs_config.lua", "w").write(message.data)
      local reply = {}
      reply.type = "operation_result"
      reply.success = true
      os.sleep(0.1)
      rednet.send(senderId, reply, "basesign_rm")
      peripheral.find("speaker").playNote("pling")
    end
  end
end

local function greeting()
  term.clear()
  term.setCursorPos(1, 1)
  writeLine("BaseSign System")
  writeLine("Author: larryr1")
  writeLine("Remote Configuration ID: " .. os.getComputerID())
  writeLine("")
  writeLine("Select an option, then press enter.")
  writeLine("1) Edit Config then Reboot")
  writeLine("2) Reboot")
  writeLine("0) Exit to Shell")

  local doOption = false
  while doOption == false do
    local event, key = os.pullEvent("key")
    key = keys.getName(key)
    if key == "one" then
      writeLine("Editing config...")
      os.sleep(0.5)
      shell.run("edit bs_config.lua")
      term.setCursorPos(1, 1)
      writeLine("Rebooting...")
      os.sleep(0.5)
      os.reboot()
    elseif key == "two" then
      os.reboot()
    elseif key == "zero" then
      doOption = true
    end
  end

  writeLine("Exiting to shell...")
  os.sleep(0.5)
end


if not fs.exists("/bs_config.lua") then
  local file = fs.open("/bs_config.lua", "w")
  file.write([===[
-- BaseSign system config
-- Background color changes take 2 reboots to show up
MONITOR_TEXT = [[
Line 1
Line 2
]]
MONITOR_TEXT_FONT = "/fonts/PublicPixel"
MONITOR_TEXT_SCALE = 1
MONITOR_TEXT_COLOR = colors.yellow
MONITOR_BACKGROUND_COLOR = colors.black
  ]===])
  file.close()
end

require(".bs_config")
local mon = peripheral.find("monitor")
local mf = require("/morefonts")

mon.setTextScale(1)
mon.clear()
mon.setCursorPos(2, 2)
mon.setTextColor(MONITOR_TEXT_COLOR)
mon.setBackgroundColor(MONITOR_BACKGROUND_COLOR)

mf.writeOn(mon, MONITOR_TEXT, nil, nil, {
  font = MONITOR_TEXT_FONT,
  dx = 0,
  dy = 0,
  scale = MONITOR_TEXT_SCALE,
  wrapWidth = 80,
  condense = true,
  sepWidth = 1,
  spaceWidth = 5,
  lineSepHeight = 5,
  textAlign = "center",
  anchorHor = "center",
  anchorVer = "center",
});

-- Run rednet handler in parallel
parallel.waitForAny(handleRednetCommand, greeting)
