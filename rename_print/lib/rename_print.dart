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
  final sourceCode = '''
// Dartでprinterを制御して印刷する
void main() async {
  final printText = 'print';
  var printer = Printer();
  await printer.print(printText);
  print('print(Done!)');
}
''';

  // 編集後のソースコードを構築するためのStringBuffer
  final buffer = StringBuffer();

  final visitor = PrintCallVisitor();

  final compilationUnit = parseString(content: sourceCode).unit;
  compilationUnit.accept(visitor);
  final methodCalls = visitor.methodCalls
    ..sort((a, b) => a.methodName.offset.compareTo(b.methodName.offset));
  // 直前にbufferに追加したコードのオフセットを保持する変数
  int lastOffset = 0;
  for (var call in methodCalls) {
    //元のソースコードのprint以外のソースコードをbufferに追加
    buffer.write(sourceCode.substring(lastOffset, call.methodName.offset));
    // 'print'の代わりに'log.info'をbufferに追加
    buffer.write('log.info');
    // 次のループでprintの次からをbufferに追加できるようにoffsetをずらす
    lastOffset = call.methodName.length + call.methodName.offset;
  }
  // 最後のprintより後のコードをbufferに追加
  buffer.write(sourceCode.substring(lastOffset));

  print('修正後のソースコード:\n${buffer.toString()}');
}
