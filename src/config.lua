local config = { }

config.ssh_path = os.getenv("ANTENNA_SSH_PATH") or "/usr/bin/ssh"
local default_ssh_flags = "-i " .. os.getenv("HOME") .. "/.ssh/id_ed25519 " .. os.getenv("ANTENNA_SSH_HOST")
config.ssh_flags = os.getenv("ANTENNA_SSH_FLAGS") or default_ssh_flags

config.ffmpeg_path = os.getenv("ANTENNA_FFMPEG_PATH") or "/usr/bin/ffmpeg"

config.source_dir = os.getenv("ANTENNA_SOURCE_DIR") or ""
config.dest_dir = os.getenv("ANTENNA_DEST_DIR") or ""

for k, v in pairs(config) do
  if (v == "") then
    print("Error: " .. k .. " was not defined")
    os.exit(1)
  end
end

return config

