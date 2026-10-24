namespace Metal

/-! # Metal syntax

Parsed, untyped syntax of the Metal Shading Language subset in the route's
assembled kernel sources (proofs/metal/Parser.lean): kernel header, MLX's
generated template line, signature and body, and MLX's explicit
instantiation. Names keep their source spelling, including `metal::`
qualification; typedef resolution, template instantiation, implicit
conversions and overload choice belong to elaboration, not to this tree.

Equality is the Bool `beq` of each type (nested and mutual types derive no
`DecidableEq`), structural so the kernel reduces it. -/

inductive Space where
  | device | constant | threadgroup | thread
deriving DecidableEq, Repr, Inhabited

/-- A type as written: `const`, an address space (both before the name, in
either order), a name (`float`, `uint4`, `T`, `bfloat16_t`, `auto`, `void`,
`simdgroup_float8x8`; `metal::` qualification dropped), and a pointer
declarator `*`. `const` qualifies the named type, so the pointee of a pointer.
`metal::vec<T, n>` is the name `T` with `vec = some n`. -/
structure TypeSpec where
  const : Bool := false
  space : Option Space := none
  name : List Char
  pointer : Bool := false
  vec : Option Nat := none
deriving DecidableEq, Repr, Inhabited

inductive UnOp where
  /-- `-e`, `!e`, `~e`, `*e`, `&e`. -/
  | neg | not | bitNot | deref | addr
deriving DecidableEq, Repr, Inhabited

inductive BinOp where
  | mul | div | mod | add | sub | shl | shr | lt | le | gt | ge | eq | ne
  | bitAnd | bitXor | bitOr | and | or
deriving DecidableEq, Repr, Inhabited

/-- How a cast was written: `(T)e`, `T(e)`, `static_cast<T>(e)`. -/
inductive CastStyle where
  | c | functional | static
deriving DecidableEq, Repr, Inhabited

mutual
/-- Explicit template argument: a type or a constant expression. -/
inductive TArg where
  | type (t : TypeSpec)
  | expr (e : Expr)
deriving Repr, Inhabited

inductive Expr where
  | int (value : Nat) (unsigned long hex : Bool)
  | float (mantissa : Nat) (exponent : Int) (single : Bool)
  | bool (value : Bool)
  /-- Possibly qualified name: `x`, `metal::simd_sum`, `mem_flags::mem_threadgroup`. -/
  | name (path : List (List Char))
  | unary (op : UnOp) (e : Expr)
  | binary (op : BinOp) (a b : Expr)
  /-- `=` (`op = none`) or compound assignment `op=`. -/
  | assign (op : Option BinOp) (target value : Expr)
  /-- `++`/`--`, prefix (`before`) or postfix. -/
  | step (increment before : Bool) (e : Expr)
  | cond (c a b : Expr)
  /-- Call, with explicit template arguments (`f<T, BITS>(…)`, `as_type<float>(…)`). -/
  | call (callee : Expr) (targs : List TArg) (args : List Expr)
  | index (array index : Expr)
  /-- Member access `.x`, `.y`, `.z`. -/
  | member (e : Expr) (field : List Char)
  /-- A functional cast's type is a bare name. -/
  | cast (style : CastStyle) (t : TypeSpec) (e : Expr)
  /-- `a, b` (in a `for` step). -/
  | comma (a b : Expr)
deriving Repr, Inhabited
end

/-- Declarator initializer: `= e` or `= {e, …}`. -/
inductive Init where
  | expr (e : Expr)
  | braces (elements : List Expr)
deriving Repr, Inhabited

/-- One declarator: name, array extents (`t[16]`, `ld[U][NL]`), initializer. -/
structure Declarator where
  name : List Char
  extents : List Expr := []
  init : Option Init := none
deriving Repr, Inhabited

/-- `#pragma clang loop unroll(full)` and `#pragma clang loop unroll_count(n)`. -/
inductive LoopHint where
  | unrollFull
  | unrollCount (n : Nat)
deriving DecidableEq, Repr, Inhabited

inductive Stmt where
  /-- Declaration: `constexpr` as written, the shared type, the declarators.
  A pointer type has exactly one declarator (`*` binds to the first). -/
  | decl (constexpr : Bool) (t : TypeSpec) (declarators : List Declarator)
  | expr (e : Expr)
  | block (body : List Stmt)
  | ite (c : Expr) (thenBranch : Stmt) (elseBranch : Option Stmt)
  /-- `for (init; condition; step) body`; `init` is a declaration or an
  expression statement. -/
  | loop (init : Option Stmt) (condition : Option Expr) (step : Option Expr) (body : Stmt)
  | continue_ | break_
  | ret (value : Option Expr)
  /-- A loop hint before a `for` statement (or before another hint). -/
  | pragma (hint : LoopHint) (body : Stmt)
  /-- `if constexpr (c) …`: only the branch the constant `c` selects is instantiated. -/
  | ifConstexpr (c : Expr) (thenBranch : Stmt) (elseBranch : Option Stmt)
  | empty
deriving Repr, Inhabited

/-- Parameter attribute: `[[buffer(i)]]` or a built-in (`[[thread_position_in_grid]]`). -/
inductive Attr where
  | buffer (index : Nat)
  | builtin (name : List Char)
deriving DecidableEq, Repr, Inhabited

/-- `type [&] name [[attr]]`. -/
structure Param where
  t : TypeSpec
  reference : Bool := false
  name : List Char
  attr : Option Attr := none
deriving DecidableEq, Repr, Inhabited

/-- `typename T`, `int N`, `bool B`, `uint U`. -/
inductive TParam where
  | type (name : List Char)
  | int (name : List Char)
  | bool (name : List Char)
  | uint (name : List Char)
deriving DecidableEq, Repr, Inhabited

/-- `[template <…>] [[[kernel]]] {static|inline}* result name(params) { body }`. -/
structure Func where
  tparams : List TParam := []
  /-- `[[kernel]]` attribute. -/
  kernel : Bool := false
  /-- `static`, `inline` as written. -/
  specifiers : List (List Char) := []
  result : TypeSpec
  name : List Char
  params : List Param
  body : List Stmt
deriving Repr, Inhabited

inductive Top where
  | func (f : Func)
  /-- `template [[host_name("h")]] [[kernel]] decltype(f<…>) f<…>;` with the
  same name and arguments in both places. -/
  | instantiate (hostName : List Char) (name : List Char) (targs : List TArg)
deriving Repr, Inhabited

/-! ## Equality -/

mutual
def TArg.beq : TArg → TArg → Bool
  | .type a, .type b => decide (a = b)
  | .expr a, .expr b => Expr.beq a b
  | _, _ => false
termination_by structural a _ => a

def TArg.beqs : List TArg → List TArg → Bool
  | [], [] => true
  | a :: as, b :: bs => TArg.beq a b && TArg.beqs as bs
  | _, _ => false
termination_by structural as _ => as

def Expr.beq : Expr → Expr → Bool
  | .int v u l h, .int v' u' l' h' => decide (v = v') && u == u' && l == l' && h == h'
  | .float m e s, .float m' e' s' => decide (m = m') && decide (e = e') && s == s'
  | .bool a, .bool b => a == b
  | .name p, .name q => decide (p = q)
  | .unary o a, .unary o' a' => decide (o = o') && Expr.beq a a'
  | .binary o a b, .binary o' a' b' => decide (o = o') && Expr.beq a a' && Expr.beq b b'
  | .assign o a b, .assign o' a' b' => decide (o = o') && Expr.beq a a' && Expr.beq b b'
  | .step i p a, .step i' p' a' => i == i' && p == p' && Expr.beq a a'
  | .cond c a b, .cond c' a' b' => Expr.beq c c' && Expr.beq a a' && Expr.beq b b'
  | .call f ts as, .call f' ts' as' => Expr.beq f f' && TArg.beqs ts ts' && Expr.beqs as as'
  | .index a i, .index a' i' => Expr.beq a a' && Expr.beq i i'
  | .member a n, .member a' n' => Expr.beq a a' && decide (n = n')
  | .cast s t a, .cast s' t' a' => decide (s = s') && decide (t = t') && Expr.beq a a'
  | .comma a b, .comma a' b' => Expr.beq a a' && Expr.beq b b'
  | _, _ => false
termination_by structural a _ => a

def Expr.beqs : List Expr → List Expr → Bool
  | [], [] => true
  | a :: as, b :: bs => Expr.beq a b && Expr.beqs as bs
  | _, _ => false
termination_by structural as _ => as
end

instance : BEq TArg := ⟨TArg.beq⟩
instance : BEq Expr := ⟨Expr.beq⟩

def Init.beq : Init → Init → Bool
  | .expr a, .expr b => a.beq b
  | .braces as, .braces bs => Expr.beqs as bs
  | _, _ => false

instance : BEq Init := ⟨Init.beq⟩

def Declarator.beq (a b : Declarator) : Bool :=
  decide (a.name = b.name) && Expr.beqs a.extents b.extents && a.init == b.init

instance : BEq Declarator := ⟨Declarator.beq⟩

mutual
def Stmt.beq : Stmt → Stmt → Bool
  | .decl x t ds, .decl x' t' ds' => x == x' && decide (t = t') && ds == ds'
  | .expr a, .expr b => a.beq b
  | .block a, .block b => Stmt.beqs a b
  | .ite c t e, .ite c' t' e' => c.beq c' && Stmt.beq t t' && Stmt.beqOpt e e'
  | .loop i c s b, .loop i' c' s' b' => Stmt.beqOpt i i' && c == c' && s == s' && Stmt.beq b b'
  | .continue_, .continue_ => true
  | .break_, .break_ => true
  | .ret a, .ret b => a == b
  | .pragma h s, .pragma h' s' => decide (h = h') && Stmt.beq s s'
  | .ifConstexpr c t e, .ifConstexpr c' t' e' => c.beq c' && Stmt.beq t t' && Stmt.beqOpt e e'
  | .empty, .empty => true
  | _, _ => false
termination_by structural a _ => a

def Stmt.beqs : List Stmt → List Stmt → Bool
  | [], [] => true
  | a :: as, b :: bs => Stmt.beq a b && Stmt.beqs as bs
  | _, _ => false
termination_by structural as _ => as

def Stmt.beqOpt : Option Stmt → Option Stmt → Bool
  | none, none => true
  | some a, some b => Stmt.beq a b
  | _, _ => false
termination_by structural a _ => a
end

instance : BEq Stmt := ⟨Stmt.beq⟩

def Func.beq (a b : Func) : Bool :=
  decide (a.tparams = b.tparams) && a.kernel == b.kernel && decide (a.specifiers = b.specifiers)
    && decide (a.result = b.result) && decide (a.name = b.name) && decide (a.params = b.params)
    && Stmt.beqs a.body b.body

instance : BEq Func := ⟨Func.beq⟩

def Top.beq : Top → Top → Bool
  | .func f, .func g => f.beq g
  | .instantiate h n ts, .instantiate h' n' ts' => decide (h = h') && decide (n = n') && TArg.beqs ts ts'
  | _, _ => false

instance : BEq Top := ⟨Top.beq⟩

end Metal
