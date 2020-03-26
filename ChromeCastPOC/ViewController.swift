//
//  ViewController.swift
//  ChromeCastPOC
//
//  Created by Ventuno Technologies on 24/03/20.
//  Copyright © 2020 Ventuno Technologies. All rights reserved.
//

import UIKit
import GoogleCast

class ViewController: UIViewController {

    private var sessionManager: GCKSessionManager!
    private var mediaInformation: GCKMediaInformation?
    
    let kReceiverAppID = kGCKDefaultMediaReceiverApplicationID
    let kDebugLoggingEnabled = true
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var _miniMediaControlsContainerView: UIView!
    
    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    
    
    var miniMediaControlsViewEnabled = false {
      didSet {
        if isViewLoaded {
         // updateControlBarsVisibility()
        }
      }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        sessionManager = GCKCastContext.sharedInstance().sessionManager
        
        sessionManager.add(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        castButton.tintColor = UIColor.gray
        //navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
        mView.addSubview(castButton)
        
        let castContext = GCKCastContext.sharedInstance()
           miniMediaControlsViewController = castContext.createMiniMediaControlsViewController()
           miniMediaControlsViewController.delegate = self
        //   updateControlBarsVisibility()
           installViewController(miniMediaControlsViewController,
                                 inContainerView: _miniMediaControlsContainerView)
    }

}

extension ViewController{
 
    
    func playVideoRemotely() {
       GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()

       // Define media metadata.
       let metadata = GCKMediaMetadata()
       metadata.setString("Big Buck Bunny (2008)", forKey: kGCKMetadataKeyTitle)
       metadata.setString("Big Buck Bunny tells the story of a giant rabbit with a heart bigger than " +
         "himself. When one sunny day three rodents rudely harass him, something " +
         "snaps... and the rabbit ain't no bunny anymore! In the typical cartoon " +
         "tradition he prepares the nasty rodents a comical revenge.",
                          forKey: kGCKMetadataKeySubtitle)
       metadata.addImage(GCKImage(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg")!,
                                  width: 480,
                                  height: 360))

       let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
       mediaInfoBuilder.streamType = GCKMediaStreamType.none
       mediaInfoBuilder.contentType = "video/mp4"
       mediaInfoBuilder.metadata = metadata
       mediaInformation = mediaInfoBuilder.build()

       let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
       mediaLoadRequestDataBuilder.mediaInformation = mediaInformation

       // Send a load request to the remote media client.
       if let request = sessionManager.currentSession?.remoteMediaClient?.loadMedia(with: mediaLoadRequestDataBuilder.build()) {
         request.delegate = self
       }
     }
}

extension ViewController:GCKRequestDelegate,GCKSessionManagerListener,GCKRemoteMediaClientListener{
    
    func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
      print("MediaViewController: sessionManager didStartSession \(session)")
        session.remoteMediaClient?.add(self)
        playVideoRemotely()
      
    }

    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
      print("MediaViewController: sessionManager didResumeSession \(session)")
     
    }

    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
      print("session ended with error: \(String(describing: error))")
//      let message = "The Casting session has ended.\n\(String(describing: error))"
//      if let window = appDelegate?.window {
//        Toast.displayMessage(message, for: 3, in: window)
//      }
      
    }

    func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError error: Error?) {
        print("Failed to start a session")
//      if let error = error {
//        showAlert(withTitle: "Failed to start a session", message: error.localizedDescription)
//      }
    }

    func sessionManager(_: GCKSessionManager,
                        didFailToResumeSession _: GCKSession, withError _: Error?) {
//      if let window = UIApplication.shared.delegate?.window {
//        Toast.displayMessage("The Casting session could not be resumed.",
//                             for: 3, in: window)
//      }
      
    }
    
}


extension ViewController{
    // MARK: - Internal methods
/*
    func updateControlBarsVisibility() {
      if miniMediaControlsViewEnabled, miniMediaControlsViewController.active {
        _miniMediaControlsHeightConstraint.constant = miniMediaControlsViewController.minHeight
        view.bringSubviewToFront(_miniMediaControlsContainerView)
      } else {
        _miniMediaControlsHeightConstraint.constant = 0
      }
      UIView.animate(withDuration: kCastControlBarsAnimationDuration, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
      view.setNeedsLayout()
    }*/

    func installViewController(_ viewController: UIViewController?, inContainerView containerView: UIView) {
      if let viewController = viewController {
        addChild(viewController)
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
      }
    }

    func uninstallViewController(_ viewController: UIViewController) {
      viewController.willMove(toParent: nil)
      viewController.view.removeFromSuperview()
      viewController.removeFromParent()
    }
    
}
extension ViewController: GCKUIMiniMediaControlsViewControllerDelegate{
    func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {
        
    }
    
   
}


extension ViewController: GCKLoggerDelegate{
    func logMessage(_ message: String,
                     at level: GCKLoggerLevel,
                     fromFunction function: String,
                     location: String) {
       if (kDebugLoggingEnabled) {
         print(function + " - " + message)
       }
     }
}

