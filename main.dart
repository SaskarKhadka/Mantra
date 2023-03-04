import 'scanner.dart';
import 'error.dart';

void main() {
  try {
    var scanner = Scanner(
        'if main == "saskar"#hiiama a   i\n #-hahah\nwhat\nklalk-#{int a = 5;\nprint(a);\n}');
    scanner.lexer();
    print(scanner.tokens);
  } on Error catch (ex) {
    print(ex.asString);
  }
}
