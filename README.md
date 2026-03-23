# simple gmod addon that trying to mimic TempleOS
![20260322025852_1](https://github.com/user-attachments/assets/05c58109-bfca-4cf1-a57c-4ec88c695345)
# Features
- Has custom random function with FIFO
- Has Input text feature (you can enter any text that supported by font)
- has entire holy bible inside and you can get random verse by enter "God" command
- has totally real communication with God. Use GodSpeak command [There is real fifo and good/bad bits that terry [*]used to sentence generator)
- Can play sounds
- has custom vocab support (need to be expanded to normal use but maybe i do it later).
- has file manager. Kernel panic
![20260323225732_1](https://github.com/user-attachments/assets/b0d54459-6e77-49d4-a425-e303ff52e561)
## convars
- holylua_terminal_view (0-1) - focus camera on terminal
# Commands
```
SYSTEM COMMANDS:
help [page] - Show this help (specify page number)
clear - Clear the screen
shutdown - Shutdown the system
reboot / boot - Reboot the system
version - Show TempleOS version
pwd - Show current path

FILE MANAGER:
dir [path] / ls [path] - List directory contents
cd <path> - Change directory
cat <file> - Display file content
edit <file> / ed <file> - Create/edit file
del <file> / delete <file> - Delete file
mkdir <dir> - Create directory
rmdir <dir> - Remove directory
drives / drv - List all drives
tree [path] [depth] - Show directory tree (depth 1-5, default 3)

DIVINE COMMANDS:
god - Random Bible verse
godspeak - Divine speech
godbits - Random divine number (1-100)
randi32 - Random 32-bit integer

SOUND COMMANDS:
music - Play TempleOS hymn
beep - System beep
snd <file> - Play custom sound
sndrst - Stop all sounds

INFO COMMANDS:
memrep - Memory report
date - Current date
time - Current time
cpurep - CPU report

EDIT MODE:
Type lines of text, send empty line or type "exit" to save and exit
```
![20260322025819_1](https://github.com/user-attachments/assets/7315944c-9229-42f0-b8e2-cbbe66ad57cd)
