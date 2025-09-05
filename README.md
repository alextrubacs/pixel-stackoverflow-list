# Pixel StackOverflow List

A modern iOS application that displays a list of users from Stack Overflow API with follow/unfollow functionality.

## 🏗️ Architecture

### Project Structure
```
pixel-stackoverflow-list/
├── Delegates/               # App lifecycle delegates
├── Enums/                   # Configuration and identifiers
├── Models/                  # Data models
├── Services/                # Business logic and API calls
├── ViewModels/              # MVVM view models
├── Views/                   # UIKit view controllers and cells
├── Resources/               # Assets and storyboards
└── pixel-stackoverflow-listTests/
    ├── MockImageLoader.swift
    ├── MockUserFetchingService.swift
    ├── UserCellViewModelTests.swift
    └── UserListViewModelTests.swift
```

## 🛠️ Technical Decisions

### MVVM Architecture
For this project I used MVVM as requested, although I would have gone with it myself. MVVM with UIKit allows to clearly separate the business logic away from view controllers and using programmatic UI, keep ViewControllers relatively lighter.

### Protocol-Oriented Design
- Using protocols to make code testable and comprehensible
- UserFetchingService is broken down into multiple concise protocols to isolate functionality so it's easily testable and replaceable

### Development Approach
- Tried to make changes in small PR's logically separated, for ease of review

### Actor Consideration
Thought of using actor for the UserFetchingService, whilst not specifically necessary for a lightweight application as such and since URLSession and Decoder already work on the background thread it's introducing minimal benefit. However if used it clearly communicates the threading intent of the class, that all should be happening on the background. Future proofs it. One could argue that it's adding unnecessary complexity, since it's introducing actor hopping, so decision was made not to use it.

### UITableViewDiffableDataSource
Used UITableViewDiffableDataSource instead of the old UITableView's traditional data source:
- ✅ Automatic animations: Smooth insertions/deletions
- ✅ Thread-safe: Can update from background threads
- ✅ Efficient: Only processes changes
- ✅ Less boilerplate: No numberOfSections, numberOfRowsInSection, cellForRowAt
- ✅ Better performance: Optimized diffing algorithm

## 🧪 Testing

- 87% test coverage
- Comprehensive unit tests for ViewModels and business logic
- Mock services for isolated testing

## 🚀 Getting Started

### Prerequisites
- Xcode 16+ with iOS 18.5 SDK
- Swift 6 compiler

### Installation
1. Clone the repository
2. Open `pixel-stackoverflow-list.xcodeproj` in Xcode
3. Build and run on simulator or device

## 📋 Future Improvements

### High Priority
- **Separate Loading/Empty States**: Currently empty state displays loading indicator, ideally needs to be separated into empty state view and loading state view
- **Progress Bar**: Replace circular progress with progress bar when users are loading
- **Pull to Refresh**: Add manual data refresh capability

### Medium Priority
- **Component Breakdown**: Break down views into separate components to decrease ViewController size
- **User Detail View**: Add detailed user profile screen
- **Advanced Error Handling**: Enhanced error recovery and offline support
- **UITests**: Add UI test coverage

### Low Priority
- **Haptics & Animations**: Add haptic feedback and more polished animations
- **Styling Improvements**: Enhanced visual design and theming
- **Search/Filter**: Add user search and filtering capabilities

## 🔧 Technologies Used

- **Swift 6** with modern concurrency
- **UIKit** with programmatic UI
- **SwiftData** for local persistence
- **Swift Testing** framework
- **MVVM** architecture pattern

---

**Built with Swift 6 and iOS 18.5**
