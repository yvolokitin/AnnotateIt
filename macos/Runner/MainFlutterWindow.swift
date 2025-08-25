import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Set min size here    
    // 1) Hard minimum (frame + content)
    let minSize = NSSize(width: 1280, height: 800)
    self.minSize = minSize
    self.contentMinSize = minSize

    // 2) Ensure starting size is at least the minimum (MainMenu.xib defaults to 800×600)
    if frame.size.width < minSize.width || frame.size.height < minSize.height {
      self.setContentSize(minSize)   // sets content rect; window frame adjusts automatically
      self.center()
    }

    self.isReleasedWhenClosed = false

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
