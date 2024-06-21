//
//  MenuView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/28/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    @State   var backgroundColor:String = "red"
    @Binding var menuItems:[MenuItem]
    @State   var textColor:Color = Color.white
    @Binding var isOpen:Bool
    @State   var itemSpacing:CGFloat = 30
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            GeometryReader { geometry in
                HStack(spacing:0) {
                    VStack(alignment:.leading, spacing: self.itemSpacing) {
                        Spacer().frame(height:50)
                        ForEach(self.menuItems, id:\.id) { menuItem in
                            Group {
                                if menuItem.isNavigationLink {
                                    NavigationLink(destination:menuItem.navigationLinkDestination, label:{
                                    
                                        if menuItem.buttonLabel != nil {
                                            menuItem.buttonLabel
                                        }else{
                                            Text(menuItem.name).foregroundColor(Color.white).padding(.horizontal)
                                        }
                                        Spacer()
                                    }).frame(minWidth:0, maxWidth: .infinity)
                                }else{
                                    Button(action:{
                                        if let action = menuItem.action {
                                            action()
                                        }
                                    }, label:{
                                        if menuItem.buttonLabel != nil {
                                            menuItem.buttonLabel
                                        }else{
                                            Text(menuItem.name).foregroundColor(Color.white).padding(.horizontal)
                                        }
                                        Spacer()
                                        }).frame(minWidth:0, maxWidth: .infinity)
                                }
                            }
                        }
                        Spacer()
                    }
                    .frame(width:geometry.size.width/2)
                    .background(Color.black)
                    .offset(x: self.isOpen ? 0 : ((geometry.size.width - geometry.size.width) - geometry.size.width/2) , y: 0)
                    .edgesIgnoringSafeArea(.all)
                    Button(action:{
                        withAnimation(.easeIn, {
                          self.isOpen.toggle()
                        })
                    }, label:{
                        Rectangle().foregroundColor(Color.black).opacity(0.4)
                    })
                    .offset(x: self.isOpen ? 0 : ((geometry.size.width + geometry.size.width) + geometry.size.width/2) , y: 0)
                    .edgesIgnoringSafeArea(.all)
                }

            }
        }
    }
}

class MenuItem: Identifiable {
    var id:UUID
    var name:String = ""
    var isNavigationLink:Bool = false
    var navigationLinkDestination:AnyView?
    var action:(()->Void)?
    var buttonLabel:AnyView?
    
    init(id:UUID = UUID(), name:String, isNavigationLink:Bool = false, navigationLinkDestination:AnyView? = nil, action:(()->Void)? = nil, buttonLabel:AnyView? = nil) {
        self.id = id
        self.name = name
        self.isNavigationLink = isNavigationLink
        self.navigationLinkDestination = navigationLinkDestination
        self.action = action
        self.buttonLabel = buttonLabel
    }
}

//struct MenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        MenuView(menuItems: .constant([
//            MenuItem(name: "Home"),
//            MenuItem(name: "Settings", isNavigationLink:true, navigationLinkDestination:AnyView(LoginForm())),
//            MenuItem(name: "Logout"),
//        ]), isOpen: .constant(true))
//    }
//}
