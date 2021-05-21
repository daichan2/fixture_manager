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
    @Binding var categoryList: [CategoryModel]
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
    @Binding var unitList: [UnitModel]
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
    @Binding var categoryLIst: [CategoryModel]
    @State var isAlertView: Bool = false
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
                if (Validation().validCategoryName(name: self.name)) {
                    // カテゴリー登録処理
                    DbManager().createCategory(name: self.name)
                    // カテゴリー一覧を取得
                    self.categoryLIst = DbManager().getCategoryList()
                    self.isActive.toggle()
                } else {
                    self.isAlertView = true
                }
            }) {
                Text("作成")
            }
            
            Button(action: {
                self.isActive.toggle()
            }) {
                Text("キャンセル")
            }
            
            .alert(isPresented: self.$isAlertView) {
                Alert(title: Text("カテゴリー名を入力してください"))
            }
        }
    }
}

// 単位Modal
struct UnitModalView: View {
    @Binding var isActive: Bool
    @Binding var name: String
    @Binding var unitList: [UnitModel]
    @State var isAlertView: Bool = false
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
                if (Validation().validUnitName(name: self.name)) {
                    // 単位登録処理
                    DbManager().createUnit(name: self.name)
                    // 単位一覧を取得
                    self.unitList = DbManager().getUnitList()
                    self.isActive.toggle()
                } else {
                    self.isAlertView = true
                }
            }) {
                Text("作成")
            }
            
            Button(action: {
                self.isActive.toggle()
            }) {
                Text("キャンセル")
            }
            
            .alert(isPresented: self.$isAlertView) {
                Alert(title: Text("単位名を入力してください"))
            }
        }
    }
}

// カメラ、ライブラリー機能
struct SwiftUIImagePicker: UIViewControllerRepresentable {
    // 画像保存
    @Binding var image: UIImage
    // カメラorライブラリー表示フラグ
    @Binding var showCameraView: Bool
    // カメラorライブラリーの選択肢
    @Binding var sourceType: UIImagePickerController.SourceType
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    // カメラorライブラリーのビュー作成
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = UIImagePickerController()
        viewController.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(self.sourceType) {
            viewController.sourceType = self.sourceType
        }
        return viewController
    }
    
    // カメラorライブラリーの表示を検知
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        print("updateUIViewController is called")
    }
    
    // UIImagePickerControllerDelegate:画像関連処理のライブラリー
    // UINavigationControllerDelegate:ナビゲーションのライブラリー
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: SwiftUIImagePicker
        init(_ parent: SwiftUIImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                self.parent.image = uiImage
            }
            self.parent.showCameraView = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.showCameraView = false
        }
    }
}

// 画像のデータ形式を変換
class ImageConversion: NSObject {
    // UIImage→String
    func imageToString(image: UIImage) -> String {
        if (image != UIImage()) {
            // 画像をNSDataに変換
            let data: NSData = image.pngData()! as NSData
            // base64形式に変換
            let imageString = data.base64EncodedString(options: .lineLength64Characters)
            return imageString
        } else {
            return ""
        }
    }
    
    // String→UIImage
    func stringToImage(imageString: String) -> UIImage {
        if (!imageString.isEmpty) {
            // base64をNSDataに変換
            let imageData = NSData(base64Encoded: imageString, options: .ignoreUnknownCharacters)
            // NSDataを画像に変換
            let image: UIImage = UIImage(data: imageData! as Data)!
            return image
        } else {
            return UIImage()
        }
    }
}

// バリデーション
class Validation {
    // カテゴリー追加時のバリデーション
    func validCategoryName(name: String) -> Bool {
        if (name.isEmpty) { return false }
        return true
    }
    
    // 単位追加時のバリデーション
    func validUnitName(name: String) -> Bool {
        if (name.isEmpty) { return false }
        return true
    }
    
    // 備品登録時のバリデーション
    func validSaveView(name: String, quantity: String) -> String {
        var errorItem: String = ""
        if (name.isEmpty) {
            errorItem = "品名"
            return errorItem
        }
        if (quantity.isEmpty) {
            errorItem = "個数"
            return errorItem
        }
        return ""
    }
}
