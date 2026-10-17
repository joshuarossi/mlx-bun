import kernels.quantization.AffineInput4Syntax
namespace Inference.Kernels.Delta.ComputeGHostSyntax
open Copy.ScalarCopySyntax (Tokens Parser accept nameToken wordChar)
open Sampling.ArgmaxShuffleSyntax (acceptMany)
open Quantization.AffineInput4Syntax (number)
set_option maxRecDepth 20000

inductive Expr where
  | input : Nat→Expr
  | castF32 : Expr→Expr
  | exponential : Expr→Expr
  | negative : Expr→Expr
  | add : Expr→Expr→Expr
  | zeroLike : Expr→List Nat→List Nat→Expr
  | logaddexp : Expr→Expr→Expr
  | multiply : Expr→Expr→Expr
  deriving DecidableEq,Repr
abbrev Bindings := List (String×Expr)

def lexAux : Nat→List Char→Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,'/'::'/'::rest => lexAux fuel (rest.dropWhile (fun c=>c != '\n'))
  | fuel+1,c::rest =>
    if [' ','\n','\t','\r'].contains c then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['(',')','[',']','{','}',',',';','=','!','.',':','?','>'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest)) else none

def lines : List Char→List (List Char)
  | [] => [[]]
  | '\n'::rest => []::lines rest
  | c::rest => match lines rest with
    | [] => [[c]]
    | head::tail => (c::head)::tail

def tokenizeLines : List (List Char)→Option Tokens
  | [] => some []
  | line::rest => do
    let head ←lexAux (line.length+1) line
    let tail ←tokenizeLines rest
    pure (head++tail)
def tokenize (source : String) := tokenizeLines (lines source.toList)

def lookup (bindings : Bindings) (name : String) : Option Expr := (bindings.find? (fun pair=>pair.1=name)).map Prod.snd
def bind (bindings : Bindings) (name : String) (value : Expr) : Bindings := (name,value)::bindings

def capture : Parser (String×Expr) := fun ts=>do
  let (name,ts) ←nameToken ts
  let ts ←acceptMany ["=","inp","["] ts
  let (index,ts) ←number ts
  let ts ←acceptMany ["]","!"] ts
  pure ((name,.input index),ts)

def captures : Parser Bindings := fun ts=>do
  let ts ←accept "const" ts
  let (a,ts) ←capture ts
  let ts ←accept "," ts
  let (b,ts) ←capture ts
  let ts ←accept "," ts
  let (c,ts) ←capture ts
  pure ([c,b,a],←accept ";" ts)

def target : Parser String := fun ts=>do
  let ts ←accept "const" ts
  let (name,ts) ←nameToken ts
  pure (name,←accept "=" ts)

def cast (bindings : Bindings) : Parser Bindings := fun ts=>do
  let (name,ts) ←target ts
  let (source,ts) ←nameToken ts
  let ts ←acceptMany [".","astype","(","Dtype",".","float32",")",";"] ts
  pure (bind bindings name (.castF32 (←lookup bindings source)),ts)

def unary (bindings : Bindings) : Parser Bindings := fun ts=>do
  let (name,ts) ←target ts
  let ts ←acceptMany ["ops","."] ts
  let (operation,ts) ←nameToken ts
  let ts ←accept "(" ts
  let (source,ts) ←nameToken ts
  let ts ←acceptMany [")",";"] ts
  let value ←lookup bindings source
  let expr ←if operation="exp" then some (.exponential value) else if operation="neg" then some (.negative value) else none
  pure (bind bindings name expr,ts)

def binary (bindings : Bindings) : Parser Bindings := fun ts=>do
  let (name,ts) ←target ts
  let ts ←acceptMany ["ops","."] ts
  let (operation,ts) ←nameToken ts
  let ts ←accept "(" ts
  let (left,ts) ←nameToken ts
  let ts ←accept "," ts
  let (right,ts) ←nameToken ts
  let ts ←acceptMany [")",";"] ts
  let left ←lookup bindings left
  let right ←lookup bindings right
  let expr ←if operation="add" then some (.add left right) else if operation="logaddexp" then some (.logaddexp left right)
    else if operation="mul" then some (.multiply left right) else none
  pure (bind bindings name expr,ts)

def dispose (bindings : Bindings) : Parser Bindings := fun ts=>do
  let (name,ts) ←nameToken ts
  let ts ←acceptMany [".","dispose","(",")",";"] ts
  let _ ←lookup bindings name
  pure (bindings.filter (fun pair=>pair.1 != name),ts)

def bytes : Parser (List Nat) := fun ts=>do
  let ts ←acceptMany ["new","Uint8Array","(","["] ts
  let rec items : Nat→Tokens→Option (List Nat×Tokens)
    | 0,_ => none
    | fuel+1,ts => do
      let (value,ts) ←number ts
      match ts with
      | ","::ts => do let (rest,ts) ←items fuel ts; pure (value::rest,ts)
      | _ => pure ([value],ts)
  let (values,ts) ←items 8 ts
  pure (values,←acceptMany ["]",")"] ts)

def zero (bindings : Bindings) : Parser Bindings := fun ts=>do
  let (bytesName,ts) ←target ts
  let (dtypeSource,ts) ←nameToken ts
  let ts ←acceptMany [".","dtype","=","=","=","Dtype",".","float32","?"] ts
  let (fp,ts) ←bytes ts
  let ts ←accept ":" ts
  let (bf,ts) ←bytes ts
  let ts ←accept ";" ts
  let (name,ts) ←target ts
  let ts ←acceptMany ["MlxArray",".","fromBytesCopy","("] ts
  let (sameBytes,ts) ←nameToken ts
  let ts ←acceptMany [",","[","]",","] ts
  let (sameDtype,ts) ←nameToken ts
  let ts ←acceptMany [".","dtype",")",";"] ts
  if sameBytes=bytesName ∧ sameDtype=dtypeSource then
    pure (bind bindings name (.zeroLike (←lookup bindings dtypeSource) fp bf),ts) else none

def parseTokens (ts : Tokens) : Option Expr := do
  let (env,ts) ←captures ts
  let (env,ts) ←cast env ts
  let (env,ts) ←unary env ts
  let (env,ts) ←dispose env ts
  let (env,ts) ←unary env ts
  let (env,ts) ←dispose env ts
  let (env,ts) ←binary env ts
  let (env,ts) ←zero env ts
  let (env,ts) ←binary env ts
  let (env,ts) ←dispose env ts
  let (env,ts) ←dispose env ts
  let (env,ts) ←binary env ts
  let (env,ts) ←dispose env ts
  let (env,ts) ←dispose env ts
  let (env,ts) ←unary env ts
  let (env,ts) ←dispose env ts
  let ts ←acceptMany ["return","["] ts
  let (result,ts) ←nameToken ts
  let ts ←acceptMany ["]",";"] ts
  if ts=[] then lookup env result else none

def parse (source : String) : Option Expr := do parseTokens (←tokenize source)

def callerSource : String := "return _computeGFn.apply([aLog, a, dtBias])[0]!;"
def parseCaller (source : String) : Option Unit := do
  let ts ←tokenize source
  let ts ←acceptMany ["return","_computeGFn",".","apply","(","[","aLog",",","a",",","dtBias","]",")","[","0","]","!",";"] ts
  if ts=[] then some () else none

def body : Expr := .exponential (.multiply (.negative (.exponential (.castF32 (.input 0))))
  (.logaddexp (.add (.input 1) (.input 2)) (.zeroLike (.add (.input 1) (.input 2)) [0,0,0,0] [0,0])))
theorem parsed_caller : parseCaller callerSource=some () := by rfl

def sourceBody : String := r#"const aL = inp[0]!, aa = inp[1]!, dt = inp[2]!;
      const aLogF = aL.astype(Dtype.float32);
      const expA = ops.exp(aLogF); aLogF.dispose();
      const negExpA = ops.neg(expA); expA.dispose();
      const adt = ops.add(aa, dt);
      // mlx nn.softplus(x) = mx.logaddexp(x, 0), where 0 is a weak Python int
      // (no cast node). ops.softplus builds the 0 via scalarLike (fromFloat32 →
      // f32→bf16 AsType). Build the 0 at adt's dtype from raw bytes so there is
      // no cast — matching mlx's graph exactly.
      const zbytes = adt.dtype === Dtype.float32
        ? new Uint8Array([0, 0, 0, 0])
        : new Uint8Array([0, 0]);
      const zero = MlxArray.fromBytesCopy(zbytes, [], adt.dtype);
      const sp = ops.logaddexp(adt, zero); adt.dispose(); zero.dispose();
      const prod = ops.mul(negExpA, sp); negExpA.dispose(); sp.dispose();
      const g = ops.exp(prod); prod.dispose();
      return [g];"#
def bodyTokens : Tokens := ["const","aL","=","inp","[","0","]","!",",","aa","=","inp","[","1","]","!",",","dt","=","inp","[","2","]","!",";","const","aLogF","=","aL",".","astype","(","Dtype",".","float32",")",";","const","expA","=","ops",".","exp","(","aLogF",")",";","aLogF",".","dispose","(",")",";","const","negExpA","=","ops",".","neg","(","expA",")",";","expA",".","dispose","(",")",";","const","adt","=","ops",".","add","(","aa",",","dt",")",";","const","zbytes","=","adt",".","dtype","=","=","=","Dtype",".","float32","?","new","Uint8Array","(","[","0",",","0",",","0",",","0","]",")",":","new","Uint8Array","(","[","0",",","0","]",")",";","const","zero","=","MlxArray",".","fromBytesCopy","(","zbytes",",","[","]",",","adt",".","dtype",")",";","const","sp","=","ops",".","logaddexp","(","adt",",","zero",")",";","adt",".","dispose","(",")",";","zero",".","dispose","(",")",";","const","prod","=","ops",".","mul","(","negExpA",",","sp",")",";","negExpA",".","dispose","(",")",";","sp",".","dispose","(",")",";","const","g","=","ops",".","exp","(","prod",")",";","prod",".","dispose","(",")",";","return","[","g","]",";"]
-- Token extraction is checked against the complete pinned host body by the
-- source binding guard; the kernel checks the grammar and data dependencies.
theorem parsed_body : parseTokens bodyTokens=some body := by rfl
end Inference.Kernels.Delta.ComputeGHostSyntax
