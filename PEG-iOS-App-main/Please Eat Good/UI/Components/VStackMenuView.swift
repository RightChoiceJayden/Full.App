//
//  VStackMenuView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct VStackMenuView: View {
    @Binding var stackItems:[VStackMenuItem]
    var body: some View {
        ZStack {
            ForEach(self.stackItems, id:\.id) { item in
                VStack(spacing:0) {
                    item.header
                    ForEach(item.views.indices) { index in
                        item.views[index]
                        Divider()
                    }
                }
            }
        }
    }
}

struct VStackMenuItem: Identifiable {
    var id:UUID = UUID()
    var header:AnyView?
    var views:[AnyView]
}

struct VStackMenuView_Previews: PreviewProvider {
    static var previews: some View {
        VStackMenuView(stackItems: .constant([
            VStackMenuItem(
                header: AnyView(CellHeaderView(label: .constant("General"))),
                views: [
                    AnyView(CellView(icon: "star", label: .constant("Password"), rightLabel: .constant("sdvsdv"))),
                    AnyView(CellView(icon: "star", label: .constant("Password"), rightLabel: .constant("sdvsdv"))),
                    AnyView(CellView(icon: "star", label: .constant("Password"), rightLabel: .constant("sdvsdv")))
                ]
            )
        ]))
    }
}
