//
//  ViewController.swift
//  MemeMe
//
//  Created by  ashwaq marzouq on 15/07/1444 AH.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var ImagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    var topTextFieldState : Bool = false
    var bottomTextFieldState : Bool = false
    var meme = MemeMe()
  
    
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -3.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
       shareButton.isEnabled = false
        configureMemeTextField(textField: topText, text: "Top")
        configureMemeTextField(textField: bottomText, text: "Bottom")
        
        
        if  UIImagePickerController.isSourceTypeAvailable(.camera){
            cameraButton.isEnabled = false;}
else{
    cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera);
}

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        ImagePickerView.image = image
        shareButton.isEnabled = true
        picker.dismiss(animated: true, completion: nil)
    }
  
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
   
    func pickImage(_ imageSource: UIImagePickerController.SourceType ) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = imageSource
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromLibrary(_ sender: Any) {
        self.pickImage(.photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any){
        self.pickImage(.camera)
    }
    func configureMemeTextField(textField: UITextField, text: String) {
        textField.text = text
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {

        if topTextFieldState == false && textField == topText {
            textField.text = ""
            topTextFieldState = true
        } else if bottomTextFieldState == false && textField == bottomText {
            textField.text = ""
            bottomTextFieldState = true
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
  
    
   
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
        view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    
    func generateMemedImage() -> UIImage {
        
       //hides toolbar and navigation bar
        // Hide toolbar and navbar
        toolBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
   
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        toolBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false

        return memedImage
        
    }
    func save(){
        // Create the meme
        let meme =  MemeMe(topText: topText.text!, bottomText: bottomText.text!, originalImage: ImagePickerView.image!, memeImage: generateMemedImage())
       
    }
    

        @IBAction func share(_ sender: Any) {
        
            let image: UIImage = generateMemedImage()
            let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(controller, animated: true, completion: nil)
            controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                
                if completed {
                    self.save()
                }
                self.dismiss(animated: true, completion: nil)
            }
           }
           }

