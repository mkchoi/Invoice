//
//  KCCompanyLogoViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 2/8/19.
//  Copyright © 2019 Kevin Choi. All rights reserved.
//

import Foundation
import UIKit

class KCCompanyLogoViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    
    @IBAction func logoButtonTapped(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("logoButtonTapped")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .overCurrentContext
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("logo.jpg")
            
            let imageData = UIImageJPEGRepresentation(image, 1)
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: paths) {
                do {
                    try fileManager.removeItem(atPath: paths as String)
                } catch {
                    print("cannot delete logo.jpg")
                }
            }
            fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        }
        
        picker.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("logo.jpg")
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: paths) {
            imageView.image = UIImage(contentsOfFile: paths)
        }
        
    }
}

