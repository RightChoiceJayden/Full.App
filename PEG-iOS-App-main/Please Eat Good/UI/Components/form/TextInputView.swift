//
//  TextInputView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct TextInputView: View {
    @Binding var label:String
    @Binding var placeholder:String
    @Binding var value:String
    var disabled:Bool = false
    var enableRightButton:Bool = false
    var rightButtonAction:((String)->Void)? = nil
    var isSecure:Bool = false
    
    var body: some View {
        VStack(spacing:0) {
            VStack {
                Spacer().frame(height:15)
                Text(self.label)
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 11))
                if self.enableRightButton {
                    HStack {
                        self.field()
                        Spacer()
                        Button(action: {
                            if let rightButtonAction = self.rightButtonAction {
                                rightButtonAction(self.value)
                            }
                        }, label: {
                            Text("Apply")
                        })
                    }
                }else{
                    self.field()
                }
            
                Spacer().frame(height:15)
            }.padding(.horizontal)
            Divider()
        }
    }
    
    func field() -> some View {
        VStack {
            if self.isSecure {
                SecureField(self.placeholder, text: self.$value)
                    .foregroundColor(Color("textColor"))
                    .disabled(self.disabled)
            }else{
                TextField(self.placeholder, text: $value)
                    .foregroundColor(Color("textColor"))
                    .disabled(self.disabled)
            }
        }
    }
}


struct TextAreaView: View {
    @Binding var label:String
    @Binding var placeholder:String
    @Binding var value:String
    var disabled:Bool = false
    var enableRightButton:Bool = false
    var rightButtonAction:((String)->Void)? = nil
    var isSecure:Bool = false
    
    var body: some View {
        VStack(spacing:0) {
            VStack {
                Spacer().frame(height:15)
                Text(self.label)
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 11))
                if self.enableRightButton {
                    HStack {
                        self.field()
                        Spacer()
                        Button(action: {
                            if let rightButtonAction = self.rightButtonAction {
                                rightButtonAction(self.value)
                            }
                        }, label: {
                            Text("Apply")
                        })
                    }
                }else{
                    self.field()
                }
            
                Spacer().frame(height:15)
            }.padding(.horizontal)
            Divider()
        }
    }
    
    func field() -> some View {
        VStack {
            if self.isSecure {
                SecureField(self.placeholder, text: self.$value)
                    .foregroundColor(Color("textColor"))
                    .disabled(self.disabled)
            }else{
                TextEditor(text: $value)
                    .foregroundColor(Color("textColor"))
                    .disabled(self.disabled)
            }
        }
    }
}
