//
//  TrainingImageDetailView.swift
//  CreateMLLabeler
//
//  Created by Andrew Durbin on 2/3/23.
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

import SwiftUI

struct TrainingImageDetailView: View {
    @Binding var file:FileListing
    var jsonService:CreateMLAnnotationService
    
    @State var showLabelInput:Bool = false
    @State var startPoint:CGPoint = CGPoint()
    @State var endPoint:CGPoint = CGPoint()
    @State var newAnnotationLabel:String = ""
    
    func onDeleteAnnotation(at offsets: IndexSet) {
        //todo also delete from observable (self.file)
        self.jsonService.removeAnnotation(forFilename: file.annotationFileEntry.imagefilename, atOffsets: offsets)
        self.file.annotationFileEntry = self.jsonService.getAnnotationsForFile(filename: self.file.annotationFileEntry.imagefilename)
        self.jsonService.writeFile(dir: self.file.dir)
    }
    
    var body: some View {
        TabView {
            List {
                ForEach(file.annotationFileEntry.annotation){ anno in
                    Text(anno.label)
                }
                .onDelete(perform: onDeleteAnnotation)
            } .toolbar {
                EditButton()
            }
            .tabItem {
                Label("Label List", systemImage: "list.dash")
            }
            Image(uiImage: UIImage(data:file.imageData) ?? UIImage())
                .overlay(
                    GeometryReader { (geometry: GeometryProxy) in
                        //ForEach(self.file.annotationFileEntry.annotation, id:\.self) { anno in
                        ForEach(Array(zip(self.file.annotationFileEntry.annotation.indices, self.file.annotationFileEntry.annotation)), id: \.0) { index, anno in
                            TrainingAnnotationView(annotation: anno, imageSize: file.imageSize)
                        }
                    }
                )
                .simultaneousGesture(DragGesture(minimumDistance: 0)
                    .onEnded({
                        print("annotation gesture ended: \($0)")
                        self.startPoint = $0.startLocation
                        self.endPoint = $0.location
                        showLabelInput = true
                    })
                ).sheet(isPresented: self.$showLabelInput) {
                    //MARK: Annotation Labeling Input
                    VStack {
                        HStack {
                            Text("New Annotation:")
                            TextField(
                                "Example Annotation Text",
                                text: self.$newAnnotationLabel
                            )
                        }
                        HStack {
                            Button("Cancel") {
                                showLabelInput = false
                            }
                            Button("Ok") {
                                saveNewAnnotation()
                                showLabelInput = false
                            }
                        }
                    }
                }
                .tabItem {
                    Label("Image View", systemImage: "list.dash")
                }
        }
    }
    
    func saveNewAnnotation() {
        let newLabel = self.newAnnotationLabel
        let startPoint = self.startPoint
        let endPoint = self.endPoint
        let minX = min(startPoint.x,endPoint.x)
        let minY = min(startPoint.y,endPoint.y)
        let maxX = max(startPoint.x, endPoint.x)
        let maxY = max(startPoint.y, endPoint.y)
        let originPt = CGPoint(x:minX, y:minY)
        let size = CGSize(width:(maxX-minX), height:(maxY-minY))
        let rect:CGRect = CGRect(origin: originPt, size: size);
        let newAnnotation = CreateMLFileAnnotation(coordinates:CreateMLAnnotationCoordinate(y: originPt.y, x: originPt.x, height: rect.height, width: rect.width), label:newLabel)
        self.jsonService.addAnnotation(forFilename: self.file.annotationFileEntry.imagefilename, newAnnotation: newAnnotation)
        self.file.annotationFileEntry.annotation.append(newAnnotation)
        self.jsonService.writeFile(dir: self.file.dir)
    }
}

struct TrainingImageDetailView_Previews: PreviewProvider {
    static var imagefilename:String = "Food.jpg"
    @State static var dir:URL = URL(string:"/")!
    @State static var imagefilenameURL:URL = URL(string:imagefilename)!
    @State static var anno:CreateMLFileAnnotation = CreateMLFileAnnotation(coordinates: CreateMLAnnotationCoordinate(y: 100, x: 100, height: 100, width: 200), label: "Brownie")
    @State static var file = FileListing(url: imagefilenameURL, dir: dir, annotationFileEntry: CreateMLFileEntry(imagefilename: imagefilename, annotation: [anno]))
    static var previews: some View {
        TrainingImageDetailView(file: $file, jsonService: CreateMLAnnotationService())
    }
}

