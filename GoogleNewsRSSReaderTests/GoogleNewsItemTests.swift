
import UIKit
import XCTest

class GoogleNewsItemTests: XCTestCase {
    
    let title = "News Title"
    var descriptionHTMLSamples: [String]!
    var testItemWithImage: GoogleNewsItem!
    var testItemNoImage: GoogleNewsItem!

    override func setUp() {
        super.setUp()
        
        /* Create GoogleNewsItem by getting descriptionHTML data from SampleDescriptionHTML.txt
           The file consists of two different scenarios:
           1. descriptionHTML with ImgURL
           2. descriptionHTML without ImgURL
        */
        let sampleDescriptionHTMLpath = NSBundle.mainBundle().pathForResource("SampleDescriptionHTML", ofType: "txt")
        if let path = sampleDescriptionHTMLpath {
            let textData = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
            descriptionHTMLSamples = textData.componentsSeparatedByString("\n")
            
            testItemWithImage = GoogleNewsItem(title: title, descriptionHTML: descriptionHTMLSamples[0])
            testItemNoImage = GoogleNewsItem(title: title, descriptionHTML: descriptionHTMLSamples[1])
        } else {
            XCTFail("Test initialization failed: SampleDescriptionHTML.txt not found")
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testTitleInitialization() {
        XCTAssertEqual(testItemWithImage.title, title, "Title property should be what it was set to in the initialization")
    }
    
    func testSummaryInitialization() {
        let descriptionHTML = descriptionHTMLSamples[0]
        XCTAssertNotEqual(testItemWithImage.summary, "", "Summary text should not be empty when initialized")
        
        // Removing ' ...' at the end of the summary and look for it in the descriptionHTML source
        let summary = testItemWithImage.summary
        let index = advance(summary.endIndex, -4)
        let trimmedSummary = testItemWithImage.summary.substringToIndex(index)
        XCTAssertTrue(descriptionHTML.rangeOfString(trimmedSummary) != nil, "Summary text should be fetched from descriptionHTML property")
    }
    
    func testDescriptionHTMLUpdatedToContainCompleteImgURL() {
        let ImgURLPrefix = "<img src=\"http://"
        var descriptionHTML = descriptionHTMLSamples[0]
        XCTAssertTrue(testItemWithImage.descriptionHTML.rangeOfString(ImgURLPrefix) != nil, "Description HTML should have 'http://' for a complete img URL")
    }
    
    func testImgURLInitialization() {
        if let imgURL = testItemWithImage.imgURL {
            XCTAssertTrue(imgURL.hasPrefix("http://"), "ImgURL should start with 'http://'")
        } else {
            XCTFail("ImgURL should exist when there is imgURL in the descriptionHTML source")
        }
        
        XCTAssertNil(testItemNoImage.imgURL, "ImgURL should be nil when there is no imgURL in the descriptionHTML source")
    }

}
