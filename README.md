# Clapet
Clapet is a utility that aims to improve clamshell mode on your Macbook.

Clamshell mode on mac allows you to keep your mac awake when you close the lid
but it only works when a power adapter is connected. This app aims to solve this
problem by allowing clamshell mode even when on battery.

When an external display is detected while on battery or power adapter, the application will 
disable sleep so you can use it with the lid closed, and as soon as the external display is 
unplugged, sleep will be enabled again to preserve battery.

## Feature
* Automatically disable sleep if an external display is connected
* Disable sleep for a specified amount of time
* Manage sleep through shortcuts

## Installing
You can download the app from the [release](https://github.com/mbenoukaiss/clapet/releases/latest)
tab or by [clicking this link](https://github.com/mbenoukaiss/clapet/releases/latest/download/Clapet.app)
link directly

When the application is done downloading, you can move it to the `Application` folder on your mac.
Due to the way it works, Clapet can not be submitted to the AppStore.

### Manual configuration
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


### Uninstalling
If you want to uninstall the app, remove the line added in the sudoers file mentioned in 
the **Manual configuration** section and delete the application from your computer.

## Contributing
Any kind of contribution either through pull requests or simple issues describing a feature 
you'd like to have  in the application or a problem you get when using it are welcome.

## License
This project is licensed under the terms of the [GNU GPLv3](./LICENSE) license
