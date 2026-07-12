local config = { }

config.ssh_path = os.getenv("ANTENNA_SSH_PATH") or "/usr/bin/ssh"
config.ssh_flags = {
  "-i",
  (os.getenv("HOME") .. "/.ssh/id_ed25519"),
  os.getenv("ANTENNA_SSH_HOST"),
}

config.ffmpeg_path = os.getenv("ANTENNA_FFMPEG_PATH") or "/usr/bin/ffmpeg"

config.map_dirs = os.getenv("ANTENNA_MAP_DIRS") -- Don't or to "" because we may not need to map

for k, v in pairs(config) do
  if (v == "") then
    print("Error: " .. k .. " was not defined")
    os.exit(1)
  end
end

return config

