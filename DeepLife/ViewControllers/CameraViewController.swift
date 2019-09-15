//
//  CameraViewController.swift
//  DeepLife
//
//  Created by Gwinyai on 15/9/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var simpleCameraView: SimpleCameraView!
    
    var simpleCamera: SimpleCamera!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        simpleCamera = SimpleCamera(cameraView: simpleCameraView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleCamera.startSession()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        simpleCamera.stopSession()
        
    }
    
    
    @IBAction func startCapture(_ sender: Any) {
        
        if simpleCamera.currentCaptureMode == .photo {
            
            simpleCamera.takePhoto { (data, success) in
                
                if success {
                   guard let data = data else { return }
                   NotificationCenter.default.post(name: NSNotification.Name("createNewPost"), object: UIImage(data: data))
                }
                
            }
            
        }
        
    }

}
