
import UIKit
import AVFoundation
import PhotosUI
import AVKit
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {
  
    
    enum MediaMode {
        case photo
        case video
    }
    var mediaMode:MediaMode = .photo
    
    var initializeTimer:Timer?
    var frame = 0
    
    var ciContext = CIContext()
    
    let classLabels = ["person","fighter"]
    
//    let classLabels = ["person", "bicycle", "car", "motorcycle", "airplane", "bus", "train", "truck", "boat", "traffic light", "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat", "dog", "horse", "sheep", "cow", "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella", "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard", "sports ball", "kite", "baseball bat", "baseball glove", "skateboard", "surfboard", "tennis racket", "bottle", "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple", "sandwich", "orange", "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair", "couch", "potted plant", "bed", "dining table", "toilet", "tv", "laptop", "mouse", "remote", "keyboard", "cell phone", "microwave", "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase", "scissors", "teddy bear", "hair drier", "toothbrush","fighter"]
    
    let colorSet:[UIColor] = {
        var colorSet:[UIColor] = []

        for _ in 0...80 {
            let color = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
            colorSet.append(color)
        }
        
        return colorSet
    }()
    
     let imageView: UIImageView = {
        let imageView = UIImageView()
         
        return imageView
    }()  
    
    let loader: UIActivityIndicatorView = {
       let loader = UIActivityIndicatorView()
        return loader
   }()
     let messageLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    lazy var coreMLRequest:VNCoreMLRequest? = {
        do {
            let model = try test(configuration: MLModelConfiguration()).model
            let vnCoreMLModel = try VNCoreMLModel(for: model)
            let request = VNCoreMLRequest(model: vnCoreMLModel)
            request.imageCropAndScaleOption = .scaleFill
            return request
        } catch let error {
            print(error)
            return nil
        }
    }()


    
    let button:UIButton = {
        let button = UIButton()
        button.setTitle("Библиотека", for: .normal)
        button.backgroundColor = .darkGray
       return button
    }()
    
    
    
    @objc func showLibrary() {
        presentPhPicker()
    }
    
    func generateThumbnail(path: URL) {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            imageView.image = thumbnail
            print("thumbnail!!")
//            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
//            return nil
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(button)
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(loader)
        button.addTarget(self, action: #selector(showLibrary), for: .touchUpInside)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.frame = CGRect(x: UIScreen.main.bounds.width/2-50, y: 400, width: 120, height: 50)
        messageLabel.frame = CGRect(x: UIScreen.main.bounds.width/2-25, y: 400, width: 230, height: 50)
        loader.frame = CGRect(x: UIScreen.main.bounds.width/2-25, y: 400, width: 50, height: 50)
        
    }
    
    func presentPhPicker(){
        let alert = UIAlertController(title: "Select Media", message: "", preferredStyle: .actionSheet)
        let imageAction = UIAlertAction(title: "Image", style: .default) { action in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.mediaMode = .photo
            self.present(picker, animated: true)
        }
        
        let videoAction = UIAlertAction(title: "Video", style: .default) { action in
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 1
            configuration.filter = .videos
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.mediaMode = .video
            self.present(picker, animated: true)
        }
        alert.addAction(imageAction)
        alert.addAction(videoAction)
        self.present(alert, animated: true)
    }
    

    override class func provideImageData(_ data: UnsafeMutableRawPointer, bytesPerRow rowbytes: Int, origin x: Int, _ y: Int, size width: Int, _ height: Int, userInfo info: Any?) {
    
    }

    


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        self.dismiss(animated: true)
    }
    func getCorrectOrientationUIImage(uiImage:UIImage) -> UIImage {
        var newImage = UIImage()
        let ciContext = CIContext()
        switch uiImage.imageOrientation.rawValue {
        case 1:
            guard let orientedCIImage = CIImage(image: uiImage)?.oriented(CGImagePropertyOrientation.down),
                  let cgImage = ciContext.createCGImage(orientedCIImage, from: orientedCIImage.extent) else { return uiImage}
            
            newImage = UIImage(cgImage: cgImage)
        case 3:
            guard let orientedCIImage = CIImage(image: uiImage)?.oriented(CGImagePropertyOrientation.right),
                  let cgImage = ciContext.createCGImage(orientedCIImage, from: orientedCIImage.extent) else { return uiImage}
            newImage = UIImage(cgImage: cgImage)
        default:
            newImage = uiImage
        }
        return newImage
    }

}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        switch mediaMode {
        case .photo:
            guard let result = results.first else { return }
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error  in
                    if let image = image as? UIImage,  let safeSelf = self {
                        
                        let correctOrientImage = safeSelf.getCorrectOrientationUIImage(uiImage: image) // iPhoneのカメラで撮った画像は回転している場合があるので画像の向きに応じて補正
                        
                        // モデルの初期化が終わっているか確認して検出実行
                        if self?.coreMLRequest != nil {
                            safeSelf.detect(image: correctOrientImage)
                        } else {
                            self?.initializeTimer = Timer(timeInterval: 0.5, repeats: true, block: { timer in
                                if self?.coreMLRequest != nil {
                                    safeSelf.detect(image: correctOrientImage)
                                    timer.invalidate()
                                }
                            })
                        }
                    }
                }
            }
            
        case .video:
            guard let result = results.first else { return }
            
            self.button.isHidden = true
            self.loader.isHidden = false
            self.loader.startAnimating()
//            imageView.isHidden =
            guard let typeIdentifier = result.itemProvider.registeredTypeIdentifiers.first else { return }
            if result.itemProvider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { [weak self] (url, error) in
                    if let error = error { print("*** error: \(error)") }
                    let start = Date()
                    DispatchQueue.main.async {
                        self?.imageView.image = nil
                    }
                    if let url = url as? URL {
                        
                        
                        result.itemProvider.loadItem(forTypeIdentifier: typeIdentifier, options:nil) { (url, error) in
                            DispatchQueue.main.async {
                                UIView.animate(withDuration: 0.5) {
                                    self?.messageLabel.isHidden = false
                                    self?.loader.frame = CGRect(x: UIScreen.main.bounds.width/2-75, y: 400, width: 50, height: 50)
                                }
                            }
                          
                            let procceessed = self?.applyProcessingOnVideo(videoURL: url as! URL) { ciImage in
                              
                              
                                let visualized = self?.detectPartsVisualizing(ciImage: ciImage)
                                return visualized
                            } _: { err, processedVideoURL in
                                let end = Date()
                                
                                let diff = end.timeIntervalSince(start)
                                print("diff: \(diff)")
                                print("processedVideoURL: \(processedVideoURL)")
                                let player = AVPlayer(url: processedVideoURL!)
                                self?.savedVideo(url: processedVideoURL!) { bool in
                                    print({bool})
                                    
                                }
                                DispatchQueue.main.async {
                                    self?.messageLabel.isHidden = true
                                    let controller = AVPlayerViewController()

                                    controller.player = player
                                    self?.present(controller, animated: true) {
                                        player.play()
                                        player.volume = 1
                                        
                                        
                                        self?.messageLabel.isHidden = true
//                                        self?.messageLabel.text = "\((self?.frame)!) frames proccessed"
                                        print("frame: \(self?.frame)")
                                        self?.frame = 0
                                    
                                        self?.loader.isHidden = true
                                        print("button is hidden = false")
                                        self?.button.isHidden = false
                                        self?.loader.stopAnimating()
                                        self?.loader.frame = CGRect(x: UIScreen.main.bounds.width/2-25, y: 400, width: 50, height: 50)
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
}

struct Detection {
    let box:CGRect
    let confidence:Float
    let label:String?
    let color:UIColor
}
