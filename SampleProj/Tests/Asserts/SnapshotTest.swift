import SDSnapshots
import UIKit
import XCTest

class SnapshotTest: XCTestCase {
    private static let device = SnapshotSimulator(
        deviceVersion: "iPhone17,3", // iPhone 16
        osVersion: OperatingSystemVersion(majorVersion: 18, minorVersion: 1, patchVersion: 0)
    )
    
    override class func setUp() {
        Xct.expectedSnapshotSimulatorDevice = Self.device
    }
}
