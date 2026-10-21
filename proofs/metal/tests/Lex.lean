import metal.Preprocess
import host.mlx.KernelSources
namespace Metal.LexTest
open Metal

/-! # Lexer and preprocessor tests

Every theorem is checked by kernel reduction (`decide +kernel`) of a Bool
checker. `chars!` writes explicit character cells (String literals reduce
slowly in the kernel). -/

def intBeq : Int → Int → Bool
  | .ofNat a, .ofNat b => Nat.beq a b
  | .negSucc a, .negSucc b => Nat.beq a b
  | _, _ => false

mutual
def tokBeq : Tok → Tok → Bool
  | .ident a, .ident b => charsBeq a b
  | .int v u l h, .int v' u' l' h' => Nat.beq v v' && u == u' && l == l' && h == h'
  | .float m e s, .float m' e' s' => Nat.beq m m' && intBeq e e' && s == s'
  | .str a, .str b => charsBeq a b
  | .punct a, .punct b => charsBeq a b
  | .pragma a, .pragma b => toksBeq a b
  | .defineObject n b, .defineObject n' b' => charsBeq n n' && toksBeq b b'
  | .defineFunction n ps b, .defineFunction n' ps' b' => charsBeq n n' && namesBeq ps ps' && toksBeq b b'
  | .err a, .err b => charsBeq a b
  | _, _ => false
def toksBeq : List Tok → List Tok → Bool
  | a :: as, b :: bs => tokBeq a b && toksBeq as bs
  | [], [] => true
  | _, _ => false
def namesBeq : List (List Char) → List (List Char) → Bool
  | a :: as, b :: bs => charsBeq a b && namesBeq as bs
  | [], [] => true
  | _, _ => false
end

/-! No `err` or `#define` token, at any depth. -/
mutual
def cleanTok : Tok → Bool
  | .err _ | .defineObject .. | .defineFunction .. => false
  | .pragma ts => clean ts
  | _ => true
def clean : List Tok → Bool
  | t :: r => cleanTok t && clean r
  | [] => true
end

def isPrefix : List Tok → List Tok → Bool
  | [], _ => true
  | p :: ps, t :: ts => tokBeq p t && isPrefix ps ts
  | _ :: _, [] => false

def hasInfix (p : List Tok) : List Tok → Bool
  | [] => isPrefix p []
  | t :: ts => isPrefix p (t :: ts) || hasInfix p ts

def hasIdent (n : List Char) : List Tok → Bool
  | .ident m :: ts => charsBeq n m || hasIdent n ts
  | _ :: ts => hasIdent n ts
  | [] => false

def lexes (s : List Char) (ts : List Tok) : Bool := toksBeq (lex s) ts

/-- Lexing ends in an `err` token. -/
def lexFails (s : List Char) : Bool := !noErr (lex s)

def pp (s : List Char) (ts : List Tok) : Bool :=
  match preprocess (lex s) with
  | some r => toksBeq r ts
  | none => false

def rejects (s : List Char) : Bool := (preprocess (lex s)).isNone

def I (s : List Char) : Tok := .ident s
def P (s : List Char) : Tok := .punct s
def N (v : Nat) : Tok := .int v false false false

/-! ## Lexer -/

theorem lex_float : lexes chars!"147.800537109375f 1e-6f 8388608.0f 256.0f 2.0 .5 1.e+2 0.0f"
    [.float 147800537109375 (-12) true, .float 1 (-6) true, .float 83886080 (-1) true,
     .float 2560 (-1) true, .float 20 (-1) false, .float 5 (-1) false, .float 1 2 false,
     .float 0 (-1) true] = true := by decide +kernel

theorem lex_int : lexes chars!"0x4B000000u 0xffffffffu 0x07 34038481u 2ul 0ul 1 7LU 0 0u"
    [.int 0x4B000000 true false true, .int 0xffffffff true false true, .int 7 false false true,
     .int 34038481 true false false, .int 2 true true false, .int 0 true true false,
     N 1, .int 7 true true false, N 0, .int 0 true false false] = true := by decide +kernel

/-- Longest match; `[[` is two tokens; `<::` not followed by `:` or `>` is `<` then `::`. -/
theorem lex_punct : lexes chars!"a<<=b>>=c<=d>=e==f!=g&&h||i::j->k++--+=-=*=/=%=&=|=^=[[x]]<::y ~!?."
    [I ['a'], P ['<', '<', '='], I ['b'], P ['>', '>', '='], I ['c'], P ['<', '='], I ['d'],
     P ['>', '='], I ['e'], P ['=', '='], I ['f'], P ['!', '='], I ['g'], P ['&', '&'], I ['h'],
     P ['|', '|'], I ['i'], P [':', ':'], I ['j'], P ['-', '>'], I ['k'], P ['+', '+'], P ['-', '-'],
     P ['+', '='], P ['-', '='], P ['*', '='], P ['/', '='], P ['%', '='], P ['&', '='], P ['|', '='],
     P ['^', '='], P ['['], P ['['], I ['x'], P [']'], P [']'], P ['<'], P [':', ':'], I ['y'],
     P ['~'], P ['!'], P ['?'], P ['.']] = true := by decide +kernel

/-- Comments are whitespace, with any characters inside; a `//` comment
continues over a spliced line; a block comment at a line start keeps the
next `#` a directive. -/
theorem lex_comments : lexes chars!"a/* · × ≤ — Ã\n*/b // c ≤ \\\n d\n/* x */ # pragma unroll\ne"
    [I ['a'], I ['b'], .pragma [I ['u', 'n', 'r', 'o', 'l', 'l']], I ['e']] = true := by decide +kernel

theorem lex_pragma : lexes chars!"  #pragma clang loop unroll_count(1)\nfor"
    [.pragma [I chars!"clang", I chars!"loop", I chars!"unroll_count", P ['('], N 1, P [')']],
     I chars!"for"] = true := by decide +kernel

theorem lex_define : lexes chars!"#define A (1.0f / 2)\n#define F(x, y) \\\n  ((x) + y) // z\n#define G() 1\n#define H (x)"
    [.defineObject ['A'] [P ['('], .float 10 (-1) true, P ['/'], N 2, P [')']],
     .defineFunction ['F'] [['x'], ['y']] [P ['('], P ['('], I ['x'], P [')'], P ['+'], I ['y'], P [')']],
     .defineFunction ['G'] [] [N 1],
     .defineObject ['H'] [P ['('], I ['x'], P [')']]] = true := by decide +kernel

theorem lex_string : lexes chars!"host_name(\"a\\\"b\\n\")"
    [I chars!"host_name", P ['('], .str ['a', '"', 'b', '\n'], P [')']] = true := by decide +kernel

/-- Outside the subset or invalid: character literals, octal, hexadecimal
floats, `h` suffix, `...`, `.*`, `->*`, digraphs, string prefixes, `$`,
non-ASCII outside comments, unterminated comments and strings, `#` within a
line, other directives, a bad parameter list. -/
theorem lex_errors :
    (lexFails chars!"'a'" && lexFails chars!"0777" && lexFails chars!"0x1p3" && lexFails chars!"1.0h"
      && lexFails chars!"f(...)" && lexFails chars!"a.*b" && lexFails chars!"a->*b" && lexFails chars!"a<:b"
      && lexFails chars!"<%" && lexFails chars!"%:" && lexFails chars!"L\"x\"" && lexFails chars!"\"x\"y"
      && lexFails chars!"$x" && lexFails chars!"x·y" && lexFails chars!"/* x" && lexFails chars!"\"x\ny\""
      && lexFails chars!"x # y" && lexFails chars!"#include <x>" && lexFails chars!"#define F(a,) a"
      && lexFails chars!"#define 1 2" && lexFails chars!"0x" && lexFails chars!"1e" && lexFails chars!"1..2")
      = true := by decide +kernel

/-! ## Preprocessor -/

theorem pp_object : pp chars!"#define A 1\nA + A" [N 1, P ['+'], N 1] = true := by decide +kernel

/-- A block comment spanning lines continues the directive (phase 3 makes it a space). -/
theorem pp_directive_comment : pp chars!"#define A 1 /* x\n y */ + 2\nA" [N 1, P ['+'], N 2] = true := by
  decide +kernel

/-- A macro is not re-expanded inside its own expansion. -/
theorem pp_self : pp chars!"#define A A + 1\n#define B C\n#define C B\nA B"
    [I ['A'], P ['+'], N 1, I ['B']] = true := by decide +kernel

/-- Arguments split at top-level commas only. -/
theorem pp_args : pp chars!"#define F(a, b) (b) * a\nF((1, 2), g(3, 4))"
    [P ['('], I ['g'], P ['('], N 3, P [','], N 4, P [')'], P [')'], P ['*'],
     P ['('], N 1, P [','], N 2, P [')']] = true := by decide +kernel

/-- Arguments are expanded before substitution; a function-like name not
followed by `(` stays. -/
theorem pp_prescan : pp chars!"#define A 5\n#define F(x) x x\nF(A) F + 1"
    [N 5, N 5, I ['F'], P ['+'], N 1] = true := by decide +kernel

/-- Rescanning with the following tokens: C11 6.10.3.4 EXAMPLE, `f(2)(9)` is `2*9*g`. -/
theorem pp_rescan : pp chars!"#define f(a) a*g\n#define g(a) f(a)\nf(2)(9)"
    [N 2, P ['*'], N 9, P ['*'], I ['g']] = true := by decide +kernel

theorem pp_empty_args : pp chars!"#define F(x) [x]\n#define G() 1\nF() G()"
    [P ['['], P [']'], N 1] = true := by decide +kernel

/-- Macros take effect from their definition; pragmas stay. -/
theorem pp_order : pp chars!"A\n#define A 1\nA\n#pragma unroll\nA"
    [I ['A'], N 1, .pragma [I chars!"unroll"], N 1] = true := by decide +kernel

theorem pp_rejects :
    (rejects chars!"#define F(a, b) a\nF(1)" && rejects chars!"#define G() 1\nG(1)"
      && rejects chars!"#define S(x) #x" && rejects chars!"#define C(a, b) a ## b"
      && rejects chars!"#define A 1\n#define A 1" && rejects chars!"#define F(x, x) x"
      && rejects chars!"#define F(x) x\nF(1" && rejects chars!"#define F(x) x\nF(\n#define A\n)"
      && rejects chars!"#define N 4\n#pragma unroll N" && rejects chars!"a $")
      = true := by decide +kernel

/-! ## Route kernels

Each kernel's header, a line feed, and its body, as `KernelSources` gives
them; MLX's assembly of the full compiled text is not modeled here. -/

def input (k : Host.Mlx.Kernel) : List Char :=
  Host.Mlx.SourceKernels.sources.header k ++ '\n' :: Host.Mlx.SourceKernels.sources.source k

/-- Preprocessing succeeds and leaves no `err` or `#define` token. -/
def ok (k : Host.Mlx.Kernel) : Bool :=
  match preprocess (lex (input k)) with
  | some ts => clean ts
  | none => false

/-- The preprocessed kernel contains each sequence. -/
def has (k : Host.Mlx.Kernel) (seqs : List (List Tok)) : Bool :=
  match preprocess (lex (input k)) with
  | some ts => seqs.all (hasInfix · ts)
  | none => false

theorem affineRow_ok : ok .affineRow = true := by decide +kernel
theorem siluRmsHeads_ok : ok .siluRmsHeads = true := by decide +kernel
theorem gatedDeltaStep_ok : ok .gatedDeltaStep = true := by decide +kernel
theorem gatedRmsNorm_ok : ok .gatedRmsNorm = true := by decide +kernel
theorem residualRmsNorm_ok : ok .residualRmsNorm = true := by decide +kernel
theorem gateUp_ok : ok .gateUp = true := by decide +kernel
theorem downPartial_ok : ok .downPartial = true := by decide +kernel
theorem downFold_ok : ok .downFold = true := by decide +kernel
theorem argmaxPartial_ok : ok .argmaxPartial = true := by decide +kernel
theorem argmaxFinish_ok : ok .argmaxFinish = true := by decide +kernel

/-- `accum += MLXQ_F(w[0] & 0x07) * x_thread[0];` expanded, the unroll
pragma, and no `MLXQ_F` left. -/
theorem affineRow_spots :
    (has .affineRow
      [[I chars!"accum", P ['+', '='], P ['('], I chars!"as_type", P ['<'], I chars!"float", P ['>'],
        P ['('], P ['('], I chars!"uint", P [')'], P ['('], I ['w'], P ['['], N 0, P [']'], P ['&'],
        .int 7 false false true, P [')'], P ['|'], .int 0x4B000000 true false true, P [')'], P ['-'],
        .float 83886080 (-1) true, P [')'], P ['*'], I chars!"x_thread", P ['['], N 0, P [']'], P [';']],
       [.pragma [I chars!"clang", I chars!"loop", I chars!"unroll_count", P ['('], N 1, P [')']],
        I chars!"for"]]
    && match preprocess (lex (input .affineRow)) with
       | some ts => !hasIdent chars!"MLXQ_F" ts
       | none => false) = true := by decide +kernel

/-- `return metal::precise::divide((float)trellis_y(s), 147.800537109375f);`,
`chunk[p >> 1] & 0xFFFF0000u :`, and `#pragma clang loop unroll(full)`. -/
theorem gateUp_spots :
    has .gateUp
      [[I chars!"return", I chars!"metal", P [':', ':'], I chars!"precise", P [':', ':'], I chars!"divide",
        P ['('], P ['('], I chars!"float", P [')'], I chars!"trellis_y", P ['('], I ['s'], P [')'], P [','],
        .float 147800537109375 (-12) true, P [')'], P [';']],
       [I chars!"chunk", P ['['], I ['p'], P ['>', '>'], N 1, P [']'], P ['&'],
        .int 0xFFFF0000 true false true, P [':']],
       [.pragma [I chars!"clang", I chars!"loop", I chars!"unroll", P ['('], I chars!"full", P [')']]]]
      = true := by decide +kernel

/-- `sum / float(DK) + 1e-6f` -/
theorem siluRmsHeads_spots :
    has .siluRmsHeads
      [[I chars!"sum", P ['/'], I chars!"float", P ['('], I chars!"DK", P [')'], P ['+'],
        .float 1 (-6) true, P [')']]] = true := by decide +kernel

/-- `2ul * WPB` and `bestId = 0xffffffffu;` -/
theorem downPartial_argmax_spots :
    (has .downPartial [[.int 2 true true false, P ['*'], I chars!"WPB"]]
      && has .argmaxFinish [[I chars!"bestId", P ['='], .int 0xffffffff true false true, P [';']]])
      = true := by decide +kernel

end Metal.LexTest
