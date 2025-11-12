import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class PrintCallVisitor extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> methodCalls = [];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // 'print'関数の呼び出しかチェック
    if (node.methodName.name == 'print' && node.target == null) {
      methodCalls.add(node);
    }
    super.visitMethodInvocation(node);
  }
}

void main() {
  final sorceCode = '''
// Dartでprinterを制御してprintする
void main() async {
  final printText = 'print';
  final printer = Printer();
  await printer.print(printText);
  print('print(Done!)');
}
''';

  final compilationUnit = parseString(content: sorceCode).unit;

  final visitor = PrintCallVisitor();
  compilationUnit.accept(visitor);

  final methodCalls = visitor.methodCalls;
  print('${methodCalls.length} 件のPrintの呼び出しが見つかりました！');
  for (final call in methodCalls.indexed) {
    print('呼び出し ${call.$1 + 1} 箇所目');
    print('オフセット: ${call.$2.offset}');
    print('ライン情報: ${compilationUnit.lineInfo.getLocation(call.$2.offset)}');
  }
}
