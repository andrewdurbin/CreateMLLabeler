//
//  FileListing.swift
//  CreateMLLabeler
//
//  Created by Andrew Durbin on 1/30/23.
//
//CreateMLLabeler
//Copyright (C) 2023 Andrew Durbin

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import SwiftUI

struct FileListing: Identifiable, Hashable, Equatable {
    let id = UUID()
    var url:URL
    var dir:URL
    var annotationFileEntry:CreateMLFileEntry
    
    var name: String {
        return url.lastPathComponent
    }
    var fullURL:URL {
        return URL(string:"file://"+dir.path+"/"+url.path)!
    }
    var imageData:Data {
        do {
            return try Data(contentsOf: fullURL)
        } catch {
            print("Failed to load image for url:\(fullURL), Unexpected error: \(error).")
            return Data()
        }
    }
    var uiImage:UIImage {
        return UIImage(data:imageData) ?? UIImage()
    }
    var imageSize:CGSize {
        return uiImage.size
    }
}

class FileListingService: ObservableObject {
    @Published var files: Array<FileListing>

    init() {
        self.files = []
    }
    
    func getImageTypes() -> Set<String> {
        return ["png","jpg","jpeg"]
    }
    
    func loadWithURLs(dirPath:URL, jsonService:CreateMLAnnotationService) -> Void {
        self.files = []
        jsonService.readFile(dir: dirPath)
        let filemgr = FileManager.default
        do {
            let items = try filemgr.contentsOfDirectory(atPath: dirPath.path)
            let allowedTypes = self.getImageTypes()
            for item in items {
                let filenameParts = item.split(separator: ".")
                if filenameParts.count < 2 {
                    continue;
                }
                let ext = String(filenameParts.last!)
                if allowedTypes.contains(ext) {
                    let annotationsFileEntry = jsonService.getAnnotationsForFile(filename: item)
                    for annotation in annotationsFileEntry.annotation {
                        print("Image \(annotationsFileEntry.imagefilename) has annotation with label \(annotation.label)")
                    }
                    self.files.append(FileListing(url:URL(string:item)!, dir:dirPath, annotationFileEntry: annotationsFileEntry))
                }
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }
}
