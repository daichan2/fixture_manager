//
//  AddFixtureView.swift
//  FixtureManagementApp
//
//  Created by 齋藤 大輔 on 2021/05/11.
//

import SwiftUI

struct AddFixtureView: View {
    // Viewの遷移情報などを持っている環境変数
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingCategoryPicker = false
    @State private var isShowingUnitPicker = false
    @State private var isCategoryModalActive = false
    @State private var isUnitModalActive = false
    @State private var newCategoryMessage: String = "カテゴリーを選択してください"
    @State private var newUnitMessage:String = "単位を選択してください"
    @State private var newFixtureName: String = ""
    @State private var newFixtureQuantity: String = ""
    @State private var categoryPickerId: Int64 = 1
    @State private var unitPickerId: Int64 = 1
    var body: some View {
        VStack {
            
            HStack {
                NewCategoryRow(isShowing: self.$isShowingCategoryPicker, isActive: self.$isCategoryModalActive, categoryMessage: self.$newCategoryMessage)
            }
            
            HStack {
                NewFixtureNameRow(name: self.$newFixtureName)
            }
            .padding(.horizontal)
            
            HStack {
                NewFixtureQuantityRow(isShowing: self.$isShowingUnitPicker,
                                      isActive: $isUnitModalActive, quantity: self.$newFixtureQuantity, unitMessage: self.$newUnitMessage)
            }
            .padding(.horizontal)
            
            HStack {
                NewImageRow()
            }
            .padding(.horizontal)
            
            ZStack {
                CategoryPicker(selection: self.$categoryPickerId, isShowing: self.$isShowingCategoryPicker, cateroryMessage: self.$newCategoryMessage)
                    .animation(.linear)
                    .offset(y: self.isShowingCategoryPicker ? 0 : UIScreen.main.bounds.height)
                UnitPicker(selection: self.$unitPickerId, isShowing: self.$isShowingUnitPicker, unitMessage: self.$newUnitMessage)
                    .animation(.linear)
                    .offset(y: self.isShowingUnitPicker ? 0 : UIScreen.main.bounds.height)
            }
        }
        .navigationBarTitle("新規作成", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("戻る")
                    .foregroundColor(Color.white)
            },
            trailing: Button(action: {
                // 備品登録処理
                DbManager().createFixture(cId: self.categoryPickerId, uId: self.unitPickerId, name: self.newFixtureName, quantity: Int64(self.newFixtureQuantity)!)
            }) {
                Text("保存")
                    .foregroundColor(Color.white)
            })
    }
}

struct AddFixtureView_Previews: PreviewProvider {
    static var previews: some View {
        AddFixtureView()
    }
}

// カテゴリー行
struct NewCategoryRow: View {
    @Binding var isShowing: Bool
    @Binding var isActive: Bool
    @Binding var categoryMessage: String
    @State private var categoryName = ""
    var body: some View {
        // カテゴリーを選択するドロップダウンリスト
        Button(action: {
            self.isShowing.toggle()
        }) {
            Text("\(self.categoryMessage)")
                .font(.caption)
                .foregroundColor(Color.black)
                .padding()
            Text(">")
                .font(.caption)
                .padding()
        }
        .frame(width: 230, height: 40, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding([.top, .leading, .trailing])
        // カテゴリー追加モーダルを表示するボタン
        Button(action: {
            self.isActive.toggle()
        }) {
            Text("+")
                .foregroundColor(Color.blue)
        }
        .sheet(isPresented: $isActive, content: {
            CategoryModalView(isActive: $isActive, name: $categoryName)
        })
        .padding(.top)
        Spacer()
    }
}
// 品名行
struct NewFixtureNameRow: View {
    @Binding var name: String
    var body: some View {
        // 品名を入力するテキストフォーム
        TextField("品名", text: $name)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 1)
            )
        Spacer()
    }
}
// 個数、単位行
struct NewFixtureQuantityRow: View {
    @Binding var isShowing: Bool
    @Binding var isActive: Bool
    @Binding var quantity: String
    @Binding var unitMessage: String
    @State private var unitName = ""
    var body: some View {
        // 個数を入力するテキストフォーム
        TextField("個数", text: $quantity)
            .padding(.horizontal)
            .frame(width: 100, height: 40, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 1)
            )
        // 単位を選択するドロップダウンリスト
        Button(action: {
            self.isShowing.toggle()
        }) {
            Text("\(self.unitMessage)")
                .font(.caption)
                .foregroundColor(Color.black)
                .padding()
            Text(">")
                .font(.caption)
                .padding([.top, .bottom, .trailing])
        }
        .frame(width: 110, height: 40, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding(.horizontal)
        // 単位追加モーダルを表示するボタン
        Button(action: {
            self.isActive.toggle()
        }) {
            Text("+")
                .foregroundColor(Color.blue)
        }
        .sheet(isPresented: $isActive, content: {
            UnitModalView(isActive: $isActive, name: $unitName)
        })
        
        Spacer()
    }
}
// 画像行
struct NewImageRow: View {
    @State private var image: UIImage?
    @State private var showCameraView = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    var body: some View {
        HStack {
            Text("画像")
            Menu {
                Button(action: {
                    self.sourceType = .camera
                    self.showCameraView.toggle()
                }, label: {
                    Text("カメラを起動")
                })
                .padding()
                
                Button(action: {
                    self.sourceType = .photoLibrary
                    self.showCameraView.toggle()
                }, label: {
                    Text("ライブラリから画像を選択")
                })
            } label: {
                if self.image != nil {
                    Image(uiImage: self.image!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                } else {
                    Text("+")
                }
            }
            .padding()
        }
        .sheet(isPresented: self.$showCameraView, content: {
            SwiftUIImagePicker(image: self.$image, showCameraView: self.$showCameraView, sourceType: self.$sourceType)
        })
        Spacer()
    }
}
