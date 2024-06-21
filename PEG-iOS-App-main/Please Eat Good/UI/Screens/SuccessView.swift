//
//  SuccessView.swift
//  iTrayne
//
//  Created by Christopher on 10/4/20.
//  Copyright © 2020 iTrayne LLC. All rights reserved.
//

import SwiftUI

struct SuccessView: View {
    
    var onClickDone:(()->Void)? = nil
    
    var body: some View {
        ZStack() {
            Color("successColor").edgesIgnoringSafeArea(.all)
            VStack(spacing:10) {
                Text("Welcome to the Afro Academy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                Spacer().frame(height:10)
                Text("You've successfully been enrolled. You should receive an email with an invite to meet with an Afro Academy instructor to get your virtual coding class schedule. Please accept the invite.")
                    .foregroundColor(.white)
                    .font(.title3)
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                Spacer().frame(height:10)
                Text("")
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:170)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    if let onClickDone = self.onClickDone {
                        onClickDone()
                    }
                }, label: {
                    Text("Done")
                        .font(.system(size: 20))
                        .frame(minWidth:0, maxWidth: .infinity)
                        .foregroundColor(.green)
                        .padding()
                })
                .background(Color.white)
                .cornerRadius(10)
                
            }.padding()
        }
        
    }
}

//struct SuccessView_Previews: PreviewProvider {
//    static var previews: some View {
//        SuccessView()
//    }
//}
