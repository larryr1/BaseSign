-- Support functions
local function write(txt, color)
  local tx, ty = term.getSize()
  local oldColor = term.getTextColor()
  if color then
    term.setTextColor(color)
  end
  term.write(txt)
  term.setTextColor(oldColor)
end

local function writeLine(txt, color)
  write(txt, color)
  local tx, ty = term.getSize()
  local x, y = term.getCursorPos()

  if (y + 1 > ty) then
    term.scroll(1)
    term.setCursorPos(1, ty)
  else
    term.setCursorPos(1, y + 1)
  end
end

-- Greeting
term.clear()
term.setCursorPos(1, 1)
writeLine("Welcome to BaseSign Installer v2.0", colors.lime)
os.sleep(0.5)

-- Check requirements
writeLine("Checking installation requirements...", colors.yellow)
local peripherals = peripheral.getNames()
local mon = peripheral.find("monitor")
local wmod = nil
for _, p in ipairs(peripherals) do
  if peripheral.getType(p) == "modem" then
    local mod = peripheral.wrap(p)
    if mod.isWireless() then
      wmod = p
      break
    end
  end
end

if mon == nil then
  writeLine("No monitor found. Attach a monitor.", colors.red)
  return
end

if wmod == nil then
  writeLine("No wireless modem found. Attach a wireless modem.", colors.red)
  return
end

writeLine("Creating directories and downloading files...")
os.sleep(0.5)
shell.run("wget https://raw.githubusercontent.com/larryr1/BaseSign/refs/heads/main/application/entry.lua BaseSignEntry.lua")
shell.run("mkdir basesign_application")
shell.run("mv BaseSignEntry.lua /basesign_application/entry.lua")
os.sleep(0.5)
writeLine("Creating startup.lua...")
if not fs.exists("/startup.lua") then
  local file = fs.open("/startup.lua", "w")
  file.write([[
shell.run("/basesign_application/entry.lua")
  ]])
  file.close()
else
  writeLine("A startup.lua already exists.")
  writeLine("You should add the following line to it:")
  writeLine('shell.run("/basesign_application/entry.lua")')
end
os.sleep(3)
term.clear()
term.setCursorPos(1, 1)
writeLine("BaseSign Installer v2.0", colors.lime)
writeLine("Set a computer name for changing settings.", colors.magenta)
writeLine("This is how you will identify the computer.")
writeLine("Name it something like: mekanism, entrance, etc.")
writeLine("Type a name and press enter:", colors.yellow)
local input = read()
os.setComputerLabel(input)
writeLine("Set computer name to " .. input, colors.gray)
writeLine("Rebooting...", colors.orange)
os.sleep(1)
os.reboot()
