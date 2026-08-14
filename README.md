# Outsource
Outsource your FFmpeg calls to a different machine, with directory mapping

# Usage
Requirements:
- Lua with luaposix

## Host
The host requires Outsource and some way to share directories with the client, such as NFS or SMB. The share is so the output files are accessible back on the host.

Create a symlink from the expected ffmpeg/ffprobe locations to the Outsource wrappers, for example:
`/usr/local/jellyfin-ffmpeg/ffmpeg` -> `/path/to/outsource-ffmpeg`
`/usr/local/jellyfin-ffmpeg/ffprobe` -> `/path/to/outsource-ffprobe`

Alternatively, set `OUTSOURCE_MODE="ffprobe"` for FFprobe.

Configure your environment variables. You will need to set `OUTSOURCE_SSH_HOST` and probably `OUTSOURCE_SSH_ID` but, depending on your setup, you may not need to set any others.
Host should be in SSH format, eg: `OUTSOURCE_SSH_ID="<user>@<host>"`
By default, `OUTSOURCE_SSH_ID` will check in the calling user's `$HOME/.ssh` for `id_ed25519`. It just needs an identity that can SSH into the client WITHOUT a password, otherwise the SSH calls will hang. You may need to include a `known_hosts` file for the SSH call to work.

Host-to-client directory mapping is optional, but requires the `OUTSOURCE_MAP_DIRS` variable to use.
First, determine where you want to map. You can easily determine this by checking the FFmpeg calls themselves. For example:
This is an FFmpeg input flag `-i file:"/data/shows/Breaking Bad/Season 01/S01E01.mkv"`. If I wanted to map `/data/shows` on the host to `/mnt/NAS/media/shows` on the client, then I would set `OUTSOURCE_MAP_DIRS="/data/shows//mnt/NAS/media/shows"`

Note the double-slash, it is necessary to separate out the host and client paths. If you want to map multiple directories, then separate them with a semicolon (;) like so: `/host/location1//client/location1;/host/location2//client/location2`

Outsource can also fallback to local FFmpeg if the client fails in any way. Ensure that `OUTSOURCE_FFMPEG_ALLBACK_PATH` and `OUTSOURCE_FFPROBE_FALLBACK_PATH` are set to an actual FFmpeg/FFprobe binary on the host system and NOT the Outsource link.
When it does so, it will attempt to remove or change hardware specific arguments to software safe values to ensure the fallback call works. Otherwise, it may try using hardware that doesn't exist on the host. However, FFmpeg is complicated so this may not always work.

By default, Outsource will attempt to log everything to `/tmp/outsource/log.txt` (`OUTSOURCE_LOG_DIR`) and the logging level can be changed with `OUTSOURCE_LOG_LEVEL`. If you want to disable logging, set the level to "none". Just note that Outsource doesn't manage the size of the logs so you need to ensure they clear automatically.

## Client
Install FFmpeg and take note of the binary location. If it is not at `/usr/bin/ffmpeg` then change `OUTSOURCE_FFMPEG_PATH` and `OUTSOURCE_FFPROBE_PATH` accordingly.

Make sure that the user being SSH'd into can run FFmpeg and is in the `video` group if your hardware needs it.

Mount a share from the host to the client using something like NFS, SMB, etc. All accessed paths on the host must be present on the client but if directory mapping is configured, the locations do not need to be identical.
Your destination mappings must be able to access the paths within the share(s).

After the host and client are configured, test the connection:
```
/path/to/outsource-ffmpeg -version
```
Verify that the returned version is for the actual FFmpeg binary on the client and not the fallback host binary:
```
ffmpeg version 7.1.4-Jellyfin Copyright (c) 2000-2026 the FFmpeg developers
built with gcc 15.2.0 (GCC)
```

# Configuration
| Variable | Default | Details |
|:-|:-|:-|
| `OUTSOURCE_SSH_PATH` | `/usr/bin/ssh` | The path on the host to the SSH binary |
| `OUTSOURCE_SSH_HOST` | `""` (Required) | The client hostname, eg: `user@host` |
| `OUTSOURCE_SSH_ID` | `$HOME/.ssh/id_ed25519` | The path on the host to the SSH identity file, required to initialize an SSH session |
| `OUTSOURCE_FFMPEG_PATH` | `/usr/bin/ffmpeg` | The path on the client to the FFmpeg binary |
| `OUTSOURCE_FFPROBE_PATH` | `/usr/bin/ffprobe` | The path on the client to the FFprobe binary |
| `OUTSOURCE_FFMPEG_ALLBACK_PATH` | `/usr/bin/ffmpeg` | The local path on the host to the FFmpeg binary |
| `OUTSOURCE_FFPROBE_FALLBACK_PATH` | `/usr/bin/ffprobe` | The local path on the host to the FFprobe binary |
| `OUTSOURCE_MAP_DIRS` | `nil` | A list of semicolon (;) separated host-to-client path mappings, eg: `/host/location//client/location` means map from `/host/location` to `/client/location`. The double-slash is where the paths are split. |
| `OUTSOURCE_LOG_DIR` | `/tmp/outsource/log.txt` | The path on the host to log to |
| `OUTSOURCE_LOG_LEVEL` | `info` | The logging level to use. One of `debug`, `info`, `warn`, `error`, `fatal`. |

# Other
Outsource's creation was inspired by some limitations with [rffmpeg](https://github.com/joshuaboniface/rffmpeg).
Currently, rffmpeg will redirect ffmpeg calls verbatim which causes a few issues.
Input/output paths need to be the same on both systems so you may need to put NFS shares in a couple places on the clients filesystem to ensure all internal host paths are mapped correctly.
This gets more complicated when used in a Docker container because bind mounts are often at locations like `/data` or `/config`, not default root directories.
Rewriting paths solves this by allowing any host directory to point to any client directory, which means that the NFS shares can be put in a more appropriate client-specific location.

Additionally, calls to the fallback binary often fail due to the calls containing arguments for hardware, which may not exist on the host.
Outsource, when calling the fallback binary, will attempt to remove or change hardware specific arguments to software safe values to ensure the fallback works. However, FFmpeg is complicated so this may not always work.

