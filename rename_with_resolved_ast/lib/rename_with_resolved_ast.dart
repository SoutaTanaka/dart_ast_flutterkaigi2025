import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

class MethodCallCollector extends RecursiveAstVisitor<void> {
  final List<SyntacticEntity> methodNames = [];

  MethodCallCollector();

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final element = node.methodName.element;

    if (element is MethodElement) {
      final methodName = element.name;
      final enclosingElement = element.enclosingElement;

      // 指定されたクラスのメソッドかチェック
      if (enclosingElement is ClassElement &&
          enclosingElement.name == 'InkJetPrinter' &&
          methodName == 'print') {
        methodNames.add(node.methodName);
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // メソッド宣言も書き換えれるように
    final element = node.declaredFragment?.element;
    if (element is MethodElement) {
      final methodName = element.name;
      final enclosingElement = element.enclosingElement;

      // 指定されたクラスのメソッドかチェック
      if (enclosingElement is ClassElement &&
          enclosingElement.name == 'InkJetPrinter' &&
          methodName == 'print') {
        methodNames.add(node.name);
      }
    }

    super.visitMethodDeclaration(node);
  }
}

Future<void> main() async {
  final targetPath = File('lib/target_source.dart').absolute.path;
  final sourceCode = await File(targetPath).readAsString();
  final collection = AnalysisContextCollection(
    includedPaths: [Directory(targetPath).parent.path],
  );
  final context = collection.contextFor(targetPath);
  final result =
      await context.currentSession.getResolvedUnit(targetPath)
          as ResolvedUnitResult;

  final unit = result.unit;
  final collector = MethodCallCollector();
  unit.accept(collector);
  print('${collector.methodNames.length} 件のInkJetPrinter.printの呼び出しが見つかりました！');
  for (final methodCall in collector.methodNames) {
    print('オフセット: ${methodCall.offset}');
  }

  final methodCalls = collector.methodNames;
  // 編集後のソースコードを構築するためのStringBuffer
  final buffer = StringBuffer();
  int lastOffset = 0;

  // visitorが収集したmethodCallsはソースコード内の順序でない可能性があるため、オフセットでソート
  methodCalls.sort((a, b) => a.offset.compareTo(b.offset));

  for (var call in methodCalls) {
    // MethodInvocationからmethodNameの部分のAstNodeを取得
    final methodName = call;
    // オフセットと長さを取得
    final offset = methodName.offset;
    final length = methodName.length;

    //元のソースコードの、最後に追加した位置から現在のprint呼び出しの直前までを追加
    buffer.write(sourceCode.substring(lastOffset, offset));

    // 'print'を'log.info'に置き換え
    buffer.write('printout');

    // lastOffsetを更新
    lastOffset = offset + length;
  }

  // Add remaining text
  buffer.write(sourceCode.substring(lastOffset));
  final modifiedSourceCode = buffer.toString();
  print('修正後のソースコード:\n$modifiedSourceCode');
}
