local log = require("log")
local ssh = require("ssh")

local posix = require("posix")

local ffmpeg = { }

-- Rewrite paths and return all ffmpeg args
function ffmpeg.rewrite_paths(cfg, args)
  for path_map in cfg.map_dirs:gmatch("[^;]+") do
    local from = path_map:match('^(.-)//')
    local to = path_map:match('/(/.-)/?$')
    log.debug("Mapping '" .. from .. "' to '" .. to .. "'")
    for i, flag in ipairs(args) do
      args[i] = flag:gsub(from, to)
    end
  end
  return args
end

-- Run a command locally
function ffmpeg.local_ffmpeg(cmd, args)
  local call_args = { cmd }
  for _, arg in ipairs(args) do
    table.insert(call_args, arg)
  end
  local code = posix.spawn(call_args)
  if code ~= 0 then
    log.error("Command exited with non-zero code " .. code)
    return false
  end
  return true
end

-- The ffmpeg command to run
function ffmpeg.cmd(cfg, args)
  args[0] = nil
  log.info("[" .. cfg.mode .. "] Received '" .. table.concat(args, " ") .. "'")
  -- Remove cmd from args table
  local cmd = cfg.ffmpeg_path
  if string.lower(cfg.mode) == "ffprobe" then
    cmd = cfg.ffprobe_path
  end
  local flags = ffmpeg.rewrite_paths(cfg, args)
  log.info("[" .. cfg.mode .. "] Sending '" .. table.concat(flags, " ") .. "'")
  local session = ssh.cmd(cfg, cmd, flags)
  if not session then
    log.warn("Remote FFmpeg command failed, running locally...")
    session = ffmpeg.local_ffmpeg(cmd, flags)
  end
  return session
end

return ffmpeg

