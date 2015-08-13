
import Foundation

class GoogleNewsRSSParser: NSObject, NSXMLParserDelegate {
    
    var googleNewsList = [GoogleNewsItem]()
    
    private var parser = NSXMLParser()
    private var elements = [:]
    private var currentElement = ""
    private var title = ""
    private var descriptionHTML = ""
    
    func parse() -> Bool {
        googleNewsList = []
        let RSSURL = NSURL(string: "http://news.google.com/?output=rss")
        parser = NSXMLParser(contentsOfURL: RSSURL)!
        parser.delegate = self
        let success = parser.parse()
        
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
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if currentElement == "title" {
            title += string ?? ""
        } else if currentElement == "description" {
            descriptionHTML += string ?? ""
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let newGoogleNewsItem = GoogleNewsItem(title: title ?? "", descriptionHTML: descriptionHTML ?? "")
            googleNewsList.append(newGoogleNewsItem)
        }
    }
}