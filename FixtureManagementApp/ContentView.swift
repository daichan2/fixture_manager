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
    @State private var indexCategoryMessage: String = "カテゴリーを選択してください"
    @State private var fixtureList: [FixtureModel] = []
    @State var unitModels: [UnitModel] = []
    var body: some View {
        NavigationView {
            VStack {

                HStack {
                    CategorySearchRow(isShowing: self.$isShowingCategoryPicker, categoryMessage: self.$indexCategoryMessage)
                }

                ZStack {

                    HStack {
                        FixtureList(fixtureList: self.$fixtureList, unitModels: self.$unitModels)
                    }

                    CategorySearchPicker(selection: self.$categoryPickerId, isShowing: self.$isShowingCategoryPicker, cateroryMessage: self.$indexCategoryMessage, fixtureList: self.$fixtureList)
                        .animation(.linear)
                        .offset(y: self.isShowingCategoryPicker ? 0 : UIScreen.main.bounds.height)
                }
            }
            .navigationBarTitle("一覧", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: AddFixtureView()) {
                Text("+")
                    .foregroundColor(Color.white)
            })
            .onAppear(perform: {
                self.fixtureList = DbManager().getFixtureList()
                var models: [UnitModel] = []
                for fixture in self.fixtureList {
                    let unitModel: UnitModel = DbManager().getUnit(id: fixture.unitId)
                    models.append(unitModel)
                }
                self.unitModels = models
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
    @Binding var fixtureList: [FixtureModel]
    @Binding var unitModels: [UnitModel]
    var body: some View {
        List() {
            ForEach(0..<self.fixtureList.count, id: \.self) { index in
                HStack {
                    NavigationLink(destination: EditFixtureView(fixtureId: .constant(self.fixtureList[index].id))) {
                        Text("\(self.fixtureList[index].name)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(self.fixtureList[index].quantity) \(self.unitModels[index].name)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }.onDelete(perform: { indexSet in
                // 備品削除
                DbManager().deleteFixture(id: self.fixtureList[indexSet.first!].id)
                self.fixtureList.remove(atOffsets: indexSet)
            })
        }
        .listStyle(PlainListStyle())
    }
}

// カテゴリー絞り込み用Picker
struct CategorySearchPicker: View {
    @Binding var selection: Int64
    @Binding var isShowing: Bool
    @Binding var cateroryMessage: String
    @Binding var fixtureList: [FixtureModel]
    @State var categoryList: [CategoryModel] = []
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                let category: CategoryModel = DbManager().getCategory(id: self.selection)
                self.cateroryMessage = category.name
                self.isShowing = false
            }) {
                HStack {
                    Spacer()
                    Text("閉じる")
                        .padding(.horizontal, 16)
                }
            }
            Picker(selection: self.$selection, label: Text("")) {
                ForEach(self.categoryList) { category in
                    Text("\(category.name)").tag(category.id)
                }
                .onChange(of: self.selection, perform: { id in
                    let category: CategoryModel = DbManager().getCategory(id: id)
                    self.cateroryMessage = category.name
                    // カテゴリー絞り込み
                    self.fixtureList = DbManager().categorySearchFixtureList(cId: category.id)
                })
            }
            .onAppear(perform: {
                self.categoryList = DbManager().getCategoryList()
                self.cateroryMessage = "カテゴリーを選択してください"
            })
            .frame(width: 200)
            .labelsHidden()
        }
    }
}
