
import Foundation

class GoogleNewsItem {
    var title: String
    var descriptionHTML: String
    var summary: String
    var imgURL: String?
    
    init(title: String, descriptionHTML: String) {
        self.title = title
        self.descriptionHTML = descriptionHTML
        summary = ""
        
        updateDescriptionHTMLImgURL()
        setSummaryText()
        setImgURL()
    }
    
    private func updateDescriptionHTMLImgURL() {
        descriptionHTML = descriptionHTML.stringByReplacingOccurrencesOfString("<img src=\"//", withString: "<img src=\"http://")
    }
    
    private func setSummaryText() {
        let descriptionTextQueryString = "//table/tr/td[2]/font/div[2]/font[2]"
        if let elements = parseDescriptionHTMLWithXPath(descriptionTextQueryString) where elements.count > 0 {
            summary = elements[0].content
        }
    }
    
    private func setImgURL() {
        let imageQueryString = "//table/tr/td[1]/font/a/img"
        if let elements = parseDescriptionHTMLWithXPath(imageQueryString) where elements.count > 0 {
            imgURL = elements[0].objectForKey("src")
        }
    }
    
    private func parseDescriptionHTMLWithXPath(XPathString: String) -> [TFHppleElement]? {
        let descriptionHTMLData = NSData(data: descriptionHTML.dataUsingEncoding(NSUTF8StringEncoding)!)
        let XpathParser = TFHpple(HTMLData: descriptionHTMLData)
        let nodes = XpathParser.searchWithXPathQuery(XPathString)
        
        return nodes as? [TFHppleElement]
    }
}