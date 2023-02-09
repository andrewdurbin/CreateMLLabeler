//
//  DocumentPicker.swift
//  CreateMLLabeler
//
//  Created by Andrew Durbin on 1/30/23.
//


import SwiftUI

//With examples from: https://capps.tech/blog/read-files-with-documentpicker-in-swiftui
struct DocumentPicker: UIViewControllerRepresentable {
    
    @Binding var dirPath:URL
    @Binding var files:[URL]
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(dirPath:$dirPath,files:$files)
    }
    
    func makeUIViewController(context:
            UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let documentPicker =
            UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    @Binding var dirPath:URL
    @Binding var files:[URL]
    
    init(dirPath: Binding<URL>, files:Binding<[URL]>){
        _dirPath = dirPath
        _files = files
    }
    
    func documentPicker(_ controller:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]){
        dirPath = urls[0]
        
        let filemgr = FileManager.default
        do {
            let items = try filemgr.contentsOfDirectory(atPath: dirPath.path)

            for item in items {
                self.files.append(URL(string:item)!)
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }
}

struct DocumentPicker_Previews: PreviewProvider {
    @State static var dirPath:URL = URL(string:"")!
    @State static var files:[URL] = []
    static var previews: some View {
        DocumentPicker(dirPath: $dirPath, files:$files)
    }
}
