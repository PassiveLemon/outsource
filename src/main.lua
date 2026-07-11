local config = require("config")
local ffmpeg = require("ffmpeg")

local function main(args)
  ffmpeg.cmd(config, args)
end

local test = {
  [0] = "/test/bin/ffmpeg",
  [1] = "-i",
  [2] = "/test/data/file1.mp4",
  [3] = "-o",
  [4] = "/test/data/file2.mp4"
}

main(test)

