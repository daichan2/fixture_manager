//
//  Common.swift
//  FixtureManagementApp
//
//  Created by 齋藤 大輔 on 2021/05/11.
//

import SwiftUI

class Common {
    public func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

//class CategoryData: ObservableObject {
//    @Published var categoryList: [CategoryModel] = []
//}

// カテゴリー用Picker
struct CategoryPicker: View {
    @Binding var selection: Int64
    @Binding var isShowing: Bool
    @Binding var cateroryMessage: String
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
                })
            }
            .onAppear(perform: {
                self.categoryList = DbManager().getCategoryList()
            })
            .frame(width: 200)
            .labelsHidden()
        }
    }
}

// 単位用Picker
struct UnitPicker: View {
    @Binding var selection: Int64
    @Binding var isShowing: Bool
    @Binding var unitMessage: String
    @State var unitList: [UnitModel] = []
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                let unit: UnitModel = DbManager().getUnit(id: self.selection)
                self.unitMessage = unit.name
                self.isShowing = false
            }) {
                HStack {
                    Spacer()
                    Text("閉じる")
                        .padding(.horizontal, 16)
                }
            }
            
            Picker(selection: self.$selection, label: Text("")) {
                ForEach(self.unitList) { unit in
                    Text("\(unit.name)").tag(unit.id)
                }
                .onChange(of: self.selection, perform: { id in
                    let unit: UnitModel = DbManager().getUnit(id: id)
                    self.unitMessage = unit.name
                })
            }
            .onAppear(perform: {
                self.unitList = DbManager().getUnitList()
            })
            .frame(width: 200)
            .labelsHidden()
        }
    }
}

// カテゴリーModal
struct CategoryModalView: View {
    @Binding var isActive: Bool
    @Binding var name: String
    var body: some View {
        TextField("カテゴリー名を入力してください", text: $name)
            .padding(.horizontal)
            .frame(width: 250, height: 40, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 1)
            )
        HStack {
            Button(action: {
                // カテゴリー登録処理
                DbManager().createCategory(name: self.name)
                self.isActive.toggle()
            }) {
                Text("作成")
            }
            Button(action: {
                self.isActive.toggle()
            }) {
                Text("キャンセル")
            }
        }
    }
}

// 単位Modal
struct UnitModalView: View {
    @Binding var isActive: Bool
    @Binding var name: String
    var body: some View {
        TextField("単位名を入力してください", text: $name)
            .padding(.horizontal)
            .frame(width: 250, height: 40, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 1)
            )
        HStack {
            Button(action: {
                // 単位登録処理
                DbManager().createUnit(name: self.name)
                self.isActive.toggle()
            }) {
                Text("作成")
            }
            Button(action: {
                self.isActive.toggle()
            }) {
                Text("キャンセル")
            }
        }
    }
}
