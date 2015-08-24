
import UIKit

class RSSTableViewController: UITableViewController {
    
    let parser = GoogleNewsRSSParser()
    var RSSdataList = [GoogleNewsItem]()
    var connectedToNetwork = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
            self.connectedToNetwork = isConnectedToNetwork()
            
            var parseSuccess = false
            if self.connectedToNetwork {
                parseSuccess = self.parser.parse()
            }
            self.RSSdataList = self.parser.getGoogleNewsList
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if !self.connectedToNetwork {
                    self.showMsgPopUp("No Internet access. Loading last successful RSS data")
                } else if !parseSuccess && self.connectedToNetwork {
                    self.showMsgPopUp("Error while fetching RSS data. Loading last successful RSS data")
                }
                
                self.tableView.reloadData()
            }
        }
        
        tableView.estimatedRowHeight = 22
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func showMsgPopUp(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
        if let imgURLString = newsItem.imgURL, let cachedImage = newsItem.thumbNailImg {
            cell.imageView?.image = cachedImage
            
        } else if let imgURLString = newsItem.imgURL where connectedToNetwork {
            // Need to set a blank image to the imageView to show the downloaded image
            let blank = UIImage(named: "Blank.jpg")
            var tempImage = CGImageCreateWithImageInRect(blank?.CGImage!, CGRect(x: 0, y: 0, width: 80, height: 80))
            cell.imageView?.image = UIImage(CGImage: tempImage)
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {
                var thumbNailImg = UIImage()
                
                if let imgURL = NSURL(string: imgURLString), let imgData = NSData(contentsOfURL: imgURL), let downloadedImg = UIImage(data: imgData) {
                    thumbNailImg = downloadedImg
                } else {
                    println("Error while downloading img")
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                        newsItem.thumbNailImg = thumbNailImg
                        cellToUpdate.imageView?.image = thumbNailImg
                        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
                        context.save(nil)
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
