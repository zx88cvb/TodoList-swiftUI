//
//  UserData.swift
//  TodoList
//
//  Created by 毕靖翔 on 2021/11/28.
//

import Foundation

class ToDo: ObservableObject {
    @Published var TodoList: [SingleToDo]
    var count: Int = 0
    
    init() {
        self.TodoList = []
    }
    
    init(data: [SingleToDo]) {
        self.TodoList = []
        for item in data {
            self.TodoList.append(SingleToDo(id: self.count, title: item.title, duedate: item.duedate))
            count += 1
        }
    }
    
    ///  根据id查询item
    /// - Parameter id: ToDo id值
    func check(id: Int) {
        self.TodoList[id].isChecked.toggle()
    }
    
    
    /// 添加todo
    /// - Parameter data: ToDo数据
    func add(data: SingleToDo) {
        self.TodoList.append(SingleToDo(id: self.count, title: data.title, duedate: data.duedate))
        count += 1
    }
}


/// ToDo对象结构体
struct SingleToDo: Identifiable {
    var id: Int = 0
    // 标题
    var title: String = ""
    // 时间
    var duedate: Date = Date()
    // 是否选中
    var isChecked: Bool = false
}
