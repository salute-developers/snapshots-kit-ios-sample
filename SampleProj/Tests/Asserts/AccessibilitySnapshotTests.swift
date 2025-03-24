@testable import SDSnapshots
import SwiftUI
import UIKit
import XCTest

final class AccessibilitySnapshotTests: XCTestCase {
    func test_Accessibility_InView() async {
        await Xct.snapshotAsync(includeAccessibility: true) { _ in
            AccessibleView()
        }
    }

    func test_Accessibility_InViewController() async {
        await Xct.snapshotAsync(includeAccessibility: true) { _ in
            AccessibleViewController(accessibleView: AccessibleView())
        }
    }

    func test_Accessibility_InSwiftUIView() async {
        await Xct.snapshotAsync(includeAccessibility: true) { _ in
            AccessibleSwiftUIView()
        }
    }
}

private final class AccessibleView: UIView {
    private let oneLineLabel = UILabel()
    private let multipleLinesLabel = UILabel()
    private let button = UIButton(type: .system)

    init() {
        super.init(frame: .zero)
        backgroundColor = .white

        oneLineLabel.text = "One Line Label"
        oneLineLabel.numberOfLines = 1
        oneLineLabel.textAlignment = .center
        oneLineLabel.textColor = .black
        oneLineLabel.font = .systemFont(ofSize: 24)
        oneLineLabel.accessibilityIdentifier = "Label 1"

        multipleLinesLabel.text = "Multiple Lines\nLabel"
        multipleLinesLabel.numberOfLines = 0
        multipleLinesLabel.textAlignment = .center
        multipleLinesLabel.textColor = .black
        multipleLinesLabel.font = .systemFont(ofSize: 24)
        multipleLinesLabel.accessibilityIdentifier = nil

        button.setTitle("Button", for: .normal)
        button.accessibilityIdentifier = "Button"

        [oneLineLabel, multipleLinesLabel, button].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor).isActive = true
        }
        button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        let vConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(>=0)-[label1]-[label2]-[button]-(>=0)-|",
            metrics: nil,
            views: [
                "label1": oneLineLabel,
                "label2": multipleLinesLabel,
                "button": button,
            ]
        )
        NSLayoutConstraint.activate(vConstraints)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        size
    }
}

private final class AccessibleViewController: UIViewController {
    private let accessibleView: AccessibleView

    init(accessibleView: AccessibleView) {
        self.accessibleView = accessibleView
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = accessibleView
    }
}

private struct AccessibleSwiftUIView: SwiftUI.View {
    var body: some View {
        VStack(spacing: 8) {
            Text("One Line Label")
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .font(.system(size: 24))
                .accessibilityIdentifier("Label 1")
            Text("Multiple Lines\nLabel")
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .font(.system(size: 24))
            Button(action: {}, label: {
                Text("Button")
            })
            .accessibilityIdentifier("Button")
        }
    }
}
