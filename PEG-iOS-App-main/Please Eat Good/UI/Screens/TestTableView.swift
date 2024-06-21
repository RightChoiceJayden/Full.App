//
//  TestTableView.swift
//  Truth Dating
//
//  Created by Christopher on 2/7/21.
//

import SwiftUI

struct TestTableView: View {
    
    @State var list:[String] = ["Item1", "Item2", "Item3", "item4", "item5"]

    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Text("Left side")
                        Spacer()
                        Text("Right Side")
                    }
                    
                    Spacer()
                    Text("Text Middle")
                    Spacer()
                    Button(action:{}, label:{
                        Text("Continue")
                            .padding(20)
                            .frame(minWidth:0, maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            
                            
                    })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Users")
        }
    }
    
    func onDelete(index:IndexSet) {
        print("DELETE THIS")
    }
}


struct DetetailView: View {
    
    @Binding var title:String
    
    var body: some View {
        ZStack {
            Text(self.title)
                .font(.title)
                .foregroundColor(.red)
        }.navigationTitle(self.title)
    }
    
    func onDelete(index:IndexSet) {
        print("DELETE THIS")
    }
}




struct TestTableView_Previews: PreviewProvider {
    static var previews: some View {
        TestTableView()
    }
}
