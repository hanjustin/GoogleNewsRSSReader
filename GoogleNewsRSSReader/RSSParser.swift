
import Foundation
import UIKit
import CoreData

class GoogleNewsRSSParser: NSObject, NSXMLParserDelegate {
    
    private var googleNewsList = [GoogleNewsItem]()
    var getGoogleNewsList: [GoogleNewsItem] {
        return googleNewsList.count == 0 ? getSavedData() : googleNewsList
    }
    
    private let RSSURL = NSURL(string: "http://news.google.com/?output=rss")
    private let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    private var parser = NSXMLParser()
    private var elements = [:]
    private var currentElement = ""
    private var title = ""
    private var descriptionHTML = ""
    private var pubDate = ""
    

    func parse() -> Bool {
        googleNewsList = []
        parser = NSXMLParser(contentsOfURL: RSSURL)!
        parser.delegate = self
        
        let success = parser.parse()
        
        if success {
            clearCoreData()
            context.save(nil)
        } else {
            googleNewsList = getSavedData()
        }

        return success
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        
        currentElement = elementName
        
        if currentElement == "item"
        {
            elements = NSMutableDictionary.alloc()
            elements = [:]
            title = ""
            descriptionHTML = ""
            pubDate = ""
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if currentElement == "title" {
            title += string ?? ""
        } else if currentElement == "description" {
            descriptionHTML += string ?? ""
        } else if currentElement == "pubDate" {
            pubDate += string ?? ""
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let entity = NSEntityDescription.entityForName("GoogleNewsItem", inManagedObjectContext: context) {
                let newItem = GoogleNewsItem(title: title, descriptionHTML: descriptionHTML, pubDate: pubDate, entity: entity, insertIntoManagedObjectContext: context)
                googleNewsList.append(newItem)
            }
        }
    }
    
    private func getSavedData() -> [GoogleNewsItem] {
        let request = NSFetchRequest(entityName: "GoogleNewsItem")
        let sortByPubDate = NSSortDescriptor(key: "pubDate", ascending: false)
        request.sortDescriptors = [sortByPubDate]
        request.returnsObjectsAsFaults = false
        let fetchedResults = context.executeFetchRequest(request, error: nil)
        
        return fetchedResults as? [GoogleNewsItem] ?? []
    }
    
    // Clearing old data from Core Data
    // If the item is not one of the newly downloaded news item, delete the item
    private func clearCoreData() {
        let savedData = getSavedData()
        
        for item in savedData {
            if !contains(googleNewsList, item) {
                context.deleteObject(item)
            }
        }
    }
    
}