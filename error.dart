void printError(String text) {
  // Prints out the text in red colour
  print('\x1B[31m$text\x1B[0m');
}

enum ErrorType {
  // Error types
  InvalidCharacterError,
  InavlidNumericValueError,
  UnterminatedStringError,
  SyntaxError,
  TypeError,
  UndeclaredVariableError,
  MultipleDeclarationError,
}

class Error {
  /*
  Defines error in the language 
  */
  late ErrorType _type;
  late String _message;
  late int _line;

  /*
  Constructor
  */
  Error(this._type, this._message, this._line) {}

  /* 
  Stringigy the error
  */
  String get asString => "At line ${_line}, \n${_type.name}: ${_message}";
}

class InvalidNumericValueError extends Error {
  InvalidNumericValueError(String message, int line)
      : super(ErrorType.InavlidNumericValueError, message, line);
}

class UnterminatedStringError extends Error {
  UnterminatedStringError(String message, int line)
      : super(ErrorType.UnterminatedStringError, message, line);
}

class InvalidCharacterError extends Error {
  InvalidCharacterError(String message, int line)
      : super(ErrorType.InvalidCharacterError, message, line);
}

class SyntaxError extends Error {
  SyntaxError(String message, int line)
      : super(ErrorType.SyntaxError, message, line);
}

class TypeError extends Error {
  TypeError(String message, int line)
      : super(ErrorType.TypeError, message, line);
}

class UndeclaredVariableError extends Error {
  UndeclaredVariableError(String message, int line)
      : super(ErrorType.TypeError, message, line);
}

class MultipleDeclarationError extends Error {
  MultipleDeclarationError(String message, int line)
      : super(ErrorType.TypeError, message, line);
}
