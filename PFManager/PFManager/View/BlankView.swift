//
//  BlankView.swift
//  PFManager
//
//  Created by junemp on 2022/12/19.
//

import SwiftUI

struct BlankView: View {
    
    var bgColor: Color
    
    var body: some View {
        VStack {
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(bgColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct BlankView_Previews: PreviewProvider {
    static var previews: some View {
        BlankView(bgColor: .black)
    }
}
