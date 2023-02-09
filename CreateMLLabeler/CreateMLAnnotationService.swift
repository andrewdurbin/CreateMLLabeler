//
//  CreateMLAnnotationService.swift
//  CreateMLLabeler
//
//  Created by Andrew Durbin on 2/6/23.
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

class CreateMLAnnotationService {
    var mlFiles:[String:CreateMLFileEntry] = [:]
    
    init(){
        self.mlFiles = [:]
    }
    func readFile(dir:URL) {
        do {
            //Sometimes they want file:// prefix...
            let jsonStr = try String(contentsOfFile: dir.path + "/annotations.json", encoding: .utf8)
            if let jsonData = jsonStr.data(using: .utf8) {
                if let jsonObj:[Any] = (try? JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers) as? [Any]) {
                    for subObj in jsonObj {
                        if let subObjData = try? JSONSerialization.data(withJSONObject: subObj, options: []) {
                            let imageFileEntry = try JSONDecoder().decode(CreateMLFileEntry.self, from: subObjData)
                            print("Successfully parsed: \(imageFileEntry.imagefilename)")
                            self.mlFiles[imageFileEntry.imagefilename] = imageFileEntry
                        }
                    }
                }
            }
        }
        catch {
            print("unable to read in annotations.json: \(error)")
        }
    }
    func writeFile(dir:URL) {
        var jsonStr = "["
        for (_,file) in self.mlFiles {
            if let jsonObjData = try? JSONEncoder().encode(file) {
                let objStr = String(decoding: jsonObjData, as: UTF8.self)
                jsonStr+=objStr+","
            }
        }

        if let lastChar = jsonStr.last {
            if lastChar == "," {
                jsonStr.remove(at: jsonStr.index(before:jsonStr.endIndex))
            }
        }
        jsonStr += "]"
        do {
            let path = "file://" + dir.path + "/annotations.json"
            try jsonStr.write(to: URL(string:path)!, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    func setAnnotations(newFileEntry:CreateMLFileEntry) {
        if var existingFileEntry = self.mlFiles[newFileEntry.imagefilename] {
            existingFileEntry.annotation = newFileEntry.annotation
            return
        }
        self.mlFiles[newFileEntry.imagefilename] = newFileEntry
    }
    func addAnnotation(forFilename:String, newAnnotation:CreateMLFileAnnotation) {
        if self.mlFiles[forFilename] == nil {
            self.mlFiles[forFilename] = CreateMLFileEntry(imagefilename: forFilename, annotation:[])
        }
        self.mlFiles[forFilename]!.annotation.append(newAnnotation)
    }
    func removeAnnotation(forFilename:String, atOffsets:IndexSet) {
        if self.mlFiles[forFilename] != nil {
            self.mlFiles[forFilename]!.annotation.remove(atOffsets: atOffsets)
        }
    }
    func getAnnotationsForFile(filename:String) -> CreateMLFileEntry {
        if let existingFileEntry = self.mlFiles[filename] {
            return existingFileEntry
        }
        return CreateMLFileEntry(imagefilename: filename, annotation: [])
    }
}
