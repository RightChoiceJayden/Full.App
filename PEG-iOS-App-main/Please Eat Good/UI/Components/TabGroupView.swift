//
//  TabGroupView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/2/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct TabGroupView : View {
    
    @Binding var tabs:[TabItem]
    @State private var activeView:AnyView? = nil
    var dontChangeTabs:Bool = false
    
    var body: some View {
        ZStack(alignment:.topLeading) {
            VStack(spacing:0) {
                Group {
                    self.activeView
                }
                
                #if TrainerApp
                
                #else
                    Hr()
                    HStack(spacing:0) {
                        ForEach(self.tabs, id:\.id) { (tab:TabItem) in
                              Button(action: {
                                tab.onTap()
                                if !tab.dontChangeTabs {
                                    self.activateAllTabs()
                                    tab.state = .inactive
                                    tab.selected = true
                                    self.activeView = tab.view
                                }
                            }, label: {
                                ZStack(alignment:.topLeading) {
                                    Group {
                                        if tab.buttonLabel != nil {
                                            tab.buttonLabel!.frame(minWidth:0, maxWidth: .infinity, minHeight: 50)
                                        }else{
                                            VStack(alignment:.leading, spacing:0) {
                                                Spacer().frame(height:20)
                                                if !tab.iconImageName.isEmpty {
                                                    HStack {
                                                        Spacer()
                                                        if tab.state == .active {
                                                            Image(tab.iconImageName).resizable().aspectRatio(contentMode: .fit).frame(width:28).foregroundColor(.gray)
                                                        }else{
                                                            Image(tab.iconImageName).resizable().aspectRatio(contentMode: .fit).frame(width:28).foregroundColor(.green)
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                    
                                                }
                                                if tab.state == .inactive {
                                                   Text(tab.name)
                                                    .foregroundColor(.green)
                                                    .frame(minWidth:0, maxWidth: .infinity, minHeight: 40)
                                                    .font(.system(size: 12))
                                                }
                                                if tab.state == .active {
                                                    Text(tab.name)
                                                    .foregroundColor(.gray)
                                                    .frame(minWidth:0, maxWidth: .infinity, minHeight: 40)
                                                    .font(.system(size: 12))
                                                }
                                            }

                                        }
                                    }
                                }
                            }).background(Color.black).disabled(tab.isInactive())
                        }
                    }
                #endif
                
            }
            //self.content()
        }.onAppear(perform: {
            
            let defaultActive = self.tabs.filter{ $0.selected == true }
            
            if defaultActive.isEmpty {
                self.activeView = self.tabs[0].view
                self.tabs[0].deactivate()
                self.tabs[0].selected = true
            }else{
                self.activeView = self.tabs[0].view
                self.tabs[0].deactivate()
                self.tabs[0].selected = true
            }

            
            
        })
    }
}

extension TabGroupView {
//    static func mockData() ->[TabItem] {
//        return [
//            TabItem(name: "Train now", view: AnyView(VStack(spacing:0){ InputSearch(value:.constant("2121 Valderas Drive, Glendale, CA 91208"), isOn: .constant(true)); MapListView(isMapViewOn: .constant(true), openMenu: .constant(false)) }), onTap: {}),
//            TabItem(name: "Book", onTap: {}),
//            TabItem(name: "Upcoming", view: AnyView(ScheduleListView()), onTap: {})
//        ]
//    }
    func activateAllTabs() {
        _ = self.tabs.map { $0.state = .active; $0.selected = false }
    }
}

enum TabState:String {
    case inactive
    case active
}

protocol TabableItem {
    var name: String { get set }
    var state:TabState { get set }
    var view:AnyView? { get set }
    var onTap:(()->Void) { get set }
    var selected:Bool { get set }
    var buttonLabel:AnyView? { get set }
}

class TabItem: TabableItem, Identifiable{
    var buttonLabel: AnyView?
    var onTap: (() -> Void)
    var id:UUID = UUID()
    var name: String
    var state: TabState
    var view: AnyView?
    var selected: Bool
    var dontChangeTabs:Bool = false
    var iconImageName:String = ""
    
    init(id:UUID = UUID(), name:String, state:TabState = .active, view:AnyView? = nil, selected:Bool = false, onTap:@escaping (()->Void), buttonLabel:AnyView? = nil, dontChangeTabs:Bool = false, iconImageName:String = "") {
        self.onTap = onTap
        self.id = id
        self.name = name
        self.view = view
        self.state = state
        self.selected = selected
        self.buttonLabel = buttonLabel
        self.dontChangeTabs = dontChangeTabs
        self.iconImageName = iconImageName
    }
    
    func isInactive() -> Bool {
        if self.state == .inactive {
            return true
        }
        return false
    }
    
    func activate() {
        self.state = .active
    }
    func deactivate() {
        self.state = .inactive
    }

}

//struct TabGroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        //TabGroupView(tabs: .constant(TabGroupView.mockData()))
//    }
//}
