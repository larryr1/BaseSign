local function writeLine(txt)
  term.write(txt)
  local x, y = term.getCursorPos()
  term.setCursorPos(1, y+1)
end

shell.run("wget run https://raw.githubusercontent.com/michielp1807/more-fonts/refs/heads/main/installer.lua")
shell.run("wget https://gist.githubusercontent.com/larryr1/4bb2b33d64ed5b22bdc38c85c0422c17/raw/cf7df64bef9698d295840f5ee042d93d8983dd7b/BaseSign.lua")
shell.run("mv BaseSign.lua startup.lua")

term.clear()
term.setCursorPos(1, 1)
writeLine("Set a computer name for changing settings remotely.")
writeLine("This is how you will identify the computer.")
writeLine("Name it something like: mekanism, entrance,")
writeLine("or something else that represents where this sign is.")
writeLine("Enter a name and press enter:")
local input = read()
os.setComputerLabel(input)
writeLine("Set computer name to " .. input)
writeLine("Rebooting...")
os.sleep(1)
os.reboot()
