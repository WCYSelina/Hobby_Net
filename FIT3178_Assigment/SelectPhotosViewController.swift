
import UIKit
import PhotosUI

class SelectPhotosViewController: UIViewController, PHPickerViewControllerDelegate {
    weak var databaseController:DatabaseProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        showPhotoPicker()
        // Do any additional setup after loading the view.
    }
    
    private func showPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0 // Set to 0 for no limit, or any other number for a specific limit.
        configuration.filter = .images // Filter to only show images.
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) { () in
            self.dismiss(animated: true)
        }
        
//        if results.isEmpty{
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let destinationVC = storyboard.instantiateViewController(withIdentifier: "AddRecordViewController")
//            navigationController?.pushViewController(destinationVC, animated: true)
//            return
//        }
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.databaseController?.image?.append(image)
                        print(self?.databaseController?.image)
                    }
                } else {
                    print("Failed to load image: \(String(describing: error))")
                }
            }
        }
    }
}
