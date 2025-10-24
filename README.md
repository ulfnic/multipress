# multipress
Run one of several commands based on frequency of execution within a rolling timeout.

Useful for a variety of purposes such as extending keyboard shortcut support to include multi-tap combos.
```bash
./multipress -- echo 1 __ echo 2 __ echo 3 & disown
sleep 0.1
./multipress -- echo 1 __ echo 2 __ echo 3 & disown
# stdout: 2
```
---
```bash
# Output help
multipress --help
```
```bash
multipress [ARGUEMENT...] [--] [COMMAND|DELIM...]

Run one of several COMMANDs based on frequency of execution within a rolling timeout.

Useful for a variety of purposes such as extending keyboard shortcut support to include
multi-tap combos.

DEPENDENCIES
	mkfifo

ARGUEMENT
	-n|--name NAME             Custom name to use for the NAME of the instance
	-d|--delim DELIM           Custom delimiter to seperate COMMANDs, default: '__'
	-t|--timeout SECONDS       Custom timeout for waiting for next ACTIVATION, default: 0.3
	-p|--prevent-overrun       Run the last COMMAND if reached by ACTIVATIONs
	-c|--command-string-mode   See: Command String mode
	--dry-run                  Do everything except running the COMMAND, print it instead
	-h|--help                  Print help doc
	--                         End option processing
	COMMAND || DELIM

ENVIRONMENT
	TMPDIR || XDG_RUNTIME_DIR   Directory to use for fifo file, fallback: /tmp
	DEBUG                       Use set -x to print debugging information

NAME
	Part of the filename used for the IPC fifo file. All parameters containing COMMAND
	and DELIM are hashed to produce the NAME. If a custom name is given that value is
	hashed instead. In both cases Command String mode state is included in the hash.

COMMAND || DELIM
	A COMMAND is executed according to its order based on the number of ACTIVATIONs.
	For example, two timely ACTIVATIONs of the script will run the second COMMAND.

	Normal mode:
		A series of command(s) with parameters divided by DELIM that undergo shell
		interpretation and are evaluated with eval.

	Command String mode:
		Does not recognize DELIM. A series of command string(s) evaluated with bash -c

ACTIVATION
	Each execution of the script constitutions an ACTIVATION under a given NAME.

	If no script is listening under a NAME, the script listens for ACTIVATIONs until
	the timeout is reached from last ACTIVATION.

	If a script is already listening under NAME, the script writes an ACTIVATION to
	that instance over IPC (see: NAME).

EXAMPLES
	# Attach these to a keybind in your keyboard manager and try single and double tap.

	# Normal mode
	multipress -- notify-send 'activated once' __ notify-send 'activated twice'

	# Command String mode
	multipress -c -- "notify-send 'activated once'" "notify-send 'activated twice'"
```
