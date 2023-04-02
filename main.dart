import 'dart:io';
import 'interpreter.dart';
import 'parser.dart';
import 'scanner.dart';
import 'error.dart';

void main() async {
  // String a = "amama\naaa";
  // String b = "";
  // for (int i = 0; i < a.length; i++) {
  //   print(a[i]);
  // }
  try {
    String file = await File("main.mnt").readAsString();
    var scanner = Scanner(file);
    scanner.lexer();
    // print(scanner.tokens);
    var parser = Parser(scanner.tokens);
    parser.createAST();
    // print(parser.parseTree);
    var interpreter = Interpreter(parser.parseTree);
    interpreter.evaluateTree();
  } on InvalidCharacterError catch (ex) {
    printError(ex.asString);
  } on UnterminatedStringError catch (ex) {
    printError(ex.asString);
  } on InvalidNumericValueError catch (ex) {
    printError(ex.asString);
  } on SyntaxError catch (ex) {
    printError(ex.asString);
  } on TypeError catch (ex) {
    printError(ex.asString);
  } on UndeclaredVariableError catch (ex) {
    printError(ex.asString);
  } on MultipleDeclarationError catch (ex) {
    printError(ex.asString);
  } on RunTimeError catch (ex) {
    printError(ex.asString);
  } on StackOverflowError catch (ex) {
    printError(ex.toString());
  }
}
