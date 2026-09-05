local log = require("log")

local config = { }

config.mode = os.getenv("OUTSOURCE_MODE") or "ffmpeg"

config.ssh_path = os.getenv("OUTSOURCE_SSH_PATH") or "/usr/bin/ssh"
config.ssh_host = os.getenv("OUTSOURCE_SSH_HOST") or ""
config.ssh_id =  os.getenv("OUTSOURCE_SSH_ID") or (os.getenv("HOME") .. "/.ssh/id_ed25519")

config.ffmpeg_path = os.getenv("OUTSOURCE_FFMPEG_PATH") or "/usr/bin/ffmpeg"
config.ffprobe_path = os.getenv("OUTSOURCE_FFPROBE_PATH") or "/usr/bin/ffprobe"
config.ffmpeg_fallback_path = os.getenv("OUTSOURCE_FFMPEG_FALLBACK_PATH") or "/usr/bin/ffmpeg"
config.ffprobe_fallback_path = os.getenv("OUTSOURCE_FFPROBE_FALLBACK_PATH") or "/usr/bin/ffprobe"

config.map_dirs = os.getenv("OUTSOURCE_MAP_DIRS") or ";"

config.log_dir = os.getenv("OUTSOURCE_LOG_DIR") or "/tmp/outsource/log.txt"
config.log_level = os.getenv("OUTSOURCE_LOG_LEVEL") or "info"

-- Make sure there's is at least a value for each
for k, v in pairs(config) do
  log.debug(k .. ": " .. v)
  if v and (v == "") then
    log.fatal(k .. " was not defined")
  end
end

return config

