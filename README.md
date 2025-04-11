# bash-watch-changes

A lightweight Bash-based watcher to monitor changes (new files, modifications, deletions...) in a specified folder using [FSWatch](https://github.com/emcrisostomo/fswatch). It triggers a custom script for each event, passing the affected file and event type.

---

## 🔍 Overview

This project allows you to:

- Monitor a folder and its subfolders recursively.
- Detect events such as file **creation**, **modification**, **deletion**, and **renaming**.
- Automatically trigger a custom script (`script.sh`) on each detected event.
- Optionally run the watcher in the background (detached from terminal).
- Log the triggered events with timestamps for later review.

---

## 📦 Scripts Included

- `watch-folder.sh`: Watches the folder and dispatches events.
- `script.sh`: Script triggered by each file event. Customizable to your needs.
- `.env`: Optional file to define user config like DB credentials.
- `watch_events.log`: Log file generated to store all event activity.

---

## ▶️ How to Run

Run the main watcher script with a folder path to monitor:

```bash
./watch-folder.sh ./my-folder/
```

To run the script in the background and keep it alive even after terminal closes:
```bash
./watch-folder.sh --no-hup ./my-folder/
```

Stop the watcher:
```bash
./watch-folder.sh --stop-watch
```

## 🛠 Options
| Option                | Description                                                           |
| --------------------- | --------------------------------------------------------------------- |
| `--events`	        | Comma-separated fswatch events (e.g. Created,Updated,Removed,Renamed) |
| `--no-hup`, `-n`	    | Run watcher in the background                                         |
| `--stop-watch`, `-s`	| Kill background watcher process                                       |
| `--help`, `-h`	    | Show help instructions                                                |

## 📝 Example: Resize New Images

To automatically resize any new image to a thumbnail:

1. Modify `script.sh` to call convert (ImageMagick) and resize the file.
2. Save the output to a tn/ subfolder.
3. Use the following command:

```bash
./watch-folder.sh --no-hup ./upload
```

## ⚙️ Install as a Systemd Service

If you want the watcher to always run as a daemon:

Copy the service file

```bash
sudo cp image_watcher.service /etc/systemd/system/image_watcher.service
```

Modify the service file to point to the correct script/folder

```bash
sudo vi /etc/systemd/system/image_watcher.service
```

```text
ExecStart=/path/to/watch-folder.sh --events=Created,Updated,Removed /path/to/watched/folder
```

Reload systemd, enable and start the service

```bash
sudo systemctl daemon-reload
sudo systemctl enable image_watcher
sudo systemctl start image_watcher
```

## 🧪 Requirements

- fswatch, install it with `install-fswatch.sh` script
- Optional: ImageMagick for image resizing


## 🧾 Sample Log Output

The script logs each event like this:

```text
2025-04-10 14:32:18 | ⚡ Created | 📁 ./upload/picture.jpg
2025-04-10 14:32:33 | ⚡ Updated | 📁 ./upload/picture.jpg
```

## 🙌 Author

Crafted with ☕️ by Pumbaa

## 📄 License

GNU GPLv3