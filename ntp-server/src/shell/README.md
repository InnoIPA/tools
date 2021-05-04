## Linux
### setup-ntp-server.sh
See `./setup-ntp-server.sh -h` for command-line options.
- Usage:
```
setup-ntp-server.sh [-h] [-v] [-s] [--config-server arg1 [arg2...]]
```
- Example:
```
./setup-ntp-server.sh -s --config-server "server 0.asia.pool.ntp.org" "server 1.asia.pool.ntp.org"
```
### uninstall-ntp-server.sh
See `./uninstall-ntp-server.sh -h` for command-line options.
- Usage:
```
uninstall-ntp-server.sh [-h]
```
- Example:
```
./uninstall-ntp-server.sh
```
## Windows
### setup-ntp-server.cmd
**Please run this batch file as administrator.**
See `setup-ntp-server.cmd /?` for command-line options.
- Usage:
```
setup-ntp-server.cmd [/?] [/v] [/e] [--config-server arg1 [arg2...]]
```
- Example:
```
setup-ntp-server.cmd --config-server "time.stdtime.gov.tw" "clock.stdtime.gov.tw"
```
### uninstall-ntp-server.cmd
- Usage: Double click this batch file.