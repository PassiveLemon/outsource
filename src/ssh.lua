local ssh = { }

function ssh.session(cfg, call)
  call = "sleep 5 && echo success"
  local call_ssh = cfg.ssh_path .. " " .. cfg.ssh_flags .. " " .. call
  print(call_ssh)
  local handle = io.popen(call_ssh, "r")
  if handle then
    local result = handle:read("*a")
    print(result)
    handle:close()
    return result
  else
    print("Error: failed to start ssh session")
    os.exit(false)
  end
end

function ssh.sftp(cfg)
  
end

function ssh.cmd(cfg, cmd, args)
  ssh.session(cfg, cmd .. args)
  print("sftp")
end

return ssh

