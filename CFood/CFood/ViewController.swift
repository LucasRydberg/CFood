//
//  ViewController.swift
//  CFood
//
//  Created by Lucas Rydberg on 9/6/18.
//  Copyright © 2018 Lucas Rydberg. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let apiKey = "sVK9c9ruBZEgAelH77XJD6EodqInTP070qn409ElAEGC"
    let version = "2018-06-09"
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topBarImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imagePicker.delegate = self
        shareButton.isHidden = true
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // disable camera button while Watson is working and show loading spinner
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        
        if let userSelectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = userSelectedImage
            imagePicker.dismiss(animated: true, completion: nil)
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            
            visualRecognition.classify(image: userSelectedImage, success: { (classifiedImages) in
                
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                
                print(self.classificationResults)
                // re-enable the camera button
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    self.shareButton.isHidden = false
                    SVProgressHUD.dismiss()
                }
                
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "hotdog")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "not-hotdog")

                    }
                    
                }
                
            })
            
            
        } else {
            print("error picking the image")
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(String(describing: navigationItem.title))")
            present(vc!, animated: true, completion: nil)
        } else {
            self.navigationItem.title = "Log into Twitter first!"
        }
    }
}

