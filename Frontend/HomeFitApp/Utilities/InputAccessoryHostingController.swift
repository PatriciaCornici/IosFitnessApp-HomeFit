import SwiftUI

final class InputAccessoryHostingController<Content: View>: UIHostingController<Content> {
    override var canBecomeFirstResponder: Bool {
        true
    }

    override var inputAccessoryView: UIView? {
        view
    }
}
