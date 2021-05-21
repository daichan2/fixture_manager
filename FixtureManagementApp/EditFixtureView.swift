//
//  EditFixtureView.swift
//  FixtureManagementApp
//
//  Created by 齋藤 大輔 on 2021/05/12.
//

import SwiftUI

struct EditFixtureView: View {
    @Binding var fixtureId: Int64
    @State var fixtureModel: FixtureModel = FixtureModel()
    @State var categoryModel: CategoryModel = CategoryModel()
    @State var unitModel: UnitModel = UnitModel()
    // Viewの遷移情報などを持っている環境変数
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingCategoryPicker = false
    @State private var isShowingUnitPicker = false
    @State private var isCategoryModalActive = false
    @State private var isUnitModalActive = false
    @State private var newCategoryMessage: String = "カテゴリーを選択してください"
    @State private var newUnitMessage:String = "単位を選択してください"
    @State private var categoryPickerId: Int64 = 1
    @State private var unitPickerId: Int64 = 1
    @State private var editFixtureQuantity: String = ""
    @State private var image: UIImage = UIImage()
    @State private var isAlertView: Bool = false
    @State private var validateMessage: String = ""
    @State private var categoryList: [CategoryModel] = []
    @State private var unitList: [UnitModel] = []
    var body: some View {
        VStack {
            
            HStack {
                EditCategoryRow(isShowing: self.$isShowingCategoryPicker, isActive: self.$isCategoryModalActive, categoryMessage: self.$newCategoryMessage, categoryList: self.$categoryList)
            }
            
            HStack {
                EditFixtureNameRow(name: self.$fixtureModel.name)
            }
            .padding(.horizontal)
            
            HStack {
                EditFixtureQuantityRow(isShowing: self.$isShowingUnitPicker, quantity: self.$editFixtureQuantity, isActive: self.$isUnitModalActive, unitMessage: self.$newUnitMessage, unitList: self.$unitList)
            }
            .padding(.horizontal)
            
            HStack {
                EditImageRow(image: self.$image)
            }
            .padding(.horizontal)
            
            ZStack {
                CategoryPicker(selection: self.$categoryPickerId, isShowing: self.$isShowingCategoryPicker, cateroryMessage: self.$newCategoryMessage, categoryList: self.$categoryList)
                    .animation(.linear)
                    .offset(y: self.isShowingCategoryPicker ? 0 : UIScreen.main.bounds.height)
                UnitPicker(selection: self.$unitPickerId, isShowing: self.$isShowingUnitPicker, unitMessage: self.$newUnitMessage, unitList: self.$unitList)
                    .animation(.linear)
                    .offset(y: self.isShowingUnitPicker ? 0 : UIScreen.main.bounds.height)
            }
        }
        .onAppear(perform: {
            // モデル取得
            self.fixtureModel = DbManager().getFixture(id: self.fixtureId)
            self.categoryModel = DbManager().getCategory(id: self.fixtureModel.categoryId)
            self.unitModel = DbManager().getUnit(id: self.fixtureModel.unitId)
            // 初期値設定
            self.newCategoryMessage = self.categoryModel.name
            self.newUnitMessage = self.unitModel.name
            self.categoryPickerId = self.categoryModel.id
            self.unitPickerId = self.unitModel.id
            self.editFixtureQuantity = String(self.fixtureModel.quantity)
            self.image = ImageConversion().stringToImage(imageString: fixtureModel.image)
        })
        .navigationBarTitle("編集", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("戻る")
                    .foregroundColor(Color.white)
            },
            trailing: Button(action: {
                // エラーメッセージを抽出
                self.validateMessage = Validation().validSaveView(name: self.fixtureModel.name, quantity: self.editFixtureQuantity)
                // エラー項目があるかチェック
                if (self.validateMessage.isEmpty) {
                    // 備品更新処理
                    DbManager().updateFixture(id: self.fixtureId, cId: self.categoryPickerId, uId: self.unitPickerId, name: self.fixtureModel.name, quantity: Int64(self.editFixtureQuantity)!, image: ImageConversion().imageToString(image: self.image))
                } else {
                    self.isAlertView = true
                }
            }) {
                Text("保存")
                    .foregroundColor(Color.white)
            })
        .alert(isPresented: self.$isAlertView) {
            Alert(title: Text("\(self.validateMessage)を入力してください"))
        }
    }
}

struct EditFixtureView_Previews: PreviewProvider {
    static var previews: some View {
        EditFixtureView(fixtureId: .constant(1))
    }
}

// カテゴリー行
struct EditCategoryRow: View {
    @Binding var isShowing: Bool
    @Binding var isActive: Bool
    @Binding var categoryMessage: String
    @Binding var categoryList: [CategoryModel]
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
            CategoryModalView(isActive: $isActive, name: $categoryName, categoryLIst: self.$categoryList)
        })
        .padding(.top)
        Spacer()
    }
}
// 品名行
struct EditFixtureNameRow: View {
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
struct EditFixtureQuantityRow: View {
    @Binding var isShowing: Bool
    @Binding var quantity: String
    @Binding var isActive: Bool
    @Binding var unitMessage: String
    @Binding var unitList: [UnitModel]
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
            UnitModalView(isActive: $isActive, name: $unitName, unitList: $unitList)
        })
        
        Spacer()
    }
}
// 画像行
struct EditImageRow: View {
    @Binding var image: UIImage
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
                if self.image != UIImage() {
                    Image(uiImage: self.image)
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
