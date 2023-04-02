import 'error.dart';

class SymbolTableNode {
  /*
  Represents a scope in the symbol table
   */

  // Represents the parent scope
  SymbolTableNode? parent;

  // Stores the variable in the scope
  late Map<String, Map<String, dynamic>> vars;

  SymbolTableNode() {
    vars = {};
  }
}

class SymbolTable {
  /*
  An abstraction of symbol table for the language
  It contains methods that can used to maintain scopes of variables
   */

  late SymbolTableNode _latestScope;

  SymbolTable() {
    /*
    Constrcutor
     */
    _latestScope = SymbolTableNode();
  }

  free() {
    /*
    Removes all entries and frees storage of current scope
    Resets the latest scope to its parent
    */
    SymbolTableNode parent = _latestScope.parent!;
    _latestScope.vars = {};
    _latestScope.parent = null;
    _latestScope = parent;
  }

  allocate() {
    /*
    Allocates a new symbol table
     */
    SymbolTableNode newNode = SymbolTableNode();
    newNode.parent = _latestScope;
    _latestScope = newNode;
    return _latestScope;
  }

  lookup(String variable, int line) {
    /*
    Searches the variable name,
    Returns the environment of the variable
     */
    SymbolTableNode? temp = _latestScope;
    while (temp != null) {
      if (temp.vars[variable] != null) {
        return temp.vars[variable];
      }
      temp = temp.parent;
    }

    if (temp == null) {
      throw UndeclaredVariableError(
          "Variable '${variable}' has not been declared", line);
    }
  }

  insert(String variable, Map<String, dynamic> value, int line) {
    /*
    Inserts the variable and its value in the symbol table,
    Returns the value of the variable
     */
    if (!_latestScope.vars.containsKey(variable)) {
      _latestScope.vars[variable] = value;
      return _latestScope;
    } else {
      throw MultipleDeclarationError(
          "Variable '${variable}' is already declared in this scope", line);
    }
  }

  setAttribute(String variable, Map<String, dynamic> value, int line) {
    /*
    Updates the variable with given name,
    Returns the new value of the variable
     */
    SymbolTableNode? temp = _latestScope;
    while (temp != null) {
      if (temp.vars[variable] != null) {
        temp.vars[variable] = value;
        break;
      }
      temp = temp.parent;
    }

    if (temp == null) {
      throw UndeclaredVariableError(
          "Variable '${variable}' has not been declared", line);
    }
  }
}
