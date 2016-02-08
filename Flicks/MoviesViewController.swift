//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Fernando Rodríguez on 1/23/16.
//  Copyright © 2016 Fernando Rodríguez. All rights reserved.
//

import UIKit
import AFNetworking
import SOTProgressHUD


class MoviesViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var NetworkErr: UIView!
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var endpoint:String = ""
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        //LightContent
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredMovies = movies
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        if isConnectedToNetwork() {
            NetworkErr.hidden = true
            netRequest()
        }else{
            NetworkErr.hidden = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {

        netRequest()
        refreshControl.endRefreshing()
    }
    
    func netRequest (){
        SOTProgressHUD.sharedHUD.show(self.view)
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                            SOTProgressHUD.sharedHUD.dismiss()
                    }
                }
        })
        
        task.resume()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMovies = movies
        collectionView.reloadData()
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
            filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
                return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
            collectionView.reloadData()
    }
    let totalColors: Int = 100
   
    
        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if let filteredMovies = filteredMovies {
                return filteredMovies.count
            }else {
                return 0
            }
        }
        
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("postercell", forIndexPath: indexPath) as! ColorCell
            let movie = filteredMovies![indexPath.row]
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = backgroundView
            
            
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            
            if let posterPath = movie["poster_path"] as? String {
                let posterUrl = NSURL(string: posterBaseUrl + posterPath)
                cell.moviePosterView.setImageWithURL(posterUrl!)
            }
            return cell
            
        }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movies = movie
        
    }
    
}
