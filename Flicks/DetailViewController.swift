//
//  DetailViewController.swift
//  Flicks
//
//  Created by Fernando Rodríguez on 2/1/16.
//  Copyright © 2016 Fernando Rodríguez. All rights reserved.
//

import UIKit




class DetailViewController: UIViewController {
    
    @IBOutlet weak var posterImgView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var trialerButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movieInfoView: UIView!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratinglabel: UILabel!
    var movies: NSDictionary!
    var generes: [NSDictionary]!
    var names: [Int]!
    var genre: String = ""
    var trailers: [String]! = []
    var thetrailer: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(movies)
        genreRequest()
        let title = movies["title"] as? String
        self.title = title
        titleLabel.text = title
        let overview = movies["overview"] as? String
        overviewLabel.text = overview
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movies["backdrop_path"] as? String {
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            posterImgView.setImageWithURL(posterUrl!)
        }
        names = movies["genre_ids"] as! [Int]
        let rating = movies["vote_average"] as! Float
        ratinglabel.text = String(rating)
        let id = movies["id"] as! Int
        trialerRequest(String(id))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        genreLabel.text = genre
        thetrailer = NSURL(string: "https://www.youtube.com/watch?v=\(trailers[0])")
        
    }
    func genreRequest (){
        
        var dataresponse: NSArray!
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "http://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)")
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
                            dataresponse = responseDictionary["genres"] as! NSArray
                            let dataArray = dataresponse
                            
                            for item in dataArray {
                                // loop through data items
                                let obj = item as! NSDictionary
                                let genreId = obj["id"] as! Int
                                for id in self.names {
                                    if id == genreId {
                                        self.genre = obj["name"]! as! String + " " + self.genre
                                    }
                                
                            }
                                    
                                    
                                
                            }
                            
                    }
                }
        })
        
        task.resume()

        
    }
    func trialerRequest(id:String){
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/\(id)/videos?api_key=\(apiKey)")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
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
                            let result = responseDictionary["results"] as! NSArray
                            
                            for item in result {
                                let dict = item as! NSDictionary
                                //print(dict["key"]!)
                                let trailstr = dict["key"] as! String
                                self.trailers.append(trailstr)
                            }
                            //print(self.trailers)
                                
                            
                            
                    }
                }
        })
        task.resume()
        
    }

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let buttn = sender as! UIButton
        let trailerViewController = segue.destinationViewController as! TrailerViewController
        trailerViewController.link = thetrailer
        
        
    }


}
