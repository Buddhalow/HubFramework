/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

import XCTest

class SelectionUITests: UITestCase {
    func testSelectingRootComponent() {
        let app = XCUIApplication()

        // Tap "Pretty pictures" and make sure we navigate to that page.
        navigateToPrettyPictures()

        // Tap the 2nd cell (index 1)
        let collectionView = rootCollectionView(for:app)
        let collectionViewCell = collectionView.children(matching: .cell).element(boundBy: 1)
        let imageView = collectionViewCell.otherElements.children(matching: .image).element
        imageView.tap()

        // Assert we've navigated away...
        XCTAssertFalse(app.navigationBars["Pretty Pictures"].exists)
    }

    func testSelectingChildComponent() {
        let app = XCUIApplication()

        // Tap "Pretty pictures" and make sure we navigate to that page.
        navigateToPrettyPictures()

        // Tap the 2nd cell (index 1) in the 1st row (index 0)
        let collectionView = rootCollectionView(for:app)
        let collectionViewCell = collectionView.children(matching: .cell).element(boundBy: 0)
        let nestedCollectionViewCell = collectionViewCell.cells.element(boundBy: 1)
        let imageView = nestedCollectionViewCell.otherElements.children(matching: .image).element
        imageView.tap()

        // Assert we've navigated away...
        XCTAssertFalse(app.navigationBars["Pretty Pictures"].exists)
    }
    
    func testChildSelectionCancelledOnParentScrolling() {
        let app = XCUIApplication()
        navigateToPrettyPictures()
        
        let collectionView = rootCollectionView(for: app)
        XCTAssertTrue(collectionView.waitForExistence(timeout: 2))
        
        let rootCell = collectionView.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(rootCell.exists)
        
        let carouselCellA = rootCell.cells.element(boundBy: 0)
        let carouselCellB = rootCell.cells.element(boundBy: 2)
        XCTAssertTrue(carouselCellA.exists)
        XCTAssertTrue(carouselCellB.exists)
        
        // Start pressing, then move to the next cell. No selection should happen = we're still in pretty pictures
        carouselCellA.press(forDuration: 3, thenDragTo: carouselCellB)
        XCTAssertTrue(app.navigationBars["Pretty Pictures"].exists)
    }

    /// This function walks the view hierarchy to find the hub framework's collection view.
    /// There are currently no accessibility elements set on the collection view or its cells, so we have no other option.
    /// - Parameter app: the top-level app instance.
    /// - Returns: the collection view element.
    private func rootCollectionView(for app: XCUIApplication) -> XCUIElement {
        let navigatonBarParentQuery = app.otherElements.containing(.navigationBar, identifier:"Pretty Pictures")
        let navigationTransitionView = navigatonBarParentQuery.children(matching: .other).element
        let viewControllerWrapperView = navigationTransitionView.children(matching: .other).element
        let hubContainerView = viewControllerWrapperView.children(matching: .other).element
        return hubContainerView.children(matching: .collectionView).element
    }
    
    private func navigateToPrettyPictures() {
        let app = XCUIApplication()
        app.collectionViews.staticTexts["Pretty pictures"].tap()
        XCTAssertTrue(app.navigationBars["Pretty Pictures"].exists)
    }
}
