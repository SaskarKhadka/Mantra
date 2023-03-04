enum ErrorType {
  // Error types
  InvalidCharacter,
  InavlidNumericValue,
  UnterminatedString,
}

class Error {
  /*
  Defines different errors in the language 
  */
  late ErrorType _type;
  late String _message;
  late int _line;
  late int _col;

  /*
  Constructor
  */
  Error(this._type, this._message, this._line, this._col) {}

  /* 
  Stringigy the error
  */
  String get asString =>
      "At line ${_line}, column ${_col}\n${_type.name}: ${_message}";
}
