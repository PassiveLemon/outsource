#!/usr/bin/env lua

local log = require("log")
local config = require("config")
local ffmpeg = require("ffmpeg")
local parse = require("parse")

local function main(args)
  log.start(config)
  ffmpeg.cmd(config, parse.args(args))
  log.stop()
end

main(arg)

