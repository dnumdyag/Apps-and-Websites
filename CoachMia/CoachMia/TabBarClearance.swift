import SwiftUI

extension View {
    /// Reserves room for the floating tab bar under a scrolling page. Pages inside a
    /// NavigationStack don't receive the bar's safe-area inset from outside the stack (measured
    /// 12 October 2026: on every tab the last content scrolled under the bar), so each scrolling
    /// page adds it itself. 52 pt is the part of the bar above the home-indicator area.
    func tabBarClearance() -> some View {
        safeAreaPadding(.bottom, 52)
    }
}
