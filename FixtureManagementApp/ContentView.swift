//
//  ContentView.swift
//  FixtureManagementApp
//
//  Created by 齋藤 大輔 on 2021/05/10.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingCategoryPicker = false
    @State private var categoryPickerId: Int64 = 1
    @State private var newCategoryMessage: String = "カテゴリーを選択してください"
    var body: some View {
        NavigationView {
            VStack {
                
                HStack {
                    CategorySearchRow(isShowing: self.$isShowingCategoryPicker, categoryMessage: self.$newCategoryMessage)
                }
                
                ZStack {
                
                    HStack {
                        FixtureList()
                    }
                    
                    CategoryPicker(selection: self.$categoryPickerId, isShowing: self.$isShowingCategoryPicker, cateroryMessage: self.$newCategoryMessage)
                        .animation(.linear)
                        .offset(y: self.isShowingCategoryPicker ? 0 : UIScreen.main.bounds.height)
                }
            }
            .navigationBarTitle("一覧", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: AddFixtureView()) {
                Text("+")
                    .foregroundColor(Color.white)
            })
        }
    }
    init() {
        Common().setupNavigationBar()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// カテゴリー検索
struct CategorySearchRow: View {
    @Binding var isShowing: Bool
    @Binding var categoryMessage: String
    var body: some View {
        // カテゴリーを選択するドロップダウンリスト
        Button(action: {
            self.isShowing.toggle()
        }) {
            Text("\(categoryMessage)")
                .font(.caption)
                .foregroundColor(Color.black)
                .padding()
            Text(">")
                .font(.caption)
                .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding()
        Spacer()
    }
}
// 備品リスト
struct FixtureList: View {
    @State var fixturesList: [FixtureModel] = []
    @State var unitModels: [UnitModel] = []
    var body: some View {
        List() {
            ForEach(0..<self.fixturesList.count, id: \.self) { index in
                HStack {
                    NavigationLink(destination: EditFixtureView(fixtureId: .constant(self.fixturesList[index].id))) {
                        Text("\(self.fixturesList[index].name)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(self.fixturesList[index].quantity) \(self.unitModels[index].name)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }.onDelete(perform: { indexSet in
                // 備品削除
                DbManager().deleteFixture(id: self.fixturesList[indexSet.first!].id)
                self.fixturesList.remove(atOffsets: indexSet)
            })
        }
        .listStyle(PlainListStyle())
        .onAppear(perform: {
            self.fixturesList = DbManager().getFixtureList()
            var models: [UnitModel] = []
            for fixture in self.fixturesList {
                let unitModel: UnitModel = DbManager().getUnit(id: fixture.unitId)
                models.append(unitModel)
            }
            self.unitModels = models
        })
    }
}
