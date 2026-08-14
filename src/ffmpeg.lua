local log = require("log")
local parse = require("parse")
local ssh = require("ssh")

local posix = require("posix")

local ffmpeg = {
  remove_flags = {
    "^-init_hw_device$",
    "^-filter_hw_device$",
    "^-hwaccel$",
    "^-hwaccel_device$",
    "^-hwaccel_output_format$",
  },
  switch_flags = {
    -- Check if the value is a hardware type before switching
    -- ["^-codec:v:?%d*$"] = "libx265",
    -- ["^-preset$"] = "medium",
  },
}

-- Rewrite paths and return all FFmpeg args
function ffmpeg.rewrite_paths(cfg, args)
  for path_map in cfg.map_dirs:gmatch("[^;]+") do
    local from = path_map:match('^(.-)//')
    local to = path_map:match('/(/.-)/?$')
    log.debug("Mapping '" .. from .. "' to '" .. to .. "'")
    for _, v, pair in parse.arg_itr(args) do
      if v then
        pair.value = v:gsub(from, to)
      end
    end
  end
  return args
end

-- Remove hardware flags from FFmpeg args
function ffmpeg.no_hardware(args)
  -- Remove specific flags and values entirely
  for _, rf in ipairs(ffmpeg.remove_flags) do
    for f, v, pair in parse.arg_itr(args) do
      if f:match(rf) then
        log.debug("Removing hardware flag: '" .. f .. " " .. v .. "'")
        pair.value = ""
      end
    end
  end
  -- Change certain flags to software safe values
  for k, sf in pairs(ffmpeg.switch_flags) do
    for f, v, pair in parse.arg_itr(args) do
      if f:match(k) and (hardware ~= "") then
        log.debug("Changing hardware flag: '" .. f .. " " .. v .. " to " .. sf .. "'")
        pair.value = sf
      end
    end
  end
  return args
end

-- Run a command locally
function ffmpeg.local_ffmpeg(cmd, args)
  local call_args = { cmd }
  for f, v in parse.arg_itr(args) do
    if v ~= "" then
      table.insert(call_args, f)
      table.insert(call_args, v)
    end
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
  log.info("[" .. cfg.mode .. "] Received '" .. parse.arg_concat(args, " ") .. "'")
  local cmd = cfg.ffmpeg_path
  if string.lower(cfg.mode) == "ffprobe" then
    cmd = cfg.ffprobe_path
  end
  local flags = ffmpeg.rewrite_paths(cfg, args)
  log.info("[" .. cfg.mode .. "] Sending '" .. parse.arg_concat(flags, " ") .. "'")
  local session = ssh.cmd(cfg, cmd, flags)
  if not session then
    log.warn("Remote FFmpeg command failed, running locally...")
    flags = ffmpeg.no_hardware(args)
    log.info("[" .. cfg.mode .. " fallback] Sending '" .. parse.arg_concat(flags, " ") .. "'")
    session = ffmpeg.local_ffmpeg(cmd, flags)
  end
  return session
end

return ffmpeg

