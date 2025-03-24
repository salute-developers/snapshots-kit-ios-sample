@testable import SDSnapshots
import UIKit
import XCTest

/// Тест для отладки работы алгоритмов сравнения изображений.
/// Сопостовляем решения по скорости и чувствительности.
final class SnapshotMatcherTests: XCTestCase {
    private let mode: SnapshotMode = .verify
    private let deviceGroup: SnapshotDeviceGroup = (.phone + .tablet).universal

    // MARK: - Equal View

    // MARK: - Simple

    func test_SimpleFrames_Point() async {
        await assertNoFalseErrorOnSimpleFrames(.pointColorDiff)
    }

    func test_SimpleFrames_PointConcurrent() async {
        await assertNoFalseErrorOnSimpleFrames(.pointColorDiffConcurrent)
    }

    // MARK: - Text

    func test_Text_Point() async {
        await assertNoFalseErrorOnText(.pointColorDiff)
    }

    func test_Text_PointConcurrent() async {
        await assertNoFalseErrorOnText(.pointColorDiffConcurrent)
    }

    // MARK: - Gradient

    func test_Gradient_Point() async {
        await assertNoFalseErrorOnGradient(.pointColorDiff)
    }

    func test_Gradient_PointConcurrent() async {
        await assertNoFalseErrorOnGradient(.pointColorDiffConcurrent)
    }

    // MARK: - Different View

    // MARK: - Button Shift 1

    func test_ButtonShiftOnePoint_Point() async {
        await assertDetectsButtonShift(1, .pointColorDiff, expected: Array(repeating: .comparingFailed, count: 6))
    }

    func test_ButtonShiftOnePoint_PointConcurrent() async {
        await assertDetectsButtonShift(1, .pointColorDiffConcurrent, expected: Array(repeating: .comparingFailed, count: 6))
    }

    // MARK: - Button Shift 10

    func test_ButtonShiftTenPoints_Point() async {
        await assertDetectsButtonShift(10, .pointColorDiff, expected: Array(repeating: .comparingFailed, count: 6))
    }

    func test_ButtonShiftTenPoints_PointConcurrent() async {
        await assertDetectsButtonShift(10, .pointColorDiffConcurrent, expected: Array(repeating: .comparingFailed, count: 6))
    }

    // MARK: - 1 Character color

    func test_CharacterColorChanged_Point() async {
        await assertDetectsCharacterColorChange(.pointColorDiff, expected: Array(repeating: .comparingFailed, count: 6))
    }

    func test_CharacterColorChanged_PointConcurrent() async {
        await assertDetectsCharacterColorChange(
            .pointColorDiffConcurrent,
            expected: Array(repeating: .comparingFailed, count: 6)
        )
    }

    // MARK: - Button color

    func test_ButtonColorChanged_Point() async {
        await assertDetectsButtonColorChange(.pointColorDiff, expected: Array(repeating: .comparingFailed, count: 6))
    }

    func test_ButtonColorChanged_PointConcurrent() async {
        await assertDetectsButtonColorChange(
            .pointColorDiffConcurrent,
            expected: Array(repeating: .comparingFailed, count: 6)
        )
    }

    // MARK: - Impl

    private func assertNoFalseErrorOnSimpleFrames(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ matcher: SnapshotMatcherKind
    ) async {
        await Xct.snapshotAsync(
            testName: "SimpleFrames",
            file: file,
            line: line,
            matcher: matcher,
            mode: mode,
            deviceGroup: deviceGroup
        ) { _ in
            SimpleView()
        }
    }

    private func assertNoFalseErrorOnText(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ matcher: SnapshotMatcherKind
    ) async {
        await Xct.snapshotAsync(
            testName: "Text",
            file: file,
            line: line,
            matcher: matcher,
            mode: mode,
            deviceGroup: deviceGroup
        ) { _ in
            ParagraphView()
        }
    }

    private func assertNoFalseErrorOnGradient(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ matcher: SnapshotMatcherKind
    ) async {
        await Xct.snapshotAsync(
            testName: "Gradient",
            file: file,
            line: line,
            matcher: matcher,
            mode: mode,
            deviceGroup: deviceGroup
        ) { _ in
            GradientView()
        }
    }

    private func assertDetectsButtonShift(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ shift: CGFloat,
        _ matcher: SnapshotMatcherKind,
        expected: [SnapshotError.Kind?]
    ) async {
        await Xct.snapshotThrows(
            testName: "ButtonShift_\(Int(shift))",
            file: file,
            line: line,
            matcher: matcher,
            mode: mode,
            deviceGroup: deviceGroup,
            expected: expected,
            prepareReference: { _ in
                let view = SimpleView()
                view.buttonShift = shift
                return view
            },
            prepareSut: { _ in
                SimpleView()
            }
        )
    }

    private func assertDetectsCharacterColorChange(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ matcher: SnapshotMatcherKind,
        expected: [SnapshotError.Kind?]
    ) async {
        await Xct.snapshotThrows(
            testName: "CharacterColorChanged",
            file: file,
            line: line,
            matcher: matcher,
            mode: mode,
            deviceGroup: deviceGroup,
            expected: expected,
            prepareReference: { _ in
                let view = SimpleView()
                view.character.textColor = .purple
                return view
            },
            prepareSut: { _ in
                SimpleView()
            }
        )
    }

    private func assertDetectsButtonColorChange(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ matcher: SnapshotMatcherKind,
        expected: [SnapshotError.Kind?]
    ) async {
        await Xct.snapshotThrows(
            testName: "ButtonColorChanged",
            file: file,
            line: line,
            matcher: matcher,
            mode: mode,
            deviceGroup: deviceGroup,
            expected: expected,
            prepareReference: { _ in
                let view = SimpleView()
                view.button.backgroundColor = .yellow
                return view
            },
            prepareSut: { _ in
                SimpleView()
            }
        )
    }
}

// MARK: - Views

private final class SimpleView: UIView {
    let avatar = UIView()
    let text = UILabel()
    let character = UILabel()
    let button = UIView()

    var buttonShift: CGFloat = 0

    init() {
        super.init(frame: .zero)

        addSubview(avatar)
        addSubview(character)
        addSubview(button)

        avatar.backgroundColor = .orange

        character.text = "I"
        character.numberOfLines = 1
        character.textAlignment = .center
        character.textColor = .brown

        button.backgroundColor = .green
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        let safeFrame = bounds.inset(by: safeAreaInsets)

        avatar.frame = CGRect(x: safeFrame.midX - 50, y: safeFrame.minY + 40, width: 100, height: 100)
        character.frame = CGRect(x: avatar.frame.center.x - 20, y: avatar.frame.maxY + 40, width: 40, height: 40)
        button.frame = CGRect(x: safeFrame.midX - 50 + buttonShift, y: character.frame.maxY + 40, width: 100, height: 50)

        avatar.layer.cornerRadius = 50
        button.layer.cornerRadius = 10
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        size
    }
}

private final class ParagraphView: UIView {
    let text = UILabel()

    init() {
        super.init(frame: .zero)

        addSubview(text)

        text.text = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit.
        Suspendisse sit amet posuere quam, at mollis sapien.
        Cras id justo ac justo consectetur imperdiet.
        Maecenas libero nisl, accumsan at imperdiet varius, pharetra et massa.
        Vivamus in augue aliquet, varius lorem at, vulputate eros.
        Duis semper arcu at vulputate eleifend.
        Interdum et malesuada fames ac ante ipsum primis in faucibus.
        Aenean sed massa non turpis volutpat molestie nec vitae nisl.
        """
        text.numberOfLines = 0
        text.textAlignment = .center
        text.textColor = .blue
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        let safeFrame = bounds.inset(by: safeAreaInsets)

        text.frame = safeFrame.inset(by: UIEdgeInsets(horizontal: 20, vertical: 40))
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        size
    }
}

private final class GradientView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    init() {
        super.init(frame: .zero)

        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor.yellow.cgColor, UIColor.green.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.type = .radial
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {}

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        size
    }
}
