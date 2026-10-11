import SwiftUI

extension View {
    /// CI screenshot job: `-scrollEnd` opens each page scrolled to its bottom (debug builds only),
    /// to check the last content clears the tab bar.
    @ViewBuilder func screenshotScrollEnd() -> some View {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-scrollEnd") {
            defaultScrollAnchor(.bottom)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
