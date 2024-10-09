-- BaseSign entry script and update checker

local function write(txt, color)
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

-- Check for Updates
writeLine("Checking for updates...", colors.yellow)
local remoteVersion = http.get("https://raw.githubusercontent.com/larryr1/BaseSign/main/version").readAll()
local localVersionHandle = fs.open("/basesign_application/version.txt", "r")
local localVersion = nil
if localVersionHandle then
  localVersion = localVersionHandle.readAll()
  localVersionHandle.close()
else
  local localVersion = "-1"
end

writeLine("Local version: " .. localVersion, colors.yellow)
writeLine("Remote version: " .. remoteVersion, colors.yellow)

if localVersion ~= remoteVersion then
  writeLine("Updating BaseSign...", colors.yellow)
  fs.delete("/basesign_application")
  fs.makeDir("/basesign_application")
  local res = http.get("https://api.github.com/repos/larryr1/BaseSign/contents/application")
  local data = textutils.unserializeJSON(res.readAll())
  for i, file in ipairs(data) do
    write("Downloading " .. file.name .. "...", colors.yellow)
    local res = http.get(file.download_url)
    local data = res.readAll()
    local path = "/basesign_application/" .. file.name
    local file = fs.open(path, "w")
    file.write(data)
    file.close()
    writeLine("done.", colors.yellow)
  end

  -- Replace startup file with remote version
  fs.delete("startup.lua")
  if (fs.exists("/basesign_application/startup.lua")) then
    fs.move("/basesign_application/startup.lua", "startup.lua")
  end

  -- Replace local version with remote version
  local file = fs.open("/basesign_application/version.txt", "w")
  file.write(remoteVersion)
  file.close()

  writeLine("Update complete. Restarting...", colors.green)
  os.sleep(1)
  os.reboot()
else
  writeLine("BaseSign is up to date.", colors.green)
end

-- Load BaseSign
os.run({}, "/basesign_application/application.lua")
