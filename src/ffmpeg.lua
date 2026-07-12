local ssh = require("ssh")

local ffmpeg = { }

-- Get the source path based on the ffmpeg arguments
function ffmpeg.get_source(args_str)
  -- '-i file:"(/dir/file)"'
  local path = args_str:match('%-i%s+file:"([^"]+)"')
  -- '"(/dir)/file"'
  local dir = path:match('(.+)/[^/]+$')
  return dir
end

-- Get the destination path based on the ffmpeg arguments
function ffmpeg.get_dest(args_str, slug)
  slug = "%-hls_segment_filename"
  -- '<slug> "(/dir/file)"'
  local path = args_str:match(slug .. '%s+"([^"]+)"')
  -- '"(/dir)/file"'
  local dir = path:match('(.+)/[^/]+$')
  return dir
end

-- Rewrite the destination path and return all ffmpeg args
function ffmpeg.rewrite_dest(cfg, args)
  -- Remove cmd and concat other args to get our flags
  args[0] = nil
  local args_str = " " .. table.concat(args, " ")
  -- Get ffmpeg paths
  local src = ffmpeg.get_source(args_str)
  local dest = ffmpeg.get_dest(args_str)
  -- Rewrite paths
  local rewrite = args_str:gsub(src, cfg.source_dir):gsub(dest, cfg.dest_dir)
  return rewrite
end

-- The ffmpeg command to run
function ffmpeg.cmd(cfg, args)
  local cmd = cfg.ffmpeg_path
  local flags = ffmpeg.rewrite_dest(cfg, args)
  ssh.cmd(cfg, cmd, flags)
end

return ffmpeg

