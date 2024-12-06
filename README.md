# github_users

A modular iOS application built with UIKit, following Clean Architecture & MVVM-C pattern principles.

## 🏗 Architecture Overview

This project implements a modular clean architecture combined with Clean Architecture principles and MVVM-C pattern for the presentation layer.

### Requirements
- iOS 13.0+
- Xcode 15+
- CocoaPods

## 📦 Module Structure

### 🎯 Main App
- **TymeX** - Main application target integrating all modules

### 🔨 Core Modules
#### Domain
- Business models
- Use cases
- Repository interfaces
- Business rules & logic

#### AppShared
- Common utilities
- Shared extensions
- Base components
- Common protocols

#### DesignSystem
- Reusable UI components
- Typography
- Color schemes
- Layout constants

#### Coordinator
- Navigation management
- Flow coordination
- Deep linking handling
- Screen routing

### 💾 Data Layer
#### NetworkService
- API client
- Network requests/responses
- DTOs
- Network error handling
- ✅ Comprehensive test coverage

#### LocalStorage
- Data persistence
- Caching logic
- CoreData management
- ✅ Full test suite

#### Data
- Repository implementations
- Data mapping
- CRUD operations
- Cache strategies

### 🎪 Feature Modules
#### Users
- User List
- User Detail
- ✅ Feature-specific tests

![IMG_2969](https://github.com/user-attachments/assets/1f1dfda8-2a95-465b-9ece-a6d6ef5084c4)
![IMG_2970](https://github.com/user-attachments/assets/19b466df-01d8-43b1-9773-b077ae4f3a69)

## Installation
1. Clone the repository
2. Run `pod install` in the project directory
3. Open the `.xcworkspace` file

