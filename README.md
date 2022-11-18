#  Sleepless
Disables sleep even when the lid is closed when an external display is detected.
Sleep is automatically enabled again after 5 minutes

## Setup
The application uses the command line utility `pmset` to work. This utility requires root
permissions to be ran. If no changes are made the application will ask for password each time
it either disables or enables sleep which can get annoying.

In order to disable password requirement to run `pmset` you will need to edit the sudoers file.
Running the following command will open the sudoers file in Vim, you can choose another editor by
setting the `EDITOR` variable before (for example `EDITOR="nano" sudo visudo`)
```shell
sudo visudo
```

Then add the following line at the bottom of the file and replace `username` by your username
```
username          ALL = NOPASSWD : /usr/bin/pmset
```

You should now be able to run `pmset` without entering your password
