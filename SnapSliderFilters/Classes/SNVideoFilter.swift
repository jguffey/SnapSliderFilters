//
//  SNVideoFilter.swift
//  Pods-SnapSliderFilters_Example
//
//  Created by Josh Guffey on 8/29/18.
//

import UIKit
import AVKit

open class SNVideoFilter: UIView {
    var videoLocation: URL?
    var currentVideoPlayer: AVPlayer?
    var videoPlayerObserver: NSObjectProtocol?
    var stickers = [SNSticker]()
    open var filterName: String?
    
    /*
     Todo:
     - Create Masking methods
     - Fill out applyFilter method
     - Create addSticker method
     - Apply Stickers
     - Test in app.
     - Update SNSliderDataSource's slider sliderAtIndex method to accept videos.
     */
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(frame: CGRect, withVideoAt url:URL, withContentMode mode:UIViewContentMode = .scaleAspectFill) {
        super.init(frame: frame)
        self.videoLocation = url
        self.contentMode = mode
        self.clipsToBounds = true
        let maskLayer = CAShapeLayer()
        self.layer.mask = maskLayer
        maskLayer.frame = frame
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open static func generateFilters(_ originalVideo: SNVideoFilter, filters:[String]) -> [SNVideoFilter] {
        var finalFilters = [SNVideoFilter]()
        
        for filter in filters {
            let filterComputed = originalVideo.applyFilter(filterNamed: filter)
            finalFilters.append(filterComputed)
        }
        
        return finalFilters
    }
    
    open func addSticker(_ sticker: SNSticker) {
        self.stickers.append(sticker)
    }
    
    // MARK: - Video Specific
    func setupNonSliderView() {
        // Load in the video, and add a sublayer to play the video.
        if let url = self.videoLocation {
            let player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.backgroundColor = UIColor.clear.cgColor
            playerLayer.frame = self.bounds
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.layer.sublayers?
                .filter { $0 is AVPlayerLayer }
                .forEach { $0.removeFromSuperlayer() }
            self.layer.addSublayer(playerLayer)
            
            // Configure the player.
            player.play()
            player.allowsExternalPlayback = false
            
            // Configure the video to loop.
            self.videoPlayerObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { (_) in
                player.seek(to: kCMTimeZero)
                player.play()
            }
            
            // Store player for later use
            self.currentVideoPlayer = player
        }
    }
    
    // MARK: - Video Filtering
    func applyFilter(filterNamed name: String) -> SNVideoFilter {
        let filter:SNVideoFilter = self.copy() as! SNVideoFilter
        // Load the video
        // Apply the filtering to the video.
        // Return the new video.
        return filter
    }
    
}

// MARK: - NSCopying protocol

extension SNVideoFilter: NSCopying {
    
    public func copy(with zone: NSZone?) -> Any {
        guard
            let videoLocation = videoLocation
            else { fatalError("The video location is mandatory") }
        
        let copy = SNVideoFilter(frame: frame, withVideoAt: videoLocation, withContentMode: contentMode)
        copy.backgroundColor = self.backgroundColor
        copy.filterName = filterName
        
        for s in stickers {
            copy.stickers.append(s.copy() as! SNSticker)
        }
        return copy
    }
}
