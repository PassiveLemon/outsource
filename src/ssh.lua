local posix = require("posix")

local ssh = { }

-- Set up the SSH path, flags, and ffmpeg command for running
function ssh.setup_args(cfg, cmd, args)
  local call_args = { cfg.ssh_path }
  for _, v in ipairs(cfg.ssh_flags) do
    table.insert(call_args, v)
  end
  local remote = { cmd }
  -- Escape each ffmpeg argument for SSH
  for _, arg in ipairs(args) do
    table.insert(remote, "'" .. arg:gsub("'", [['"'"']]) .. "'")
  end
  table.insert(call_args, table.concat(remote, " "))
  return call_args
end

-- Run a command on an SSH client
function ssh.session(cfg, cmd, args)
  local call_args = ssh.setup_args(cfg, cmd, args)
  local code = posix.spawn(call_args)
  if code == 255 then
    print("Error: failed to start ssh session: exit code " .. code)
    return false
  elseif code ~= 0 then
    print("Error: command exited with non-zero code " .. code)
    return false
  end
  return true
end

-- The command to run over SSH
function ssh.cmd(cfg, cmd, args)
  local session = ssh.session(cfg, cmd, args)
  print(session)
end

return ssh

