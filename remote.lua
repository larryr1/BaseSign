-- Begin rednet
peripheral.find("modem", rednet.open)

-- Print text with color
local function printColor(text, color)
  local originalColor = term.getTextColor()
  term.setTextColor(color)
  print(text)
  term.setTextColor(originalColor)
end

local targetComputer = nil
local function chooseComputer()
  print("Enter the computer ID to configure, then press enter. Enter 0 to perform lookup.")
  local id = tonumber(read())

  if id == 0 then
    local hosts = {rednet.lookup("basesign_rm")}
    printColor("Found " .. #hosts .. " hosts.", colors.orange)
    for _, host in ipairs(hosts) do
      local msg = {}
      msg.type = "id"
      msg.operation = "get"
      msg.source = os.getComputerID()
      rednet.send(host, msg, "basesign_rm")
      local id, message = rednet.receive("basesign_rm", 1)
      if message == nil then
        printColor("No response from " .. host, colors.red)
      else
        printColor("#" .. id .. " " .. message["data"], colors.blue)
      end
    end
    chooseComputer()
  else
    targetComputer = id
  end
end

-- Send the specified message and wait for a reply
local function sendAndConfirmCommand(msg)
  local m = msg
  m.request_id = math.random(1, 10000000)
  rednet.send(targetComputer, msg, "basesign_rm")
  local reply = nil
  while reply == nil do
    local id, message = rednet.receive("basesign_rm")
    print("Received message from " .. id)
    if message["request_id"] == m.request_id then
      reply = message
    end
  end

  if (reply == nil) then
    print("No reply received.")
    return
  end

  if (reply["success"] == true) then
    print("Operation successful.")
  else
    print("Operation failed.")
  end

  return reply
end

local function sendReboot()
  -- Send command to reboot
  local msg = {}
  msg.type = "reboot"
  msg.source = os.getComputerID()
  sendAndConfirmCommand(msg)
end

local function getLabel()
  -- Send command to get label
  local msg = {}
  msg.type = "id"
  msg.operation = "get"
  msg.source = os.getComputerID()
  local reply = sendAndConfirmCommand(msg)
  print("The remote computer label is: " .. reply["data"])
end

local function setLabel()
  print("Enter the new label, then press enter.")
  local label = read()
  local msg = {}
  msg.type = "id"
  msg.operation = "set"
  msg.source = os.getComputerID()
  msg.data = label
  local reply = sendAndConfirmCommand(msg)
end

-- Save remote config to temp file
local function getRemoteConfig()
  local msg = {}
  msg.type = "config_file"
  msg.operation = "get"
  msg.source = os.getComputerID()
  local reply = sendAndConfirmCommand(msg)
  if fs.exists("/tmp_bs_config.lua") then
    fs.delete("/tmp_bs_config.lua")
  end
  local f = fs.open("/tmp_bs_config.lua", "w")
  f.write(reply["data"])
  f.close()
end

-- Load temp file and send to remote
local function setRemoteConfig()
  local msg = {}
  msg.type = "config_file"
  msg.operation = "set"
  msg.source = os.getComputerID()
  local f = fs.open("/tmp_bs_config.lua", "r")
  msg.data = f.readAll()
  f.close()
  local reply = sendAndConfirmCommand(msg)
end

local function editRemoteConfig()
  shell.run("edit /tmp_bs_config.lua")
end

while true do
  term.clear()
  term.setCursorPos(1, 1)
  printColor("BaseSign Remote Configuration v11 - for BaseSign V5", colors.lime)
  chooseComputer()
  printColor("Configuring computer #" .. targetComputer, colors.orange)
  printColor("What do you want to do?", colors.orange)
  print("1) Reboot")
  print("2) Get Label")
  print("3) Set Label")
  print("4) Edit Config")
  local option = tonumber(read())

  if option == 1 then
    sendReboot()
  end

  if option == 2 then
    getLabel()
  end

  if option == 3 then
    setLabel()
  end

  if option == 4 then
    getRemoteConfig()
    editRemoteConfig()
    setRemoteConfig()
  end
end
