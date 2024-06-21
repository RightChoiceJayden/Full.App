//
//  HeaderView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/28/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct HeaderView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var includeMenu:Bool
    @Binding var menuBtnToggle:Bool
    @Binding var hasLogo:Bool
    @Binding var hasBackBtn:Bool
    @Binding var title:String
    var rightView:AnyView? = nil
    var isModal:Bool = false
    var onClickBack:(()->Void)? = nil
    var centerTitle:Bool = false
    @Binding var exitScreen:Bool
    
    var body : some View {
        ZStack(alignment:.topLeading) {
            Color.black
            VStack(alignment:.leading, spacing: 0) {
                
                HStack {
                    if self.includeMenu {
                        Button(action: {
                            withAnimation(.default, {
                             self.menuBtnToggle.toggle()
                            })
                        }, label: {
                            Image("menu").renderingMode(.original)
                        })
                        Spacer().frame(width:10)
                    }
                    
                    if self.hasBackBtn {
                        Button(action: {
                            if let back = self.onClickBack {
                                back()
                            }
                            self.presentationMode.wrappedValue.dismiss()
                            
                            self.exitScreen = true
                            
                        }, label: {
                            if self.isModal {
                                Image("exit")
                                .renderingMode(.original)
                                .resizable().frame(width:18, height:18)
                            }else{
                              Image("back")
                                .renderingMode(.original)
                                .resizable().frame(width:18, height:18)
                            }
                        })
                    }
                    
                    if !self.title.isEmpty {
                        if self.centerTitle {
                            Spacer()
                        }
                        Text(self.title).foregroundColor(Color.white)
                        if self.centerTitle {
                            Spacer()
                        }
                        
                    }
                    
                    if self.hasLogo {
                      Image("logo")
                    }
                    
                    if self.rightView != nil {
                        Spacer()
                        self.rightView
                    }

                }.padding(.horizontal)
                Spacer().frame(height:12)
            } //end vstack
        }.frame(height:30) //end zstack
        
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(includeMenu: .constant(true), menuBtnToggle:.constant(true), hasLogo: .constant(false), hasBackBtn: .constant(false), title: .constant("dsvsd"), exitScreen: .constant(false))
    }
}

