# Dart AST とその活用 - FlutterKaigi 2025

このリポジトリは、**FlutterKaigi 2025**のセッション「Dart AST とその活用」で使用したデモコードです。  
DartのAST（抽象構文木）を解析・活用する方法を段階的に紹介しています。

## 📋 目次

- [環境構築](#環境構築)
- [ディレクトリ構成](#ディレクトリ構成)
- [実行方法](#実行方法)
- [各デモの説明](#各デモの説明)

## 🛠 環境構築

本リポジトリは [fvm](https://fvm.app/) を利用してDartのバージョン管理を行っています。

### 必要なツール

- [fvm](https://fvm.app/)
- Dart（fvm経由でインストール）

### セットアップ手順

1. **fvmをインストール**  
   ```sh
   brew tap leoafarias/fvm
   brew install fvm
   ```

2. **Dartのバージョンをセットアップ**  
   プロジェクトルートで以下を実行
   ```sh
   fvm install
   fvm use
   ```

3. **依存関係をインストール**  
   ルートディレクトリで以下を実行
    ```sh
    fvm dart pub get
   ```

## 📁 ディレクトリ構成

```
dart_ast_flutterkaigi2025/
├── search_print/              # デモ1: ASTを使った検索
│   ├── lib/
│   │   └── search_print.dart  # print関数の呼び出しを検索
│   ├── analysis_options.yaml
│   └── pubspec.yaml
│
├── rename_print/              # デモ2: ASTを使った置換（基本）
│   ├── lib/
│   │   └── rename_print.dart  # print関数をlog.infoに置換
│   ├── analysis_options.yaml
│   └── pubspec.yaml
│
├── rename_with_resolved_ast/  # デモ3: Resolved ASTを使った高度な置換
│   ├── lib/
│   │   ├── rename_with_resolved_ast.dart  # 特定クラスのメソッドのみ置換
│   │   └── target_source.dart             # 解析対象のソースコード
│   ├── analysis_options.yaml
│   └── pubspec.yaml
│
├── pubspec.yaml
└── README.md
```

## 🚀 実行方法

各デモは独立して実行できます。プロジェクトルートから以下のコマンドで実行してください。

### デモ1: print関数の検索
```sh
fvm dart run search_print/lib/search_print.dart
```

### デモ2: print関数の置換（基本）
```sh
fvm dart run rename_print/lib/rename_print.dart
```

### デモ3: 特定クラスのメソッドのみ置換（Resolved AST）
```sh
fvm dart run rename_with_resolved_ast/lib/rename_with_resolved_ast.dart
```

## 📚 各デモの説明

### 1. `search_print/` - ASTを使った検索

**目的**: ASTを使ってコード内の`print`関数の呼び出しを検索し、その位置情報を取得する

**主なポイント**:
- `parseString`を使った簡易的なAST生成
- `RecursiveAstVisitor`を使ったAST探索
- `visitMethodInvocation`でメソッド呼び出しをキャッチ
- オフセットやライン情報の取得

### 2. `rename_print/` - ASTを使った置換（基本）

**目的**: `print`関数を`log.info`に自動置換する

**主なポイント**:
- AST情報を元にしたコード書き換え
- オフセットを使った文字列操作
- `StringBuffer`を使った効率的な文字列構築


### 3. `rename_with_resolved_ast/` - Resolved ASTを使った高度な置換

**目的**: 特定のクラス（`InkJetPrinter`）の`print`メソッドのみを`printout`に置換する

**主なポイント**:
- `AnalysisContextCollection`を使ったResolved ASTの生成
- 型情報を使った精密な解析
- `Element`を使ったクラスやメソッドの識別
- メソッド宣言とメソッド呼び出しの両方を置換
