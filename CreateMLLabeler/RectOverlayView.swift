//
//  RectOverlayView.swift
//  CreateMLLabeler
//
//  Created by Andrew Durbin on 2/13/23.
//

import SwiftUI

struct RectOverlayView: View {
    var rect:CGRect
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Rectangle().path(in:self.rect).stroke(Color.purple, lineWidth: 2.0)
            }
        }
    }
}

struct RectOverlayView_Previews: PreviewProvider {
    @State static var rect = CGRect(x: 0, y: 0, width: 100, height: 100)
    
    static var previews: some View {
        RectOverlayView(rect:rect)
    }
}
