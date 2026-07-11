local config = { }

config.ssh_path = os.getenv("ANTENNA_SSH_PATH") or "/usr/bin/ssh"
config.ssh_flags = os.getenv("ANTENNA_SSH_FLAGS") or ""

config.ffmpeg_path = os.getenv("ANTENNA_FFMPEG_PATH") or "/usr/bin/ffmpeg"

config.source_dir = os.getenv("ANTENNA_SOURCE_DIR") or ""
config.dest_dir = os.getenv("ANTENNA_DEST_DIR") or ""

for k, v in ipairs(config) do
  if (v == "") or (not v) then
    print("Error: " .. k .. " was not defined")
    os.exit(1)
  end
end

return config

