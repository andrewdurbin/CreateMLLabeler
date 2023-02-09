//
//  CreateML.swift
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

struct CreateMLAnnotationCoordinate: Hashable, Encodable, Decodable {
    var y:CGFloat
    var x:CGFloat
    var height:CGFloat
    var width:CGFloat
}
extension CreateMLAnnotationCoordinate {
    var rect:CGRect {
        return CGRect(x:x, y:y, width:width, height: height)
    }
}
struct CreateMLFileAnnotation: Hashable, Encodable, Decodable {
    var coordinates:CreateMLAnnotationCoordinate
    var label:String
}
extension CreateMLFileAnnotation: Identifiable {
    var id:String {
        return "\(coordinates.x).\(coordinates.y).\(coordinates.height).\(coordinates.width)"
    }
}
struct CreateMLFileEntry: Hashable, Encodable, Decodable {
    var imagefilename:String
    var annotation:Array<CreateMLFileAnnotation>
}
