
import UIKit

class RSSTableViewController: UITableViewController {
    
    let parser = GoogleNewsRSSParser()
    var RSSdataList = [GoogleNewsItem]()
    var imagesCache = [String:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 22
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            let hasNetwork = isConnectedToNetwork()
            
            if hasNetwork {
                self.parser.parse()
            }
            self.RSSdataList = self.parser.getGoogleNewsList
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RSSdataList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let newsItem = RSSdataList[indexPath.row]
        cell.imageView?.image = nil
        cell.textLabel?.text = newsItem.title
        cell.detailTextLabel?.text = newsItem.summary
        
        // Use cached image or download new image for the cell
        if let imgURLString = newsItem.imgURL, let cachedImage = imagesCache[imgURLString] {
            cell.imageView?.image = cachedImage
            
        } else if let imgURLString = newsItem.imgURL {
            
            // Need to set a blank image to the imageView to show the downloaded image
            let blank = UIImage(named: "Blank.jpg")
            var tempImage = CGImageCreateWithImageInRect(blank?.CGImage!, CGRect(x: 0, y: 0, width: 80, height: 80))
            cell.imageView?.image = UIImage(CGImage: tempImage)
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                var downloadedImg = UIImage()
                
                if let imgURL = NSURL(string: imgURLString), let imgData = NSData(contentsOfURL: imgURL), let img = UIImage(data: imgData) {
                    downloadedImg = img
                } else {
                    println("Error while downloading img")
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                        cellToUpdate.imageView?.image = downloadedImg
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNewsArticle", let indexPath = self.tableView.indexPathForSelectedRow(),
            let destinationVC = segue.destinationViewController as? GoogleNewsArticleViewController {
                destinationVC.newsItem = RSSdataList[indexPath.row]
        }
    }
    
}
