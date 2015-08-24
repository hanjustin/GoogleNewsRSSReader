
import UIKit

class GoogleNewsArticleViewController: UIViewController {
    
    @IBOutlet weak var relatedLinksWebView: UIWebView!
    @IBOutlet weak var storyArticleWebView: UIWebView!
    
    var newsItem: GoogleNewsItem!
    
    @IBAction func toggleLinks(sender: UIBarButtonItem) {
        toggleWebViewsVisibility()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebViews()
        relatedLinksWebView.delegate = self
        storyArticleWebView.delegate = self
        storyArticleWebView.hidden = true
    }
    
    func loadWebViews() {
        if let newsItem = newsItem {
            relatedLinksWebView.loadHTMLString(newsItem.descriptionHTML, baseURL: nil)
        }
    }
    
    func toggleWebViewsVisibility() {
        relatedLinksWebView.hidden = !relatedLinksWebView.hidden
        storyArticleWebView.hidden = !storyArticleWebView.hidden
        let newRightBarButtonText = relatedLinksWebView.hidden ? "Show Links" : "Hide Links"
        navigationItem.rightBarButtonItem?.title = newRightBarButtonText
    }
}

extension GoogleNewsArticleViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // Only load initial HTML data in relatedLinksWebView
        if navigationType == .Other {
            return true
        }
        
        storyArticleWebView.loadRequest(request)
        toggleWebViewsVisibility()
        return false
    }
}

