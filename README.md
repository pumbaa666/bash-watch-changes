# bash-watch-changes
Watch changes in a folder (new files, files modifed, files deleted, ...) using [FSWatch](https://github.com/emcrisostomo/fswatch) and launch a script accordingly

# watch-and-resize-images
A set of bash scripts to monitor changes in a specified folder and its subfolders.
It resize any new image into a thumbnail and output all changes into the terminal
as a list of HTML links

# How to run it
Run the script watch-image-in-folder.sh with the folder to watch as an argument.
Any new image comming in this folder or its subfolder will be resized and stored into a "tn" subfolder.
To run it in another process and get back your terminal, add an '&' at the end of the command

```
./watch-image-in-folder.sh upload &
```

# To install it as a service (daemon)
```
sudo cp image_watcher.service /etc/systemd/system/image_watcher.service
# Modify the path of the script and the folder to watch

sudo systemctl daemon-reload
sudo systemctl enable image_watcher
sudo systemctl start image_watcher
```