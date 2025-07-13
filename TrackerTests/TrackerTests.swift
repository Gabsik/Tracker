//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Ленар Габсалямов on 12.07.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker



class TrackerTests: XCTestCase {
    
//    override func setUp() {
//        super.setUp()
//        // Используй true, если хочешь перезаписать снимки
//        isRecording = true
//    }
    
    func testViewControllerLight() {
        let trackersViewController = TrackersViewController()
        let navTrackersViewController = UINavigationController(rootViewController: trackersViewController)
        //        _ = navTrackersViewController.view
        
        assertSnapshot(matching: navTrackersViewController, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testViewControllerDark() {
        let trackersViewController = TrackersViewController()
        let navTrackersViewController = UINavigationController(rootViewController: trackersViewController)
        //        _ = navTrackersViewController.view
        
        assertSnapshot(matching: navTrackersViewController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
