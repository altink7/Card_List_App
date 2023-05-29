//
//  ContentView.swift
//  03_kelmendi
//
//  Created by Altin Kelmendi on 20.05.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ItemViewModel()

    var body: some View {
        NavigationView {
            ItemListView()
                .environmentObject(viewModel)
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

