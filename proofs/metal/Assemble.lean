import host.mlx.Value
import host.ts.Source

namespace Metal.Assemble
open Host.Mlx

/-! # Custom-kernel source assembly (MLX v0.32.2)

The text MLX compiles for a custom kernel built with `mlx_fast_metal_kernel_new`
and applied with `mlx_fast_metal_kernel_apply`: `metal::utils() + source_`
(mlx/backend/metal/custom_kernel.cpp:50-53), where `source_` is the text below,
written by mlx/backend/common/metal_kernel.cpp (ml-explore/mlx@1f8e74e3):
the header, `write_signature`'s template line and parameter list, the body,
`"\n}\n"`, and the explicit instantiation (:327-349). `metal::utils()` is not
modelled here.

Texts are byte lists (one `Char` per UTF-8 byte, as `KernelSources` keeps
them); MLX's `std::string::find` is byte substring search (`contains`).
AssembleSourceBinding.ts checks the attribute table, the constant-space
bound and `typeString` against the pinned C++ text. -/

/-! ## Byte texts -/

/-- `pattern` occurs in `text` at the front. -/
def startsWith : List Char → List Char → Bool
  | _, [] => true
  | [], _ :: _ => false
  | c :: cs, p :: ps => c == p && startsWith cs ps

/-- `text.find(pattern) != std::string::npos`. -/
def contains : List Char → List Char → Bool
  | [], pattern => startsWith [] pattern
  | c :: cs, pattern => startsWith (c :: cs) pattern || contains cs pattern

theorem startsWith_iff (text pattern : List Char) :
    startsWith text pattern = true ↔ ∃ rest, text = pattern ++ rest := by
  induction pattern generalizing text with
  | nil => simp [startsWith]
  | cons p ps ih =>
    cases text with
    | nil => simp [startsWith]
    | cons c cs =>
      simp only [startsWith, Bool.and_eq_true, beq_iff_eq, ih, List.cons_append, List.cons.injEq,
        exists_and_left]

theorem contains_iff (text pattern : List Char) :
    contains text pattern = true ↔ ∃ before after, text = before ++ pattern ++ after := by
  induction text with
  | nil =>
    rw [contains, startsWith_iff]
    constructor
    · rintro ⟨rest, h⟩; exact ⟨[], rest, h⟩
    · rintro ⟨before, after, h⟩
      rw [eq_comm, List.append_eq_nil_iff, List.append_eq_nil_iff] at h
      exact ⟨[], by rw [h.1.2]; rfl⟩
  | cons c cs ih =>
    rw [contains, Bool.or_eq_true, startsWith_iff, ih]
    constructor
    · rintro (⟨rest, h⟩ | ⟨before, after, h⟩)
      · exact ⟨[], rest, h⟩
      · exact ⟨c :: before, after, by rw [h]; rfl⟩
    · rintro ⟨before, after, h⟩
      cases before with
      | nil => exact .inl ⟨after, h⟩
      | cons b bs =>
        simp only [List.cons_append, List.cons.injEq] at h
        exact .inr ⟨bs, after, h.2⟩

/-- `sep`-separated concatenation. -/
def joinWith (sep : List Char) : List (List Char) → List Char
  | [] => []
  | [x] => x
  | x :: xs => x ++ sep ++ joinWith sep xs

/-- Decimal digits of `n` (`std::to_string`, `operator<<` on a non-negative value). -/
def decimalAux : Nat → Nat → List Char → List Char
  | 0, _, acc => acc
  | fuel + 1, n, acc =>
    if n < 10 then Char.ofNat (48 + n) :: acc
    else decimalAux fuel (n / 10) (Char.ofNat (48 + n % 10) :: acc)

def decimal (n : Nat) : List Char := decimalAux (n + 1) n []

/-- `operator<<` on an `int`. -/
def intText : Int → List Char
  | .ofNat n => decimal n
  | .negSucc n => '-' :: decimal (n + 1)

theorem decimal_examples :
    decimal 0 = ['0'] ∧ decimal 7 = ['7'] ∧ decimal 10 = ['1', '0'] ∧
      decimal 897988541 = chars!"897988541" ∧ intText (-12) = chars!"-12" := by decide

/-! ## MLX constants -/

/-- mlx/backend/common/compiled.cpp:31-67 `get_type_string`; its `default`
branch throws, and every `Dtype` has a case. -/
def typeString : Dtype → Option (List Char)
  | .float32 => some chars!"float"
  | .float16 => some chars!"float16_t"
  | .bfloat16 => some chars!"bfloat16_t"
  | .float64 => some chars!"double"
  | .complex64 => some chars!"complex64_t"
  | .bool => some chars!"bool"
  | .int8 => some chars!"int8_t"
  | .int16 => some chars!"int16_t"
  | .int32 => some chars!"int32_t"
  | .int64 => some chars!"int64_t"
  | .uint8 => some chars!"uint8_t"
  | .uint16 => some chars!"uint16_t"
  | .uint32 => some chars!"uint32_t"
  | .uint64 => some chars!"uint64_t"

theorem typeString_isSome (d : Dtype) : (typeString d).isSome := by cases d <;> rfl

/-- metal_kernel.cpp:18: inputs with fewer elements go in the constant address space. -/
def maxConstantArraySize : Nat := 8

/-- metal_kernel.cpp:243-264: built-in attributes and their parameter types,
in MLX's order. -/
def metalAttributes : List (List Char × List Char) := [
  (chars!"dispatch_quadgroups_per_threadgroup", chars!"uint"),
  (chars!"dispatch_simdgroups_per_threadgroup", chars!"uint"),
  (chars!"dispatch_threads_per_threadgroup", chars!"uint3"),
  (chars!"grid_origin", chars!"uint3"),
  (chars!"grid_size", chars!"uint3"),
  (chars!"quadgroup_index_in_threadgroup", chars!"uint"),
  (chars!"quadgroups_per_threadgroup", chars!"uint"),
  (chars!"simdgroup_index_in_threadgroup", chars!"uint"),
  (chars!"simdgroups_per_threadgroup", chars!"uint"),
  (chars!"thread_execution_width", chars!"uint"),
  (chars!"thread_index_in_quadgroup", chars!"uint"),
  (chars!"thread_index_in_simdgroup", chars!"uint"),
  (chars!"thread_index_in_threadgroup", chars!"uint"),
  (chars!"thread_position_in_grid", chars!"uint3"),
  (chars!"thread_position_in_threadgroup", chars!"uint3"),
  (chars!"threadgroup_position_in_grid", chars!"uint3"),
  (chars!"threadgroups_per_grid", chars!"uint3"),
  (chars!"threads_per_grid", chars!"uint3"),
  (chars!"threads_per_simdgroup", chars!"uint"),
  (chars!"threads_per_threadgroup", chars!"uint3")]

/-! ## Arguments -/

/-- An input array as `write_signature` sees it: the name given to
`metal_kernel`, the array's dtype and shape. -/
structure Input where
  name : List Char
  dtype : Dtype
  shape : List Nat

def Input.size (i : Input) : Nat := i.shape.foldr (· * ·) 1

/-- A template argument (`std::variant<int, bool, Dtype>`, metal_kernel.h). -/
inductive TemplateArg where
  | int (name : List Char) (value : Int)
  | bool (name : List Char) (value : Bool)
  | dtype (name : List Char) (value : Dtype)

def TemplateArg.name : TemplateArg → List Char
  | .int n _ | .bool n _ | .dtype n _ => n

/-- metal_kernel.cpp:73-80. -/
def TemplateArg.paramType : TemplateArg → List Char
  | .int .. => chars!"int"
  | .bool .. => chars!"bool"
  | .dtype .. => chars!"typename"

/-- metal_kernel.cpp:188-194: `operator<<` on the value (`bool` prints `1`/`0`). -/
def TemplateArg.text : TemplateArg → Option (List Char)
  | .int _ v => some (intText v)
  | .bool _ b => some (if b then ['1'] else ['0'])
  | .dtype _ d => typeString d

/-- The value is a C++ `int`. -/
def TemplateArg.representable : TemplateArg → Bool
  | .int _ v => decide (-2147483648 ≤ v ∧ v < 2147483648)
  | _ => true

/-! ## Name -/

/-- metal_kernel.cpp:179-199 `write_template`: `<v1, v2, …>`. -/
def templateDef (args : List TemplateArg) : Option (List Char) := do
  let values ← args.mapM TemplateArg.text
  pure ('<' :: joinWith chars!", " values ++ ['>'])

/-- metal_kernel.cpp:204-215: `<`, `>` and `, ` become `_`. -/
def hashChars : List Char → List Char
  | [] => []
  | ',' :: ' ' :: rest => '_' :: hashChars rest
  | c :: rest => (if c = '<' ∨ c = '>' then '_' else c) :: hashChars rest

/-- metal_kernel.cpp:201-218 `make_template_hash` (with :216's `pop_back`). -/
def templateHash (templateDef : List Char) : List Char := (hashChars templateDef).dropLast

theorem templateHash_example :
    templateHash chars!"<bfloat16_t, 3, -1>" = chars!"_bfloat16_t_3_-1" := by decide

/-- metal_kernel.cpp:313-321: an input's name suffix. -/
def inputSuffix (i : Input) : Option (List Char) := do
  let t ← typeString i.dtype
  pure ('_' :: t ++
    (if i.shape.isEmpty then ['s'] else if i.size < maxConstantArraySize then ['c'] else []))

/-- metal_kernel.cpp:301-325 `kernel_name`. -/
def kernelName (name : List Char) (inputs : List Input) (outputDtypes : List Dtype)
    (args : List TemplateArg) : Option (List Char) := do
  let template ← if args.isEmpty then pure [] else do
    let d ← templateDef args
    pure ('_' :: templateHash d)
  let ins ← inputs.mapM inputSuffix
  let outs ← outputDtypes.mapM fun d => do
    let t ← typeString d
    pure ('_' :: t)
  pure (chars!"custom_kernel_" ++ name ++ template ++ ins.flatten ++ outs.flatten)

/-! ## Signature -/

/-- metal_kernel.cpp:236-242: whether the body mentions `n_shape`, `n_strides`,
`n_ndim` (the body only, not the header). -/
def shapeInfo (source name : List Char) : Bool × Bool × Bool :=
  (contains source (name ++ chars!"_shape"), contains source (name ++ chars!"_strides"),
    contains source (name ++ chars!"_ndim"))

/-- metal_kernel.cpp:266-271: a parameter for each table attribute the body
mentions (substring search: comments count, and `threads_per_threadgroup`,
`simdgroups_per_threadgroup`, `quadgroups_per_threadgroup` match inside their
`dispatch_` forms). -/
def attributes (source : List Char) : List (List Char) :=
  metalAttributes.filterMap fun (attr, type) =>
    if contains source attr then
      some (chars!"  " ++ type ++ [' '] ++ attr ++ chars!" [[" ++ attr ++ chars!"]]")
    else none

def bufferAttr (index : Nat) : List Char := chars!" [[buffer(" ++ decimal index ++ chars!")]]"

/-- metal_kernel.cpp:116-135: the shape, strides and ndim parameters from
buffer `index`, and the next index. -/
def shapeLines (name : List Char) (info : Bool × Bool × Bool) (index : Nat) : List Char × Nat :=
  let (a, index) := if info.1 then
    (chars!"  const constant int* " ++ name ++ chars!"_shape" ++ bufferAttr index ++ chars!",\n", index + 1)
    else ([], index)
  let (b, index) := if info.2.1 then
    (chars!"  const constant int64_t* " ++ name ++ chars!"_strides" ++ bufferAttr index ++ chars!",\n", index + 1)
    else ([], index)
  let (c, index) := if info.2.2 then
    (chars!"  const constant int& " ++ name ++ chars!"_ndim" ++ bufferAttr index ++ chars!",\n", index + 1)
    else ([], index)
  (a ++ b ++ c, index)

/-- metal_kernel.cpp:95-136: the input parameters from buffer `index`, and
the next index. -/
def inputLines (source : List Char) : List Input → Nat → Option (List Char × Nat)
  | [], index => some ([], index)
  | i :: rest, index => do
    let t ← typeString i.dtype
    let location := if i.size < maxConstantArraySize then chars!"constant" else chars!"device"
    let ref := if i.shape.isEmpty then ['&'] else ['*']
    let line := chars!"  const " ++ location ++ [' '] ++ t ++ ref ++ [' '] ++ i.name ++ bufferAttr index ++ chars!",\n"
    let (extra, next) :=
      if i.shape.isEmpty then ([], index + 1) else shapeLines i.name (shapeInfo source i.name) (index + 1)
    let (more, last) ← inputLines source rest next
    pure (line ++ extra ++ more, last)

/-- metal_kernel.cpp:137-162: the output parameters from buffer `index`
(`atomic<T>` with atomic outputs, :143-149). An
output ends in `,\n` iff `index < inputs.size() + output_names.size() - 1 ||
attributes.size() > 0` (:155-156), `bound` being the left side's bound;
`index` counts the shape buffers, so with any of them and no attributes an
output before the last can end in `) {\n`. -/
def outputLines (atomic : Bool) (bound : Nat) (hasAttributes : Bool) :
    List (List Char × Dtype) → Nat → Option (List Char)
  | [], _ => some []
  | (name, d) :: rest, index => do
    let t ← typeString d
    let type := if atomic then chars!"atomic<" ++ t ++ ['>'] else t
    let sep := if decide (index < bound) || hasAttributes then chars!",\n" else chars!") {\n"
    let more ← outputLines atomic bound hasAttributes rest (index + 1)
    pure (chars!"  device " ++ type ++ chars!"* " ++ name ++ bufferAttr index ++ sep ++ more)

/-- metal_kernel.cpp:164-173. -/
def attributeLines : List (List Char) → List Char
  | [] => []
  | [a] => a ++ chars!") {\n"
  | a :: rest => a ++ chars!",\n" ++ attributeLines rest

/-- metal_kernel.cpp:69-90: `template <int N, typename T, …>\n`. -/
def templateLine (args : List TemplateArg) : List Char :=
  if args.isEmpty then []
  else chars!"template <" ++ joinWith chars!", " (args.map fun a => a.paramType ++ [' '] ++ a.name) ++ chars!">\n"

/-- metal_kernel.cpp:69-173: what `write_signature` writes between the header
and the body. -/
def signature (kernelName source : List Char) (inputs : List Input) (outputNames : List (List Char))
    (outputDtypes : List Dtype) (args : List TemplateArg) (atomic : Bool) : Option (List Char) := do
  let attrs := attributes source
  let (ins, index) ← inputLines source inputs 0
  let outs ← outputLines atomic (inputs.length + outputNames.length - 1) (!attrs.isEmpty)
    (outputNames.zip outputDtypes) index
  pure (templateLine args ++ chars!"[[kernel]] void " ++ kernelName ++ chars!"(\n" ++ ins ++ outs ++
    attributeLines attrs)

/-- metal_kernel.cpp:340-349: the explicit instantiation under the kernel's name. -/
def instantiation (kernelName : List Char) (args : List TemplateArg) : Option (List Char) :=
  if args.isEmpty then some [] else do
    let d ← templateDef args
    let full := kernelName ++ d
    pure (chars!"\ntemplate [[host_name(\"" ++ kernelName ++ chars!"\")]] [[kernel]] decltype(" ++ full ++
      chars!") " ++ full ++ chars!";\n")

/-! ## Assembly -/

/-- The kernel source MLX compiles after `metal::utils()`
(metal_kernel.cpp:231-234, 295-297 reject no outputs and mismatched counts;
:301-349 build the text). `none` also when a dtype has no type string or an
`int` argument is no C++ `int`. -/
def assemble (name : List Char) (inputs : List Input) (outputNames : List (List Char))
    (outputDtypes : List Dtype) (source header : List Char) (args : List TemplateArg) (atomic : Bool) :
    Option (List Char) :=
  if outputNames.isEmpty || outputNames.length != outputDtypes.length || !args.all TemplateArg.representable
  then none
  else do
    let k ← kernelName name inputs outputDtypes args
    let sig ← signature k source inputs outputNames outputDtypes args atomic
    let inst ← instantiation k args
    pure (header ++ sig ++ source ++ chars!"\n}\n" ++ inst)

theorem assemble_noOutputs (name : List Char) (inputs : List Input) (outputDtypes : List Dtype)
    (source header : List Char) (args : List TemplateArg) (atomic : Bool) :
    assemble name inputs [] outputDtypes source header args atomic = none := rfl

/-- A shape buffer shifts the outputs' indices: with no attributes, the first
of two outputs closes the parameter list. -/
theorem assemble_shapeQuirk :
    assemble chars!"k" [⟨chars!"a", .float32, [8]⟩] [chars!"b", chars!"c"] [.float32, .float32]
      chars!"a_shape" [] [] false =
    some chars!"[[kernel]] void custom_kernel_k_float_float_float(\n  const device float* a [[buffer(0)]],\n  const constant int* a_shape [[buffer(1)]],\n  device float* b [[buffer(2)]]) {\n  device float* c [[buffer(3)]]) {\na_shape\n}\n" := by
  decide

end Metal.Assemble
