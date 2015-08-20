
import Foundation

// Check network connection by attempting to connect to Google
func isConnectedToNetwork() -> Bool {
    let url = NSURL(string: "http://google.com/")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "HEAD"
    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
    request.timeoutInterval = 5.0
    
    var response: NSURLResponse?
    NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil)
    
    if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
        return true
    }

    return false
}