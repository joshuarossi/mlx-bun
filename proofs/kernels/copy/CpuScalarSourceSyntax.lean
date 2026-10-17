import kernels.copy.ScalarCopySyntax
namespace Inference.Kernels.Copy.CpuScalarSourceSyntax
open ScalarCopySyntax (Tokens Parser accept nameToken wordChar decimal)
set_option maxRecDepth 10000

-- Restricted C++ grammar for array(0,dtype), scalar construction and init's
-- allocation/switch/std::copy. It is not a general C++ or standard-library
-- frontend; native object/pointer extraction and host ABI remain boundaries.
inductive Kind where | bf16 | fp32 deriving DecidableEq, Repr

def dtype : Kind → String | .bf16 => "bfloat16" | .fp32 => "float32"
def ctype : Kind → String | .bf16 => "bfloat16_t" | .fp32 => "float"
def itemBytes : Kind → Nat | .bf16 => 2 | .fp32 => 4

def skipBlock : Nat → List Char → Option (List Char)
  | 0,_ => none
  | _+1,[] => none
  | _+1,'*'::'/'::rest => some rest
  | fuel+1,_::rest => skipBlock fuel rest

def lexAux : Nat → List Char → Option Tokens
  | 0,_ => none
  | _+1,[] => some []
  | fuel+1,'/'::'*'::rest => do lexAux fuel (←skipBlock (rest.length+1) rest)
  | fuel+1,'/'::'/'::rest => lexAux fuel (rest.dropWhile (· != '\n'))
  | fuel+1,c::rest =>
    if c.isWhitespace then lexAux fuel rest
    else if wordChar c then do
      pure (String.ofList (c::rest.takeWhile wordChar)::(←lexAux fuel (rest.dropWhile wordChar)))
    else if ['(',')','{','}','<','>',';',',',':','&','*','+','=','.'].contains c then do
      pure (String.singleton c::(←lexAux fuel rest))
    else none

def tokenize (source : String) : Option Tokens := lexAux (source.length+1) source.toList

def accepts : List String → Tokens → Option Tokens
  | [],tokens => some tokens
  | expected::rest,tokens => do accepts rest (←accept expected tokens)

structure ZeroCall where
  value : Nat
  dtypeVariable : String
  deriving DecidableEq, Repr

def parseZeroCall (source : String) : Option ZeroCall := do
  let rest ←accepts ["array","("] (←tokenize source)
  let literal ←rest.head?
  let rest := rest.tail
  let value ←decimal literal
  let rest ←accept "," rest
  let (dtypeVariable,rest) ←nameToken rest
  let rest ←accept ")" rest
  if rest=[] then some ⟨value,dtypeVariable⟩ else none

structure Constructor where
  argumentType : String
  argument : String
  dtypeArgument : String
  descriptorDtype : String
  initArgument : String
  deriving DecidableEq, Repr

def parseConstructor (source : String) : Option Constructor := do
  let rest ←accepts ["template","<","typename","T",">","array",":",":","array","("] (←tokenize source)
  let (argumentType,rest) ←nameToken rest
  let (argument,rest) ←nameToken rest
  let rest ←accepts [",","Dtype"] rest
  let (dtypeArgument,rest) ←nameToken rest
  let rest ←accepts [")",":","array_desc_","(","std",":",":","make_shared","<","ArrayDesc",">","(","Shape","{","}",","] rest
  let (descriptorDtype,rest) ←nameToken rest
  let rest ←accepts [")",")","{","init","(","&"] rest
  let (initArgument,rest) ←nameToken rest
  let rest ←accepts [")",";","}"] rest
  if rest=[] then some ⟨argumentType,argument,dtypeArgument,descriptorDtype,initArgument⟩ else none

structure Copy where
  dtypeName : String
  begin : String
  endBase : String
  count : String
  outputType : String
  deriving DecidableEq, Repr

def copyCase : Parser Copy := fun tokens => do
  let rest ←accept "case" tokens
  let (dtypeName,rest) ←nameToken rest
  let rest ←accepts [":","std",":",":","copy","("] rest
  let (begin,rest) ←nameToken rest
  let rest ←accept "," rest
  let (endBase,rest) ←nameToken rest
  let rest ←accept "+" rest
  let (count,rest) ←nameToken rest
  let rest ←accepts ["(",")",",","data","<"] rest
  let (outputType,rest) ←nameToken rest
  let rest ←accepts [">","(",")",")",";","break",";"] rest
  pure (⟨dtypeName,begin,endBase,count,outputType⟩,rest)

def cases : Nat → Parser (List Copy)
  | 0 => fun _ => none
  | fuel+1 => fun tokens =>
    match tokens with
    | "case"::_ => do
      let (first,rest) ←copyCase tokens
      let (tail,rest) ←cases fuel rest
      pure (first::tail,rest)
    | _ => some ([],tokens)

structure Init where
  source : String
  allocationCount : String
  allocationDtype : String
  selector : String
  branches : List Copy
  deriving DecidableEq, Repr

def parseInit (source : String) : Option Init := do
  let tokens ←tokenize source
  let rest ←accepts ["template","<","typename","It",">","void","array",":",":","init","(","It"] tokens
  let (source,rest) ←nameToken rest
  let rest ←accepts [")","{","set_data","(","allocator",":",":","malloc","("] rest
  let (allocationCount,rest) ←nameToken rest
  let rest ←accepts ["(",")","*","size_of","("] rest
  let (allocationDtype,rest) ←nameToken rest
  let rest ←accepts ["(",")",")",")",")",";","switch","("] rest
  let (selector,rest) ←nameToken rest
  let rest ←accepts ["(",")",")","{"] rest
  let (branches,rest) ←cases tokens.length rest
  let rest ←accepts ["}","}"] rest
  if rest=[] then some ⟨source,allocationCount,allocationDtype,selector,branches⟩ else none

def selected (kind : Kind) (init : Init) : Option Copy :=
  init.branches.find? (fun branch => branch.dtypeName=dtype kind)

def zeroCallSource : String := "array(0, dtype)"
def constructorSource : String := r#"template <typename T>
array::array(T val, Dtype dtype /* = TypeToDtype<T>() */)
    : array_desc_(std::make_shared<ArrayDesc>(Shape{}, dtype)) {
  init(&val);
}"#
def initSource : String := r#"template <typename It>
void array::init(It src) {
  set_data(allocator::malloc(size() * size_of(dtype())));
  switch (dtype()) {
    case bool_:
      std::copy(src, src + size(), data<bool>());
      break;
    case uint8:
      std::copy(src, src + size(), data<uint8_t>());
      break;
    case uint16:
      std::copy(src, src + size(), data<uint16_t>());
      break;
    case uint32:
      std::copy(src, src + size(), data<uint32_t>());
      break;
    case uint64:
      std::copy(src, src + size(), data<uint64_t>());
      break;
    case int8:
      std::copy(src, src + size(), data<int8_t>());
      break;
    case int16:
      std::copy(src, src + size(), data<int16_t>());
      break;
    case int32:
      std::copy(src, src + size(), data<int32_t>());
      break;
    case int64:
      std::copy(src, src + size(), data<int64_t>());
      break;
    case float16:
      std::copy(src, src + size(), data<float16_t>());
      break;
    case float32:
      std::copy(src, src + size(), data<float>());
      break;
    case float64:
      std::copy(src, src + size(), data<double>());
      break;
    case bfloat16:
      std::copy(src, src + size(), data<bfloat16_t>());
      break;
    case complex64:
      std::copy(src, src + size(), data<complex64_t>());
      break;
  }
}"#

def constructor : Constructor := ⟨"T","val","dtype","dtype","val"⟩
def copy (kind : Kind) : Copy := ⟨dtype kind,"src","src","size",ctype kind⟩
theorem parsed_zero : parseZeroCall zeroCallSource=some ⟨0,"dtype"⟩ := by decide +kernel
theorem parsed_constructor : parseConstructor constructorSource=some constructor := by decide +kernel

-- Parsed numeric operands of the fallback constructor's selected non-NaN
-- update and final 16-bit assignment. The union/float representation is ABI.
structure Rounding where
  word : String
  member : String
  sourceWord : String
  sourceMember : String
  shift : Nat
  parityMask : Nat
  bias : Nat
  result : String
  resultWord : String
  resultMember : String
  resultShift : Nat
  deriving DecidableEq, Repr

def hexDigit (c : Char) : Option Nat :=
  if '0'≤c ∧ c≤'9' then some (c.toNat-'0'.toNat)
  else if 'A'≤c ∧ c≤'F' then some (c.toNat-'A'.toNat+10)
  else if 'a'≤c ∧ c≤'f' then some (c.toNat-'a'.toNat+10) else none

def hexAux : List Char → Nat → Option Nat
  | [],n => some n
  | c::rest,n => do hexAux rest (16*n+(←hexDigit c))
def number (token : String) : Option Nat :=
  match token.toList with
  | '0'::'x'::rest => if rest=[] then none else hexAux rest 0
  | _ => decimal token

def natural : Parser Nat := fun tokens => do
  let token ←tokens.head?
  pure (←number token,tokens.tail)

def member : Parser (String × String) := fun tokens => do
  let (word,rest) ←nameToken tokens
  let rest ←accept "." rest
  let (field,rest) ←nameToken rest
  pure ((word,field),rest)

def parseRounding (source : String) : Option Rounding := do
  let tokens ←tokenize source
  let ((word,field),rest) ←member tokens
  let rest ←accepts ["+","=","("] rest
  let ((sourceWord,sourceMember),rest) ←member rest
  let rest ←accepts [">",">"] rest
  let (shift,rest) ←natural rest
  let rest ←accept "&" rest
  let (mask,rest) ←natural rest
  let rest ←accepts [")","+","uint32_t","("] rest
  let (bias,rest) ←natural rest
  let rest ←accepts [")",";"] rest
  let (result,rest) ←nameToken rest
  let rest ←accept "=" rest
  let ((resultWord,resultMember),rest) ←member rest
  let rest ←accepts [">",">"] rest
  let (resultShift,rest) ←natural rest
  let rest ←accept ";" rest
  if rest=[] then some ⟨word,field,sourceWord,sourceMember,shift,mask,bias,result,resultWord,resultMember,resultShift⟩ else none

def roundingSource : String := r#"in.u += (in.u >> 16 & 1) + uint32_t(0x7FFF);

      // Take upper 16 bits
      bits_ = in.u >> 16;"#
def rounding : Rounding := ⟨"in","u","in","u",16,1,32767,"bits_","in","u",16⟩
theorem parsed_rounding : parseRounding roundingSource=some rounding := by decide +kernel

def initHeaderSource : String := r#"template <typename It>
void array::init(It src) {
  set_data(allocator::malloc(size() * size_of(dtype())));
  switch (dtype()) {
"#

def bf16CaseSource : String := r#"    case bfloat16:
      std::copy(src, src + size(), data<bfloat16_t>());
      break;"#

def fp32CaseSource : String := r#"    case float32:
      std::copy(src, src + size(), data<float>());
      break;"#
-- Only the selected switch case is retained in this path extraction. The
-- byte guard checks the actual full init and unique case spans; C++ switch
-- selection and standard-library correspondence remain reviewed boundaries.
def selectedInitSource (kind : Kind) : String :=
  initHeaderSource++(match kind with | .bf16 => bf16CaseSource | .fp32 => fp32CaseSource)++"\n  }\n}"
def selectedProgram (kind : Kind) : Init := ⟨"src","size","dtype","dtype",[copy kind]⟩
theorem parsed_selected_init (kind : Kind) : parseInit (selectedInitSource kind)=some (selectedProgram kind) := by
  cases kind <;> decide +kernel
end Inference.Kernels.Copy.CpuScalarSourceSyntax
