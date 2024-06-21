//
//  Item.swift
//  Truth Dating
//
//  Created by Christopher on 1/25/21.
//

import SwiftUI
import URLImage

struct Item: View {
    
    var title:String
    var subtitle:String = ""
    var subTitleColor:Color = .gray
    var thumbnailURL:String = ""
    var thumbnailImageName:String = ""
    var bodyText:String = ""
    
    var rightTitle:String = ""
    var rightSubtitle:String = ""
    var rightThumbnailURL:String = ""
    var rightThumbnailImageName:String = ""
    var rightBodyText:String = ""
    
    var showDivider:Bool = false
    
    var spacing:CGFloat = 10
    var thumbnailRadius:CGFloat = 3;
    
    var body: some View {
        self.content()
    }
    
    func content() -> some View {
        VStack(spacing:self.spacing) {
            HStack {
                self.leftContent()
                Spacer()
                self.rightContent()
            }
            if self.showDivider {
                Divider()
            }
        }
    }
    
    func urlImage() -> some View {
        Group {
            if self.thumbnailURL.isEmpty {
                Image("image-placeholder")
                    .resizable()
                    .cornerRadius(self.thumbnailRadius)
                    .frame(width: 60, height: 60)
            }else{
                URLImage(url: URL(string: self.thumbnailURL)!,
                 content: { image in
                     image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Rectangle())
                        .frame(width: 60, height: 60)
                        .cornerRadius(self.thumbnailRadius)
                        .clipped()
                 })
            }
        }
    }
    
    func leftContent() -> some View {
        Group {
            if !self.thumbnailImageName.isEmpty {
                Image(self.thumbnailImageName)
                    .resizable()
                    .cornerRadius(5)
                    .frame(width: 60, height: 60)
            }else if(!self.thumbnailURL.isEmpty){
                self.urlImage()
            }
            VStack(spacing:4) {
                Text(self.title)
                    .frame(minWidth:0, maxWidth:.infinity, alignment:.leading)
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.black)
                if !self.subtitle.isEmpty {
                    Text(self.subtitle)
                        .frame(minWidth:0, maxWidth:.infinity, alignment:.leading)
                        .foregroundColor(self.subTitleColor)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .lineLimit(1)
                }
                if !self.bodyText.isEmpty {
                    Text(self.bodyText)
                        .frame(minWidth:0, maxWidth:.infinity, alignment:.leading)
                        .foregroundColor(.gray)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .lineLimit(1)
                }
            }
        }
    }
    
    func rightContent() -> some View {
        Group {
            if !self.rightThumbnailImageName.isEmpty {
                Image(self.rightThumbnailImageName)
                    .resizable()
                    .cornerRadius(5)
                    .frame(width: 60, height: 60)
            }
            VStack(spacing:4) {
                Spacer()
                if !self.rightTitle.isEmpty {
                    Text(self.rightTitle)
                        .font(.system(size: 14, weight: .bold, design: .default))
                }
                if !self.rightSubtitle.isEmpty {
                    Text(self.rightSubtitle)
                        .foregroundColor(self.subTitleColor)
                        .font(.system(size: 13, weight: .regular, design: .default))
                }
                if !self.rightBodyText.isEmpty {
                    Text(self.rightBodyText)
                        .foregroundColor(.gray)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .lineLimit(1)
                }
                Spacer()
            }
        }
    }
}

//struct Item_Previews: PreviewProvider {
//    static var previews: some View {
//        Item()
//    }
//}
