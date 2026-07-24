local log = require("log")

local posix = require("posix")

local ssh = { }

-- Set up the call arguments for SSH
function ssh.ssh_args(cfg)
  local call_args = { cfg.ssh_path, "-i", cfg.ssh_id, cfg.ssh_host }
  return call_args
end

-- Set up the call arguments for an SSH call command
function ssh.ssh_cmd_args(cmd, args)
  local call_args = { cmd }
  -- Escape each FFmpeg argument for SSH
  if args then
    for _, arg in ipairs(args) do
      local escaped_arg = "'" .. arg:gsub("'", [['"'"']]) .. "'"
      table.insert(call_args, escaped_arg)
    end
  end
  return call_args
end

-- Run a command on an SSH client
function ssh.session(args)
  local code = posix.spawn(args)
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
  local ssh_args = ssh.ssh_args(cfg)
  local cmd_args = ssh.ssh_cmd_args(cmd, args)
  local ssh_call_args = ssh_args
  for _, v in ipairs(cmd_args) do
    table.insert(ssh_call_args, v)
  end
  local session = ssh.session(ssh_call_args)
  return session
end

return ssh

