import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

class InkJetPrintVisitor extends RecursiveAstVisitor<void> {
  final List<SyntacticEntity> methodNames = [];

  InkJetPrintVisitor();

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final element = node.methodName.element;
    if (element is MethodElement && node.methodName.name == 'print') {
      final enclosingElement = element.enclosingElement;
      // 指定されたクラスのメソッドかチェック
      if (enclosingElement is ClassElement &&
          enclosingElement.name == 'InkJetPrinter') {
        methodNames.add(node.methodName);
      }
    }
    super.visitMethodInvocation(node);
  }

  // メソッド宣言も書き換えれるように
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final element = node.declaredFragment?.element;
    if (element is MethodElement && element.name == 'print') {
      final enclosingElement = element.enclosingElement;
      // 指定されたクラスのメソッドかチェック
      if (enclosingElement is ClassElement &&
          enclosingElement.name == 'InkJetPrinter') {
        methodNames.add(node.name);
      }
    }
    super.visitMethodDeclaration(node);
  }
}

Future<void> main() async {
  // Resolved ASTを生成する
  final targetPath = File('lib/target_source.dart').absolute.path;
  final collection = AnalysisContextCollection(
    includedPaths: [Directory(targetPath).parent.path],
  );
  final context = collection.contextFor(targetPath);
  final result =
      await context.currentSession.getResolvedUnit(targetPath)
          as ResolvedUnitResult;
  final unit = result.unit;

  final visitor = InkJetPrintVisitor();
  unit.accept(visitor);

  final methodNames = visitor.methodNames
    ..sort((a, b) => a.offset.compareTo(b.offset));

  final sourceCode = await File(targetPath).readAsString();
  final buffer = StringBuffer();
  int lastOffset = 0;
  for (var call in methodNames) {
    //元のソースコードのprint以外のソースコードをbufferに追加
    buffer.write(sourceCode.substring(lastOffset, call.offset));
    // 'print'の代わりに'printout'をbufferに追加
    buffer.write('printout');
    // 次のループでprintの次からをbufferに追加できるようにoffsetをずらす
    lastOffset = call.length + call.offset;
  }
  // 最後のprintより後のコードをbufferに追加
  buffer.write(sourceCode.substring(lastOffset));

  print('修正後のソースコード:\n${buffer.toString()}');
}
