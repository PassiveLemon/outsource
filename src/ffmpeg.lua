local ssh = require("ssh")

local posix = require("posix")

local ffmpeg = { }

-- Rewrite paths and return all ffmpeg args
function ffmpeg.rewrite_paths(cfg, args)
  -- Remove cmd and rewrite all paths that match a mapping
  args[0] = nil
  for i, _ in ipairs(args) do
    for path_map in cfg.map_dirs:gmatch("[^;]+") do
      local from = path_map:match('^(.-)//')
      local to = path_map:match('/(/.-)$')
      args[i] = args[i]:gsub(from, to)
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
    print("Error: command exited with non-zero code " .. code)
    return false
  end
  return true
end

-- The ffmpeg command to run
function ffmpeg.cmd(cfg, args)
  local cmd = cfg.ffmpeg_path
  if args[0]:match("ffprobe") then
    cmd = cfg.ffprobe_path
  end
  local flags = ffmpeg.rewrite_paths(cfg, args)
  local session = ssh.cmd(cfg, cmd, flags)
  if not session then
    print("Warning: remote ffmpeg command failed, running locally...")
    session = ffmpeg.local_ffmpeg(cmd, flags)
  end
  return session
end

return ffmpeg

