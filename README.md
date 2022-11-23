# Sleepless
Sleepless is a utility that can automatically manages sleep of your macbook.
When an external display is detected, the application will disable sleep so you can use
it with the lid closed, and as soon as the external display is unplugged, sleep will be
enabled again to preserve battery.

## Installing
You can download the app [from this link](https://github.com/mbenoukaiss/sleepless/releases/latest/download/Sleepless.app)
or in the release tab on GitHub and move it to the `Application` folder on your mac.

Due to the way it works, Sleepless can not be submitted on the AppStore.

## Manual configuration
When launched the application will ask you to configure the `pmset` utility, if you skipped it
you still do it from the advanced tab in settings or you can do it manually by following the
instructions below.

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
username ALL = NOPASSWD : /usr/bin/pmset
```

You should now be able to run `pmset` without entering your password
