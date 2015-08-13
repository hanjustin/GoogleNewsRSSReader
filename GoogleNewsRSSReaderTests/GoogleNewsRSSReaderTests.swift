
import UIKit
import XCTest

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
    
    func testImagesOnTableCells() {
        testVC.RSSdataList[0].imgURL = "https://www.google.com/images/srpr/logo11w.png"
        testVC.RSSdataList[1].imgURL = nil
        testVC.imagesCache = [String:UIImage]()
        
        testVC.tableView.reloadData()
        let cells = testVC.tableView.visibleCells() as! [UITableViewCell]
        
        XCTAssertNotNil(cells[0].imageView?.image, "Cell's image should not be nil for news item with imgURL")
        XCTAssertNil(cells[1].imageView?.image, "Cell's image should be nil for news item without imgURL")
    }
    
    func testRSSParseSuccess() {
        XCTAssertTrue(testVC.RSSdataList.count > 0, "Successful parse is expected to have more than 1 data result")
        // TableView should be also reloaded.
    }
    
    func testRSSParseFailure() {
        // To be implemented. Decide what to do when it failed.
    }
}
