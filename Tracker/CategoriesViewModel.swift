


import Foundation

final class CategoriesViewModel {
    let categoryStore: TrackerCategoryStore
    
    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet { onCategoriesChanged?() }
    }
    
    private(set) var selectedIndex: Int? {
        didSet { onCategoriesChanged?() }
    }
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
        fetchCategories()
    }
    
    func fetchCategories() {
        categories = categoryStore.fetchCategories()
    }
    
    func addNewCategory(title: String) {
        do {
            try categoryStore.addNewCategory(title: title)
        } catch {
            print("Ошибка добавления категории: \(error)")
        }
    }
    
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedIndex = index
        onCategorySelected?(categories[index])
    }
    
    func category(at index: Int) -> TrackerCategory {
        categories[index]
    }
    
    func isSelected(at index: Int) -> Bool {
        index == selectedIndex
    }
    
    var isEmpty: Bool {
        categories.isEmpty
    }
    
    var numberOfCategories: Int {
        categories.count
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate() {
        fetchCategories()
    }
}
