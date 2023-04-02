import 'error.dart';
import 'token.dart';

class Parser {
  /*
  An abstraction of parser for the language
  It contains methods that creates the abstract synatx tree for the input program
  */
  List<Map<String, dynamic>> _tokens;
  TokenType? _nextToken;
  String? _nextLexeme;
  late Map<String, dynamic> _parseTree;
  List<Map<String, dynamic>> _body = [];
  int? _nextLine;
  int _currIndex = -1;
  late TokenType _nextStatement;

  Parser(this._tokens) {
    /*
     Constructor
     */
    _parseTree = {
      "type": TreeNodeTypes.Program,
    };
  }

  /*
  Getter for the abstract synatx tree
   */
  Map<String, dynamic> get parseTree => _parseTree;

  _getToken() {
    /*
    Gets the next token and next lexeme in the input code
    puts it in _nextToken and _nextLexeme
    */
    _currIndex++;
    if (_currIndex < _tokens.length) {
      _nextToken = _tokens[_currIndex]["token"];
      _nextLexeme = _tokens[_currIndex]["lexeme"];
      _nextLine = _tokens[_currIndex]["line"];
    } else {
      _nextLexeme = null;
      _nextToken = null;
      _nextLine = null;
    }
  }

  _peekNext() {
    /*
    Returns the next token to be used without updating _nextToken  
    */
    if (_currIndex + 1 < _tokens.length) {
      return _tokens[_currIndex + 1]["token"];
    } else {
      return null;
    }
  }

  _prevLineNumber() {
    /*
    Returns the line number of previous token
     */
    if (_currIndex != 0) {
      return _tokens[_currIndex - 1]["line"];
    } else {
      return -1;
    }
  }

  createAST() {
    /*
     Creates the abstract synatx tree of the tokens
     */
    _getToken();
    while (_nextToken != TokenType.EOF) {
      _nextStatement = _nextToken!;
      Map<String, dynamic> result = _stmt();
      _body.add(result);
      if (_nextToken != TokenType.EOF) _getToken();
    }
    _parseTree["body"] = _body;
  }

  _stmt() {
    /*
    Cerates AST for different types of statements
    Returns a node for the said statement
     */
    if (_nextToken == TokenType.IDENTIFIER) {
      // Assignment type
      return _checkSemiColon(_assignment());
    } else if (_nextToken == TokenType.VAR) {
      // Variable decleration type
      return _checkSemiColon(_varDecl());
    } else if (_nextToken == TokenType.IF) {
      // If statement
      _getToken();
      return _ifStmt();
    } else if (_nextToken == TokenType.WHILE) {
      // While statement
      _getToken();
      return _whileStmt();
    } else if (_nextToken == TokenType.FOR) {
      // For statement
      _getToken();
      return _forStmt();
    } else if (_nextToken == TokenType.PRINT) {
      _getToken();
      return _checkSemiColon(_printStmt());
    } else if (_nextToken == TokenType.BREAK) {
      return _checkSemiColon(_breakStmt());
    } else if (_nextToken == TokenType.CONTINUE) {
      return _checkSemiColon(_continueStatement());
    } else if (_nextToken == TokenType.RETURN) {
      return _checkSemiColon(_returnStatement());
    } else if (_nextToken == TokenType.FUNC) {
      _getToken();
      var result = _functionDeclerationStatement();
      return result;
    } else if (_nextToken == TokenType.CALL) {
      _getToken();
      return _checkSemiColon(_functionCallStatement());
    } else {
      throw SyntaxError("Invalid statement type", _nextLine!);
    }
  }

  _list() {
    Map<String, dynamic> listTree = {
      "type": TreeNodeTypes.List,
      "line": _nextLine,
    };
    List<dynamic> elements = [];
    while (_nextToken != TokenType.EOF && _nextToken != TokenType.RBRACKET) {
      elements.add(_boolean1());
      if (_nextToken == TokenType.COMMA) _getToken();
    }
    if (_nextToken == TokenType.EOF) {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("No closing bracket ] to match [", errorLine);
    }
    _getToken();
    listTree["value"] = elements;
    return listTree;
  }

  _functionCallArguments() {
    List<Map<String, dynamic>> args = [];

    while (_nextToken != TokenType.RPAREN && _nextToken != TokenType.EOF) {
      args.add(_boolean1());
      if (_nextToken == TokenType.COMMA) _getToken();

      if (args.length > 64) {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw MaxParametersExceeded(
            "There can only be a maximum of 64 parameters in a function",
            errorLine);
      }
    }
    if (_nextToken == TokenType.EOF) {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError(
          "Arguments in a function call must be enclosed inside paranthesis",
          errorLine);
    }
    return args;
  }

  _functionCallStatement() {
    Map<String, dynamic> funcCallTree = {
      "type": TreeNodeTypes.FunctionCall,
      "line": _nextLine,
    };
    if (_nextToken == TokenType.IDENTIFIER) {
      funcCallTree["function"] = _nextLexeme;
      _getToken();
      if (_nextToken == TokenType.LPAREN) {
        _getToken();
        funcCallTree["args"] = _functionCallArguments();
        _getToken();
        return funcCallTree;
      } else {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError("Invalid function call statement", errorLine);
      }
    } else {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("Invalid function call statement", errorLine);
    }
  }

  _functionParams() {
    List<Map<String, dynamic>> params = [];
    int defaultParamsCount = 0;
    bool defaultParamFound = false;
    while (true) {
      if (_nextToken == TokenType.IDENTIFIER) {
        if (_peekNext() == TokenType.EQUAL) {
          var result = _assignment();
          result["default"] = true;
          params.add(result);
          defaultParamsCount++;
          defaultParamFound = true;
        } else {
          if (defaultParamFound) {
            int errorLine =
                _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
            throw SyntaxError(
                "All parameters after a default parameter must also be a default parameter",
                errorLine);
          }
          var result = _factor();
          result["default"] = false;
          params.add(result);
        }
        if (params.length > 64) {
          int errorLine =
              _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
          throw MaxParametersExceeded(
              "There can only be a maximum of 64 parameters in a function",
              errorLine);
        }
        if (_nextToken == TokenType.RPAREN) {
          return {
            "params": params,
            "defaultParamsCount": defaultParamsCount,
          };
        } else if (_nextToken == TokenType.COMMA) {
          if (_peekNext() == TokenType.RPAREN) {
            _getToken();
            return {
              "params": params,
              "defaultParamsCount": defaultParamsCount,
            };
          }
          _getToken();
        } else {
          int errorLine =
              _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
          throw SyntaxError(
              "Paramters must be enclosed inside paranthesis and seperated by comma",
              errorLine);
        }
      } else if (_nextToken == TokenType.RPAREN) {
        return {
          "params": params,
          "defaultParamsCount": defaultParamsCount,
        };
      } else {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError("Invalid parameter decleration", errorLine);
      }
    }
  }

  _functionDeclerationStatement() {
    if (_nextToken == TokenType.IDENTIFIER) {
      if (keywords[_nextLexeme] != null) {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError(
            "'${_nextLexeme}' can't be used as an identifier because it's a keyword",
            errorLine);
      }
      Map<String, dynamic> funcDeclTree = {
        "type": TreeNodeTypes.FunctionDecleration,
        "line": _nextLine,
        "name": _nextLexeme,
      };
      _getToken();
      if (_nextToken == TokenType.LPAREN) {
        _getToken();
        // Parse parameters
        var result = _functionParams();
        funcDeclTree["params"] = result["params"];
        funcDeclTree["defaultParamsCount"] = result["defaultParamsCount"];

        _getToken();
        if (_nextToken == TokenType.LCURL) {
          // Parse block statements
          _getToken();
          funcDeclTree["body"] = {
            "type": TreeNodeTypes.BlockStatement,
            "body": _blockStatements(),
            "line": _nextLine,
          };
          return funcDeclTree;
        } else {
          int errorLine =
              _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
          throw SyntaxError(
              "Enclose block statements inside curly braces", errorLine);
        }
      }
    } else {
      var message = "Please insert a valid function name";
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError(message, errorLine);
    }
  }

  _breakStmt() {
    /*
    Parses break statement
     */
    if (_nextStatement == TokenType.FOR || _nextStatement == TokenType.WHILE) {
      _getToken();
      return {
        "type": TreeNodeTypes.BreakStatement,
        "line": _nextLine,
      };
    } else {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError(
          "A break statement can't be used outside of a loop", errorLine);
    }
  }

  _continueStatement() {
    /*
    Parses continue statement
     */
    if (_nextStatement == TokenType.FOR || _nextStatement == TokenType.WHILE) {
      _getToken();
      return {
        "type": TreeNodeTypes.ContinueStatement,
        "line": _nextLine,
      };
    } else {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError(
          "A continue statement can't be used outside of a loop", errorLine);
    }
  }

  _returnStatement() {
    /*
    Parses return statement
     */
    if (_nextStatement == TokenType.FUNC) {
      _getToken();
      return {
        "type": TreeNodeTypes.ReturnStatment,
        "line": _nextLine,
        "value": _boolean1(),
      };
    } else {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError(
          "A retrurn statement can't be used outside of a function", errorLine);
    }
  }

  _printStmt() {
    /*
    Parses the print statement
     */
    if (_nextToken == TokenType.LPAREN) {
      Map<String, dynamic> printTree = {
        "type": TreeNodeTypes.PrintStatement,
        "line": _nextLine,
      };
      printTree["value"] = _boolean1();
      return printTree;
    }
  }

  _forStmtInit() {
    /*
    Parses the initialization statement of a for loop
     */
    switch (_nextToken) {
      case TokenType.VAR:
        return _checkSemiColon(_varDecl());
      case TokenType.IDENTIFIER:
        if (_peekNext() == TokenType.SEMI_COLON) {
          return _checkSemiColon(_factor());
        } else if (_peekNext() == TokenType.EQUAL) {
          return _checkSemiColon(_assignment());
        } else {
          int errorLine =
              _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
          throw SyntaxError(
              "Invalid initialization statement in for loop", errorLine);
        }
      default:
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError(
            "Invalid initialization statement in for loop", errorLine);
    }
  }

  _forStmtTest() {
    /*
    Parses the test statement of a for loop
     */
    var res = _boolean1();
    if (_nextToken != TokenType.SEMI_COLON) {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("Invalid test condition in for loop", errorLine);
    } else
      return res;
  }

  _forStmtUpdate() {
    /*
    Parses the update statement of a for loop
     */
    if (_nextToken == TokenType.IDENTIFIER) {
      if (_peekNext() == TokenType.EQUAL) {
        return _assignment();
      }
    }
    int errorLine =
        _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
    throw SyntaxError("Invalid update statement in for loop", errorLine);
  }

  _forStmt() {
    /*
    Creates the AST for for statements
    Returns a node for the for statement
     */
    if (_nextToken == TokenType.LPAREN) {
      Map<String, dynamic> forTree = {
        "type": TreeNodeTypes.ForStatement,
        "line": _nextLine,
      };
      // forTree["scope"] = _symbolTable.allocate();
      _getToken();
      forTree["init"] = _forStmtInit();

      _getToken();
      forTree["test"] = _forStmtTest();

      _getToken();
      forTree["update"] = _forStmtUpdate();

      if (_nextToken != TokenType.RPAREN) {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError(
            "Closing paranthesis in for loop not found", errorLine);
      }

      _getToken();
      if (_nextToken == TokenType.LCURL) {
        // Parse the block statements
        _getToken();
        forTree["body"] = {
          "type": TreeNodeTypes.BlockStatement,
          "body": _blockStatements(),
          "line": _nextLine,
        };
        return forTree;
      } else {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError(
            "Enclose block statements inside blocks curly braces", errorLine);
      }
    } else {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError(
          "Insert the for loop parameters inside paranthesis", errorLine);
    }
  }

  _whileStmt() {
    /*
    Creates the AST for while statements
    Returns a node for the while statement
     */
    if (_nextToken == TokenType.LPAREN) {
      Map<String, dynamic> whileTree = {
        "type": TreeNodeTypes.WhileStatement,
        "line": _nextLine,
      };

      // Parse test condition
      _getToken();
      whileTree["test"] = _boolean1();

      if (_nextToken != TokenType.RPAREN) {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError("Invalid test condition for while loop", errorLine);
      }

      _getToken();
      if (_nextToken == TokenType.LCURL) {
        // Parse block statements
        _getToken();
        whileTree["body"] = {
          "type": TreeNodeTypes.BlockStatement,
          "body": _blockStatements(),
          "line": _nextLine,
        };
        return whileTree;
      } else {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError(
            "Enclose block statements inside curly braces", errorLine);
      }
    } else {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("Insert test condition inside paranthesis", errorLine);
    }
  }

  _ifStmt() {
    /*
    Creates the AST for for statements
    Returns a node for the if statement
     */
    if (_nextToken == TokenType.LPAREN) {
      Map<String, dynamic> ifTree = {
        "type": TreeNodeTypes.IfStatement,
        "line": _nextLine,
      };

      _getToken();
      // Parse test condition
      ifTree["test"] = _boolean1();

      if (_nextToken != TokenType.RPAREN) {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError("Invalid test condition for if statement", errorLine);
      }

      _getToken();

      if (_nextToken == TokenType.LCURL) {
        // Parse block statements
        _getToken();
        ifTree["consequent"] = {
          "type": TreeNodeTypes.BlockStatement,
          "body": _blockStatements(),
          "line": _nextLine,
        };
        // Parse elseif or else statements
        if (_peekNext() == TokenType.ELSE || _peekNext() == TokenType.ELSEIF) {
          _getToken();
          ifTree["alternate"] = _elseIf() ?? _elseStmt();
        }
        return ifTree;
      } else {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError(
            "Enclose block statements inside curly braces", errorLine);
      }
    } else {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("Insert test condition inside paranthesis", errorLine);
    }
  }

  _elseIf() {
    /*
    Parses the elseif statements
     */
    if (_nextToken == TokenType.ELSEIF) {
      _getToken();
      var elseIfTree = _ifStmt();
      return elseIfTree;
    }
  }

  _elseStmt() {
    /*
    Parses the else statement
     */
    if (_nextToken == TokenType.ELSE) {
      _getToken();
      if (_nextToken == TokenType.LCURL) {
        _getToken();
        return {
          "type": TreeNodeTypes.BlockStatement,
          "body": _blockStatements(),
          "line": _nextLine,
        };
      } else {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError(
            "Enclose block statements inside blocks curly braces", errorLine);
      }
    }
  }

  _blockStatements() {
    /*
    Parses the block statements {}
    Returns a list of nodes for the statement types
     */
    var body = [];
    while (_nextToken != TokenType.EOF && _nextToken != TokenType.RCURL) {
      body.add(_stmt());
      _getToken();
    }

    if (_nextToken == TokenType.EOF) {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("Unterminated block", errorLine);
    }
    return body;
  }

  _checkSemiColon(Map<String, dynamic> result) {
    /*
    Checks if the statemnt ends with a semicolon or not
    Returns the statement node if it does else logs error and exits the program
     */

    if (_nextToken == TokenType.SEMI_COLON) {
      return result;
    } else {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("Statements must end with semicolon ;", errorLine);
    }
  }

  _varDecl() {
    /*
    Creates AST for varibale declaration statements
    Returns a node for the variable decleration type
     */
    _getToken();

    var value;
    if (keywords[_nextLexeme] != null) {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError(
          "'${_nextLexeme}' can't be used as an identifier because it's a keyword",
          errorLine);
    }
    if (_nextToken != TokenType.IDENTIFIER) {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("Invalid syntax for varibale decleration", errorLine);
    }
    Map<String, dynamic>? tree = {
      "type": TreeNodeTypes.VariableDeclaration,
      "id": _nextLexeme,
      "line": _nextLine,
    };
    _getToken();
    if (_nextToken != TokenType.EQUAL) {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("Invalid syntax for variable declaration", errorLine);
    }
    _getToken();
    // Parse the initialization value
    if (_nextToken == TokenType.NULL) {
      value = {
        "type": TreeNodeTypes.Null,
        "value": null,
        "line": _nextLine,
      };
      tree["init"] = value;

      _getToken();
    } else {
      value = _boolean1();
      tree["init"] = value;
    }
    return tree;
  }

  _assignment() {
    /*
    Parses the assignment statements
    Returns a node for the assignemnt type
     */
    var lexeme = _nextLexeme;
    Map<String, dynamic>? left = {};
    if (_peekNext() == TokenType.LBRACKET) {
      _getToken();
      _getToken();
      left = {
        "type": TreeNodeTypes.MemeberAccessExpression,
        "value": lexeme,
        "line": _nextLine,
        "index": _boolean1(),
      };
      if (_nextToken != TokenType.RBRACKET) {
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError("Invalid memeber access expression", errorLine);
      }
      _getToken();
    } else {
      _getToken();
      left = {
        "type": TreeNodeTypes.Identifier,
        "value": lexeme,
        "line": _nextLine,
      };
    }
    if (_nextLexeme == "=") {
      var operator = _nextLexeme!;
      _getToken();
      // Parse the update value for the identifier
      var right = _boolean1();

      left = {
        "type": TreeNodeTypes.Assignment,
        "left": left,
        "right": right,
        "operator": operator,
        "line": _nextLine,
      };
    } else {
      int errorLine =
          _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      throw SyntaxError("Invalid syntax for assignment statement", errorLine);
    }
    return left;
  }

  _boolean1() {
    /*
    Parses the boolean OR expressions (Lowest Precedence)
    Returns a node for the expression type
     */
    var left = _boolean2();
    while (_nextLexeme == "or") {
      var operator = _nextLexeme!;
      _getToken();
      var right = _boolean2();

      left = {
        "type": TreeNodeTypes.LogicalExpression,
        "left": left,
        "right": right,
        "operator": operator,
        "line": _nextLine,
      };
    }
    return left;
  }

  _boolean2() {
    /*
    Parses the boolean AND expressions
    Returns a node for the expression type
     */
    var left = _relational1();
    while (_nextLexeme == "and") {
      var operator = _nextLexeme!;
      _getToken();
      var right = _relational1();

      left = {
        "type": TreeNodeTypes.LogicalExpression,
        "left": left,
        "right": right,
        "operator": operator,
        "line": _nextLine,
      };
    }
    return left;
  }

  _relational1() {
    /*
    Parses the relational == and != expressions
    Returns a node for the expression type
     */
    var left = _relational2();
    while (["==", "!="].contains(_nextLexeme)) {
      var operator = _nextLexeme!;
      _getToken();
      var right = _relational2();

      left = {
        "type": TreeNodeTypes.LogicalExpression,
        "left": left,
        "right": right,
        "operator": operator,
        "line": _nextLine,
      };
    }
    return left;
  }

  _relational2() {
    /*
    Parses the relational >, >=, < and <= expressions
    Returns a node for the expression type
     */
    var left = _arithmetic1();
    while ([">", ">=", "<", "<="].contains(_nextLexeme)) {
      var operator = _nextLexeme!;
      _getToken();
      var right = _arithmetic1();

      left = {
        "type": TreeNodeTypes.LogicalExpression,
        "left": left,
        "right": right,
        "operator": operator,
        "line": _nextLine,
      };
    }
    return left;
  }

  _arithmetic1() {
    /*
    Parses the arithmetic + and - expressions
    Returns a node for the expression type
     */
    var left = _arithmetic2();
    while ("+-".contains(_nextLexeme!)) {
      var operator = _nextLexeme!;
      _getToken();
      var right = _arithmetic2();

      left = {
        "type": TreeNodeTypes.BinaryExpression,
        "left": left,
        "right": right,
        "operator": operator,
        "line": _nextLine,
      };
    }
    return left;
  }

  _arithmetic2() {
    /*
    Parses the *, / and % expressions (Highest Precedence)
    Returns a node for the expression type
     */
    var left = _factor();
    while ("*/%".contains(_nextLexeme!)) {
      var operator = _nextLexeme!;
      _getToken();

      var right = _factor();

      left = {
        "type": TreeNodeTypes.BinaryExpression,
        "left": left,
        "right": right,
        "operator": operator,
        "line": _nextLine,
      };
    }
    return left;
  }

  _factor() {
    /*
    Parses the identifiers, operators, paranthesis and boolean keywords
    Returns a node for the token type
     */

    switch (_nextToken) {
      case TokenType.IDENTIFIER:
        var lexeme = _nextLexeme;
        if (_peekNext() == TokenType.LBRACKET) {
          _getToken();
          _getToken();
          Map<String, dynamic> result = {
            "type": TreeNodeTypes.MemeberAccessExpression,
            "value": lexeme,
            "index": _boolean1(),
            "line": _nextLine,
          };
          if (_nextToken != TokenType.RBRACKET) {
            int errorLine =
                _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
            throw SyntaxError("Invalid memeber access expression", errorLine);
          }
          _getToken();
          return result;
        }
        _getToken();
        return {
          "type": TreeNodeTypes.Identifier,
          "value": lexeme,
          "line": _nextLine,
        };
      // case TokenType.COMMA:
      //   if (_nextStatement != TokenType.CALL) {
      //     int errorLine =
      //         _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
      //     throw SyntaxError("Invalid token ${_nextLexeme}", errorLine);
      //   }
      //   _getToken();
      //   break;
      case TokenType.CALL:
        _getToken();
        return _functionCallStatement();
      case TokenType.MINUS:
        _getToken();
        var result = _factor();
        return {
          "type": TreeNodeTypes.UnaryExpression,
          "prefix": true,
          "right": result,
          "operator": "-",
          "line": _nextLine,
        };
      case TokenType.LBRACKET:
        _getToken();
        return _list();
      case TokenType.PLUS:
        _getToken();
        var result = _factor();
        return {
          "type": TreeNodeTypes.UnaryExpression,
          "prefix": true,
          "right": result,
          "operator": "+",
          "line": _nextLine,
        };
      case TokenType.NOT:
        _getToken();
        var result = _factor();
        return {
          "type": TreeNodeTypes.UnaryExpression,
          "prefix": true,
          "right": result,
          "operator": "!",
          "line": _nextLine,
        };
      case TokenType.STRING:
        var lexeme = _nextLexeme;
        _getToken();
        return {
          "type": TreeNodeTypes.String,
          "value": lexeme,
          "line": _nextLine,
        };
      case TokenType.NUMBER:
        var lexeme = _nextLexeme;
        _getToken();
        return {
          "type": TreeNodeTypes.Number,
          "value": double.parse(lexeme!),
          "line": _nextLine,
        };
      case TokenType.STRING:
        var lexeme = _nextLexeme;
        _getToken();
        return {
          "type": TreeNodeTypes.String,
          "value": lexeme!.toString(),
          "line": _nextLine,
        };
      case TokenType.LPAREN:
        _getToken();
        var intTree = _boolean1();
        if (_nextToken == TokenType.RPAREN) {
          _getToken();
          return intTree;
        }
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError("No closing paranthesis ) to match (", errorLine);
      case TokenType.True:
        _getToken();
        return {
          "type": TreeNodeTypes.Boolean,
          "value": true,
          "line": _nextLine,
        };
      case TokenType.False:
        _getToken();
        return {
          "type": TreeNodeTypes.Boolean,
          "value": false,
          "line": _nextLine,
        };
      case TokenType.NULL:
        _getToken();
        return {
          "type": TreeNodeTypes.Null,
          "value": null,
          "line": _nextLine,
        };
      default:
        int errorLine =
            _nextLine == _prevLineNumber() ? _nextLine : _prevLineNumber();
        throw SyntaxError("Invalid token ${_nextLexeme}", errorLine);
    }
  }
}
