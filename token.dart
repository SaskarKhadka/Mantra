enum TokenType {
  // Operators
  PLUS,
  MINUS,
  MUL,
  DIV,
  MODULUS,
  LPAREN,
  RPAREN,
  SEMI_COLON,
  LCURL,
  RCURL,

  EQUAL,
  EQUALEQUAL,
  NOTEQUAL,
  NOT,
  GREATER,
  GTEQUAL,
  LESS,
  LESSEQUAL,

  // Keywords
  VAR,
  FOR,
  WHILE,
  IF,
  ELSEIF,
  ELSE,
  FUNC,
  PRINT,
  True,
  NULL,
  False,
  OR,
  AND,
  BREAK,
  CONTINUE,

  // LITERALS
  STRING,
  NUMBER,
  IDENTIFIER,

  EOF
}

final Map<String, dynamic> keywords = {
  "var": TokenType.VAR,
  "for": TokenType.FOR,
  "while": TokenType.WHILE,
  "if": TokenType.IF,
  "elseif": TokenType.ELSEIF,
  "else": TokenType.ELSE,
  "func": TokenType.FUNC,
  "print": TokenType.PRINT,
  "True": TokenType.True,
  "null": TokenType.NULL,
  "False": TokenType.False,
  "or": TokenType.OR,
  "and": TokenType.AND,
  "break": TokenType.BREAK,
  "continue": TokenType.CONTINUE,
};

enum TreeNodeTypes {
  /*
  Types of nodes in AST
  */
  String,
  Number,
  Identifier,
  Boolean,
  Null,
  Program,
  BinaryExpression,
  VariableDeclaration,
  Assignment,
  BlockStatement,
  UnaryExpression,
  LogicalExpression,
  IfStatement,
  ForStatement,
  WhileStatement,
  PrintStatement,
  BreakStatement,
  ContinueStatement
}

enum RunTimeTypes {
  Null,
  Number,
  Boolean,
  String,
}
