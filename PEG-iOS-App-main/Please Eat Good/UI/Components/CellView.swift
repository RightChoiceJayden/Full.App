//
//  CellView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct CellView: View {
    
    var icon:String? = nil
    @Binding var label:String
    var isDestinationLink:Bool = true
    var destination:AnyView? = nil
    var action:(()->Void)? = nil
    @Binding var rightLabel:String
    var showRightArrow:Bool  = true
    var rightSubtitle:String = ""
    
    var body: some View {
        ZStack(alignment:.leading) {
            Color("backgroundColor")
            if self.isDestinationLink {
                NavigationLink(destination: AnyView(self.destination), label: {
                    HStack(spacing:0) {
                        if self.icon != nil {
                             Image(self.icon!).renderingMode(.original).resizable().frame(width:18, height: 18)
                                Spacer().frame(width:20)
                        }
                        Text(self.label)
                            .foregroundColor(Color("textColor"))
                        Spacer()
                        VStack(spacing:0) {
                            if !self.rightLabel.isEmpty {
                                Text(self.rightLabel).foregroundColor(Color("textColor")).frame(width:200, alignment: .trailing)
                            }
                            if !self.rightSubtitle.isEmpty {
                                Text(self.rightSubtitle).foregroundColor(Color("textColor")).frame(minWidth:0, maxWidth: .infinity, alignment: .trailing)
                                    .font(.system(size: 10, weight: .regular, design: .default))
                            }
                        }
                        if self.showRightArrow {
                            Spacer().frame(width:20)
                            Image("chevron").resizable().frame(width:12, height:12).foregroundColor(.gray)
                        }
                    }
                }).padding(20)
            }else{
                Button(action: {
                    self.action
                }, label: {
                    HStack(spacing:15) {
                        if self.icon != nil {
                             Image(self.icon!).renderingMode(.original).resizable().frame(width:18, height: 18)
                        }
                        Text(self.label).foregroundColor(Color.white)
                        if !self.rightLabel.isEmpty {
                            Spacer()
                            Text(self.rightLabel).foregroundColor(Color.white)
                        }
                        
                    }
                }).padding(.horizontal)
            }
        }
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(icon: "star", label: .constant("Update Password"), rightLabel: .constant("savsdv"))
    }
}
