#!/usr/bin/env lua

local log = require("log")
local config = require("config")
local ffmpeg = require("ffmpeg")

local function main(args)
  log.start(config)
  -- Remove cmd from args table
  args[0] = nil
  ffmpeg.cmd(config, args)
  log.stop()
end

main(arg)

