//
//  ContentView.swift
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

import SwiftUI

struct ContentView: View {
    @State var showDirectoryPicker:Bool = false
    @State var dirPath:URL = URL(string:"file:///")!
    @State var fileURLs:[URL] = []
    
    @ObservedObject var service: FileListingService
    @State var jsonService: CreateMLAnnotationService
    
    var body: some View {
        NavigationView {
            List(self.$service.files) { $file in
                NavigationLink(file.name, destination: TrainingImageDetailView(file: $file, jsonService: jsonService)).fixedSize()
            }
            .navigationTitle("Image Files")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Select Directory") {
                        showDirectoryPicker = true
                    }
                }
            }
        }
        .sheet(isPresented: self.$showDirectoryPicker) {
            DocumentPicker(dirPath: self.$dirPath, files: self.$fileURLs)
        }
        .onChange(of: self.showDirectoryPicker) { newValue in
            if newValue == false {
                service.loadWithURLs(dirPath: self.dirPath, jsonService:self.jsonService)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(service: FileListingService(), jsonService: CreateMLAnnotationService())
    }
}
