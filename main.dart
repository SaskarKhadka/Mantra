import 'dart:io';
import 'parser.dart';
import 'scanner.dart';
import 'error.dart';

void main() async {
  try {
    // var scanner = Scanner(
    //     'if main == "saskar"#hiiama a   i\n #-hahah\nwhat\nklalk-#{int a = 5;\nprint(a);\n}');
    String file = await File("main.mnt").readAsString();
    var scanner = Scanner(file);
    scanner.lexer();
    // print(scanner.tokens);
    var parser = Parser(scanner.tokens);
    parser.createAST();
    print(parser.parseTree);
  } on Error catch (ex) {
    print(ex.asString);
  }
}
