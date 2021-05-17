//
//  FixtureModel.swift
//  FixtureManagementApp
//
//  Created by 齋藤 大輔 on 2021/05/14.
//

import Foundation

class FixtureModel: Identifiable {
    public var id: Int64 = 0
    public var categoryId: Int64 = 0
    public var unitId: Int64 = 0
    public var name: String = ""
    public var quantity: Int64 = 0
    public var createdAt: String = ""
    public var updatedAt: String = ""
}
