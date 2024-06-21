//
//  AlertUIVIew.swift
//  iTrayne
//
//  Created by Christopher on 10/1/20.
//  Copyright © 2020 iTrayne LLC. All rights reserved.
//

import SwiftUI

enum AlertType {
    case success, error
}

struct AlertUIVIew: View {
    
    @Binding var title:String
    @Binding var subTitle:String
    @Binding var type:AlertType
    
    var body: some View {
        Button(action: {
            
        }, label: {
            HStack {
                VStack(spacing:8) {
                    Text(self.title)
                        .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        
                    Text(self.subTitle)
                        .font(.system(size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                Spacer()
                VStack {
                    
                    Image("exit").renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width:20).padding()
                    Spacer()
                }
            }.padding(20)

        })
        .frame(height:120)
        .background(Color.green)
        .offset(x: 0, y: 35)
    }
}

//struct AlertUIVIew_Previews: PreviewProvider {
//    static var previews: some View {
//        AlertUIVIew()
//    }
//}
