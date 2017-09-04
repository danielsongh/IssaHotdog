import UIKit
import AVFoundation
import CoreML
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    
    @IBOutlet var previewView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    
    let predictor = Predictor()
    let cameraController = CameraController()
    
    override var prefersStatusBarHidden: Bool { return true }

    let strokeTextAttributes = [
        NSAttributedStringKey.strokeColor: UIColor.black,
        NSAttributedStringKey.foregroundColor: UIColor.white,
        NSAttributedStringKey.strokeWidth: -4.0,
        NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 30)
        ] as [NSAttributedStringKey : Any]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCameraController()
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        styleCaptureButton()
    }
    
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.previewView)
        }
    }
    
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.black.cgColor
        cameraButton.layer.borderWidth = 2
        
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            self.imageView.image = image
            self.previewView.isHidden = true
            
            //self.imageView.isHidden = false
            
            
            if self.predictor.issaHotdog(image: image) {
                self.resultLabel.attributedText = NSMutableAttributedString(string: "Issa hotdog!!!!!", attributes: self.strokeTextAttributes)

                //self.resultLabel.text = "Issa hotdog!!!!!"
                self.emojiLabel.text = "🌭"
                
            }
            else {
                self.resultLabel.attributedText = NSMutableAttributedString(string: "Issnotta hotdog", attributes: self.strokeTextAttributes)

                //self.resultLabel.text = "Issnotta hotdog"
                self.emojiLabel.text = "😩"
            }
            
            
            self.resultLabel.sizeToFit()
            
        }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        imageView.image = nil
        previewView.isHidden = false
        
    }
    
}
