import 'dart:io';
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
  List<Map<String, dynamic>> body = [];
  int _currIndex = -1;

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

  getToken() {
    /*
    Gets the next token and next lexeme in the input code
    puts it in _nextToken and _nextLexeme
    */
    _currIndex++;
    if (_currIndex < _tokens.length) {
      _nextToken = _tokens[_currIndex]["token"];
      _nextLexeme = _tokens[_currIndex]["lexeme"];
    } else {
      _nextLexeme = null;
      _nextToken = null;
    }
  }

  createAST() {
    /*
     Creates the abstract synatx tree of the tokens
     */
    getToken();
    while (_nextToken != TokenType.EOF) {
      Map<String, dynamic> result = stmt();
      body.add(result);
      if (_nextToken != TokenType.EOF) getToken();
    }
    _parseTree["body"] = body;
  }

  stmt() {
    /*
    Cerates AST for different types of statements
    Returns a node for the said statement
     */
    var result;
    if (_nextToken == TokenType.IDENTIFIER) {
      // Assignment type
      result = assignment();
      return checkSemiColon(result);
    } else if (_nextToken == TokenType.VAR) {
      // Variable decleration type
      result = varDecl();
      return checkSemiColon(result);
    } else if (_nextToken == TokenType.IF) {
      // If statement
      getToken();
      result = ifStmt();
      return result;
    } else if (_nextToken == TokenType.WHILE) {
      // While statement
      getToken();
      result = whileStmt();
      return result;
    } else if (_nextToken == TokenType.FOR) {
      // For statement
      getToken();
      result = forStmt();
      return result;
    }
  }

  forStmtInit() {
    /*
    Parses the initialization statement of a for loop
     */
    switch (_nextToken) {
      case TokenType.VAR:
        return checkSemiColon(varDecl());
      case TokenType.IDENTIFIER:
        return checkSemiColon(assignment());
      default:
        print("Invalid initialization condition in for loop");
        exit(0);
    }
  }

  forStmtTest() {
    /*
    Parses the test statement of a for loop
     */
    return checkSemiColon(boolean1());
  }

  forStmtUpdate() {
    /*
    Parses the update statement of a for loop
     */
    if (_nextToken == TokenType.IDENTIFIER) {
      var result = assignment();
      print(result);
      return result;
    } else {
      print("invalid update value in for loop");
      exit(0);
    }
  }

  forStmt() {
    /*
    Creates the AST for for statements
    Returns a node for the for statement
     */
    if (_nextToken == TokenType.LPAREN) {
      Map<String, dynamic> forTree = {"type": "ForStatement"};
      getToken();
      forTree["init"] = forStmtInit();

      getToken();
      forTree["test"] = forStmtTest();

      getToken();
      forTree["update"] = forStmtUpdate();

      if (_nextToken != TokenType.RPAREN) {
        print("Closing paranthesis in for loop not found");
        exit(0);
      }

      getToken();
      if (_nextToken == TokenType.LCURL) {
        // Parse the block statements
        getToken();
        forTree["body"] = {
          "type": "BlockStatement",
          "body": blockStatements(),
        };
        return forTree;
      } else {
        print("Enclose block statements inside blocks {}");
        exit(0);
      }
    } else {
      print("Please insert the for loop parameters inside paranthesis");
      exit(0);
    }
  }

  whileStmt() {
    /*
    Creates the AST for while statements
    Returns a node for the while statement
     */
    if (_nextToken == TokenType.LPAREN) {
      Map<String, dynamic> ifTree = {"type": "WhileStatement"};
      // Parse test condition
      ifTree["test"] = boolean1();
      if (_nextToken == TokenType.LCURL) {
        // Parse block statements
        getToken();
        ifTree["body"] = {
          "type": "BlockStatement",
          "body": blockStatements(),
        };
        return ifTree;
      } else {
        print("Enclose block statements inside blocks {}");
        exit(0);
      }
    } else {
      print("Pleasse insert the while test condition inside paranthesis");
      exit(0);
    }
  }

  ifStmt() {
    /*
    Creates the AST for for statements
    Returns a node for the if statement
     */
    if (_nextToken == TokenType.LPAREN) {
      Map<String, dynamic> ifTree = {"type": "IfStatement"};

      // Parse test condition
      ifTree["test"] = boolean1();

      if (_nextToken == TokenType.LCURL) {
        // Parse block statements
        getToken();
        ifTree["consequent"] = {
          "type": "BlockStatement",
          "body": blockStatements(),
        };
        // Parse elseif or else statements
        ifTree["alternate"] = elseIf() ?? elseStmt();
        return ifTree;
      } else {
        print("Enclose block statements inside blocks {}");
        exit(0);
      }
    } else {
      print("Pleasse insert the if else test condition inside paranthesis");
      exit(0);
    }
  }

  elseIf() {
    /*
    Parses the elseif statements
     */
    if (_nextToken == TokenType.ELSEIF) {
      getToken();
      var elseIfTree = ifStmt();
      return elseIfTree;
    }
  }

  elseStmt() {
    /*
    Parses the else statement
     */
    if (_nextToken == TokenType.ELSE) {
      getToken();
      if (_nextToken == TokenType.LCURL) {
        getToken();
        return {"type": "BlockStatement", "body": blockStatements()};
      } else {
        print("Enclose block statements inside blocks {}");
        exit(0);
      }
    }
  }

  blockStatements() {
    /*
    Parses the block statements {}
    Returns a list of nodes for the statement types
     */
    var body = [];
    while (_nextToken != TokenType.EOF && _nextToken != TokenType.RCURL) {
      body.add(stmt());
      getToken();
    }
    if (_nextToken == TokenType.EOF) {
      print("Terminate gar na yar block lai } lekhera");
      exit(0);
    }
    getToken();
    return body;
  }

  checkSemiColon(Map<String, dynamic> result) {
    /*
    Checks if the statemnt ends with a semicolon or not
    Returns the statement node if it does else logs error and exits the program
     */
    if (_nextToken == TokenType.SEMI_COLON) {
      return result;
    } else {
      print("Invalid token semi colon le matra end hunxa");
      exit(0);
    }
  }

  varDecl() {
    /*
    Creates AST for varibale declaration statements
    Returns a node for the variable decleration type
     */
    getToken();
    if (_nextToken != TokenType.IDENTIFIER) {
      print("INvalid syntax for varibale decl");
      exit(0);
    }
    Map<String, dynamic>? tree = {
      "type": TreeNodeTypes.VariableDeclaration,
      "id": _nextLexeme,
    };
    getToken();
    if (_nextToken != TokenType.EQUAL) {
      print("INvalid syntax for varibale decl");
      exit(0);
    }
    getToken();
    // Parse the initialization statement
    if (_nextToken == TokenType.NULL) {
      tree["init"] = {"type": "Null", "value": "null"};
      getToken();
    } else {
      tree["init"] = boolean1();
    }
    return tree;
  }

  assignment() {
    /*
    Parses the assignment statements
    Returns a node for the assignemnt type
     */
    var lexeme = _nextLexeme;
    getToken();
    Map<String, dynamic>? left = {
      "type": TreeNodeTypes.Identifier,
      "value": lexeme,
    };
    if (_nextLexeme == "=") {
      var operator = _nextLexeme!;
      getToken();
      // Parse the update statement for the identifier
      var right = boolean1();

      left = {
        "type": TreeNodeTypes.Assignment,
        "left": left,
        "right": right,
        "operator": operator,
      };
    }
    return left;
  }

  boolean1() {
    /*
    Parses the boolean OR expressions (Lowest Precedence)
    Returns a node for the expression type
     */
    var left = boolean2();
    while (_nextLexeme == "or") {
      var operator = _nextLexeme!;
      getToken();
      var right = boolean2();

      left = {
        "type": TreeNodeTypes.LogicalExpression,
        "left": left,
        "right": right,
        "operator": operator,
      };
    }
    return left;
  }

  boolean2() {
    /*
    Parses the boolean AND expressions
    Returns a node for the expression type
     */
    var left = relational1();
    while (_nextLexeme == "and") {
      var operator = _nextLexeme!;
      getToken();
      var right = relational1();

      left = {
        "type": TreeNodeTypes.LogicalExpression,
        "left": left,
        "right": right,
        "operator": operator,
      };
    }
    return left;
  }

  relational1() {
    /*
    Parses the relational == and != expressions
    Returns a node for the expression type
     */
    var left = relational2();
    while (["==", "!="].contains(_nextLexeme)) {
      var operator = _nextLexeme!;
      getToken();
      var right = relational2();

      left = {
        "type": TreeNodeTypes.LogicalExpression,
        "left": left,
        "right": right,
        "operator": operator,
      };
    }
    return left;
  }

  relational2() {
    /*
    Parses the relational >, >=, < and <= expressions
    Returns a node for the expression type
     */
    var left = arithmetic1();
    while ([">", ">=", "<", "<="].contains(_nextLexeme)) {
      var operator = _nextLexeme!;
      getToken();
      var right = arithmetic1();

      left = {
        "type": TreeNodeTypes.LogicalExpression,
        "left": left,
        "right": right,
        "operator": operator,
      };
    }
    return left;
  }

  arithmetic1() {
    /*
    Parses the arithmetic + and - expressions
    Returns a node for the expression type
     */
    var left = arithmetic2();
    while ("+-".contains(_nextLexeme!)) {
      var operator = _nextLexeme!;
      getToken();
      var right = arithmetic2();

      left = {
        "type": TreeNodeTypes.BinaryExpression,
        "left": left,
        "right": right,
        "operator": operator,
      };
    }
    return left;
  }

  arithmetic2() {
    /*
    Parses the *, / and % expressions (Highest Precedence)
    Returns a node for the expression type
     */
    var left = factor();
    while ("*/%".contains(_nextLexeme!)) {
      var operator = _nextLexeme!;
      getToken();

      var right = factor();

      left = {
        "type": TreeNodeTypes.BinaryExpression,
        "left": left,
        "right": right,
        "operator": operator,
      };
    }
    return left;
  }

  factor() {
    /*
    Parses the identifiers, operators, paranthesis and boolean keywords
    Returns a node for the token type
     */
    switch (_nextToken) {
      case TokenType.IDENTIFIER:
        var lexeme = _nextLexeme;
        getToken();
        return {"type": TreeNodeTypes.Identifier, "value": lexeme};
      case TokenType.MINUS:
        getToken();
        var result = factor();
        return {
          "type": TreeNodeTypes.UnaryExpression,
          "prefix": true,
          "right": result,
          "operator": "-",
        };
      case TokenType.PLUS:
        getToken();
        var result = factor();
        // getToken();
        return {
          "type": TreeNodeTypes.UnaryExpression,
          "prefix": true,
          "right": result,
          "operator": "+",
        };
      case TokenType.NOT:
        getToken();
        var result = factor();
        return {
          "type": TreeNodeTypes.UnaryExpression,
          "prefix": true,
          "right": result,
          "operator": "!",
        };
      case TokenType.STRING:
        var lexeme = _nextLexeme;
        getToken();
        return {"type": TreeNodeTypes.String, "value": lexeme};
      case TokenType.NUMBER:
        var lexeme = _nextLexeme;
        getToken();
        return {"type": TreeNodeTypes.Number, "value": double.parse(lexeme!)};
      case TokenType.LPAREN:
        getToken();
        var intTree = boolean1();
        if (_nextToken == TokenType.RPAREN) {
          getToken();
          return intTree;
        }
        print('ERORORORORORORORORRORO Closing paranthesis khai vai?');
        exit(0);
      case TokenType.True:
        getToken();
        return {"type": TreeNodeTypes.Boolean, "value": "true"};
      case TokenType.False:
        getToken();
        return {"type": TreeNodeTypes.Boolean, "value": "false"};
      default:
        //TODO: Error
        print("ERROROROROOR Yellai ta chinina ta maile");
        exit(0);
    }
  }
}
