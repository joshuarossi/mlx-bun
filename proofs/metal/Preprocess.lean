import metal.Lexer
namespace Metal

/-! # Metal preprocessor

Macro expansion over the lexer's tokens (C++ [cpp.replace]), by Prosser's
hide-set algorithm: every token carries the names of the macros whose
expansion produced it and is never expanded by one of them again. A
`#define` takes effect at its position and is removed; `#pragma` tokens
stay in the stream unexpanded.

* An object-like macro name is replaced by its body; a function-like one
  only when the next token is `(`: the arguments up to the matching `)`
  split at top-level commas, and each parameter in the body is replaced by
  its argument, macro-expanded on its own. The result is rescanned with the
  tokens after it, so a function-like name at its end may take its
  arguments from there.
* The hide set of an object-like expansion is the name's plus the name; of
  a function-like one, the name's intersected with the closing `)`'s, plus
  the name; argument tokens keep theirs, extended by that set.

Rejected (`none`): an `err` token; a body with `#` or `##`; repeated
parameter names; a redefinition; an argument count unlike the parameter
count (a parameterless macro takes `()`); an unterminated invocation; a
directive inside an invocation or right after a function-like name; a
pragma naming a macro (whether pragmas expand would matter); running out
of fuel. -/

structure Macro where
  name : List Char
  function : Bool
  params : List (List Char)
  body : List Tok

/-- A token and its hide set. -/
abbrev HTok := Tok × List (List Char)

def mem (n : List Char) : List (List Char) → Bool
  | m :: ms => charsBeq n m || mem n ms
  | [] => false

def lookup (n : List Char) : List Macro → Option Macro
  | m :: ms => bif charsBeq n m.name then some m else lookup n ms
  | [] => none

/-- The single-character punctuation `c`. -/
def isP (c : Char) : Tok → Bool
  | .punct [d] => Nat.beq c.toNat d.toNat
  | _ => false

def isDirective : Tok → Bool
  | .defineObject .. | .defineFunction .. | .pragma _ | .err _ => true
  | _ => false

/-- No `#`, `##` or `err` in a macro body. -/
def plainBody : List Tok → Bool
  | .punct p :: ts => !(charsBeq p ['#'] || charsBeq p ['#', '#']) && plainBody ts
  | .err _ :: _ => false
  | _ :: ts => plainBody ts
  | [] => true

def distinct : List (List Char) → Bool
  | p :: ps => !mem p ps && distinct ps
  | [] => true

def define (env : List Macro) (m : Macro) : Option (List Macro) :=
  bif (lookup m.name env).isSome || !plainBody m.body || !distinct m.params then none else some (m :: env)

def mentions (env : List Macro) : List Tok → Bool
  | .ident n :: ts => (lookup n env).isSome || mentions env ts
  | _ :: ts => mentions env ts
  | [] => false

/-- An invocation's arguments, the hide set of its closing `)`, and the
tokens after it. -/
structure Args where
  args : List (List HTok)
  close : List (List Char)
  rest : List HTok

/-- Arguments after the opening `(`: nesting depth, the current argument and
the earlier ones (both reversed). -/
def collect (depth : Nat) (cur : List HTok) (args : List (List HTok)) : List HTok → Option Args
  | [] => none
  | (t, hs) :: s =>
    bif isDirective t then none
    else bif isP ')' t then
      (bif Nat.beq depth 0 then some ⟨(cur.reverse :: args).reverse, hs, s⟩
       else collect (depth - 1) ((t, hs) :: cur) args s)
    else bif isP '(' t then collect (depth + 1) ((t, hs) :: cur) args s
    else bif isP ',' t && Nat.beq depth 0 then collect depth [] (cur.reverse :: args) s
    else collect depth ((t, hs) :: cur) args s

/-- `F()` passes one empty argument, which a parameterless macro accepts. -/
def arityOk : List (List Char) → List (List HTok) → Bool
  | [], [[]] => true
  | [], _ => false
  | ps, as => Nat.beq ps.length as.length

def paramIndex (n : List Char) : List (List Char) → Option Nat
  | p :: ps => bif charsBeq n p then some 0 else (paramIndex n ps).map (· + 1)
  | [] => none

def nth : List (List HTok) → Nat → List HTok
  | a :: _, 0 => a
  | _ :: as, i + 1 => nth as i
  | [], _ => []

def addHs (hs : List (List Char)) : List HTok → List HTok
  | (t, h) :: s => (t, h ++ hs) :: addHs hs s
  | [] => []

/-- A macro body with hide set `hs`, each parameter replaced by its argument
expanded by `ex`. -/
def subst (ex : List HTok → Option (List HTok)) (params : List (List Char)) (args : List (List HTok))
    (hs : List (List Char)) : List Tok → Option (List HTok)
  | [] => some []
  | t :: b =>
    match t with
    | .ident n =>
      match paramIndex n params with
      | some i => (ex (nth args i)).bind fun e => (subst ex params args hs b).map fun r => addHs hs e ++ r
      | none => (subst ex params args hs b).map ((t, hs) :: ·)
    | _ => (subst ex params args hs b).map ((t, hs) :: ·)

/-- Continuation of the expansion loop: macros, tokens to scan, output so far (reversed). -/
abbrev PK := List Macro → List HTok → List HTok → Option (List HTok)

/-- Identifier `t` named `n` with hide set `hs`, before tokens `s`. -/
def expandIdent (k : PK) (env : List Macro) (t : Tok) (n : List Char) (hs : List (List Char))
    (s acc : List HTok) : Option (List HTok) :=
  let ex := fun x => (k env x []).map List.reverse
  bif mem n hs then k env s ((t, hs) :: acc) else
  match lookup n env with
  | none => k env s ((t, hs) :: acc)
  | some m =>
    bif m.function then
      match s with
      | (u, _) :: s' =>
        bif isDirective u then none
        else bif isP '(' u then
          match collect 0 [] [] s' with
          | some a =>
            bif arityOk m.params a.args then
              (subst ex m.params a.args (n :: hs.filter (mem · a.close)) m.body).bind fun e => k env (e ++ a.rest) acc
            else none
          | none => none
        else k env s ((t, hs) :: acc)
      | [] => k env s ((t, hs) :: acc)
    else (subst ex [] [] (n :: hs) m.body).bind fun e => k env (e ++ s) acc

def expandStep (k : PK) (env : List Macro) : List HTok → List HTok → Option (List HTok)
  | [], acc => some acc
  | (t, hs) :: s, acc =>
    match t with
    | .ident n => expandIdent k env t n hs s acc
    | .defineObject n b => (define env ⟨n, false, [], b⟩).bind fun env' => k env' s acc
    | .defineFunction n ps b => (define env ⟨n, true, ps, b⟩).bind fun env' => k env' s acc
    | .pragma ts => bif mentions env ts then none else k env s ((t, hs) :: acc)
    | .err _ => none
    | _ => k env s ((t, hs) :: acc)

/-- One step per token scanned or macro expanded; an argument's expansion
runs on the remaining fuel. -/
def expand : Nat → PK
  | 0, _, _, _ => none
  | fuel + 1, env, s, acc => expandStep (expand fuel) env s acc

def ppFuel : Nat := 1048576

def unwind : List HTok → List Tok → List Tok
  | (t, _) :: acc, out => unwind acc (t :: out)
  | [], out => out

def preprocess (ts : List Tok) : Option (List Tok) :=
  (expand ppFuel [] (ts.map fun t => (t, [])) []).map fun acc => unwind acc []

theorem preprocess_err (cs : List Char) (ts : List Tok) : preprocess (.err cs :: ts) = none := rfl

theorem preprocess_nil : preprocess [] = some [] := rfl

end Metal
