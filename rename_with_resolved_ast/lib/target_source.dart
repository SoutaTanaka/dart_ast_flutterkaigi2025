// Dartでprinterを制御して印刷する
import 'dart:developer';

void main() async {
  final printText = 'print';
  final inkJetPrinter = InkJetPrinter();
  final laserPrinter = LaserPrinter();

  await inkJetPrinter.print(printText);
  await laserPrinter.print(printText);
}

class InkJetPrinter {
  Future<void> print(String message) async {
    await Future.delayed(Duration(seconds: 1));
    log('InjJet printing: $message');
  }

  Future<void> printMultiple(List<String> messages) async {
    for (final message in messages) {
      await print(message);
    }
  }
}

class LaserPrinter {
  Future<void> print(String message) async {
    await Future.delayed(Duration(seconds: 1));
    log('Laser printing: $message');
  }

  Future<void> printMultiple(List<String> messages) async {
    for (final message in messages) {
      await print(message);
    }
  }
}