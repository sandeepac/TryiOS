 

import Foundation
import UIKit

CommandLine.unsafeArgv.withMemoryRebound(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))
{    argv in
    _ = UIApplicationMain(CommandLine.argc, argv, NSStringFromClass(TimerUIApplication.self), NSStringFromClass(AppDelegate.self))
}

