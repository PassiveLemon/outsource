local log = require("log")
local parse = require("parse")

local posix = require("posix")

local ssh = { }

-- Set up the SSH path, flags, and FFmpeg command for running
function ssh.setup_args(cfg, cmd, args)
  local call_args = { cfg.ssh_path, "-i", cfg.ssh_id, cfg.ssh_host }
  local remote = { cmd }
  -- Escape each ffmpeg argument for SSH
  if args then
    for f, v in parse.arg_itr(args) do
      local escaped_flag = "'" .. f .. "'"
      table.insert(remote, escaped_flag)
      if v and (v ~= "") then
        local escaped_value = "'" .. v:gsub("'", [['"'"']]) .. "'"
        table.insert(remote, escaped_value)
      end
    end
  end
  table.insert(call_args, table.concat(remote, " "))
  return call_args
end

-- Run a command on an SSH client
function ssh.session(cfg, cmd, args)
  local call_args = ssh.setup_args(cfg, cmd, args)
  local code = posix.spawn(call_args)
  if code == 255 then
    log.error("Failed to start SSH session: exit code " .. code)
    return false
  elseif code ~= 0 then
    log.error("Command exited with non-zero code " .. code)
    return false
  end
  return true
end

-- The command to run over SSH
function ssh.cmd(cfg, cmd, args)
  local session = ssh.session(cfg, cmd, args)
  return session
end

return ssh

