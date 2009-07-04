package min.lang;

import java.util.Stack;

public class Scanner {
  final String input;
  Message root = null;
  Message message = null;
  Stack<Message> argStack = new Stack<Message>();
  Stack<Integer> indentStack = new Stack<Integer>();
  int currentIndent = 0;
  boolean inBlock = false;
  boolean debug = false;

  public Scanner(String input) {
    this.input = input;
  }

  %%{
    machine Scanner;
    
    action mark { mark = p; }
    
    newline     = "\r"? "\n" %{ lineno++; };
    indent      = "  " | "\t";
    block       = newline %mark indent+;
    whitespace  = " ";
    comment     = whitespace* "#" (any - newline)* newline;
    string      = ("'" (any - "'")* "'" )
                | ('"' (any - '"')* '"' );
    number      = [0-9]+;
    identifier  = ( alnum | "_" | "$" | "@" )+;
    operator    = "+" | "-" | "*" | "/" | "**" | "^" | "%"
                | "||" | "|" | "&&" | "&"
                | "<<"
                | "<=" | "<" | ">=" | ">"
                | "==" | "!=" | "!"
                | "=";
    terminator  = ";" | ".";
    symbol      = identifier | operator | terminator;
    
    main := |*
      # Indentation magic
      #":" block => {
      #  
      #}
      block  => {
        if (this.inBlock) {
          int indent = (te - mark) / 2;
          if (indent < currentIndent) { // dedent
            debugIndent(lineno, "-", indent);
            this.indentStack.pop();
            this.message = this.argStack.pop();
            if (this.argStack.empty()) this.inBlock = false;
            pushUniqueMessage(new Message("\n"));
          } else if (indent > currentIndent) { // indent
            debugIndent(lineno, "+", indent);
            this.indentStack.push(indent);
          } else { // same block
            debugIndent(lineno, "=", indent);
            pushUniqueMessage(new Message("\n"));
          }
          currentIndent = indent;
        } else {
          pushUniqueMessage(new Message("\n"));
        }
      };
      newline         => {
        if (!indentStack.empty()) {
          debugIndent(lineno, "-", 0);
          while (!this.indentStack.empty()) {
            this.indentStack.pop();
            this.message = this.argStack.pop();
          }
          currentIndent = 0;
          inBlock = false;
        }
        pushUniqueMessage(new Message("\n"));
      };
      
      # Ignored tokens
      whitespace;
      comment;
      
      # Symbols and literals
      string           => { pushMessage(new Message(getSlice(ts, te), MinObject.newString(getSlice(ts + 1, te - 1)))); };
      number           => { pushMessage(new Message(getSlice(ts, te), MinObject.newNumber(Integer.parseInt(getSlice(ts, te))))); };
      symbol           => { pushMessage(new Message(getSlice(ts, te))); };
      ":"              => { this.inBlock = true; this.argStack.push(this.message); this.message = null; };
      "(" terminator*  => { this.argStack.push(this.message); this.message = null; };
      "," terminator*  => { this.message = null; };
      ")"              => {
        if (this.argStack.empty())
          throw new ParsingException("Unmatched closing parenthesis at line " + lineno);
        this.message = this.argStack.pop();
      };
    *|;
    
    write data nofinal;
  }%%
  
  @SuppressWarnings("fallthrough")
  public Message scan() throws ParsingException {
    char[] data = input.toCharArray();
    int cs, top;
    int eof = data.length;
    int p = 0, pe = eof, ts = 0, te = 0, act = 0, mark = 0;
    int[] stack = new int[32];
    int lineno = 1;
    
    %% write init;
    %% write exec;
    
    if (cs == Scanner_error || p != pe) {
      // TODO Better error reporting
      throw new ParsingException(String.format("Syntax error at line %d around '%s...'", lineno, input.substring(p, Math.min(p+5, pe))));
    }
    
    if (!this.argStack.empty())
      throw new ParsingException(this.argStack.size() + " unclosed parenthesis at line " + lineno);
    
    return this.root;
  }
  
  private String getSlice(int start, int end) {
    return input.substring(start, end);
  }
  
  private Message pushMessage(Message m) {
    if (this.message != null)
      message.setNext(m);
    else if (!this.argStack.empty())
      this.argStack.peek().args.add(m);
      
    this.message = m;
    
    if (this.root == null) this.root = this.message;
    return m;
  }
  
  private Message pushUniqueMessage(Message m) {
    if (message != null && message.name.equals(m.name)) return message;
    return pushMessage(m);
  }
  
  private void debugIndent(int lineno, String action, int indent) {
    if (debug)
      System.out.println(String.format("[%2d] %s to %d was %d (indentStack: %d)", lineno-1, action, indent, currentIndent, indentStack.size()));
  }
}