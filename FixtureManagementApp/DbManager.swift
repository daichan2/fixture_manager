//
//  DbManager.swift
//  FixtureManagementApp
//
//  Created by 齋藤 大輔 on 2021/05/10.
//

import Foundation
import SQLite

class DbManager {
    // sqliteへ接続するためのインスタンス
    private var db: Connection!
    // カテゴリーテーブルのインスタンス
    private var categories: Table!
    // カテゴリーテーブルのカラム群
    private var categoriesId: Expression<Int64>!              // 初期化はデータを入れなければいけないが、それを回避
    private var categoriesName: Expression<String>!
    private var categoriesCreatedAt: Expression<String>!
    private var categoriesUpdatedAt: Expression<String>!
    
    // 単位テーブルのインスタンス
    private var units: Table!
    // 単位テーブルのカラム群
    private var unitsId: Expression<Int64>!
    private var unitsName: Expression<String>!
    private var unitsCreatedAt: Expression<String>!
    private var unitsUpdatedAt: Expression<String>!
    
    // 備品テーブルのインスタンス
    private var fixtures: Table!
    // 備品テーブルのカラム群
    private var fixturesId: Expression<Int64>!
    private var categoryId: Expression<Int64>!
    private var unitId: Expression<Int64>!
    private var fixturesName: Expression<String>!
    private var fixturesQuantity: Expression<Int64>!
    private var fixturesCreatedAt: Expression<String>!
    private var fixturesUpdatedAt: Expression<String>!
    
    init() {
        
        do {
            // 端末のディレクトリパスを取得
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            // DB接続(ファイルがなければ新規作成)
            db = try Connection("\(path)/application.sqlite3")
            // カテゴリーテーブルインスタンスを作成
            categories = Table("categories")
            // カテゴリーテーブルのカラムのインスタンスを作成
            categoriesId = Expression<Int64>("id")
            categoriesName = Expression<String>("name")
            categoriesCreatedAt = Expression<String>("created_at")
            categoriesUpdatedAt = Expression<String>("updated_at")
            
            // 単位テーブルインスタンスを作成
            units = Table("units")
            // 単位テーブルのカラムのインスタンスを作成
            unitsId = Expression<Int64>("id")
            unitsName = Expression<String>("name")
            unitsCreatedAt = Expression<String>("created_at")
            unitsUpdatedAt = Expression<String>("updated_at")
            
            // 備品テーブルインスタンスを作成
            fixtures = Table("fixtures")
            // 備品テーブルのカラムのインスタンスを作成
            fixturesId = Expression<Int64>("id")
            categoryId = Expression<Int64>("category_id")
            unitId = Expression<Int64>("unit_id")
            fixturesName = Expression<String>("name")
            fixturesQuantity = Expression<Int64>("quantity")
            fixturesCreatedAt = Expression<String>("created_at")
            fixturesUpdatedAt = Expression<String>("updated_at")
            
            // カテゴリーテーブルが存在するかチェック
            if (!UserDefaults.standard.bool(forKey: "is_categories_table_created")) {
                // カテゴリーテーブルを作成
                try db.run(categories.create { (t) in
                    t.column(categoriesId, primaryKey: true)
                    t.column(categoriesName, check: nil)
                    t.column(categoriesCreatedAt, check: nil)
                    t.column(categoriesUpdatedAt, check: nil)
                })
                // カテゴリーテーブルを作成した証拠を残す
                UserDefaults.standard.set(true, forKey: "is_categories_table_created")
            }

            // 単位テーブルが存在するかチェック
            if (!UserDefaults.standard.bool(forKey: "is_units_table_created")) {
                // 単位テーブルを作成
                try db.run(units.create { (t) in
                    t.column(unitsId, primaryKey: true)
                    t.column(unitsName, check: nil)
                    t.column(unitsCreatedAt, check: nil)
                    t.column(unitsUpdatedAt, check: nil)
                })
                // 単位テーブルを作成した証拠を残す
                UserDefaults.standard.set(true, forKey: "is_units_table_created")
            }
            
            // 備品テーブルが存在するかチェック
            if (!UserDefaults.standard.bool(forKey: "is_fixtures_table_created")) {
                // 備品テーブルを作成
                try db.run(fixtures.create { (t) in
                    t.column(fixturesId, primaryKey: true)
                    t.column(categoryId, references: categories, categoriesId)
                    t.column(unitId, references: units, unitsId)
                    t.column(fixturesName, check: nil)
                    t.column(fixturesQuantity, check: nil)
                    t.column(fixturesCreatedAt, check: nil)
                    t.column(fixturesUpdatedAt, check: nil)
                    t.foreignKey(categoryId, references: categories, categoriesId, delete: .setNull)
                    t.foreignKey(unitId, references: units, unitsId, delete: .setNull)
                })
                // 備品テーブルを作成した証拠を残す
                UserDefaults.standard.set(true, forKey: "is_fixtures_table_created")
            }
        } catch {
            // 失敗時に挙動
            print(error.localizedDescription)
        }
    }
    
    // カテゴリー一覧取得
    public func getCategoryList() -> [CategoryModel] {
        var categoryModels: [CategoryModel] = []
        categories = categories.order(categoriesId.desc)
        do {
            for category in try db.prepare(categories) {
                let categoryModel: CategoryModel = CategoryModel()
                categoryModel.id = category[categoriesId]
                categoryModel.name = category[categoriesName]
                categoryModel.createdAt = category[categoriesCreatedAt]
                categoryModel.updatedAt = category[categoriesUpdatedAt]
                categoryModels.append(categoryModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        return categoryModels
    }
    
    // カテゴリーを一件取得
    public func getCategory(id: Int64) -> CategoryModel {
        let categoryModel: CategoryModel = CategoryModel()
        let categoryRow = categories.filter(categoriesId == id)
        do {
            for category in try db.prepare(categoryRow) {
                categoryModel.id = category[categoriesId]
                categoryModel.name = category[categoriesName]
                categoryModel.createdAt = category[categoriesCreatedAt]
                categoryModel.updatedAt = category[categoriesUpdatedAt]
            }
        } catch {
            print(error.localizedDescription)
        }
        return categoryModel
    }
    
    // カテゴリー登録処理
    public func createCategory(name: String) {
        //現在の日付を取得
        let date:Date = Date()
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss"
        //日付をStringに変換する
        let sDate = format.string(from: date)
        do {
            let category = categories.insert(categoriesName <- name, categoriesCreatedAt <- sDate, categoriesUpdatedAt <- sDate)
            try db.run(category)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 単位一覧取得
    public func getUnitList() -> [UnitModel] {
        var unitModels: [UnitModel] = []
        units = units.order(unitsId.desc)
        do {
            for unit in try db.prepare(units) {
                let unitModel: UnitModel = UnitModel()
                unitModel.id = unit[unitsId]
                unitModel.name = unit[unitsName]
                unitModel.createdAt = unit[unitsCreatedAt]
                unitModel.updatedAt = unit[unitsUpdatedAt]
                unitModels.append(unitModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        return unitModels
    }
    
    // 単位を一件取得
    public func getUnit(id: Int64) -> UnitModel {
        let unitModel: UnitModel = UnitModel()
        let unitRow = units.filter(unitsId == id)
        do {
            for unit in try db.prepare(unitRow) {
                unitModel.id = unit[unitsId]
                unitModel.name = unit[unitsName]
                unitModel.createdAt = unit[unitsCreatedAt]
                unitModel.updatedAt = unit[unitsUpdatedAt]
            }
        } catch {
            print(error.localizedDescription)
        }
        return unitModel
    }
    
    // 単位登録処理
    public func createUnit(name: String) {
        //現在の日付を取得
        let date:Date = Date()
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss"
        //日付をStringに変換する
        let sDate = format.string(from: date)
        do {
            let unit = units.insert(unitsName <- name, unitsCreatedAt <- sDate, unitsUpdatedAt <- sDate)
            try db.run(unit)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 備品一覧取得
    public func getFixtureList() -> [FixtureModel] {
        var fixtureModels: [FixtureModel] = []
        fixtures = fixtures.order(fixturesId.desc)
        do {
            for fixture in try db.prepare(fixtures) {
                let fixtureModel: FixtureModel = FixtureModel()
                fixtureModel.id = fixture[fixturesId]
                fixtureModel.categoryId = fixture[categoryId]
                fixtureModel.unitId = fixture[unitId]
                fixtureModel.name = fixture[fixturesName]
                fixtureModel.quantity = fixture[fixturesQuantity]
                fixtureModel.createdAt = fixture[fixturesCreatedAt]
                fixtureModel.updatedAt = fixture[fixturesUpdatedAt]
                fixtureModels.append(fixtureModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        return fixtureModels
    }
    
    // 備品を一件取得
    public func getFixture(id: Int64) -> FixtureModel {
        let fixtureModel: FixtureModel = FixtureModel()
        let fixtureRow = fixtures.filter(fixturesId == id)
        do {
            for fixture in try db.prepare(fixtureRow) {
                fixtureModel.id = fixture[fixturesId]
                fixtureModel.categoryId = fixture[categoryId]
                fixtureModel.unitId = fixture[unitId]
                fixtureModel.name = fixture[fixturesName]
                fixtureModel.quantity = fixture[fixturesQuantity]
                fixtureModel.createdAt = fixture[fixturesCreatedAt]
                fixtureModel.updatedAt = fixture[fixturesUpdatedAt]
            }
        } catch {
            print(error.localizedDescription)
        }
        return fixtureModel
    }
    
    // 備品登録処理
    public func createFixture(cId: Int64, uId: Int64, name: String, quantity: Int64) {
        //現在の日付を取得
        let date:Date = Date()
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss"
        //日付をStringに変換する
        let sDate = format.string(from: date)
        do {
            let fixture = fixtures.insert(categoryId <- cId, unitId <- uId, fixturesName <- name, fixturesQuantity <- quantity, fixturesCreatedAt <- sDate, fixturesUpdatedAt <- sDate)
            try db.run(fixture)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 備品更新処理
    public func updateFixture(id: Int64, cId: Int64, uId: Int64, name: String, quantity: Int64) {
        //現在の日付を取得
        let date:Date = Date()
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm:ss"
        //日付をStringに変換する
        let sDate = format.string(from: date)
        do {
            let fixture = fixtures.filter(fixturesId == id)
            try db.run(fixture.update(categoryId <- cId, unitId <- uId, fixturesName <- name, fixturesQuantity <- quantity, fixturesUpdatedAt <- sDate))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 備品削除処理
    public func deleteFixture(id: Int64) {
        do {
            let fixture = fixtures.filter(fixturesId == id)
            try db.run(fixture.delete())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 備品カテゴリー絞り込み
    public func categorySearchFixtureList(cId: Int64) -> [FixtureModel] {
        var fixtureModels: [FixtureModel] = []
        fixtures = fixtures.filter(categoryId == cId).order(fixturesId.desc)
        do {
            for fixture in try db.prepare(fixtures) {
                let fixtureModel: FixtureModel = FixtureModel()
                fixtureModel.id = fixture[fixturesId]
                fixtureModel.categoryId = fixture[categoryId]
                fixtureModel.unitId = fixture[unitId]
                fixtureModel.name = fixture[fixturesName]
                fixtureModel.quantity = fixture[fixturesQuantity]
                fixtureModel.createdAt = fixture[fixturesCreatedAt]
                fixtureModel.updatedAt = fixture[fixturesUpdatedAt]
                fixtureModels.append(fixtureModel)
            }
        } catch {
            print(error.localizedDescription)
        }
        return fixtureModels
    }
}
