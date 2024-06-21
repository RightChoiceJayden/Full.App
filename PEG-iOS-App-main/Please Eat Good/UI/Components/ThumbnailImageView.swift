//
//  ThumbnailImageView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/31/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI
import URLImage

struct ThumbnailImageView: View {
    @State private var placeholder:String = "image-placeholder"
    @Binding var imageURL:URL
    
    var body: some View {
        ZStack {
            URLImage(url: imageURL,
                     content: { image in
                         image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Rectangle())
                            .frame(width: 100, height:100)
                            .clipped()
                     })
//            URLImage(imageURL,
//            processors: [ Resize(size: CGSize(width: 100.0, height: 100.0), scale: UIScreen.main.scale) ],
//            placeholder: {_ in
//                Image(self.placeholder)
//                    .resizable()
//                    .frame(width: 100, height: 100, alignment: .center)
//                    .aspectRatio(contentMode: .fit)
//                    .clipShape(Circle())
//                    .shadow(radius: 10.0)
//                },
//            content: {
//                $0.image
//                    .resizable()
//                    .frame(width: 100, height: 100, alignment: .center)
//                    .aspectRatio(contentMode: .fit)
//                    .clipShape(Circle())
//                    .shadow(radius: 10.0)
//
//            })
        }
    }
}

struct ThumbnailImageView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailImageView(imageURL: .constant(URL(string: "gergerg")!))
    }
}
