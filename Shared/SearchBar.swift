//
//  SearchBar.swift
//  Notesi
//
//  Created by Quentin Eude on 16/02/2021.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String

    @State private var isFocused = false

    var body: some View {
        ZStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchText) { editing in
                        isFocused = editing
                    }
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isFocused ? Color.accentColor : Color.clear)
                            .background(Color.black.opacity(0.2).cornerRadius(8))
                    )
                    .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
            }
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        }
        .frame(height: 50)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchText: .constant("Toto"))
    }
}
