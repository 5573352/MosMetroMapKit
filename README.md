# MosMetroMapKit


## Dismiss after 30

For timer for dismissimg a metro map controller set method to you AppDelegate class%

// The callback for when the timeout was fired.
func applicationDidTimout(notification: NSNotification) {
    if let vc = self.window?.rootViewController as? UINavigationController {
        if let myTableViewController = vc.visibleViewController as? MyMainViewController {
            // Call a function defined in your view controller.
            myMainViewController.userIdle()
        } else {
            // We are not on the main view controller. Here, you could segue to the desired class.
            let storyboard = UIStoryboard(name: "MyStoryboard", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("myStoryboardIdentifier")
        }
    }
}
