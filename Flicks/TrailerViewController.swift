//
//  TrailerViewController.swift
//  Flicks
//
//  Created by Fernando Rodríguez on 2/5/16.
//  Copyright © 2016 Fernando Rodríguez. All rights reserved.
//

import UIKit
import YoutubeSourceParserKit
import MediaPlayer

class TrailerViewController: UIViewController {
    var link:NSURL!
    let moviePlayer = MPMoviePlayerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Trailer"
        print(link)
        moviePlayer.view.frame = view.frame
        view.addSubview(moviePlayer.view)
        moviePlayer.fullscreen = true
        let youtubeURL = link
        playVideoWithYoutubeURL(youtubeURL)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playVideoWithYoutubeURL(url: NSURL) {
        Youtube.h264videosWithYoutubeURL(url, completion: { (videoInfo, error) -> Void in
            if let
                videoURLString = videoInfo?["url"] as? String,
                videoTitle = videoInfo?["title"] as? String {
                    self.moviePlayer.contentURL = NSURL(string: videoURLString)
            }
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
