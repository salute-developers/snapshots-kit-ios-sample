@testable import SDSnapshots
import SwiftUI
import UIKit
import XCTest

final class PrepareSutTests: SnapshotTest {
    private static let deviceGroup: SnapshotDeviceGroup = .init(
        rotatable: false,
        SnapshotDevice(
            portraitWidth: 100,
            portraitHeight: 100,
            scale: 2,
            portraitSafeArea: .zero,
            landscapeSafeArea: .zero,
            orientation: .portrait,
            isCropOn: false
        ),
        SnapshotDevice(
            portraitWidth: 120,
            portraitHeight: 120,
            scale: 2,
            portraitSafeArea: .zero,
            landscapeSafeArea: .zero,
            orientation: .portrait,
            isCropOn: false
        )
    )
    
    func test_PrepareSut_DifferentView_Works() async {
        Xct.assertEqual(Self.deviceGroup.devices.count, 2)
        await Xct.snapshotAsync(deviceGroup: Self.deviceGroup) { _ in SampleView() }
    }
    
    func test_PrepareSut_InSnapshotAsync_SameView_Fails() async throws {
        try Xct.skip("XCTExpectFailure does not work in async test! Test is expected to fail!")
        //        XCTExpectFailure(enabled: true, strict: true)
        
        let sut = await SampleView()
        
        Xct.assertEqual(Self.deviceGroup.devices.count, 2)
        await Xct.snapshotAsync(
            testName: "test_PrepareSut_DifferentView_Works",
            deviceGroup: Self.deviceGroup
        ) { _ in sut }
    }
    
    func test_PrepareSut_InSnapshotThrows_SameView_Fails() async {
        let sut = await SampleView()
        
        Xct.assertEqual(Self.deviceGroup.devices.count, 2)
        await Xct.snapshotThrows(
            testName: "test_PrepareSut_DifferentView_Works", // reuse other test reference
            deviceGroup: Self.deviceGroup,
            expected: [.sutHasBeenReused],
            prepareReference: { _ in SampleView() },
            prepareSut: { _ in sut }
        )
    }
    
    @MainActor
    func test_SnapshotSutChecker_Check_SutHasBeenSeenBefore_Throws() {
        let checker = SnapshotSutChecker()
        let sameView = UIView()
        
        Xct.assertNoThrow({ try checker.check(UIView()) })
        Xct.assertNoThrow({ try checker.check(UIView()) })
        Xct.assertNoThrow({ try checker.check(sameView) })
        Xct.assertThrowsError({ try checker.check(sameView) }, SnapshotError.sutHasBeenReused)
        Xct.assertNoThrow({ try checker.check(UIView()) })
    }
    
    @MainActor
    func test_SnapshotSutChecker_Check_SnapshotsHolderSubjectHasBeenSeenBefore_Throws() {
        let checker = SnapshotSutChecker()
        let sameView = UIView()
        let holder = SnapshotSutHolder(subject: sameView, retained: [])
        
        Xct.assertNoThrow({ try checker.check(sameView) })
        Xct.assertThrowsError({ try checker.check(holder) }, SnapshotError.sutHasBeenReused)
        Xct.assertNoThrow({ try checker.check(UIView()) })
    }
}

private final class SampleView: UIView {
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .red
    }
    
    override func sizeThatFits(_: CGSize) -> CGSize {
        CGSize(square: 60)
    }
}

