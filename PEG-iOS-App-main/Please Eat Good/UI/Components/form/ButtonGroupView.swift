//
//  ButtonGroupView.swift
//  Afro Academy
//
//  Created by Christopher on 11/14/20.
//

import SwiftUI

struct ButtonGroupView: View {
    
    var title:String? = nil
    var labels:[String] = []
    @Binding var selected:String
    var onSelected:( (String)->Void )? = nil
   
    
    var body: some View {
        VStack(spacing:0) {
            Spacer().frame(height:15)
            if self.title != nil {
                Text(verbatim: self.title!)
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 11))
                Spacer().frame(height:15)
            }
            
            HStack {
                ForEach(self.labels, id:\.self) { label in
                    Button(action:{
                        self.selected = label
                        if let onSelected = self.onSelected {
                            onSelected(self.selected)
                        }
                    }, label:{
                        Text(label)
                            .foregroundColor(self.selected == label ? Color("primaryColor") : Color("textColor"))
                            .padding(10)
                            .frame(minWidth:0, maxWidth: .infinity, alignment: .center)
                            
                    })
                    .border(self.selected == label ? Color("primaryColor") : Color("textColor"), width: 1)
                }
            }
            Spacer().frame(height:15)
        }.padding(.horizontal)
    }
}
