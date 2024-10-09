local function writeLine(txt)
  term.write(txt)
  local x, y = term.getCursorPos()
  term.setCursorPos(1, y+1)
end

term.clear()
term.setCursorPos(1, 1)
writeLine("BaseSign Installer v2.0")
os.sleep(2)
writeLine("Creating directories and downloading files...")

shell.run("wget https://raw.githubusercontent.com/larryr1/BaseSign/refs/heads/main/application/entry.lua BaseSignEntry.lua")
shell.run("mkdir basesign_application")
shell.run("mv BaseSignEntry.lua /basesign_application/entry.lua")

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

term.clear()
term.setCursorPos(1, 1)
writeLine("Set a computer name for changing settings.")
writeLine("This is how you will identify the computer.")
writeLine("Name it something like: mekanism, entrance, etc.")
writeLine("Type a name and press enter:")
local input = read()
os.setComputerLabel(input)
writeLine("Set computer name to " .. input)
writeLine("Rebooting...")
os.sleep(1)
os.reboot()
