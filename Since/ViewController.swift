//
//  ViewController.swift
//  Since
//
//  Created by Kyaw Ye Htun on 4/7/19.
//  Copyright © 2019 Kyaw Ye Htun. All rights reserved.
//

import Foundation
import UIKit
import SwiftyGif

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    
    @IBOutlet weak var imgViw: UIImageView!
    let logoAnimationView = LogoAnimationView()
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = self.loadImageFromDiskWith(fileName: "gg")
        if image == nil {
             imgViw.image = UIImage(named: "ZEPETO_CAPTURE")
        }else{
            imgViw.image = image
        }
        
        view.addSubview(logoAnimationView)
        logoAnimationView.pinEdgesToSuperView()
        logoAnimationView.logoGifImageView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logoAnimationView.logoGifImageView.startAnimatingGif()
    }
    @IBAction func addImg(_ sender: Any) {
        ImagePickerManager().pickImage(self){ image in
            //here is the image
            self.saveImage(imageName: "gg", image: image)
            self.imgViw.image = image
        }
    }
    func loadImageFromDiskWith(fileName: String) -> UIImage? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
            
        }
        
        return nil
    }
    func saveImage(imageName: String, image: UIImage) {
        
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
            
        }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
        
    }
}

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    
    override init(){
        super.init()
    }
    
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
        self.viewController = viewController;
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default){
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController.present(alert, animated: true, completion: nil)
    }
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertView(title:"Warning", message: "You don't have camera", delegate:nil, cancelButtonTitle:"OK")
            alertWarning.show()
        }
    }
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.viewController!.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
//        photoImageView.image = selectedImage

        pickImageCallback?(selectedImage)
    }
    
    //  // For Swift 4.2
    //  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //      picker.dismiss(animated: true, completion: nil)
    //      guard let image = info[.originalImage] as? UIImage else {
    //          fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
    //      }
    //      pickImageCallback?(image)
    //  }
    
   
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
    }
    
}

class LogoAnimationView: UIView {
    
    let logoGifImageView = UIImageView(gifImage: UIImage(gifName: "logo.gif"), loopCount: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    func pinEdgesToSuperView() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
    }
    private func commonInit() {
        backgroundColor = UIColor(white: 246.0 / 255.0, alpha: 1)
        addSubview(logoGifImageView)
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoGifImageView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        logoGifImageView.heightAnchor.constraint(equalToConstant: 108).isActive = true
    }
}


extension ViewController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}
