
import UIKit
import PhotosUI
import FirebaseStorage

class SelectPhotosViewController: UIViewController, PHPickerViewControllerDelegate {
    weak var databaseController:DatabaseProtocol?
    var addPostController:SheetAddPostViewController?
    var updatePostController:UpdatePostViewController?
    var selectedImages:[UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        showPhotoPicker()
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("di")
        selectedImages = []
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
        
        if results.isEmpty{
            print("hello")
            databaseController?.selectedImage = nil
        }
        var counter = 0
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        counter += 1
                        self?.selectedImages.append(image)
                        if counter == results.count{
                            if let addPostController = self?.addPostController{
                                self?.addPostController!.addImage(images: self!.selectedImages)
                            }
                            if let updatePostController = self?.updatePostController{
                                self?.updatePostController!.addImage(images: self!.selectedImages)
                            }
                        }
                    }
                } else {
                    print("Failed to load image: \(String(describing: error))")
                }
            }
        }
    }
}
