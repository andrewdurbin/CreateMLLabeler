//
//  TrainingAnnotationView.swift
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

struct TrainingAnnotationView: View {
    var annotation:CreateMLFileAnnotation
    var imageSize:CGSize
    @State var showLabel:Bool = false
    
    func onAnnotationHover(hovered:Bool) {
        showLabel.toggle()
    }
    
    func translateAbsoluteRectToRelative(absRect:CGRect, geometry:GeometryProxy) -> CGRect {
        return absRect
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Rectangle().path(in:self.translateAbsoluteRectToRelative(absRect:self.annotation.coordinates.rect, geometry: geo)).stroke(Color.purple, lineWidth: 2.0)
                Rectangle().path(in:self.translateAbsoluteRectToRelative(absRect:CGRect(x:self.annotation.coordinates.x, y:self.annotation.coordinates.y,  width:self.annotation.coordinates.width, height:20), geometry: geo)).fill(.purple).opacity(0.4)
                Text(annotation.label).position(x: annotation.coordinates.x+annotation.coordinates.width/2, y: annotation.coordinates.y+10).font(.system(size: 12, weight: .light, design: .serif))
            }
        }
    }
}

struct TrainingAnnotationView_Previews: PreviewProvider {
    @State static var anno = CreateMLFileAnnotation(coordinates: CreateMLAnnotationCoordinate(y: 0, x: 0, height: 100, width: 200), label: "Brownie")
    
    static var previews: some View {
        TrainingAnnotationView(annotation: anno, imageSize: CGSize())
    }
}
