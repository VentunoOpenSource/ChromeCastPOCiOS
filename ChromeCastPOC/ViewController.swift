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
    let kCastControlBarsAnimationDuration: TimeInterval = 0.20
    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var _miniMediaControlsContainerView: UIView!
    
    @IBOutlet weak var _miniMediaControlsHeightConstraint: NSLayoutConstraint!
    
    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    
    
    var miniMediaControlsViewEnabled = false {
      didSet {
        if isViewLoaded {
          updateControlBarsVisibility()
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
        //_miniMediaControlsContainerView?.isHidden = true
        let castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
        castButton.tintColor = UIColor.gray
        //navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
        mView.addSubview(castButton)
        
        let castContext = GCKCastContext.sharedInstance()
        miniMediaControlsViewController = castContext.createMiniMediaControlsViewController()
        miniMediaControlsViewController.delegate = self
        updateControlBarsVisibility()
        installViewController(miniMediaControlsViewController,
                              inContainerView: _miniMediaControlsContainerView)
    }

}

extension ViewController{
 
    
    func playVideoRemotely() {
       // _miniMediaControlsContainerView?.isHidden = false
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
        
        miniMediaControlsViewEnabled = true
        playVideoRemotely()
      
    }

    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
      print("MediaViewController: sessionManager didResumeSession \(session)")
        miniMediaControlsViewEnabled = true
        
        
    }

    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
      print("session ended with error: \(String(describing: error))")
      
      
    }

    func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError error: Error?) {
        print("Failed to start a session")
      if let error = error {
        showAlert(withTitle: "Failed to start a session", message: error.localizedDescription)
      }
    }

    func sessionManager(_: GCKSessionManager,
                        didFailToResumeSession _: GCKSession, withError _: Error?) {
    
      print("session didFailToResumeSession")
    }
    
}


extension ViewController{
    // MARK: - Internal methods

    func updateControlBarsVisibility() {
        print("miniMediaControlsViewEnabled",miniMediaControlsViewEnabled,miniMediaControlsViewController.active)
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
    }

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
         updateControlBarsVisibility()
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

extension ViewController{
    func showAlert(withTitle title: String,message: String) {
       let alertController = UIAlertController(title: title,
                                               message: message,
                                               preferredStyle: UIAlertController.Style.alert)
       let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
       alertController.addAction(action)

       present(alertController, animated: true, completion: nil)
     }
}


