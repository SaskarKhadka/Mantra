import 'constants.dart';
import 'error.dart';
import 'token.dart';

class Scanner {
  /*
  An abstraction of lexical analyzer for the language
  */
  late String _code;
  int _line = 1;
  int _col = -1;
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

  getChar() {
    /*
    Gets the next character in the input code
    puts it in nextChar
    */
    _col++;
    _handlePos++;
    _nextChar = _handlePos < _code.length ? _code[_handlePos] : null;
  }

  lexer() {
    /*
    Lexical analyzer
    */
    getChar();
    while (_nextChar != null) {
      // updateLexeme();
      // print(
      //     "Next Char: ${_nextChar == ' ' ? 'space' : _nextChar == "\n" ? 'nextline' : _nextChar}");
      Error? error = tokenize();
      if (error != null) throw error;
      clearLexeme();
      // print(
      //     "Lexeme: ${_lexeme == ' ' ? 'space' : _lexeme == "\n" ? 'nextline' : _lexeme}");

    }
    _tokens.add({"token": TokenType.EOF, "lexeme": "END"});
  }

  updateLexeme() {
    /*
    Updates value of _lexeme with _nextChar
    */
    _lexeme += _nextChar!;
  }

  clearLexeme() {
    /*
    Sets empty string to _lexeme
    */
    _lexeme = "";
  }

  tokenize() {
    /*
    Tokenizes the given input
    */
    if (isalpha()) {
      // If the character is a letter, determine the identifier or keyword
      Error? error = determineIdentifierOrKeyword();
      var keywordIndex = keywords.indexOf(_lexeme.toUpperCase());

      _tokens.add({
        "token":
            keywordIndex == -1 ? TokenType.IDENTIFIER : keywords[keywordIndex],
        "lexeme": _lexeme,
      });
      return error;
    } else if (isdigit()) {
      // If the character is a digit, determine the number
      Error? error = determineNumber();
      _tokens.add({"token": TokenType.NUMBER, "lexeme": _lexeme});
      return error;
    } else if (_nextChar == '"') {
      // If the character is a double quote, determine the string
      Error? error = determineString();
      _tokens.add({"token": TokenType.STRING, "lexeme": _lexeme});
      return error;
    } else if (_nextChar == " " || _nextChar == "\t" || _nextChar == "\n") {
      if (_nextChar == "\n") {
        _line += 1;
        _col = 0;
      }
      getChar();
    } else if (_nextChar == "=") {
      updateLexeme();
      getChar();
      updateLexeme();
      // If the character is =, determine if it is ASSIGNMENT or EQUALITY operator
      if (_nextChar == "=")
        _tokens.add({"token": TokenType.EQUALEQUAL, "lexeme": _lexeme});
      else
        _tokens.add({"token": TokenType.EQUAL, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == "!") {
      updateLexeme();
      getChar();
      updateLexeme();
      // If the character is !, determine if it is NOT or NOT EQUAL operator
      if (_nextChar == "=")
        _tokens.add({"token": TokenType.NOTEQUAL, "lexeme": _lexeme});
      else
        _tokens.add({"token": TokenType.NOT, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == ">") {
      updateLexeme();
      getChar();
      updateLexeme();
      // If the character is >, determine if it is GREATER THAN or GREATER THAN OR EQUAL operator
      if (_nextChar == "=")
        _tokens.add({"token": TokenType.GTEQUAL, "lexeme": _lexeme});
      else
        _tokens.add({"token": TokenType.GREATER, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == "<") {
      updateLexeme();
      getChar();
      updateLexeme();
      // If the character is <, determine if it is LESS THAN or LESS THAN OR EQUAL operator
      if (_nextChar == "=")
        _tokens.add({"token": TokenType.LESSEQUAL, "lexeme": _lexeme});
      else
        _tokens.add({"token": TokenType.LESS, "lexeme": _lexeme});
      getChar();
    }
    // Similarly, tokenize all the operators
    else if (_nextChar == "(") {
      updateLexeme();
      _tokens.add({"token": TokenType.LPAREN, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == ")") {
      updateLexeme();
      _tokens.add({"token": TokenType.RPAREN, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == "{") {
      updateLexeme();
      _tokens.add({"token": TokenType.LCURL, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == "}") {
      updateLexeme();
      _tokens.add({"token": TokenType.RCURL, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == "+") {
      updateLexeme();
      _tokens.add({"token": TokenType.PLUS, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == "-") {
      updateLexeme();
      _tokens.add({"token": TokenType.MINUS, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == "*") {
      updateLexeme();
      _tokens.add({"token": TokenType.MUL, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == "/") {
      updateLexeme();
      _tokens.add({"token": TokenType.DIV, "lexeme": _lexeme});
      getChar();
    } else if (_nextChar == ";") {
      updateLexeme();
      _tokens.add({"token": TokenType.SEMI_COLON, "lexeme": _lexeme});
      getChar();
    } else {
      if (_nextChar == "#") {
        // If the character is #, check if it is a one line(#) or multiline comment(#-, -#)
        getChar();
        if (_nextChar == "-") {
          // If multiline comment skip multiple lines until -#
          String? prev = "#";
          while (prev! + _nextChar! != "-#") {
            prev = _nextChar;
            getChar();
          }
        } else {
          // If one line comment skip the line
          while (_nextChar != "\n") {
            getChar();
          }
        }
        getChar();
      } else {
        updateLexeme();
        getChar();
        // Returns error if unknown character is encountered
        return Error(ErrorType.InvalidCharacter,
            "Are you fucking kiddig me with ${_lexeme}?", _line, _col);
      }
    }
  }

  determineString() {
    /*
    Determines the string values in the input
    */
    updateLexeme();
    getChar();
    while (_nextChar != null && _nextChar != '"') {
      updateLexeme();
      getChar();
    }

    if (_nextChar == null) {
      return Error(ErrorType.UnterminatedString,
          "Terminate gar na yar string lai", _line, _col);
    } else {
      updateLexeme();
      getChar();
    }
  }

  determineIdentifierOrKeyword() {
    /*
    Determines the identifiers and keywords in the input
    */
    while (_nextChar != null && isalphanumeric()) {
      updateLexeme();
      getChar();
    }
  }

  determineNumber() {
    /*
    Determines the numeric values in the input
    */
    while (_nextChar != null && (_nextChar == "." || isdigit())) {
      if (_nextChar == "." && isdecimal()) {
        return Error(ErrorType.InavlidNumericValue, "K garxas ae", _line, _col);
      } else {
        updateLexeme();
        getChar();
      }
    }
  }

  bool isalpha() {
    /*
    Checks if _nextChar is a letter or not
    */
    return letters.contains(_nextChar!);
  }

  bool isdigit() {
    /*
    Checks if _nextChar is a digit or not
    */
    return numbers.contains(_nextChar!);
  }

  bool isalphanumeric() {
    /*
    Checks if _nextChar is alphanumeric or not
    */
    return isdigit() || isalpha();
  }

  bool isdecimal() {
    /*
    Checks if the numeric value in _lexeme is a decimal or not
    */
    var value = double.parse(_lexeme);
    return value.floor() != value;
  }
}
