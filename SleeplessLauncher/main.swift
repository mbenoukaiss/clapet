import Cocoa

let delegate = LauncherAppDelegate()
NSApplication.shared.delegate = delegate

let application = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
