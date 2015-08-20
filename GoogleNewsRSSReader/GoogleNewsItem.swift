
import Foundation
import CoreData
import UIKit

class GoogleNewsItem: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var descriptionHTML: String
    @NSManaged var pubDate: String
    var summary: String {
        return getSummaryText()
    }
    var imgURL: String?
    
    // Init inheritance problem. "use of unimplemented initializer" will happen from core data fetch request. Need to research further.
    convenience init(title: String, descriptionHTML: String, pubDate: String,
                     entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.title = title
        self.descriptionHTML = descriptionHTML
        self.pubDate = pubDate
        
        updateDescriptionHTMLImgURL()
        setImgURL()
    }
    
    convenience init(title: String, descriptionHTML: String, pubDate: String) {
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext!
        let entity = NSEntityDescription.entityForName("GoogleNewsItem", inManagedObjectContext: context)!
        self.init(title: title, descriptionHTML: descriptionHTML, pubDate: pubDate, entity: entity, insertIntoManagedObjectContext: context)
    }
    
    private func updateDescriptionHTMLImgURL() {
        descriptionHTML = descriptionHTML.stringByReplacingOccurrencesOfString("<img src=\"//", withString: "<img src=\"http://")
    }
    
    private func setImgURL() {
        let imageQueryString = "//table/tr/td[1]/font/a/img"
        if let elements = parseDescriptionHTMLWithXPath(imageQueryString) where elements.count > 0 {
            imgURL = elements[0].objectForKey("src")
        }
    }
    
    private func getSummaryText() -> String {
        let descriptionTextQueryString = "//table/tr/td[2]/font/div[2]/font[2]"
        if let elements = parseDescriptionHTMLWithXPath(descriptionTextQueryString) where elements.count > 0 {
            return elements[0].content
        }
        
        return ""
    }
    
    private func parseDescriptionHTMLWithXPath(XPathString: String) -> [TFHppleElement]? {
        let descriptionHTMLData = NSData(data: descriptionHTML.dataUsingEncoding(NSUTF8StringEncoding)!)
        let XpathParser = TFHpple(HTMLData: descriptionHTMLData)
        let nodes = XpathParser.searchWithXPathQuery(XPathString)
        
        return nodes as? [TFHppleElement]
    }
}