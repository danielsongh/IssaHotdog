import Foundation
import CoreML
import UIKit

class Predictor {
    
    let model = Inceptionv3()
    
    func issaHotdog(image: UIImage) -> Bool {
        if let resizedImage = image.scaleImage(newSize: CGSize(width: 299.0, height: 299.0)), let pixelBuffer = resizedImage.buffer(), let prediction = try? model.prediction(image: pixelBuffer) {
            return prediction.classLabel == "hotdog, hot dog, red hot"
        }
        return false
    }
}
