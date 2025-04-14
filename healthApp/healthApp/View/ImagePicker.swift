import SwiftUI
import UIKit

/// A wrapper around UIImagePickerController to allow SwiftUI to present the camera.
struct ImagePicker: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    /// Access to presentation environment for dismissing the view
    @Environment(\.presentationMode) private var presentationMode
    
    /// Binding to pass the selected image back to the parent view
    @Binding var selectedImage: UIImage?
    
    /// Determines whether to show camera or photo library
    /// Defaults to photo library, can be set to .camera
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // MARK: - UIViewControllerRepresentable Methods
    
    /// Creates and configures the UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType // Set to camera or photo library
        imagePicker.delegate = context.coordinator // Set delegate to handle selection and cancellation
        return imagePicker
    }
    
    /// Updates the view controller (not needed for this implementation)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    /// Creates a coordinator to handle UIKit delegate callbacks
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    /// Coordinator class that acts as a delegate for the UIImagePickerController
    /// Handles image selection and cancellation events
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        /// Reference to the parent ImagePicker to access its properties
        let parent: ImagePicker
        
        /// Initialize with reference to parent
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        /// Called when user selects an image
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Retrieve the selected image from the info dictionary
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image // Update the binding with selected image
            }
            // Dismiss the picker
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        /// Called when user cancels image selection
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Dismiss if user cancels without selecting an image
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
