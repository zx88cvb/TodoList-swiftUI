//
//  ContentView.swift
//  TodoList
//
//  Created by 毕靖翔 on 2021/11/28.
//

import SwiftUI

var formatter = DateFormatter()

/// 初始化卡片数据
/// - Returns: 卡片数组
func initUserData() -> [SingleToDo] {
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    var output: [SingleToDo] = []
    if let dataStored = UserDefaults.standard.object(forKey: "TodoList") as? Data {
        var data: [SingleToDo] = []
        do {
            data = try decoder.decode([SingleToDo].self, from: dataStored)
        } catch {
            print("error:\(error)")
            data = []
        }
        
        for item in data    {
            // 没有被删除才放进卡片
            if(!item.deleted) {
                output.append(SingleToDo(id: data.count, title: item.title, duedate: item.duedate, isChecked: item.isChecked, isFavorite: item.isFavorite))
            }
        }
    }
    
    return output
}

struct ContentView: View {
    @ObservedObject var userData: ToDo = ToDo(data: initUserData())
    
    // 编辑页面
    @State var showEditingPage: Bool = false
    // 编辑模式
    @State var editMode: Bool = false
    // 选中卡片数组
    @State var selection: [Int] = []
    // 是否是收藏模式
    @State var showLikeOnly: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ForEach(self.userData.todoList) {item in
                            // 没有被删除才放进卡片 且 (如果是非收藏模式 或者 收藏模式下只显示收藏的卡片)
                            if(!item.deleted && (!self.showLikeOnly || item.isFavorite)) {
                                SingleCardView(editMode: self.$editMode, selection: self.$selection, index: item.id)
                                    .environmentObject(self.userData)
                                .padding(.horizontal)
                                .padding(.top)
                                .animation(.spring())
                                .transition(.slide)
                                
                            }
                        }
                    }
                }.navigationTitle("提醒事项")
                .toolbar {
                    HStack(spacing: 20) {
                        // 只有编辑模式才显示删除按钮
                        if(self.editMode) {
                            DeleteButton(selection: self.$selection, editMode: self.$editMode)
                                .environmentObject(self.userData)
                            LikeButton(selection: self.$selection, editMode: self.$editMode)
                                .environmentObject(self.userData)
                        } else {
                            ShowLikeButton(showLikeOnly: self.$showLikeOnly)
                        }
                        
                        EditingButton(editMode: self.$editMode, selection: self.$selection)
                    }
                }
            }
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button(action: {
                        self.showEditingPage = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)
                            .foregroundColor(.blue)
                            .padding(.trailing)
                    }.sheet(isPresented: self.$showEditingPage, content: {
                        EditingPage().environmentObject(self.userData)
                    })
                }
            }
        }
        
    }
}


/// 多选收藏
struct LikeButton: View {
    // 选中卡片数组
    @Binding var selection: [Int]
    // 展示选择右上角编辑按钮
    @Binding var editMode: Bool
    
    @EnvironmentObject var userData: ToDo
     
    var body: some View {
        Button(action: {
            
        }) {
            Image(systemName: "star.lefthalf.fill")
                .imageScale(.large)
                .foregroundColor(.yellow)
                .onTapGesture {
                    for i in selection {
                        self.userData.todoList[i].isFavorite.toggle()
                    }
                    if (selection.isEmpty) {
                        self.editMode = false
                    }
                }
        }
    }
}

/// 展示收藏卡片
struct ShowLikeButton: View {
    @Binding var showLikeOnly: Bool
    
    var body: some View {
        Button(action: {
            self.showLikeOnly.toggle()
        }) {
            Image(systemName: self.showLikeOnly ? "star.fill": "star")
                .imageScale(.large)
                .foregroundColor(.yellow)
        }
    }
}

/// 右上角编辑按钮
struct EditingButton: View {
    @Binding var editMode: Bool
    // 选中卡片数组
    @Binding var selection: [Int]
    
    var body: some View {
        Button(action: {
            self.editMode.toggle()
            // 取消清空所有
            self.selection.removeAll()
        }) {
            Image(systemName: "gear")
                .imageScale(.large)
        }
    }
}

/// 右上角删除选中按钮
struct DeleteButton: View {
    // 选中卡片数组
    @Binding var selection: [Int]
    
    // 展示选择右上角编辑按钮
    @Binding var editMode: Bool
    
    @EnvironmentObject var userData: ToDo
    
    var body: some View {
        Button(action: {
            for i in self.selection {
                self.userData.delete(id: i)
            }
            if selection.isEmpty {
                self.editMode = false
            }
        }) {
            Image(systemName: "trash")
                .imageScale(.large)
        }
    }
}

struct SingleCardView: View {
    @EnvironmentObject var userData: ToDo
    
    // 是否显示编辑弹窗
    @State var showEditingPage: Bool = false
    // 右上角编辑按钮
    @Binding var editMode: Bool
    
    // 选中卡片数组
    @Binding var selection: [Int]
    
    var index: Int
    
    var body: some View {
        HStack {
            // 蓝色矩形
            Rectangle()
                .frame(width: 6)
                .foregroundColor(Color(self.userData.todoList[index].isFavorite ? "Favorite_Color" : "Default_Color"))
            
            // 如果处于编辑模式则显示删除按钮
            if(editMode) {
                Button(action: {
                    self.userData.delete(id: self.index)
                    self.editMode = false
                }) {
                    Image(systemName: "trash")
                        .imageScale(.large)
                        .padding(.leading)
                }
            }
            
            
            Button(action: {
                // 只有不是编辑状态下,才显示编辑界面
                if(!editMode) {
                    self.showEditingPage = true
                }
            }) {
                // 中间todo
                Group {
                    VStack(alignment: .leading, spacing: 6.0) {
                        Text(self.userData.todoList[index].title)
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                            .strikethrough(self.userData.todoList[index].isChecked)
                        Text(formatter.string(from: self.userData.todoList[index].duedate))
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
            }
            .sheet(isPresented: self.$showEditingPage, content: {
                EditingPage(title: self.userData.todoList[index].title,
                            duedate: self.userData.todoList[index].duedate,
                            isFavorite: self.userData.todoList[index].isFavorite,
                            id: self.index)
                    .environmentObject(self.userData)
            })
            
            
            // 收藏
            if (self.userData.todoList[index].isFavorite) {
                Image(systemName: "star.fill")
                    .imageScale(.large)
                    .foregroundColor(.yellow)
            }
            
            // 如果处于编辑模式则显示圆形按钮
            if(editMode) {
                Image(systemName: self.selection.firstIndex(where: {
                    $0 == self.index}) == nil ? "circle": "checkmark.circle.fill")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture {
                        // 查找当前id是否存在与选中数组中
                        let i = self.selection.firstIndex(where: {
                            $0 == self.index
                        })
                        if i == nil {
                            self.selection.append(self.index)
                        } else {
                            self.selection.remove(at: i!)
                        }
                    }
            } else {
                // 选择框
                Image(systemName: self.userData.todoList[index].isChecked ? "checkmark.square.fill" :"square")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture {
                        self.userData.check(id: index)
                    }
            }
            
        }.frame(height: 80)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10, x: 0, y: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(userData: ToDo(data: [
            SingleToDo(title: "Eat", duedate: Date(), isFavorite: false),
            SingleToDo(title: "Sleep", duedate: Date(), isFavorite: false)
        ]))
    }
}
