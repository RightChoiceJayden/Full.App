//
//  CellHeaderView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/29/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct CellHeaderView: View {
    
    @Binding var label:String
    
    var body: some View {
        ZStack(alignment:.leading) {
            Color("panelBackgroundColor")
            VStack(spacing:0) {
                Divider()
                Text(self.label)
                    .foregroundColor(Color("textColor") )
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                Divider()
            }
            
        }
    }
}

struct CellHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CellHeaderView(label: .constant("General"))
    }
}
