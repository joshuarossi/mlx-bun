import metal.Parser
import metal.Preprocess
import host.mlx.KernelSources

/-! Kernel-checked tests of the Metal parser. Unit tests parse token lists
that `toks!` builds at elaboration time, independently of
proofs/metal/Lexer.lean; the end-to-end tests parse the lexed and
preprocessed exact route sources inside MLX's generated signature. -/

namespace Metal.ParseTest
open Lean Metal

/-! ## Token lists

`toks!"…"` tokenizes C source text at elaboration time: identifiers,
numbers (`0x…` hexadecimal; a `.` or exponent makes a floating literal,
mantissa and exponent as spelled; `u`, `l`, `f` suffixes), `"…"` strings,
`#pragma` lines (one `pragma` token of the line's tokens), longest-match
punctuation; `//` comments and blanks separate tokens. -/

private def listE (ty : Lean.Expr) (xs : List Lean.Expr) : Lean.Expr :=
  xs.foldr (fun x acc => mkApp3 (mkConst ``List.cons [.zero]) ty x acc) (mkApp (mkConst ``List.nil [.zero]) ty)

private def isIdChar (c : Char) : Bool := c.isAlphanum || c == '_'

private def digitOf (c : Char) : Nat :=
  if c.isDigit then c.toNat - 48 else if c.isLower then c.toNat - 87 else c.toNat - 55

private def digitsVal (base : Nat) (cs : List Char) : Nat := cs.foldl (fun n c => n * base + digitOf c) 0

private def isHexChar (c : Char) : Bool :=
  c.isDigit || (Nat.ble 97 c.toNat && Nat.ble c.toNat 102) || (Nat.ble 65 c.toNat && Nat.ble c.toNat 70)

private def numTake (hex : Bool) : Nat → Option Char → List Char → List Char
  | 0, _, _ => []
  | _, _, [] => []
  | f + 1, prev, c :: cs =>
    if isIdChar c || c == '.' then c :: numTake hex f (some c) cs
    else if (c == '-' || c == '+') && !hex && (prev == some 'e' || prev == some 'E') then c :: numTake hex f (some c) cs
    else []

private def boolE (b : Bool) : Lean.Expr := if b then mkConst ``Bool.true else mkConst ``Bool.false

private def numTok (w : List Char) : Lean.Expr :=
  if w.take 2 == ['0', 'x'] then
    let ds := (w.drop 2).takeWhile isHexChar
    let suf := w.drop (2 + ds.length)
    mkApp4 (mkConst ``Tok.int) (mkRawNatLit (digitsVal 16 ds)) (boolE (suf.contains 'u')) (boolE (suf.contains 'l')) (boolE true)
  else if w.any (fun c => c == '.' || c == 'e') then
    let ip := w.takeWhile Char.isDigit
    let rest := w.drop ip.length
    let fr := if rest.head? == some '.' then (rest.drop 1).takeWhile Char.isDigit else []
    let rest := if rest.head? == some '.' then rest.drop (1 + fr.length) else rest
    let neg := rest.take 2 == ['e', '-']
    let ex := if rest.head? == some 'e' then (rest.drop (if neg || rest.take 2 == ['e', '+'] then 2 else 1)).takeWhile Char.isDigit else []
    let e : Int := (if neg then -(digitsVal 10 ex : Int) else (digitsVal 10 ex : Int)) - fr.length
    mkApp3 (mkConst ``Tok.float) (mkRawNatLit (digitsVal 10 (ip ++ fr))) (toExpr e) (boolE (w.getLast? == some 'f'))
  else
    let ds := w.takeWhile Char.isDigit
    let suf := w.drop ds.length
    mkApp4 (mkConst ``Tok.int) (mkRawNatLit (digitsVal 10 ds)) (boolE (suf.contains 'u')) (boolE (suf.contains 'l')) (boolE false)

private def puncts : List (List Char) :=
  [['<','<','='], ['>','>','='], ['<','<'], ['>','>'], ['<','='], ['>','='], ['=','='], ['!','='],
   ['&','&'], ['|','|'], ['+','+'], ['-','-'], ['+','='], ['-','='], ['*','='], ['/','='], ['%','='],
   ['&','='], ['|','='], ['^','='], [':',':'], ['-','>']]

private def punctLen (cs : List Char) : Nat :=
  match puncts.find? (fun p => cs.take p.length == p) with
  | some p => p.length
  | none => 1

private def scan : Nat → List Char → List Lean.Expr
  | 0, _ => []
  | _, [] => []
  | f + 1, c :: cs =>
    if c == ' ' || c == '\n' || c == '\t' then scan f cs
    else if c == '/' && cs.head? == some '/' then scan f (cs.dropWhile (· != '\n'))
    else if c == '#' then
      let line := cs.takeWhile (· != '\n')
      mkApp (mkConst ``Tok.pragma) (listE (mkConst ``Tok) (scan f (line.drop 6))) :: scan f (cs.dropWhile (· != '\n'))
    else if c.isAlpha || c == '_' then
      let w := (c :: cs).takeWhile isIdChar
      mkApp (mkConst ``Tok.ident) (Host.Ts.charCells w) :: scan f ((c :: cs).drop w.length)
    else if c.isDigit then
      let w := numTake (c == '0' && cs.head? == some 'x') (cs.length + 2) none (c :: cs)
      numTok w :: scan f ((c :: cs).drop w.length)
    else if c == '"' then
      let s := cs.takeWhile (· != '"')
      mkApp (mkConst ``Tok.str) (Host.Ts.charCells s) :: scan f (cs.drop (s.length + 1))
    else
      let n := punctLen (c :: cs)
      mkApp (mkConst ``Tok.punct) (Host.Ts.charCells ((c :: cs).take n)) :: scan f ((c :: cs).drop n)

elab:max "toks!" s:str : term =>
  return listE (mkConst ``Tok) (scan (s.getString.length + 1) s.getString.toList)

/-! ## Expected syntax -/

def v (n : List Char) : Expr := .name [n]
def n (k : Nat) : Expr := .int k false false false
def nu (k : Nat) : Expr := .int k true false false
def bin (op : BinOp) (a b : Expr) : Expr := .binary op a b
def ty (n : List Char) : TypeSpec := { name := n }
def call (f : List Char) (as : List Expr) : Expr := .call (v f) [] as
def set (a b : Expr) : Stmt := .expr (.assign none a b)
def decl1 (t : TypeSpec) (x : List Char) (e : Expr) : Stmt := .decl false t [{ name := x, init := some (.expr e) }]

def exprIs (c : ParseCtx) (ts : List Tok) (e : Expr) : Bool := parseExpr c ts == some e
def stmtsAre (c : ParseCtx) (ts : List Tok) (ss : List Stmt) : Bool := parseStmts c ts == some ss
def stmtsReject (c : ParseCtx) (ts : List Tok) : Bool := (parseStmts c ts).isNone

/-- The affine-row kernel body's scope: template type `T`, the header's template functions. -/
def affine : ParseCtx := { types := [chars!"T"], templates := [chars!"mlxq_load_vector", chars!"mlxq_qdot"] }

/-! ## Expressions -/

theorem precedence : exprIs {} toks!"a + b * c << d < e == f & g ^ h | i && j || k"
    (bin .or (bin .and (bin .bitOr (bin .bitXor (bin .bitAnd (bin .eq (bin .lt
      (bin .shl (bin .add (v chars!"a") (bin .mul (v chars!"b") (v chars!"c"))) (v chars!"d"))
      (v chars!"e")) (v chars!"f")) (v chars!"g")) (v chars!"h")) (v chars!"i")) (v chars!"j"))
      (v chars!"k")) = true := by decide +kernel

theorem left_assoc : exprIs {} toks!"a - b - c / d * e % f >> 1 >> 2"
    (bin .shr (bin .shr (bin .sub (bin .sub (v chars!"a") (v chars!"b"))
      (bin .mod (bin .mul (bin .div (v chars!"c") (v chars!"d")) (v chars!"e")) (v chars!"f"))) (n 1)) (n 2))
    = true := by decide +kernel

theorem assign_right_assoc : exprIs {} toks!"a = b += c <<= d >>= e"
    (.assign none (v chars!"a") (.assign (some .add) (v chars!"b")
      (.assign (some .shl) (v chars!"c") (.assign (some .shr) (v chars!"d") (v chars!"e"))))) = true := by
  decide +kernel

theorem compound_assignments : stmtsAre {} toks!"a -= b; a *= b; a /= b; a %= b; a &= b; a |= b; a ^= b;"
    (([.sub, .mul, .div, .mod, .bitAnd, .bitOr, .bitXor] : List BinOp).map fun op =>
      .expr (.assign (some op) (v chars!"a") (v chars!"b"))) = true := by decide +kernel

theorem nested_ternary : exprIs {} toks!"!active ? 0u : (uint)R % (uint)SPLITS == 0u ? ROWS_PER : r0 >= (uint)R ? 0u : metal::min(ROWS_PER, (uint)R - r0)"
    (.cond (.unary .not (v chars!"active")) (nu 0)
      (.cond (bin .eq (bin .mod (.cast .c (ty chars!"uint") (v chars!"R")) (.cast .c (ty chars!"uint") (v chars!"SPLITS"))) (nu 0))
        (v chars!"ROWS_PER")
        (.cond (bin .ge (v chars!"r0") (.cast .c (ty chars!"uint") (v chars!"R"))) (nu 0)
          (.call (.name [chars!"metal", chars!"min"]) []
            [v chars!"ROWS_PER", bin .sub (.cast .c (ty chars!"uint") (v chars!"R")) (v chars!"r0")])))) = true := by
  decide +kernel

theorem ternary_assignment : exprIs {} toks!"value = isnan(value) ? -INFINITY : value"
    (.assign none (v chars!"value") (.cond (call chars!"isnan" [v chars!"value"])
      (.unary .neg (v chars!"INFINITY")) (v chars!"value"))) = true := by decide +kernel

theorem prefix_postfix : exprIs {} toks!"-x[i]++ + !*p - ~++j + i--"
    (bin .add (bin .sub (bin .add (.unary .neg (.step true false (.index (v chars!"x") (v chars!"i"))))
      (.unary .not (.unary .deref (v chars!"p")))) (.unary .bitNot (.step true true (v chars!"j"))))
      (.step false false (v chars!"i"))) = true := by decide +kernel

theorem members : exprIs {} toks!"(threadgroup_position_in_grid.y * S + sg) * R + thread_position_in_grid.z"
    (bin .add (bin .mul (bin .add (bin .mul (.member (v chars!"threadgroup_position_in_grid") chars!"y") (v chars!"S"))
      (v chars!"sg")) (v chars!"R")) (.member (v chars!"thread_position_in_grid") chars!"z")) = true := by
  decide +kernel

theorem qualified_names : exprIs {} toks!"threadgroup_barrier(metal::mem_flags::mem_threadgroup | metal::mem_flags::mem_device)"
    (call chars!"threadgroup_barrier" [bin .bitOr (.name [chars!"metal", chars!"mem_flags", chars!"mem_threadgroup"])
      (.name [chars!"metal", chars!"mem_flags", chars!"mem_device"])]) = true := by decide +kernel

theorem precise_call : exprIs {} toks!"metal::precise::rsqrt(acc / float(D) + as_type<float>(uint(EPS)))"
    (.call (.name [chars!"metal", chars!"precise", chars!"rsqrt"]) []
      [bin .add (bin .div (v chars!"acc") (.cast .functional (ty chars!"float") (v chars!"D")))
        (.call (v chars!"as_type") [.type (ty chars!"float")] [.cast .functional (ty chars!"uint") (v chars!"EPS")])])
    = true := by decide +kernel

/-! ### Casts -/

theorem c_cast_binds_tighter : exprIs {} toks!"(uint)C / 32u + (int)((p & 0xFFFFu) + (p >> 16)) - 510"
    (bin .sub (bin .add (bin .div (.cast .c (ty chars!"uint") (v chars!"C")) (nu 32))
      (.cast .c (ty chars!"int") (bin .add (bin .bitAnd (v chars!"p") (.int 0xFFFF true false true))
        (bin .shr (v chars!"p") (n 16))))) (n 510)) = true := by decide +kernel

theorem pointer_cast_deref : stmtsAre {} toks!"return *(const threadgroup float*)(table + bits);"
    [.ret (some (.unary .deref (.cast .c { const := true, space := some .threadgroup, name := chars!"float", pointer := true }
      (bin .add (v chars!"table") (v chars!"bits")))))] = true := by decide +kernel

theorem cast_then_index : exprIs {} toks!"((const device uint4*)x)[(c % N_RUNS) * 4u + c / N_RUNS]"
    (.index (.cast .c { const := true, space := some .device, name := chars!"uint4", pointer := true } (v chars!"x"))
      (bin .add (bin .mul (bin .mod (v chars!"c") (v chars!"N_RUNS")) (nu 4)) (bin .div (v chars!"c") (v chars!"N_RUNS"))))
    = true := by decide +kernel

theorem functional_casts : exprIs affine toks!"T(float(values[i]) * inv) + uint(DK) + T(0)"
    (bin .add (bin .add (.cast .functional (ty chars!"T")
      (bin .mul (.cast .functional (ty chars!"float") (.index (v chars!"values") (v chars!"i"))) (v chars!"inv")))
      (.cast .functional (ty chars!"uint") (v chars!"DK"))) (.cast .functional (ty chars!"T") (n 0))) = true := by
  decide +kernel

theorem static_cast_as_type : exprIs affine toks!"static_cast<T>(v) + as_type<float>((uint)(q) | 0x4B000000u)"
    (bin .add (.cast .static (ty chars!"T") (v chars!"v"))
      (.call (v chars!"as_type") [.type (ty chars!"float")]
        [bin .bitOr (.cast .c (ty chars!"uint") (v chars!"q")) (.int 0x4B000000 true false true)])) = true := by
  decide +kernel

/-- A parenthesized non-type is an expression, also before `?` and `==`. -/
theorem parens_not_casts : exprIs affine toks!"((TAIL) == 1) + ((gateT < 0) ? sigY : 1 - sigY)"
    (bin .add (bin .eq (v chars!"TAIL") (n 1))
      (.cond (bin .lt (v chars!"gateT") (n 0)) (v chars!"sigY") (bin .sub (n 1) (v chars!"sigY")))) = true := by
  decide +kernel

/-! ### Template arguments -/

theorem templated_call : exprIs affine toks!"mlxq_load_vector<T, BITS>(x + c * 16, t)"
    (.call (v chars!"mlxq_load_vector") [.type (ty chars!"T"), .expr (v chars!"BITS")]
      [bin .add (v chars!"x") (bin .mul (v chars!"c") (n 16)), v chars!"t"]) = true := by decide +kernel

theorem templated_call_expr_arg : exprIs affine toks!"result[r] + mlxq_qdot<2 * BITS>(ws + r * ROWB, x_thread, s, b, sum)"
    (bin .add (.index (v chars!"result") (v chars!"r"))
      (.call (v chars!"mlxq_qdot") [.expr (bin .mul (n 2) (v chars!"BITS"))]
        [bin .add (v chars!"ws") (bin .mul (v chars!"r") (v chars!"ROWB")), v chars!"x_thread", v chars!"s",
         v chars!"b", v chars!"sum"])) = true := by decide +kernel

/-- `<` after a name that is not a template function is less-than. -/
theorem less_than_not_template : exprIs affine toks!"lane < 4 ? scores[lane] : head < uint(HK)"
    (.cond (bin .lt (v chars!"lane") (n 4)) (.index (v chars!"scores") (v chars!"lane"))
      (bin .lt (v chars!"head") (.cast .functional (ty chars!"uint") (v chars!"HK")))) = true := by decide +kernel

theorem reject_template_args_on_plain_name : (parseExpr affine toks!"foo<T>(x)").isNone = true := by decide +kernel
theorem reject_sizeof : (parseExpr {} toks!"sizeof(x)").isNone = true := by decide +kernel
theorem reject_comma_operator : (parseExpr {} toks!"a, b").isNone = true := by decide +kernel

theorem relational : exprIs {} toks!"a != b == c > d >= e <= f"
    (bin .eq (bin .ne (v chars!"a") (v chars!"b"))
      (bin .le (bin .ge (bin .gt (v chars!"c") (v chars!"d")) (v chars!"e")) (v chars!"f"))) = true := by
  decide +kernel

/-! ## Statements -/

theorem multi_declarator : stmtsAre {} toks!"const uint col = r + tid * 4u + i, index = row * uint(D) + col;"
    [.decl false { const := true, name := chars!"uint" }
      [{ name := chars!"col", init := some (.expr (bin .add (bin .add (v chars!"r") (bin .mul (v chars!"tid") (nu 4))) (v chars!"i"))) },
       { name := chars!"index", init := some (.expr (bin .add (bin .mul (v chars!"row")
           (.cast .functional (ty chars!"uint") (v chars!"D"))) (v chars!"col"))) }]] = true := by decide +kernel

theorem arrays : stmtsAre {} toks!"float result[R] = {0}; uint ld[U][NL]; uint g[KG + 1], gv[KG + 1]; uint bits; float e[2] = {};"
    [.decl false (ty chars!"float") [{ name := chars!"result", extents := [v chars!"R"], init := some (.braces [n 0]) }],
     .decl false (ty chars!"uint") [{ name := chars!"ld", extents := [v chars!"U", v chars!"NL"] }],
     .decl false (ty chars!"uint") [{ name := chars!"g", extents := [bin .add (v chars!"KG") (n 1)] },
       { name := chars!"gv", extents := [bin .add (v chars!"KG") (n 1)] }],
     .decl false (ty chars!"uint") [{ name := chars!"bits" }],
     .decl false (ty chars!"float") [{ name := chars!"e", extents := [n 2], init := some (.braces []) }]] = true := by
  decide +kernel

theorem spaces_and_qualifiers : stmtsAre affine
    toks!"threadgroup float xs[K]; thread float t[16]; const threadgroup float* x_thread = xs + k; thread const uint* w = v; threadgroup float* sums = codebook; constexpr int BPL = 2 * BITS; const auto y = 1; T values[4];"
    [.decl false { space := some .threadgroup, name := chars!"float" } [{ name := chars!"xs", extents := [v chars!"K"] }],
     .decl false { space := some .thread, name := chars!"float" } [{ name := chars!"t", extents := [n 16] }],
     decl1 { const := true, space := some .threadgroup, name := chars!"float", pointer := true } chars!"x_thread"
       (bin .add (v chars!"xs") (v chars!"k")),
     decl1 { const := true, space := some .thread, name := chars!"uint", pointer := true } chars!"w" (v chars!"v"),
     decl1 { space := some .threadgroup, name := chars!"float", pointer := true } chars!"sums" (v chars!"codebook"),
     .decl true (ty chars!"int") [{ name := chars!"BPL", init := some (.expr (bin .mul (n 2) (v chars!"BITS"))) }],
     decl1 { const := true, name := chars!"auto" } chars!"y" (n 1),
     .decl false (ty chars!"T") [{ name := chars!"values", extents := [n 4] }]] = true := by decide +kernel

/-- The route's type names, builtin and template parameters, each start a declaration. -/
theorem type_names : ((parseStmts { types := [chars!"InT", chars!"StT"] }
    toks!"float a; int b; uint c; bool d; uchar e; uint8_t f; uint16_t g; uint32_t h; ulong i; uint3 j; uint4 k; float4 l; bfloat16_t m; InT o; StT p;").map
    (List.map fun | .decl false t [_] => t.name | _ => []) == some
    [chars!"float", chars!"int", chars!"uint", chars!"bool", chars!"uchar", chars!"uint8_t", chars!"uint16_t",
     chars!"uint32_t", chars!"ulong", chars!"uint3", chars!"uint4", chars!"float4", chars!"bfloat16_t", chars!"InT", chars!"StT"])
    = true := by decide +kernel

/-- `T* a, b` would make only `a` a pointer; the tree cannot say so. -/
theorem reject_pointer_declarators : stmtsReject {} toks!"const device float* a = p, b = q;" = true := by decide +kernel
theorem reject_duplicate_space : stmtsReject {} toks!"device threadgroup float* a = p;" = true := by decide +kernel
/-- Without `T` in scope, `T values[4];` is no statement. -/
theorem reject_unknown_type : stmtsReject {} toks!"T values[4];" = true := by decide +kernel
/-- A functional cast cannot start a statement (C++ would read a declaration). -/
theorem reject_cast_statement : stmtsReject {} toks!"uint(x);" = true := by decide +kernel
theorem reject_missing_semicolon : stmtsReject {} toks!"x = 1 y = 2;" = true := by decide +kernel

theorem for_loops : stmtsAre {} toks!"for (; r + (uint)U <= rows; r += (uint)U) {} for (i = 0; ; ) continue; for (int j = 0; j < 16; j++) xs[c * 16 + j] = t[j];"
    [.loop none (some (bin .le (bin .add (v chars!"r") (.cast .c (ty chars!"uint") (v chars!"U"))) (v chars!"rows")))
       (some (.assign (some .add) (v chars!"r") (.cast .c (ty chars!"uint") (v chars!"U")))) (.block []),
     .loop (some (set (v chars!"i") (n 0))) none none .continue_,
     .loop (some (decl1 (ty chars!"int") chars!"j" (n 0))) (some (bin .lt (v chars!"j") (n 16)))
       (some (.step true false (v chars!"j")))
       (set (.index (v chars!"xs") (bin .add (bin .mul (v chars!"c") (n 16)) (v chars!"j"))) (.index (v chars!"t") (v chars!"j")))]
    = true := by decide +kernel

theorem if_else : stmtsAre {} toks!"if (head < uint(HK)) q[i] = a; else k[i] = b; if (a) if (b) x = 1; else x = 2; if (j & 1u) { x = 1; } else { const uint vi = 0; x = vi; }"
    [.ite (bin .lt (v chars!"head") (.cast .functional (ty chars!"uint") (v chars!"HK")))
       (set (.index (v chars!"q") (v chars!"i")) (v chars!"a")) (some (set (.index (v chars!"k") (v chars!"i")) (v chars!"b"))),
     .ite (v chars!"a") (.ite (v chars!"b") (set (v chars!"x") (n 1)) (some (set (v chars!"x") (n 2)))) none,
     .ite (bin .bitAnd (v chars!"j") (nu 1)) (.block [set (v chars!"x") (n 1)])
       (some (.block [decl1 { const := true, name := chars!"uint" } chars!"vi" (n 0), set (v chars!"x") (v chars!"vi")]))]
    = true := by decide +kernel

theorem jumps : stmtsAre {} toks!"continue; break; return; return x; ; { } if (true) {} else ;"
    [.continue_, .break_, .ret none, .ret (some (v chars!"x")), .empty, .block [], .ite (.bool true) (.block []) (some .empty)]
    = true := by decide +kernel

theorem pragma_loops : stmtsAre {} toks!"#pragma clang loop unroll(full)
for (uint i = 0; i < (uint)KG; ++i) g[i] = gcodes[gw + i];
#pragma clang loop unroll_count(1)
#pragma clang loop unroll(full)
for (;;) {}"
    [.pragma .unrollFull (.loop (some (decl1 (ty chars!"uint") chars!"i" (n 0)))
       (some (bin .lt (v chars!"i") (.cast .c (ty chars!"uint") (v chars!"KG")))) (some (.step true true (v chars!"i")))
       (set (.index (v chars!"g") (v chars!"i")) (.index (v chars!"gcodes") (bin .add (v chars!"gw") (v chars!"i"))))),
     .pragma (.unrollCount 1) (.pragma .unrollFull (.loop none none none (.block [])))] = true := by decide +kernel

theorem reject_pragma_before_statement : stmtsReject {} toks!"#pragma clang loop unroll(full)
x = 1;" = true := by decide +kernel
theorem reject_unknown_pragma : stmtsReject {} toks!"#pragma unroll
for (;;) {}" = true := by decide +kernel

/-! ## The affine-row body -/

def affineBody : List Tok := toks!"
  constexpr int BPL = 2 * BITS;                   // weight bytes per lane per K step
  constexpr int ROWB = K * BITS / 8;
  constexpr int GROUPS = K / 64;
  const uint sg = simdgroup_index_in_threadgroup, lane = thread_index_in_simdgroup;
  // MLX's x_thread for every 16-value chunk of x, and each chunk's sum.
  threadgroup float xs[K];
  threadgroup float ss[K / 16];
  for (int c = (int)(sg * 32 + lane); c < K / 16; c += S * 32) {
    thread float t[16];
    ss[c] = mlxq_load_vector<T, BITS>(x + c * 16, t);
    for (int j = 0; j < 16; j++) xs[c * 16 + j] = t[j];
  }
  threadgroup_barrier(mem_flags::mem_threadgroup);
  const int row0 = (threadgroup_position_in_grid.y * S + sg) * R;
  const device uint8_t* ws = (const device uint8_t*)w + row0 * ROWB + lane * BPL;
  const device T* sc = scales + row0 * GROUPS + lane / 4;
  const device T* bi = biases + row0 * GROUPS + lane / 4;
  float result[R] = {0};
  #pragma clang loop unroll_count(1)
  for (int k = 0; k < K; k += 512) {
    const float sum = ss[(k + lane * 16) / 16];
    const threadgroup float* x_thread = xs + k + lane * 16;
    for (int r = 0; r < R; r++) {
      const float s = sc[r * GROUPS];
      const float b = bi[r * GROUPS];
      result[r] += mlxq_qdot<BITS>(ws + r * ROWB, x_thread, s, b, sum);
    }
    ws += 32 * BPL;
    sc += 8;
    bi += 8;
  }
  for (int r = 0; r < R; r++) {
    const float v = simd_sum(result[r]);
    if (lane == 0) y[row0 + r] = static_cast<T>(v);
  }
"

theorem affine_body_statements : (parseStmts affine affineBody).map List.length = some 15 := by decide +kernel

/-- The body's first loop, the `uint8_t` pointer cast and the final loop, exactly. -/
theorem affine_body_parts : (((parseStmts affine affineBody).map fun ss =>
    [ss[3]!, ss[6]!, ss[9]!, ss[14]!]) == some
    [.decl false { const := true, name := chars!"uint" }
       [{ name := chars!"sg", init := some (.expr (v chars!"simdgroup_index_in_threadgroup")) },
        { name := chars!"lane", init := some (.expr (v chars!"thread_index_in_simdgroup")) }],
     .loop (some (decl1 (ty chars!"int") chars!"c" (.cast .c (ty chars!"int") (bin .add (bin .mul (v chars!"sg") (n 32)) (v chars!"lane")))))
       (some (bin .lt (v chars!"c") (bin .div (v chars!"K") (n 16))))
       (some (.assign (some .add) (v chars!"c") (bin .mul (v chars!"S") (n 32))))
       (.block [.decl false { space := some .thread, name := chars!"float" } [{ name := chars!"t", extents := [n 16] }],
         set (.index (v chars!"ss") (v chars!"c")) (.call (v chars!"mlxq_load_vector") [.type (ty chars!"T"), .expr (v chars!"BITS")]
           [bin .add (v chars!"x") (bin .mul (v chars!"c") (n 16)), v chars!"t"]),
         .loop (some (decl1 (ty chars!"int") chars!"j" (n 0))) (some (bin .lt (v chars!"j") (n 16))) (some (.step true false (v chars!"j")))
           (set (.index (v chars!"xs") (bin .add (bin .mul (v chars!"c") (n 16)) (v chars!"j"))) (.index (v chars!"t") (v chars!"j")))]),
     decl1 { const := true, space := some .device, name := chars!"uint8_t", pointer := true } chars!"ws"
       (bin .add (bin .add (.cast .c { const := true, space := some .device, name := chars!"uint8_t", pointer := true } (v chars!"w"))
         (bin .mul (v chars!"row0") (v chars!"ROWB"))) (bin .mul (v chars!"lane") (v chars!"BPL"))),
     .loop (some (decl1 (ty chars!"int") chars!"r" (n 0))) (some (bin .lt (v chars!"r") (v chars!"R"))) (some (.step true false (v chars!"r")))
       (.block [decl1 { const := true, name := chars!"float" } chars!"v" (call chars!"simd_sum" [.index (v chars!"result") (v chars!"r")]),
         .ite (bin .eq (v chars!"lane") (n 0))
           (set (.index (v chars!"y") (bin .add (v chars!"row0") (v chars!"r"))) (.cast .static (ty chars!"T") (v chars!"v"))) none])])
    = true := by decide +kernel

/-! ## Functions, signature and instantiation -/

def header : List Tok := toks!"
template <typename T, int bits>
inline float mlxq_load_vector(const device T* x, thread float* x_thread) {
  float sum = 0;
  return sum;
}
template <int bits>
inline float mlxq_qdot(const device uint8_t* w, const threadgroup float* x_thread, float scale) {
  return scale * x_thread[0];
}
static inline uint trellis_y(uint s) { return s * 34038481u + 76625530u; }
inline bool better(float x, uint xi, float y, uint yi) {
  return x > y || (x == y && xi < yi);
}
"

def funcOf (tps : List TParam) (specs : List (List Char)) (res : TypeSpec) (name : List Char) (ps : List Param)
    (body : List Stmt) : Top :=
  .func { tparams := tps, specifiers := specs, result := res, name, params := ps, body }

def headerTree : List Top :=
  [funcOf [.type chars!"T", .int chars!"bits"] [chars!"inline"] (ty chars!"float") chars!"mlxq_load_vector"
     [{ t := { const := true, space := some .device, name := chars!"T", pointer := true }, name := chars!"x" },
      { t := { space := some .thread, name := chars!"float", pointer := true }, name := chars!"x_thread" }]
     [decl1 (ty chars!"float") chars!"sum" (n 0), .ret (some (v chars!"sum"))],
   funcOf [.int chars!"bits"] [chars!"inline"] (ty chars!"float") chars!"mlxq_qdot"
     [{ t := { const := true, space := some .device, name := chars!"uint8_t", pointer := true }, name := chars!"w" },
      { t := { const := true, space := some .threadgroup, name := chars!"float", pointer := true }, name := chars!"x_thread" },
      { t := ty chars!"float", name := chars!"scale" }]
     [.ret (some (bin .mul (v chars!"scale") (.index (v chars!"x_thread") (n 0))))],
   funcOf [] [chars!"static", chars!"inline"] (ty chars!"uint") chars!"trellis_y" [{ t := ty chars!"uint", name := chars!"s" }]
     [.ret (some (bin .add (bin .mul (v chars!"s") (.int 34038481 true false false)) (.int 76625530 true false false)))],
   funcOf [] [chars!"inline"] (ty chars!"bool") chars!"better"
     [{ t := ty chars!"float", name := chars!"x" }, { t := ty chars!"uint", name := chars!"xi" },
      { t := ty chars!"float", name := chars!"y" }, { t := ty chars!"uint", name := chars!"yi" }]
     [.ret (some (bin .or (bin .gt (v chars!"x") (v chars!"y"))
       (bin .and (bin .eq (v chars!"x") (v chars!"y")) (bin .lt (v chars!"xi") (v chars!"yi")))))]]

theorem header_functions : (parseUnit header == some headerTree) = true := by decide +kernel

def kernelName : List Char :=
  chars!"custom_kernel_mlx_bun_affine_row__bfloat16_t_5120_1024_3_4_16_bfloat16_t_floats_bfloat16_t"

def signature : List Tok := toks!"
template <typename T, int N, int K, int BITS, int R, int S>
[[kernel]] void custom_kernel_mlx_bun_affine_row__bfloat16_t_5120_1024_3_4_16_bfloat16_t_floats_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const constant float& small [[buffer(1)]],
  device bfloat16_t* y [[buffer(2)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
  y[threadgroup_position_in_grid.x] = static_cast<T>(small);
}

template [[host_name(\"custom_kernel_mlx_bun_affine_row__bfloat16_t_5120_1024_3_4_16_bfloat16_t_floats_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_affine_row__bfloat16_t_5120_1024_3_4_16_bfloat16_t_floats_bfloat16_t<bfloat16_t, 5120, 1024, 3, 4, 16>) custom_kernel_mlx_bun_affine_row__bfloat16_t_5120_1024_3_4_16_bfloat16_t_floats_bfloat16_t<bfloat16_t, 5120, 1024, 3, 4, 16>;
"

def instArgs : List TArg := [.type (ty chars!"bfloat16_t"), .expr (n 5120), .expr (n 1024), .expr (n 3), .expr (n 4), .expr (n 16)]

def signatureTree : List Top :=
  [.func { tparams := [.type chars!"T", .int chars!"N", .int chars!"K", .int chars!"BITS", .int chars!"R", .int chars!"S"],
           kernel := true, result := ty chars!"void", name := kernelName,
           params := [{ t := { const := true, space := some .device, name := chars!"bfloat16_t", pointer := true },
                        name := chars!"x", attr := some (.buffer 0) },
                      { t := { const := true, space := some .constant, name := chars!"float" }, reference := true,
                        name := chars!"small", attr := some (.buffer 1) },
                      { t := { space := some .device, name := chars!"bfloat16_t", pointer := true },
                        name := chars!"y", attr := some (.buffer 2) },
                      { t := ty chars!"uint", name := chars!"simdgroup_index_in_threadgroup",
                        attr := some (.builtin chars!"simdgroup_index_in_threadgroup") },
                      { t := ty chars!"uint3", name := chars!"threadgroup_position_in_grid",
                        attr := some (.builtin chars!"threadgroup_position_in_grid") }],
           body := [set (.index (v chars!"y") (.member (v chars!"threadgroup_position_in_grid") chars!"x"))
             (.cast .static (ty chars!"T") (v chars!"small"))] },
   .instantiate kernelName kernelName instArgs]

theorem signature_and_instantiation : (parseUnit signature == some signatureTree) = true := by decide +kernel

/-- Without template arguments MLX writes no template line and no instantiation. -/
theorem plain_kernel : (parseUnit toks!"
template <bool B> inline bool pick(bool x) { return B && x; }
[[kernel]] void k(const constant int& n [[buffer(0)]], device int* y [[buffer(1)]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]]) { y[thread_index_in_simdgroup] = n; }" ==
    some [funcOf [.bool chars!"B"] [chars!"inline"] (ty chars!"bool") chars!"pick" [{ t := ty chars!"bool", name := chars!"x" }]
            [.ret (some (bin .and (v chars!"B") (v chars!"x")))],
          .func { kernel := true, result := ty chars!"void", name := chars!"k",
                  params := [{ t := { const := true, space := some .constant, name := chars!"int" }, reference := true,
                               name := chars!"n", attr := some (.buffer 0) },
                             { t := { space := some .device, name := chars!"int", pointer := true }, name := chars!"y",
                               attr := some (.buffer 1) },
                             { t := ty chars!"uint", name := chars!"thread_index_in_simdgroup",
                               attr := some (.builtin chars!"thread_index_in_simdgroup") }],
                  body := [set (.index (v chars!"y") (v chars!"thread_index_in_simdgroup")) (v chars!"n")] }]) = true := by
  decide +kernel

theorem reject_mismatched_instantiation : (parseUnit toks!"
template <typename T> [[kernel]] void k(device T* y [[buffer(0)]]) {}
template [[host_name(\"k\")]] [[kernel]] decltype(k<float>) k<bfloat16_t>;").isNone = true := by decide +kernel

theorem reject_undeclared_instantiation : (parseUnit toks!"
[[kernel]] void k(device float* y [[buffer(0)]]) {}
template [[host_name(\"k\")]] [[kernel]] decltype(k<float>) k<float>;").isNone = true := by decide +kernel

/-! ## End to end

Each route kernel's exact header and body (Host.Mlx.SourceKernels), lexed
and preprocessed, inside the text MLX's `metal_kernel` generates around them:
template line, `[[kernel]]` signature (`const device|constant T*` inputs,
`device T*` outputs, the attributes the body names) and explicit
instantiation. -/

open Host.Mlx in
/-- `header`, the generated signature `sig`, the body, `}` and the instantiation `inst`. -/
def assembled (k : Kernel) (sig inst : List Char) : List Char :=
  SourceKernels.sources.header k ++ '\n' :: sig ++ SourceKernels.sources.source k ++ chars!"\n}\n" ++ inst

/-- The unit's top-level items, from the assembled text. -/
def tops (k : Host.Mlx.Kernel) (sig inst : List Char) : Option (List Top) :=
  (preprocess (lex (assembled k sig inst))).bind parseUnit

def topCount (k : Host.Mlx.Kernel) (sig inst : List Char) : Option Nat := (tops k sig inst).map List.length

def affineSig : List Char := chars!"template <typename T, int N, int K, int BITS, int R, int S>
[[kernel]] void custom_kernel_mlx_bun_affine_row__bfloat16_t_5120_1024_3_4_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device uint32_t* w [[buffer(1)]],
  const device bfloat16_t* scales [[buffer(2)]],
  const device bfloat16_t* biases [[buffer(3)]],
  device bfloat16_t* y [[buffer(4)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"
def affineInst : List Char := chars!"
template [[host_name(\"custom_kernel_mlx_bun_affine_row__bfloat16_t_5120_1024_3_4_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_affine_row__bfloat16_t_5120_1024_3_4_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 5120, 1024, 3, 4, 16>) custom_kernel_mlx_bun_affine_row__bfloat16_t_5120_1024_3_4_16_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 5120, 1024, 3, 4, 16>;
"

/-- Header functions, kernel, instantiation; the kernel's body is the one
parsed from `toks!` above (the body has no floating literal). -/
theorem affine_row_end_to_end :
    (match tops .affineRow affineSig affineInst with
     | some [.func load, .func qdot, .func kern, .instantiate _ _ as] =>
       nameEq load.name chars!"mlxq_load_vector" && nameEq qdot.name chars!"mlxq_qdot" && kern.kernel
         && kern.params.length == 8 && TArg.beqs as instArgs && some kern.body == parseStmts affine affineBody
     | _ => false) = true := by decide +kernel

def siluSig : List Char := chars!"template <typename T, int C, int HK, int HV, int DK, int DV>
[[kernel]] void custom_kernel_mlx_bun_silu_rms_heads__bfloat16_t_8192_16_32_128_128_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device bfloat16_t* qscale [[buffer(1)]],
  const device bfloat16_t* kscale [[buffer(2)]],
  device bfloat16_t* q [[buffer(3)]],
  device bfloat16_t* k [[buffer(4)]],
  device bfloat16_t* v [[buffer(5)]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"
def siluInst : List Char := chars!"
template [[host_name(\"custom_kernel_mlx_bun_silu_rms_heads__bfloat16_t_8192_16_32_128_128_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_silu_rms_heads__bfloat16_t_8192_16_32_128_128_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 8192, 16, 32, 128, 128>) custom_kernel_mlx_bun_silu_rms_heads__bfloat16_t_8192_16_32_128_128_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 8192, 16, 32, 128, 128>;
"
theorem silu_rms_heads_end_to_end : topCount .siluRmsHeads siluSig siluInst = some 2 := by decide +kernel

def gatedSig : List Char := chars!"template <typename InT, typename StT, int Dk, int Dv, int Hk, int Hv>
[[kernel]] void custom_kernel_gated_delta_step__bfloat16_t_float_128_128_16_32_bfloat16_t_bfloat16_t_bfloat16_t_float_bfloat16_t_float_int32_tc_bfloat16_t_float(
  const device bfloat16_t* q [[buffer(0)]],
  const device bfloat16_t* k [[buffer(1)]],
  const device bfloat16_t* v [[buffer(2)]],
  const device float* g [[buffer(3)]],
  const device bfloat16_t* beta [[buffer(4)]],
  const device float* state_in [[buffer(5)]],
  const constant int32_t* Tin [[buffer(6)]],
  device bfloat16_t* y [[buffer(7)]],
  device float* state_out [[buffer(8)]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 thread_position_in_grid [[thread_position_in_grid]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]]) {
"
def gatedInst : List Char := chars!"
template [[host_name(\"custom_kernel_gated_delta_step__bfloat16_t_float_128_128_16_32_bfloat16_t_bfloat16_t_bfloat16_t_float_bfloat16_t_float_int32_tc_bfloat16_t_float\")]] [[kernel]] decltype(custom_kernel_gated_delta_step__bfloat16_t_float_128_128_16_32_bfloat16_t_bfloat16_t_bfloat16_t_float_bfloat16_t_float_int32_tc_bfloat16_t_float<bfloat16_t, float, 128, 128, 16, 32>) custom_kernel_gated_delta_step__bfloat16_t_float_128_128_16_32_bfloat16_t_bfloat16_t_bfloat16_t_float_bfloat16_t_float_int32_tc_bfloat16_t_float<bfloat16_t, float, 128, 128, 16, 32>;
"
theorem gated_delta_step_end_to_end : topCount .gatedDeltaStep gatedSig gatedInst = some 2 := by decide +kernel

def rmsAttrs : List Char := chars!"  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"
def gatedRmsSig : List Char := chars!"template <typename T, int D, int THREADS, int EPS>
[[kernel]] void custom_kernel_mlx_bun_gated_rms_norm__bfloat16_t_4096_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device bfloat16_t* gate [[buffer(1)]],
  const device bfloat16_t* weight [[buffer(2)]],
  device bfloat16_t* out [[buffer(3)]],
" ++ rmsAttrs
def gatedRmsInst : List Char := chars!"
template [[host_name(\"custom_kernel_mlx_bun_gated_rms_norm__bfloat16_t_4096_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_gated_rms_norm__bfloat16_t_4096_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 4096, 1024, 897988541>) custom_kernel_mlx_bun_gated_rms_norm__bfloat16_t_4096_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 4096, 1024, 897988541>;
"
theorem gated_rms_norm_end_to_end : topCount .gatedRmsNorm gatedRmsSig gatedRmsInst = some 2 := by decide +kernel

def residualSig : List Char := chars!"template <typename T, int D, int THREADS, int EPS>
[[kernel]] void custom_kernel_mlx_bun_residual_rms_norm__bfloat16_t_5120_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device bfloat16_t* update [[buffer(1)]],
  const device bfloat16_t* weight [[buffer(2)]],
  device bfloat16_t* residual [[buffer(3)]],
  device bfloat16_t* normalized [[buffer(4)]],
" ++ rmsAttrs
def residualInst : List Char := chars!"
template [[host_name(\"custom_kernel_mlx_bun_residual_rms_norm__bfloat16_t_5120_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_residual_rms_norm__bfloat16_t_5120_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 5120, 1024, 897988541>) custom_kernel_mlx_bun_residual_rms_norm__bfloat16_t_5120_1024_897988541_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t_bfloat16_t<bfloat16_t, 5120, 1024, 897988541>;
"
theorem residual_rms_norm_end_to_end : topCount .residualRmsNorm residualSig residualInst = some 2 := by decide +kernel

def gateUpSig : List Char := chars!"template <typename T, int R, int C, int BT, int KG, int KU, int L, int ROWS_TG, int THREADS, int TAIL>
[[kernel]] void custom_kernel_mlx_bun_trellis_gateup_codebook_row__bfloat16_t_17408_5120_256_2_3_12_32_1024_1_bfloat16_t_uint32_t_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t(
  const device bfloat16_t* x [[buffer(0)]],
  const device uint32_t* gcodes [[buffer(1)]],
  const device bfloat16_t* gscales [[buffer(2)]],
  const device uint32_t* ucodes [[buffer(3)]],
  const device bfloat16_t* uscales [[buffer(4)]],
  device bfloat16_t* mid [[buffer(5)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 thread_position_in_grid [[thread_position_in_grid]],
  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],
  uint3 threadgroups_per_grid [[threadgroups_per_grid]]) {
"
def gateUpInst : List Char := chars!"
template [[host_name(\"custom_kernel_mlx_bun_trellis_gateup_codebook_row__bfloat16_t_17408_5120_256_2_3_12_32_1024_1_bfloat16_t_uint32_t_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_gateup_codebook_row__bfloat16_t_17408_5120_256_2_3_12_32_1024_1_bfloat16_t_uint32_t_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t<bfloat16_t, 17408, 5120, 256, 2, 3, 12, 32, 1024, 1>) custom_kernel_mlx_bun_trellis_gateup_codebook_row__bfloat16_t_17408_5120_256_2_3_12_32_1024_1_bfloat16_t_uint32_t_bfloat16_t_uint32_t_bfloat16_t_bfloat16_t<bfloat16_t, 17408, 5120, 256, 2, 3, 12, 32, 1024, 1>;
"
/-- Ten header functions (trellis decode and the codebook window), kernel, instantiation. -/
theorem gate_up_end_to_end : topCount .gateUp gateUpSig gateUpInst = some 12 := by decide +kernel

def downSig : List Char := chars!"template <typename T, int R, int C, int K, int L, int P, int U, int SPLITS, int THREADS, int INTERLEAVE>
[[kernel]] void custom_kernel_mlx_bun_trellis_down_codebook_row__bfloat16_t_17408_5120_2_12_16_2_128_256_0_bfloat16_t_uint32_t_bfloat16_t_float(
  const device bfloat16_t* x [[buffer(0)]],
  const device uint32_t* codes [[buffer(1)]],
  const device bfloat16_t* scales [[buffer(2)]],
  device float* partial [[buffer(3)]],
" ++ rmsAttrs
def downInst : List Char := chars!"
template [[host_name(\"custom_kernel_mlx_bun_trellis_down_codebook_row__bfloat16_t_17408_5120_2_12_16_2_128_256_0_bfloat16_t_uint32_t_bfloat16_t_float\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_down_codebook_row__bfloat16_t_17408_5120_2_12_16_2_128_256_0_bfloat16_t_uint32_t_bfloat16_t_float<bfloat16_t, 17408, 5120, 2, 12, 16, 2, 128, 256, 0>) custom_kernel_mlx_bun_trellis_down_codebook_row__bfloat16_t_17408_5120_2_12_16_2_128_256_0_bfloat16_t_uint32_t_bfloat16_t_float<bfloat16_t, 17408, 5120, 2, 12, 16, 2, 128, 256, 0>;
"
theorem down_partial_end_to_end : topCount .downPartial downSig downInst = some 12 := by decide +kernel

def foldSig : List Char := chars!"template <typename T, int C>
[[kernel]] void custom_kernel_mlx_bun_trellis_down_codebook_fold__bfloat16_t_5120_float_bfloat16_t(
  const device float* partial [[buffer(0)]],
  device bfloat16_t* out [[buffer(1)]],
  uint simdgroup_index_in_threadgroup [[simdgroup_index_in_threadgroup]],
  uint thread_index_in_simdgroup [[thread_index_in_simdgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"
def foldInst : List Char := chars!"
template [[host_name(\"custom_kernel_mlx_bun_trellis_down_codebook_fold__bfloat16_t_5120_float_bfloat16_t\")]] [[kernel]] decltype(custom_kernel_mlx_bun_trellis_down_codebook_fold__bfloat16_t_5120_float_bfloat16_t<bfloat16_t, 5120>) custom_kernel_mlx_bun_trellis_down_codebook_fold__bfloat16_t_5120_float_bfloat16_t<bfloat16_t, 5120>;
"
theorem down_fold_end_to_end : topCount .downFold foldSig foldInst = some 2 := by decide +kernel

def argmaxAttrs : List Char := chars!"  uint3 thread_position_in_threadgroup [[thread_position_in_threadgroup]],
  uint3 threadgroup_position_in_grid [[threadgroup_position_in_grid]]) {
"
def partialSig : List Char := chars!"template <typename T, int V, int P>
[[kernel]] void custom_kernel_normalized_argmax_partial__bfloat16_t_248320_243_bfloat16_t_bfloat16_t_float_uint32_t(
  const device bfloat16_t* logits [[buffer(0)]],
  const constant bfloat16_t* lse [[buffer(1)]],
  device float* values [[buffer(2)]],
  device uint32_t* indices [[buffer(3)]],
" ++ argmaxAttrs
def partialInst : List Char := chars!"
template [[host_name(\"custom_kernel_normalized_argmax_partial__bfloat16_t_248320_243_bfloat16_t_bfloat16_t_float_uint32_t\")]] [[kernel]] decltype(custom_kernel_normalized_argmax_partial__bfloat16_t_248320_243_bfloat16_t_bfloat16_t_float_uint32_t<bfloat16_t, 248320, 243>) custom_kernel_normalized_argmax_partial__bfloat16_t_248320_243_bfloat16_t_bfloat16_t_float_uint32_t<bfloat16_t, 248320, 243>;
"
theorem argmax_partial_end_to_end : topCount .argmaxPartial partialSig partialInst = some 3 := by decide +kernel

def finishSig : List Char := chars!"template <int P>
[[kernel]] void custom_kernel_normalized_argmax_finish__243_float_uint32_t_uint32_t(
  const device float* values [[buffer(0)]],
  const device uint32_t* indices [[buffer(1)]],
  device uint32_t* out [[buffer(2)]],
" ++ argmaxAttrs
def finishInst : List Char := chars!"
template [[host_name(\"custom_kernel_normalized_argmax_finish__243_float_uint32_t_uint32_t\")]] [[kernel]] decltype(custom_kernel_normalized_argmax_finish__243_float_uint32_t_uint32_t<243>) custom_kernel_normalized_argmax_finish__243_float_uint32_t_uint32_t<243>;
"
theorem argmax_finish_end_to_end : topCount .argmaxFinish finishSig finishInst = some 3 := by decide +kernel

end Metal.ParseTest
