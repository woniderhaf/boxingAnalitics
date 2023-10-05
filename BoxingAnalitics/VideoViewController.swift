//
//  VideoViewController.swift
//  BoxingAnalitics
//
//  Created by Ivan Ivanov on 05.10.2023.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController {
    let videoURL: URL?
    
    private let player:AVPlayer
    
    private let playerLayer:AVPlayerLayer
    
    init(videoURL:URL) {
        self.videoURL = videoURL
        self.player = AVPlayer(url: videoURL)
        self.playerLayer = AVPlayerLayer(player: self.player)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(playerLayer)
        view.backgroundColor = .systemBackground
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        player.play()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let window = UIScreen.main
        if UIDevice.current.orientation.isLandscape {
            playerLayer.frame = window.bounds
        } else {
            playerLayer.frame = window.bounds
        }
    }
    
    @objc func back() {
        self.dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    


}
