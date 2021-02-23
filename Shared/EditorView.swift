//
//  EditorView.swift
//  Notesi
//
//  Created by Quentin Eude on 09/02/2021.
//

import SwiftDown
import SwiftUI

struct EditorView: View {
    @Binding var text: String?

    var body: some View {
        Group {
            if text != nil {
                SwiftDownTextView(text: $text ?? "No file selected")
                    .insetsSize(40)
            } else {
                Text("No file selected")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(
            text: .constant(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam ligula erat, porta a gravida in, posuere eget lectus. Donec pulvinar aliquet urna, ut pharetra diam bibendum nec. In non semper libero, id condimentum dolor. Ut in mollis magna. Nulla odio neque, finibus sed tortor quis, lacinia consequat leo. Ut ac varius nisl. Suspendisse tempus dui orci, quis pharetra dolor finibus non. Proin feugiat sollicitudin pulvinar. In dapibus urna leo, lobortis ullamcorper eros vulputate eget. Vestibulum velit neque, condimentum sed luctus in, cursus eu arcu. Ut mattis metus in libero condimentum, a maximus dui varius. Quisque ultricies lacus quis quam posuere, nec blandit tortor finibus. Pellentesque vehicula ultricies sagittis."
            ))
    }
}
