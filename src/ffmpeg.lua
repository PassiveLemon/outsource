local ssh = require("ssh")

local ffmpeg = { }

-- Get the ffmpeg path based on the ffmpeg arguments
function ffmpeg.get_ffmpeg(args)
  -- '^(dir)$'
  local dir = args[0]:match("^([/%w]+)$")
  return dir
end

-- Get the source path based on the ffmpeg arguments
function ffmpeg.get_source(args_str)
  -- '-i /(dir)/file'
  local dir = args_str:match("%-i ([/%w]+)/")
  return dir
end

-- Get the destination path based on the ffmpeg arguments
function ffmpeg.get_dest(args_str)
  -- '-o /(dir)/file'
  local dir = args_str:match("%-o ([/%w]+)/")
  return dir
end

-- Rewrite the destination path and return all ffmpeg args
function ffmpeg.rewrite_dest(cfg, args)
  -- Concat all args into a string
  local args_str = ""
  for _, arg in ipairs(args) do
    args_str = args_str .. " " .. arg
  end
  -- Get ffmpeg paths
  local fmpg = ffmpeg.get_ffmpeg(args)
  local src = ffmpeg.get_source(args_str)
  local dest = ffmpeg.get_dest(args_str)
  -- Rewrite paths
  local rewrite = args_str:gsub(fmpg, ""):gsub(src, cfg.source_dir):gsub(dest, cfg.dest_dir)
  return rewrite
end

function ffmpeg.cmd(cfg, args)
  local cmd = cfg.ffmpeg_path
  local flags = ffmpeg.rewrite_dest(cfg, args)
  ssh.cmd(cfg, cmd, flags)
end

return ffmpeg

