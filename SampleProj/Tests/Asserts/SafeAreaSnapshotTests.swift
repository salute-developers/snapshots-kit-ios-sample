@testable import SDSnapshots
import UIKit
import XCTest

final class SafeAreaSnapshotTests: SnapshotTest {
    private let deviceGroup: SnapshotDeviceGroup = (.phone + .tablet).universal

    func test_SafeArea_InView() async {
        await Xct.snapshotAsync(deviceGroup: deviceGroup) { device in
            let sut = SafeAreaView()
            sut.specText = device.specText
            return sut
        }
    }

    func test_SafeArea_InViewController() async {
        await Xct.snapshotAsync(deviceGroup: deviceGroup) { device in
            let sut = SafeAreaView()
            sut.specText = device.specText
            return SafeAreaViewController(safeAreaView: sut).view
        }
    }

    func test_WithoutSafeArea_InView() async {
        await Xct.snapshotAsync(deviceGroup: deviceGroup.noSafeArea) { device in
            let sut = SafeAreaView()
            sut.specText = device.specText
            return sut
        }
    }

    func test_WithoutSafeArea_InViewController() async {
        await Xct.snapshotAsync(deviceGroup: deviceGroup.noSafeArea) { device in
            let sut = SafeAreaView()
            sut.specText = device.specText
            return SafeAreaViewController(safeAreaView: sut).view
        }
    }
}

private final class SafeAreaView: UIView {
    private let croppedView = UIView()
    private let topInsetLabel = UILabel()
    private let bottomInsetLabel = UILabel()
    private let leftInsetLabel = UILabel()
    private let rightInsetLabel = UILabel()
    private let specLabel = UILabel()

    var specText: String {
        get { specLabel.text ?? "" }
        set { specLabel.text = newValue }
    }

    init() {
        super.init(frame: .zero)
        let labels = [
            topInsetLabel,
            leftInsetLabel,
            rightInsetLabel,
            bottomInsetLabel,
        ]

        addSubview(croppedView)
        croppedView.addSubview(specLabel)
        labels.forEach {
            addSubview($0)
            $0.textAlignment = .center
            $0.textColor = .blue
        }
        backgroundColor = .white
        croppedView.backgroundColor = .cyan
        specLabel.numberOfLines = 0
        specLabel.textColor = .blue
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        croppedView.frame = bounds.inset(by: safeAreaInsets)

        let labelSide: CGFloat = 40
        topInsetLabel.frame = CGRect(origin: .zero, width: bounds.width, height: labelSide)
        bottomInsetLabel.frame = CGRect(x: 0, y: bounds.height - labelSide, width: bounds.width, height: labelSide)
        leftInsetLabel.frame = CGRect(origin: .zero, width: labelSide, height: bounds.height)
        rightInsetLabel.frame = CGRect(x: bounds.width - labelSide, y: 0, width: labelSide, height: bounds.height)
        specLabel.frame = croppedView.bounds

        topInsetLabel.text = "\(safeAreaInsets.top)"
        rightInsetLabel.text = "\(safeAreaInsets.right)"
        leftInsetLabel.text = "\(safeAreaInsets.left)"
        bottomInsetLabel.text = "\(safeAreaInsets.bottom)"
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        size
    }
}

private final class SafeAreaViewController: UIViewController {
    private let safeAreaView: SafeAreaView

    init(safeAreaView: SafeAreaView) {
        self.safeAreaView = safeAreaView
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = safeAreaView
    }
}
