//
//  SwitchView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/28/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct SwitchView: View {
    @Binding var isOn:Bool
    var body : some View {
        ZStack(alignment:.trailing) {
            Rectangle().foregroundColor(Color.gray).frame(height:25).cornerRadius(50)
            Button(action: {
                withAnimation(.easeIn) {
                    self.isOn.toggle()
                }
            }, label: {
                ZStack {
                    Circle().foregroundColor(.green).frame(height:30)
                    Image("map-icon").renderingMode(.original).resizable().aspectRatio(contentMode: .fit).frame(width:10)
                }.offset(x: self.isOn ? 10 : -10, y: 0)
            })
        }.frame(width:50)
    }
}

struct SwitchView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchView(isOn: .constant(true))
    }
}
