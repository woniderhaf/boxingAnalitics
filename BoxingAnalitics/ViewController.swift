
import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    private let button:UIButton = {
        let button = UIButton()
        button.setTitle("Library", for: .normal)
        button.backgroundColor = .darkGray
       return button
    }()
    
    private let imagePicker = UIImagePickerController()
    
    @objc func showLibrary() {
        print("showLibrary")
        self.present(imagePicker, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(button)
        button.addTarget(self, action: #selector(showLibrary), for: .touchUpInside)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.allowsEditing = false
        
    }
    
    private func goVideoView(url:URL) {
        let vc = VideoViewController(videoURL: url)
        navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.frame = CGRect(x: 200, y: 400, width: 100, height: 50)
    }
    override class func provideImageData(_ data: UnsafeMutableRawPointer, bytesPerRow rowbytes: Int, origin x: Int, _ y: Int, size width: Int, _ height: Int, userInfo info: Any?) {
    
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let mediaURL = info[.mediaURL] else {
            print("error")
            self.dismiss(animated: true)
         
            return
        }
        
        guard let url = URL(string: String(describing: mediaURL)) else {
            return
        }
     
        
        self.dismiss(animated: true) {
            
            self.goVideoView(url:url)
        }
   
        
    }
    


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        self.dismiss(animated: true)
    }

}

