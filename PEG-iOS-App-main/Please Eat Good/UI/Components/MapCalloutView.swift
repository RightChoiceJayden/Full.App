//
//  MapCalloutView.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/7/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import SwiftUI

struct MapCalloutView: View {
    
    @Binding var buttonView:AnyView
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack(alignment:.top) {
                VStack(alignment:.leading) {
                    Text("Christopher").font(.system(size: 22, weight: .bold, design: .default))
                    Text("Los Angeles").foregroundColor(Color.gray)
                    Spacer().frame(height:10)
                    Text("$20/hr").foregroundColor(Color.gray)
                }
                Spacer().frame(width:20)
                VStack(alignment:.trailing) {
                    Image("avatar").resizable().frame(width:40, height: 40)
                    Spacer()
                    Text("0.5 mi").foregroundColor(Color.gray)
                }
            }
            Spacer().frame(height:20)
            NavigationLink(destination: buttonView, label: {
                Text("View").foregroundColor(Color.black).frame(minWidth:0, maxWidth: .infinity, minHeight: 30)
                }).background(LinearGradient(gradient: Gradient(colors: [Color("green"), Color("yellow")]), startPoint: .leading, endPoint: .trailing)).cornerRadius(50)
            Text("Christopher").font(.system(size: 18, weight: .bold, design: .default)).foregroundColor(Color.white)
        }
    }
}

struct MapCalloutView_Previews: PreviewProvider {
    static var previews: some View {
        MapCalloutView(buttonView: .constant(AnyView(Text("sdvsv"))))
    }
}
