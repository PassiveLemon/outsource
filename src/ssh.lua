local ssh = { }

-- Run a command on an SSH client
function ssh.session(cfg, call)
  -- Concat the ssh path, flags, and ffmpeg command for running
  local call_ssh = cfg.ssh_path .. " " .. cfg.ssh_flags .. " " .. call
  local handle, err = io.popen(call_ssh, "r")
  if handle then
    local result = handle:read("*a")
    local ok, reason, code = handle:close()
    if ok then
      return result
    elseif code == 255 then
      print("Error: failed to start ssh session: " .. reason)
      return false
    else
      print("Error: command exited with non-zero code " .. code .. ": " .. result)
      return false
    end
  else
    print("Error: failed to execute ssh: " .. err)
    os.exit(1)
  end
end

-- The command to run over SSH
function ssh.cmd(cfg, cmd, args)
  local session = ssh.session(cfg, cmd .. args)
  print(session)
end

return ssh

