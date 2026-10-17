namespace Host.Ts

/-! JavaScript-subset syntax after TypeScript erasure, as Bun's transpiler
emits it. Names and literal text are character lists, not `String`: kernel
reduction of `String` operations decodes UTF-8 bytes and is prohibitively
slow. String, number and template literals keep their raw source text;
escape decoding and numeric conversion belong to the semantics. -/

abbrev Name := List Char

inductive BinOp where
  | add | sub | mul | div | mod | exp | shl | shr | ushr | band | bor | bxor
  | lt | gt | le | ge | eq | ne | seq | sne | inst | in_

inductive LogOp where | and | or | nullish

inductive AsgOp where
  | assign | bin (op : BinOp) | log (op : LogOp)

inductive UnOp where | neg | pos | not | bnot | typeof | void | delete

/-- `regex` keeps a regular-expression literal's raw pattern and flags. -/
inductive Lit where
  | num (raw : List Char) | big (raw : List Char) | str (raw : List Char)
  | bool (b : Bool) | null | regex (pattern flags : List Char)

/-- `using` and `await using` are declaration kinds, as in ESTree. -/
inductive DeclKind where | var | let_ | const | using | awaitUsing

inductive MethodKind where | method | get | set

mutual
inductive Expr where
  | lit (l : Lit)
  | id (n : Name)
  | this | super
  /-- Raw quasis (one more than substitutions); `tag` for tagged templates. -/
  | template (tag : Option Expr) (quasis : List (List Char)) (subs : List Expr)
  | array (elems : List Elem)
  | object (props : List Property)
  | func (f : Func)
  | arrow (f : Func)
  | cls (c : Class)
  | member (obj : Expr) (prop : Name) (optional : Bool)
  | priv (obj : Expr) (prop : Name) (optional : Bool)
  | index (obj prop : Expr) (optional : Bool)
  | call (callee : Expr) (args : List Elem) (optional : Bool)
  | new (callee : Expr) (args : List Elem)
  /-- Optional-chain boundary: an absent `?.` link short-circuits to here. -/
  | chain (e : Expr)
  | unary (op : UnOp) (e : Expr)
  | update (inc pre : Bool) (target : Expr)
  | bin (op : BinOp) (a b : Expr)
  | log (op : LogOp) (a b : Expr)
  | cond (c a b : Expr)
  | assign (op : AsgOp) (target : Pat) (value : Expr)
  | seq (a b : Expr)
  | yield (arg : Option Expr) (delegate : Bool)
  | await (e : Expr)

/-- Array elements and call arguments. -/
inductive Elem where | hole | expr (e : Expr) | spread (e : Expr)

inductive Key where
  | id (n : Name) | str (raw : List Char) | num (raw : List Char)
  | priv (n : Name) | computed (e : Expr)

inductive Property where
  | init (k : Key) (v : Expr)
  | short (n : Name)
  | method (kind : MethodKind) (k : Key) (f : Func)
  | spread (e : Expr)

inductive Pat where
  | id (n : Name)
  /-- Member target of an assignment. -/
  | expr (e : Expr)
  | array (elems : List (Option Pat)) (rest : Option Pat)
  | object (props : List (Key × Pat)) (rest : Option Pat)
  | dflt (p : Pat) (d : Expr)

inductive Body where | block (ss : List Stmt) | expr (e : Expr)

/-- `props` lists constructor parameter properties (`private x`), which
erasure turns into `this.x = x` assignments. -/
inductive Func where
  | mk (name : Option Name) (params : List Pat) (rest : Option Pat) (body : Body)
      (async generator : Bool) (props : List Name)

inductive Member where
  | ctor (f : Func)
  | method (static : Bool) (kind : MethodKind) (k : Key) (f : Func)
  | field (static : Bool) (k : Key) (init : Option Expr)
  | block (ss : List Stmt)

inductive Class where
  | mk (name : Option Name) (super : Option Expr) (members : List Member)

inductive ForHead where
  | decl (kind : DeclKind) (ds : List (Pat × Option Expr))
  | expr (e : Expr)

inductive Stmt where
  | expr (e : Expr)
  | decl (kind : DeclKind) (ds : List (Pat × Option Expr))
  | func (f : Func)
  | cls (c : Class)
  /-- `const` enums are inlined by Bun; both kinds are member tables. -/
  | enum (const : Bool) (name : Name) (members : List (Key × Option Expr))
  | ret (e : Option Expr)
  | if_ (c : Expr) (t : Stmt) (e : Option Stmt)
  | block (ss : List Stmt)
  | for_ (init : Option ForHead) (test update : Option Expr) (body : Stmt)
  | forOf (await : Bool) (kind : Option DeclKind) (p : Pat) (e : Expr) (body : Stmt)
  | forIn (kind : Option DeclKind) (p : Pat) (e : Expr) (body : Stmt)
  | while_ (c : Expr) (body : Stmt)
  | doWhile (body : Stmt) (c : Expr)
  | switch (d : Expr) (cases : List (Option Expr × List Stmt))
  | try_ (b : List Stmt) (handler : Option (Option Pat × List Stmt))
      (finalizer : Option (List Stmt))
  | throw (e : Expr)
  | break (label : Option Name)
  | continue (label : Option Name)
  | labeled (l : Name) (s : Stmt)
  | empty
end

inductive Spec where
  /-- `import d`, `import * as ns`, `import {a as b}` (imported, local). -/
  | default (local_ : Name) | ns (local_ : Name) | named (imported local_ : Name)

/-- Module items after erasure. Type-only imports/exports and specifiers
are removed; `export` wraps the exported declaration. -/
inductive Item where
  | stmt (s : Stmt)
  | import_ (specs : List Spec) (src : List Char)
  | export_ (s : Stmt)
  | exportDefault (e : Expr)
  | exportNamed (specs : List (Name × Name)) (src : Option (List Char))
  | exportAll (ns : Option Name) (src : List Char)

abbrev Module := List Item

end Host.Ts
