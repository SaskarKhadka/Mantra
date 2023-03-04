enum TokenType {
  // Operators
  PLUS,
  MINUS,
  MUL,
  DIV,
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
  TRUE,
  NULL,
  FALSE,
  OR,
  AND,

  // LITERALS
  STRING,
  NUMBER,
  IDENTIFIER,

  EOF
}

final List<String> keywords = [
  TokenType.VAR.name,
  TokenType.FOR.name,
  TokenType.WHILE.name,
  TokenType.IF.name,
  TokenType.ELSEIF.name,
  TokenType.ELSE.name,
  TokenType.FUNC.name,
  TokenType.PRINT.name,
  TokenType.TRUE.name,
  TokenType.NULL.name,
  TokenType.FALSE.name,
  TokenType.OR.name,
  TokenType.AND.name,
];
