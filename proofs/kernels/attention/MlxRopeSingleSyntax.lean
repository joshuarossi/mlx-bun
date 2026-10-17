import kernels.normalization.MlxRmsLoopSyntax

namespace Inference.Kernels.Attention.MlxRopeSingleSyntax
open Normalization.MlxRmsLoopSyntax (word acceptAll)
open Copy.ScalarCopySyntax (Tokens Parser)
set_option maxRecDepth 10000

def lex : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,c::rest =>
    if [' ','\n','\t','\r'].contains c then lex fuel rest
    else if word c then do
      pure (String.ofList (c::rest.takeWhile word)::(←lex fuel (rest.dropWhile word)))
    else if ['(',')','[',']',';','=','+','-','*','<','>',':','.','/'].contains c then do
      pure (String.singleton c::(←lex fuel rest)) else none

def tokenize (s : String) : Option Tokens := lex (s.length+1) s.toList

inductive Index where
  | lane | head | stride | grid | first
  | add : Index → Index → Index
  | mul : Index → Index → Index
  deriving DecidableEq, Repr

def atom : Parser Index
  | "pos"::"."::"x"::rest => some (.lane,rest)
  | "pos"::"."::"y"::rest => some (.head,rest)
  | "grid"::"."::"x"::rest => some (.grid,rest)
  | "stride"::rest => some (.stride,rest)
  | "index_1"::rest => some (.first,rest)
  | _ => none

def product (ts : Tokens) : Option (Index × Tokens) := do
  let (a,rest) ←atom ts
  match rest with
  | "*"::rest => do let (b,rest) ←atom rest; pure (.mul a b,rest)
  | _ => pure (a,rest)

def sum (ts : Tokens) : Option (Index × Tokens) := do
  let (a,rest) ←product ts
  match rest with
  | "+"::rest => do let (b,rest) ←product rest; pure (.add a b,rest)
  | _ => pure (a,rest)

structure Indices where
  first : Index
  second : Index
  deriving DecidableEq, Repr

def parseIndices (s : String) : Option Indices := do
  let ts ←tokenize s
  let rest ←acceptAll ["index_1","="] ts
  let (a,rest) ←sum rest
  let rest ←acceptAll [";","index_2","="] rest
  let (b,rest) ←sum rest
  let rest ←acceptAll [";"] rest
  if rest=[] then some ⟨a,b⟩ else none

def sourceIndices : String := r#"index_1 = pos.x + pos.y * stride;
    index_2 = index_1 + grid.x;"#
def indices : Indices := ⟨.add .lane (.mul .head .stride),.add .first .grid⟩
theorem parsed_indices : parseIndices sourceIndices=some indices := by decide +kernel

-- Fixed typed scalar production: both BF16 loads precede both stores. The
-- forward arithmetic shell is validated separately from platform contraction.
inductive Cell where | forwardPair deriving DecidableEq, Repr

def parseCell (s : String) : Option Cell := do
  let ts ←tokenize s
  let rest ←acceptAll ["float","x1","=","static_cast","<","float",">","(","in","[","index_1","]",")",";","float","x2","=","static_cast","<","float",">","(","in","[","index_2","]",")",";"] ts
  let rest ←acceptAll ["rx1","=","x1","*","costheta","-","x2","*","sintheta",";",
    "rx2","=","x1","*","sintheta","+","x2","*","costheta",";"] rest
  let rest ←acceptAll ["out","[","index_1","]","=","static_cast","<","T",">","(","rx1",")",";",
    "out","[","index_2","]","=","static_cast","<","T",">","(","rx2",")",";"] rest
  if rest=[] then some .forwardPair else none

def sourceCell : String := r#"float x1 = static_cast<float>(in[index_1]);
  float x2 = static_cast<float>(in[index_2]);
rx1 = x1 * costheta - x2 * sintheta;
    rx2 = x1 * sintheta + x2 * costheta;
out[index_1] = static_cast<T>(rx1);
  out[index_2] = static_cast<T>(rx2);"#
theorem parsed_cell : parseCell sourceCell=some .forwardPair := by decide +kernel

def eval (lane head stride grid first : Nat) : Index → Nat
  | .lane => lane | .head => head | .stride => stride | .grid => grid | .first => first
  | .add a b => eval lane head stride grid first a + eval lane head stride grid first b
  | .mul a b => eval lane head stride grid first a * eval lane head stride grid first b

def positions (ast : Indices) (lane head stride grid : Nat) : Nat × Nat :=
  let first := eval lane head stride grid 0 ast.first
  (first,eval lane head stride grid first ast.second)

theorem selected_positions (lane : Fin 32) (head : Fin rows) :
    positions indices lane.val head.val 256 32=(256*head.val+lane.val,256*head.val+lane.val+32) := by
  simp [positions,indices,eval,Nat.mul_comm,Nat.add_comm]

theorem selected_range (lane : Fin 32) (head : Fin rows) :
    (positions indices lane.val head.val 256 32).2<256*rows := by
  rw [selected_positions]; have := lane.isLt; have := head.isLt; dsimp; omega

inductive Angle where | single deriving DecidableEq, Repr

def parseAngle (s : String) : Option Angle := do
  let ts ←tokenize s
  let rest ←acceptAll ["float","d","=","static_cast","<","float",">","(","pos",".","x",")","/","static_cast","<","float",">","(","grid",".","x",")",";",
    "float","inv_freq","=","metal",":",":","exp2","(","-","d","*","base",")",";",
    "float","L","=","scale","*","static_cast","<","float",">","(","offset",")",";",
    "float","theta","=","L","*","inv_freq",";",
    "float","costheta","=","metal",":",":","fast",":",":","cos","(","theta",")",";",
    "float","sintheta","=","metal",":",":","fast",":",":","sin","(","theta",")",";"] ts
  if rest=[] then some .single else none

def sourceAngle : String := r#"float d = static_cast<float>(pos.x) / static_cast<float>(grid.x);
  float inv_freq = metal::exp2(-d * base);
float L = scale * static_cast<float>(offset);
float theta = L * inv_freq;
  float costheta = metal::fast::cos(theta);
  float sintheta = metal::fast::sin(theta);"#
theorem parsed_angle : parseAngle sourceAngle=some .single := by decide +kernel

end Inference.Kernels.Attention.MlxRopeSingleSyntax
