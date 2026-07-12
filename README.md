# antenna
Run FFmpeg commands on another host, with directory mapping

## Limitations
While Antenna allows you to run FFmpeg commands on another host, you need to be aware of the hardware capabilities of both. Antenna is effectively an FFmpeg proxy, not a load-balancer (though this may change in the future).
For example, Antenna can be used to enable hardware transcoding for Jellyfin if the host machine doesn't have a GPU. However, if the client is inaccessible or the SSH calls fail and requires the host to fall back to local FFmpeg calls, then that GPU is no longer available and the local calls will fail.

# Usage
## Requirements
Lua with luaposix

## Host
The host requires Antenna and some way to share directories with the client, such as NFS or SMB. The share is so the output files are accessible back on the host.

Create a symlink from the expected ffmpeg/ffprobe locations to antenna.lua, for example:
`/usr/local/jellyfin-ffmpeg/ffmpeg` -> `/path/to/antenna.lua`

For FFprobe to work, the Antenna symlink name must be "ffprobe". This is not required for FFmpeg, but is still recommended.

Configure your environment variables. You will need to set `ANTENNA_SSH_HOST` and probably `ANTENNA_SSH_ID` but, depending on your setup, you may not need to set any others.
Host should be in SSH format, eg: `ANTENNA_SSH_ID="<user>@<host>"`
By default, `ANTENNA_SSH_ID` will check in the calling user's `$HOME/.ssh` for `id_ed25519`. It just needs an identity that can SSH into the client WITHOUT a password, otherwise the SSH calls will hang.

Host-to-client directory mapping is optional, but requires the `ANTENNA_MAP_DIRS` variable to use.
First, determine where you want to map. You can easily determine this by checking the FFmpeg calls themselves. For example:
This is an FFmpeg input flag `-i file:"/data/shows/Breaking Bad/Season 01/S01E01.mkv"`. If I wanted to map `/data/shows` to `/mnt/NAS/media/shows`, then I would set `ANTENNA_MAP_DIRS="/data/shows//mnt/NAS/media/shows"`

Note the double-slash, it is necessary to separate out the host and client paths. If you want to map multiple directories, then separate them with a semi-colon (;) like so: `/host/location1//client/location1;/host/location2//client/location2`

Antenna can also fallback to local FFmpeg if the client fails in any way. Ensure that `ANTENNA_FFMPEG_ALLBACK_PATH` and `ANTENNA_FFPROBE_FALLBACK_PATH` are set to an actual FFmpeg/FFprobe binary on the host system and NOT the Antenna link.

## Client
Install FFmpeg and take note of the binary location. If it is not at `/usr/bin/ffmpeg` then change `ANTENNA_FFMPEG_PATH` and `ANTENNA_FFPROBE_PATH` accordingly.

Mount a share from the host to the client using something like NFS, SMB, etc. All accessed paths on the host must be present on the client but if directory mapping is configured, the locations do not need to be identical.

After the host and client are configured, test the connection:
```
/path/to/ffmpeg(antenna.lua) -version
```
Verify that the returned version is for the actual FFmpeg binary on the client and not the fallback host binary:
```
ffmpeg version 7.1.4-Jellyfin Copyright (c) 2000-2026 the FFmpeg developers
built with gcc 15.2.0 (GCC)
```

# Configuration
| Variable | Default | Details |
|:-|:-|:-|:-|
| `ANTENNA_SSH_PATH` | `/usr/bin/ssh` | The path on the host to the SSH binary |
| `ANTENNA_SSH_HOST` | `""` (Required) | The client hostname, eg: `user@host` |
| `ANTENNA_SSH_ID` | `/home/<user>/.ssh/id_ed25519` (Required) | The path on the host to the SSH identity file, required to initialize an SSH session |
| `ANTENNA_FFMPEG_PATH` | `/usr/bin/ffmpeg` | The path on the client to the FFmpeg binary |
| `ANTENNA_FFPROBE_PATH` | `/usr/bin/ffprobe` | The path on the client to the FFprobe binary |
| `ANTENNA_FFMPEG_ALLBACK_PATH` | `/usr/bin/ffmpeg` | The local path on the host to the FFmpeg binary |
| `ANTENNA_FFPROBE_FALLBACK_PATH` | `/usr/bin/ffprobe` | The local path on the host to the FFprobe binary |
| `ANTENNA_MAP_DIRS` | `nil` | A list of semi-colon (;) delimited host-to-client path mappings, eg: `/host/location//client/location` means map from `/host/location` to `/client/location`. The double-slash is where the paths are split. |

# Other
Antenna's creation was inspired by some limitations with [rffmpeg](https://github.com/joshuaboniface/rffmpeg).
Currently, rffmpeg will redirect ffmpeg calls verbatim, meaning that input/output paths need to be the same on both systems.
This means that you may need to put NFS shares in a couple places on the clients filesystem to ensure all internal host paths are mapped correctly.
This gets more complicated when used in a Docker container because bind mounts are often at locations like `/data` or `/config`, not default root directories.
Rewriting paths solves this by allowing any host directory to point to any client directory, which means that the NFS shares can be put in a more appropriate client-specific location.

# Todo
Todo:
- General
  - [x] Env var configuration to avoid using flags
  - [ ] Logging
  - Find a better name for the project
- [x] SSH
  - [x] SSH session
    - Use other flags to improve connections, like timeouts
  - [x] Run commands
  - [ ] Start an sftp share from the host to client?
- [x] FFmpeg
  - [x] Rewrite paths
  - [x] FFprobe
  - [x] Fallback to local ffmpeg if remote fails

