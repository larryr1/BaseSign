shell.run("wget run https://raw.githubusercontent.com/michielp1807/more-fonts/refs/heads/main/installer.lua")
shell.run("wget https://gist.githubusercontent.com/larryr1/4bb2b33d64ed5b22bdc38c85c0422c17/raw/cf7df64bef9698d295840f5ee042d93d8983dd7b/BaseSign.lua")
shell.run("mv BaseSign.lua startup.lua")
os.reboot()
