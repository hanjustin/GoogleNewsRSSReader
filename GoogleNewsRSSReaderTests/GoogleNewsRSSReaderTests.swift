
import UIKit
import XCTest

// VERY INCOMPLETE
// Some test codes will not even run.
// Many test cases are not implemented. Still learning how to properly test iOS application code.

class GoogleNewsRSSReaderTests: XCTestCase {
    
    var testVC: RSSTableViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        testVC = storyboard.instantiateViewControllerWithIdentifier("GoogleNewsRSSTable") as! RSSTableViewController
        let initialize = testVC.view
        testVC.viewDidLoad()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTextsOnTableCells() {
        for cell in testVC.tableView.visibleCells() {
            XCTAssertNotNil(cell.textLabel , "News article item should have a title")
            XCTAssertNotNil(cell.detailTextLabel, "News article item should have a short summary")
        }
    }
    
    func testRSSParseSuccess() {
        XCTAssertTrue(testVC.RSSdataList.count > 0, "Successful parse is expected to have more than 1 data result")
        // There should be no popup
        // TableView should be also reloaded.
    }
    
    func testRSSParseFailure() {
        // A popup with the RSS parse failure message should be shown.
        // Last successful RSS data should be shown
    }
    
    func testNoNetworkConnection() {
        // A popup with the 'No Internet' message should be shown.
        // Last successful RSS data should be shown
    }
}
