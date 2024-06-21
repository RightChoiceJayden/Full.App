//
//  LoadingView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/2/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct LoadingView:View {
    
    var title:String = "Loading..."
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
            VStack(spacing:25) {
                Text(self.title).foregroundColor(Color("textColor"))
            }
        }
    }
}

struct Hide:ViewModifier {
    @Binding var hide:Bool
    func body(content: Content) -> some View {
        if hide {
            return content.opacity(0)
        }else{
            return content.opacity(1)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
