import 'constants.dart';
import 'error.dart';
import 'token.dart';

class Scanner {
  /*
  An abstraction of lexical analyzer for the language
  */
  late String _code;
  int _line = 1;
  int _handlePos = -1;
  List<Map<String, dynamic>> _tokens = [];
  String? _nextChar;
  String _lexeme = "";

  Scanner(this._code) {
    /*
    Constructor
    */
    _nextChar = null;
  }

  // Getter for tokens
  List<Map<String, dynamic>> get tokens => _tokens;

  _getChar() {
    /*
    Gets the next character in the input code
    puts it in nextChar
    */
    _handlePos++;
    _nextChar = _handlePos < _code.length ? _code[_handlePos] : null;
  }

  lexer() {
    /*
    Lexical analyzer
    */
    _getChar();
    while (_nextChar != null) {
      _tokenize();
      _clearLexeme();
    }
    _tokens.add({"token": TokenType.EOF, "lexeme": "END"});
  }

  _updateLexeme() {
    /*
    Updates value of _lexeme with _nextChar
    */
    _lexeme += _nextChar!;
  }

  _clearLexeme() {
    /*
    Sets empty string to _lexeme
    */
    _lexeme = "";
  }

  _tokenize() {
    /*
    _tokenizes the given input
    */
    if (_isalpha()) {
      // If the character is a letter, determine the identifier or keyword
      _determineIdentifierOrKeyword();
      var keyword = keywords[_lexeme];
      _tokens.add({
        "token": keyword == null ? TokenType.IDENTIFIER : keyword,
        "lexeme": _lexeme,
        "line": _line,
      });
    } else if (_isdigit()) {
      // If the character is a digit, determine the number
      _determineNumber();
      _tokens.add({
        "token": TokenType.NUMBER,
        "lexeme": _lexeme,
        "line": _line,
      });
    } else if (_nextChar == '"') {
      // If the character is a double quote, determine the string
      _determineString();
      _tokens.add({
        "token": TokenType.STRING,
        "lexeme": _lexeme,
        "line": _line,
      });
    } else if (_nextChar == " " ||
        _nextChar == "\t" ||
        _nextChar == "\n" ||
        _nextChar == "\r") {
      if (_nextChar == "\n") {
        _line += 1;
      }
      _getChar();
    } else if (_nextChar == "=") {
      _updateLexeme();
      var initialLexeme = _lexeme;
      _getChar();
      // If the character is =, determine if it is ASSIGNMENT or EQUALITY operator
      if (_nextChar == "=") {
        _tokens.add({
          "token": TokenType.EQUALEQUAL,
          "lexeme": "==",
          "line": _line,
        });
        _getChar();
      } else
        _tokens.add({
          "token": TokenType.EQUAL,
          "lexeme": initialLexeme,
          "line": _line,
        });
    } else if (_nextChar == "!") {
      _updateLexeme();
      var initialLexeme = _lexeme;
      _getChar();
      // If the character is !, determine if it is NOT or NOT EQUAL operator
      if (_nextChar == "=") {
        _tokens.add({
          "token": TokenType.NOTEQUAL,
          "lexeme": "!=",
          "line": _line,
        });
        _getChar();
      } else
        _tokens.add({
          "token": TokenType.NOT,
          "lexeme": initialLexeme,
          "line": _line,
        });
    } else if (_nextChar == ">") {
      _updateLexeme();
      var initialLexeme = _lexeme;
      _getChar();
      // If the character is >, determine if it is GREATER THAN or GREATER THAN OR EQUAL operator
      if (_nextChar == "=") {
        _tokens.add({
          "token": TokenType.GTEQUAL,
          "lexeme": ">=",
          "line": _line,
        });
        _getChar();
      } else
        _tokens.add({
          "token": TokenType.GREATER,
          "lexeme": initialLexeme,
          "line": _line,
        });
    } else if (_nextChar == "<") {
      _updateLexeme();
      var initialLexeme = _lexeme;
      _getChar();
      // If the character is <, determine if it is LESS THAN or LESS THAN OR EQUAL operator
      if (_nextChar == "=") {
        _tokens.add({
          "token": TokenType.LESSEQUAL,
          "lexeme": "<=",
          "line": _line,
        });
        _getChar();
      } else
        _tokens.add({
          "token": TokenType.LESS,
          "lexeme": initialLexeme,
          "line": _line,
        });
    }
    // Similarly, _tokenize all the operators
    else if (_nextChar == "(") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.LPAREN,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else if (_nextChar == ")") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.RPAREN,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else if (_nextChar == "{") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.LCURL,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else if (_nextChar == "}") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.RCURL,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else if (_nextChar == "+") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.PLUS,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else if (_nextChar == "-") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.MINUS,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else if (_nextChar == "*") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.MUL,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else if (_nextChar == "/") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.DIV,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else if (_nextChar == "%") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.MODULUS,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else if (_nextChar == ";") {
      _updateLexeme();
      _tokens.add({
        "token": TokenType.SEMI_COLON,
        "lexeme": _lexeme,
        "line": _line,
      });
      _getChar();
    } else {
      if (_nextChar == "#") {
        // If the character is #, check if it is a one line(#) or multiline comment(#-, -#)
        _getChar();
        if (_nextChar == "-") {
          // If multiline comment skip multiple lines until -#
          String? prev = "#";
          while (prev! + _nextChar! != "-#") {
            prev = _nextChar;
            if (_nextChar == "\n") _line++;
            _getChar();
          }
        } else {
          // If one line comment skip the line
          while (_nextChar != "\n") {
            _getChar();
          }
          _line++;
        }
        _getChar();
      } else {
        _updateLexeme();
        _getChar();
        // Returns error if unknown character is encountered
        return InvalidCharacterError(
            "Are you fucking kiddig me with ${_lexeme}?", _line);
      }
    }
  }

  _determineString() {
    /*
    Determines the string values in the input
    */
    _updateLexeme();
    _getChar();
    while (_nextChar != null && _nextChar != '"') {
      _updateLexeme();
      _getChar();
    }

    if (_nextChar == null) {
      throw UnterminatedStringError("Terminate gar na yar string lai", _line);
    } else {
      _updateLexeme();
      _getChar();
    }
  }

  _determineIdentifierOrKeyword() {
    /*
    Determines the identifiers and keywords in the input
    */
    while (_nextChar != null && _isalphanumeric()) {
      _updateLexeme();
      _getChar();
    }
  }

  _determineNumber() {
    /*
    Determines the numeric values in the input
    */
    while (_nextChar != null && (_nextChar == "." || _isdigit())) {
      if (_nextChar == "." && _isdecimal()) {
        throw InvalidNumericValueError("K garxas ae", _line);
      } else {
        _updateLexeme();
        _getChar();
      }
    }
  }

  bool _isalpha() {
    /*
    Checks if _nextChar is a letter or not
    */
    return letters.contains(_nextChar!);
  }

  bool _isdigit() {
    /*
    Checks if _nextChar is a digit or not
    */
    return numbers.contains(_nextChar!);
  }

  bool _isalphanumeric() {
    /*
    Checks if _nextChar is alphanumeric or not
    */
    return _isdigit() || _isalpha();
  }

  bool _isdecimal() {
    /*
    Checks if the numeric value in _lexeme is a decimal or not
    */
    var value = double.parse(_lexeme);
    return value.floor() != value;
  }
}
