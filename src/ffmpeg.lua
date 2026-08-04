local log = require("log")
local ssh = require("ssh")

local posix = require("posix")

local ffmpeg = {
  hardware_flags = { "-init_hw_device", "-filter_hw_device" },
}

-- Rewrite paths and return all FFmpeg args
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

-- Remove hardware flags from FFmpeg args
function ffmpeg.no_hardware(_, args)
  -- Detect the flag first, then remove it and it's value
  for k, _ in pairs(ffmpeg.hardware_flags) do
    for i, flag in ipairs(args) do
      local tack = args[i]
      local value = args[i+1]
      if flag:match(k) then
        log.debug("Removing hardware flag: '" .. tack .. " " .. value .. "'")
        table.remove(args, (i+1))
        table.remove(args, i)
      end
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

-- The FFmpeg command to run
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
    flags = ffmpeg.no_hardware(cfg, args)
    session = ffmpeg.local_ffmpeg(cmd, flags)
  end
  return session
end

return ffmpeg

