//
//  UserData.swift
//  TodoList
//
//  Created by 毕靖翔 on 2021/11/28.
//

import Foundation

var encoder = JSONEncoder()
var decoder = JSONDecoder()

class ToDo: ObservableObject {
    @Published var todoList: [SingleToDo]
    var count: Int = 0
    
    init() {
        self.todoList = []
    }
    
    init(data: [SingleToDo]) {
        self.todoList = []
        for item in data {
            self.todoList.append(SingleToDo(id: self.count, title: item.title, duedate: item.duedate, isChecked: item.isChecked, isFavorite: item.isFavorite))
            count += 1
        }
    }
    
    ///  根据id查询item
    /// - Parameter id: ToDo id值
    func check(id: Int) {
        self.todoList[id].isChecked.toggle()
        
        self.dataStore()
    }
    
    
    /// 添加todo
    /// - Parameter data: ToDo数据
    func add(data: SingleToDo) {
        self.todoList.append(SingleToDo(id: self.count, title: data.title, duedate: data.duedate, isFavorite: data.isFavorite))
        count += 1
        self.sort()
        
        self.dataStore()
    }
    
    
    /// 编辑
    /// - Parameters:
    ///   - id: id
    ///   - data: todo数据
    func edit(id: Int, data: SingleToDo) {
        self.todoList[id].title = data.title
        self.todoList[id].duedate = data.duedate
        self.todoList[id].isChecked = false
        self.todoList[id].isFavorite = data.isFavorite
        
        self.sort()
        
        self.dataStore()
    }
    
    
    /// 删除元素
    /// - Parameter id: id
    func delete(id: Int) {
        self.todoList[id].deleted = true
        self.sort()
        
        self.dataStore()
    }
    
    /// 排序
    func sort() {
        self.todoList.sort(by: {
            (data1, data2) in
            return data1.duedate.timeIntervalSince1970 < data2.duedate.timeIntervalSince1970
        })
        
        for i in 0..<self.todoList.count {
            self.todoList[i].id = i
        }
    }
    
    
    /// 数据存储
    func dataStore() {
        let dataStored = try! encoder.encode(self.todoList)
        UserDefaults.standard.set(dataStored, forKey: "TodoList")
    }
}


/// ToDo对象结构体
struct SingleToDo: Identifiable, Codable {
    var id: Int = 0
    // 标题
    var title: String = ""
    // 时间
    var duedate: Date = Date()
    // 是否选中
    var isChecked: Bool = false
    // 是否收藏
    var isFavorite: Bool = false
    // 是否删除
    var deleted: Bool = false
}
