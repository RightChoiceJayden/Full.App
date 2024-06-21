//
//  SearchBarView.swift
//  iTrayne_Trainer
//
//  Created by Christopher on 8/6/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation

import SwiftUI

struct SearchBar: UIViewRepresentable {

    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            // SearchBar text
            let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideUISearchBar?.textColor = UIColor.white
            text = searchText
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search for a new address"
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
            let textFieldInsideUISearchBar = uiView.value(forKey: "searchField") as? UITextField
                   textFieldInsideUISearchBar?.textColor = UIColor.white
        
    }
}
