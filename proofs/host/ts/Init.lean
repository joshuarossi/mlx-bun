import host.ts.Machine
import host.ts.Prelude
namespace Host.Ts

/-! # The realm

Intrinsic objects at the fixed addresses of `Core`, builtin functions,
the global object, and the prelude's JavaScript builtins. -/

section
variable {S : Type}

abbrev B (S : Type) := StateM (St S)

def mkFn (n : Native) (data : List Val := []) : B S Val :=
  modifyGet fun s => let (a, s) := s.allocObj (.fn (.native n data)) (.obj aFunctionProto) []; (.obj a, s)

def setP (a : Nat) (k : PKey) (p : PropV) : B S Unit :=
  modify fun s => match s.obj? a with
    | some o => s.setObj a { o with props := setPropL k p o.props }
    | none => s

def method (a : Nat) (name : Name) (n : Native) (data : List Val := []) : B S Unit := do
  let f ← mkFn n data
  setP a (.str name) (.data f true false)

def symMethod (a : Nat) (sym : Nat) (n : Native) : B S Unit := do
  let f ← mkFn n
  setP a (.sym sym) (.data f true false)

def constP (a : Nat) (name : Name) (v : Val) : B S Unit := setP a (.str name) (.data v false false)

def newObj (proto : Val) (k : Kind := .ordinary) : B S Nat :=
  modifyGet fun s => let (a, s) := s.allocObj k proto []; (a, s)

/-- A builtin constructor/function object with a `prototype`. -/
def ctorFn (n : Native) (proto : Nat) (data : List Val := []) : B S Nat := do
  let f ← mkFn n data
  match f with
  | .obj a => do
    setP a kPrototype (.data (.obj proto) false false)
    setP proto kConstructor (.data f true false)
    pure a
  | _ => pure 0

def global (name : Name) (v : Val) : B S Unit := setP aGlobal (.str name) (.data v true false)

def getP (a : Nat) (k : PKey) : B S Val := do
  match (← get).obj? a with
  | some o => match findProp k o.props with
    | some (.data v _ _) => pure v
    | _ => pure .undef
  | none => pure .undef

def getA (a : Nat) (k : PKey) : B S Nat := do
  match ← getP a k with
  | .obj b => pure b
  | _ => pure 0

/-- Intrinsic objects 1 … 39 and their prototype links. -/
def intrinsicProto (a : Nat) : Val :=
  bif Nat.beq a aObjectProto then .null
  else bif Nat.beq a aTypeErrorProto || Nat.beq a aRangeErrorProto || Nat.beq a aReferenceErrorProto || Nat.beq a aSuppressedProto then .obj aErrorProto
  else bif Nat.ble 17 a && Nat.ble a 26 then .obj aTypedProto
  else bif Nat.beq a aBufferProto then .obj (aTypedProtoOf .u8)
  else bif Nat.beq a aGenProto || Nat.beq a aArrayIterProto then .obj aIterProto
  else .obj aObjectProto

def allocIntrinsics : Nat → B S Unit
  | 0 => pure ()
  | n + 1 => do allocIntrinsics n; let _ ← newObj (intrinsicProto (n + 1)); pure ()

def strNatV (n : Nat) : Val := natV n

def errorCtor (n : ErrN) (proto : Nat) (name : Name) : B S Unit := do
  let f ← ctorFn (.err n) proto
  setP proto (.str chars!"name") (.data (.str name) true false)
  setP proto kMessage (.data (.str []) true false)
  global name (.obj f)

def typedCtor (k : EltK) (name : Name) : B S Unit := do
  let p := aTypedProtoOf k
  let f ← ctorFn (.buf .typedCtor) p [natV k.code, natV p]
  constP f chars!"BYTES_PER_ELEMENT" (natV k.size)
  constP p chars!"BYTES_PER_ELEMENT" (natV k.size)
  global name (.obj f)

def preludeFn (env : Env) (name : Name) : B S Val := do
  let s ← get
  pure (((lookupEnv name env).bind fun c => (s.cell? c).bind id).getD .undef)

def realmObj : B S Unit := do
  allocIntrinsics 39
  modify fun s => { s with next := aFirst }
  -- Object
  method aObjectProto chars!"hasOwnProperty" (.obj .protoHasOwn)
  method aObjectProto chars!"toString" (.obj .protoToString)
  let obj ← ctorFn (.obj .keys) aObjectProto
  for (n, f) in [(chars!"keys", ObjN.keys), (chars!"entries", .entries), (chars!"values", .values),
      (chars!"freeze", .freeze), (chars!"hasOwn", .hasOwn), (chars!"fromEntries", .fromEntries),
      (chars!"assign", .assign), (chars!"getPrototypeOf", .getPrototypeOf), (chars!"isFrozen", .isFrozen)] do
    method obj n (.obj f)
  global chars!"Object" (.obj obj)

def realmFn : B S Unit := do
  method aFunctionProto chars!"call" (.fn .call)
  method aFunctionProto chars!"apply" (.fn .apply)
  method aFunctionProto chars!"bind" (.fn .bind)

def realmArr : B S Unit := do
  let arr ← ctorFn (.arr .ctor) aArrayProto
  method arr chars!"isArray" (.arr .isArray)
  for (n, f) in [(chars!"push", ArrN.push), (chars!"pop", .pop), (chars!"slice", .slice), (chars!"at", .at),
      (chars!"includes", .includes), (chars!"indexOf", .indexOf), (chars!"join", .join), (chars!"fill", .fill),
      (chars!"concat", .concat), (chars!"splice", .splice), (chars!"reverse", .reverse), (chars!"shift", .shift),
      (chars!"unshift", .unshift), (chars!"lastIndexOf", .lastIndexOf)] do
    method aArrayProto n (.arr f)
  method aArrayProto chars!"keys" (.iter .keys)
  method aArrayProto chars!"entries" (.iter .entries)
  let vals ← mkFn (.iter .values)
  setP aArrayProto (.str chars!"values") (.data vals true false)
  setP aArrayProto (.sym symIterator) (.data vals true false)
  global chars!"Array" (.obj arr)

def realmIter : B S Unit := do
  let vals ← getP aArrayProto (.str chars!"values")
  symMethod aIterProto symIterator (.iter .self)
  method aArrayIterProto chars!"next" (.iter .next)
  -- typed arrays share the read-only array algorithms
  for (n, f) in [(chars!"at", ArrN.at), (chars!"includes", .includes), (chars!"indexOf", .indexOf), (chars!"join", .join)] do
    method aTypedProto n (.arr f)
  for (n, f) in [(chars!"slice", BufN.taSlice), (chars!"subarray", .taSubarray), (chars!"fill", .taFill), (chars!"set", .taSet)] do
    method aTypedProto n (.buf f)
  method aTypedProto chars!"keys" (.iter .keys)
  method aTypedProto chars!"entries" (.iter .entries)
  setP aTypedProto (.str chars!"values") (.data vals true false)
  setP aTypedProto (.sym symIterator) (.data vals true false)
  typedCtor .i8 chars!"Int8Array"
  typedCtor .u8 chars!"Uint8Array"
  typedCtor .i16 chars!"Int16Array"
  typedCtor .u16 chars!"Uint16Array"
  typedCtor .i32 chars!"Int32Array"
  typedCtor .u32 chars!"Uint32Array"
  typedCtor .f32 chars!"Float32Array"
  typedCtor .f64 chars!"Float64Array"
  typedCtor .i64 chars!"BigInt64Array"
  typedCtor .u64 chars!"BigUint64Array"
  let ab ← ctorFn (.buf .arrayBuffer) aArrayBufferProto
  global chars!"ArrayBuffer" (.obj ab)
  let dv ← ctorFn (.buf .dataView) aDataViewProto
  for (n, f) in [(chars!"getUint32", BufN.getU32), (chars!"setUint32", .setU32), (chars!"getInt32", .getI32),
      (chars!"setInt32", .setI32), (chars!"getFloat32", .getF32), (chars!"setFloat32", .setF32),
      (chars!"getBigUint64", .getBigU64), (chars!"setBigUint64", .setBigU64)] do
    method aDataViewProto n (.buf f)
  global chars!"DataView" (.obj dv)
  let buf ← newObj (.obj aObjectProto)
  method buf chars!"from" (.buf .bufferFrom)
  setP buf kPrototype (.data (.obj aBufferProto) false false)
  global chars!"Buffer" (.obj buf)

def realmStr : B S Unit := do
  let vals ← getP aArrayProto (.str chars!"values")
  for (n, f) in [(chars!"slice", StrN.slice), (chars!"startsWith", .startsWith), (chars!"endsWith", .endsWith),
      (chars!"includes", .includes), (chars!"indexOf", .indexOf), (chars!"split", .split), (chars!"trim", .trim),
      (chars!"toLowerCase", .toLowerCase), (chars!"toUpperCase", .toUpperCase), (chars!"replace", .replace),
      (chars!"padStart", .padStart), (chars!"charCodeAt", .charCodeAt), (chars!"at", .at), (chars!"toString", .toString),
      (chars!"valueOf", .toString), (chars!"concat", .concat), (chars!"substring", .substring)] do
    method aStringProto n (.str f)
  for (n, f) in [(chars!"repeat", Str2N.repeat), (chars!"padEnd", .padEnd), (chars!"trimEnd", .trimEnd),
      (chars!"trimStart", .trimStart), (chars!"replaceAll", .replaceAll), (chars!"lastIndexOf", .lastIndexOf)] do
    method aStringProto n (.str2 f)
  setP aStringProto (.sym symIterator) (.data vals true false)
  let str ← ctorFn (.num .string) aStringProto
  method str chars!"raw" (.str2 .raw)
  method str chars!"fromCharCode" (.str2 .fromCharCode)
  global chars!"String" (.obj str)
  method aNumberProto chars!"toString" (.num .numToString)
  let num ← ctorFn (.num .number) aNumberProto
  for (n, f) in [(chars!"isSafeInteger", NumN.isSafeInteger), (chars!"isInteger", .isInteger),
      (chars!"isFinite", .isFinite), (chars!"isNaN", .isNaN), (chars!"parseInt", .parseInt), (chars!"parseFloat", .parseFloat)] do
    method num n (.num f)
  constP num chars!"POSITIVE_INFINITY" (.num (.lit (.inf false)))
  constP num chars!"NEGATIVE_INFINITY" (.num (.lit (.inf true)))
  constP num chars!"MAX_SAFE_INTEGER" (natV (2 ^ 53 - 1))
  constP num chars!"MIN_SAFE_INTEGER" (intV (-(2 ^ 53 - 1 : Nat)))
  global chars!"Number" (.obj num)
  method aBigIntProto chars!"toString" (.num .bigToString)
  let big ← ctorFn (.num .bigint) aBigIntProto
  global chars!"BigInt" (.obj big)
  let bool ← ctorFn (.num .boolean) aBooleanProto
  global chars!"Boolean" (.obj bool)
  let sym ← ctorFn (.num .symbol) aSymbolProto
  constP sym chars!"iterator" (.sym symIterator)
  constP sym chars!"asyncIterator" (.sym symAsyncIterator)
  constP sym chars!"dispose" (.sym symDispose)
  constP sym chars!"asyncDispose" (.sym symAsyncDispose)
  global chars!"Symbol" (.obj sym)

def realmMath : B S Unit := do
  let math ← newObj (.obj aObjectProto)
  for (n, f) in [(chars!"floor", MathN.floor), (chars!"ceil", .ceil), (chars!"min", .min), (chars!"max", .max),
      (chars!"pow", .pow), (chars!"trunc", .trunc), (chars!"sqrt", .sqrt), (chars!"round", .round),
      (chars!"abs", .abs), (chars!"fround", .fround), (chars!"sign", .sign)] do
    method math n (.math f)
  global chars!"Math" (.obj math)

def realmErr : B S Unit := do
  method aErrorProto chars!"toString" (.err .toString)
  errorCtor .error aErrorProto chars!"Error"
  errorCtor .typeError aTypeErrorProto chars!"TypeError"
  errorCtor .rangeError aRangeErrorProto chars!"RangeError"
  errorCtor .referenceError aReferenceErrorProto chars!"ReferenceError"
  errorCtor .suppressed aSuppressedProto chars!"SuppressedError"

def realmColl : B S Unit := do
  let mapC ← ctorFn (.map .ctor) aMapProto
  for (n, f) in [(chars!"get", MapN.get), (chars!"set", .set), (chars!"has", .has), (chars!"delete", .delete),
      (chars!"clear", .clear), (chars!"keys", .keys), (chars!"values", .values)] do
    method aMapProto n (.map f)
  let ents ← mkFn (.map .entries)
  setP aMapProto (.str chars!"entries") (.data ents true false)
  setP aMapProto (.sym symIterator) (.data ents true false)
  global chars!"Map" (.obj mapC)
  let wm ← ctorFn (.map .weakCtor) aWeakMapProto
  for (n, f) in [(chars!"get", MapN.get), (chars!"set", .set), (chars!"has", .has), (chars!"delete", .delete)] do
    method aWeakMapProto n (.map f)
  global chars!"WeakMap" (.obj wm)
  let setC ← ctorFn (.set .ctor) aSetProto
  for (n, f) in [(chars!"add", SetN.add), (chars!"has", .has), (chars!"delete", .delete), (chars!"clear", .clear)] do
    method aSetProto n (.set f)
  let svals ← mkFn (.set .values)
  setP aSetProto (.str chars!"values") (.data svals true false)
  setP aSetProto (.str chars!"keys") (.data svals true false)
  setP aSetProto (.sym symIterator) (.data svals true false)
  global chars!"Set" (.obj setC)
  let fr ← ctorFn (.fn .finRegCtor) aFinRegProto
  method aFinRegProto chars!"register" (.fn .finRegister)
  method aFinRegProto chars!"unregister" (.fn .finUnregister)
  global chars!"FinalizationRegistry" (.obj fr)

def realmCtl : B S Unit := do
  let pr ← ctorFn (.ctl .promiseCtor) aPromiseProto
  method pr chars!"resolve" (.ctl .promiseResolve)
  method pr chars!"reject" (.ctl .promiseReject)
  method aPromiseProto chars!"then" (.ctl .promiseThen)
  method aPromiseProto chars!"catch" (.ctl .promiseCatch)
  global chars!"Promise" (.obj pr)
  method aGenProto chars!"next" (.ctl .genNext)
  method aGenProto chars!"return" (.ctl .genReturn)
  method aGenProto chars!"throw" (.ctl .genThrow)
  method aAsyncGenProto chars!"next" (.ctl .agenNext)
  method aAsyncGenProto chars!"return" (.ctl .agenReturn)
  method aAsyncGenProto chars!"throw" (.ctl .agenThrow)
  symMethod aAsyncGenProto symAsyncIterator (.iter .self)
  method aAlsProto chars!"run" (.ctl .alsRun)
  method aAlsProto chars!"getStore" (.ctl .alsGetStore)
  method aJsCallbackProto chars!"close" (.fn .noop)

def realmMisc : B S Unit := do
  let refl ← newObj (.obj aObjectProto)
  method refl chars!"get" (.fn .reflectGet)
  method refl chars!"has" (.fn .reflectHas)
  method refl chars!"apply" (.fn .reflectApply)
  global chars!"Reflect" (.obj refl)
  let perf ← newObj (.obj aObjectProto)
  method perf chars!"now" (.fn .perfNow)
  global chars!"performance" (.obj perf)
  let con ← newObj (.obj aObjectProto)
  for n in [chars!"log", chars!"error", chars!"warn", chars!"info", chars!"debug"] do
    method con n (.fn .consoleLog)
  global chars!"console" (.obj con)
  let json ← newObj (.obj aObjectProto)
  method json chars!"stringify" (.fn .jsonStringify)
  global chars!"JSON" (.obj json)
  constP aGlobal chars!"globalThis" (.obj aGlobal)
  constP aGlobal chars!"undefined" .undef
  constP aGlobal chars!"NaN" (.num (.lit .nan))
  constP aGlobal chars!"Infinity" (.num (.lit (.inf false)))

def preludeStmts : List Stmt := Prelude.ast.filterMap fun
  | .stmt st => some st
  | _ => none

def hoistPrelude : B S Env := modifyGet fun s => hoist s preludeStmts []

def realmPrelude : B S Unit := do
  let arr ← getA aGlobal (.str chars!"Array")
  let env ← hoistPrelude
  for n in [chars!"map", chars!"forEach", chars!"filter", chars!"some", chars!"every", chars!"find",
      chars!"findIndex", chars!"reduce", chars!"flatMap", chars!"sort"] do
    setP aArrayProto (.str n) (.data (← preludeFn env n) true false)
  for n in [chars!"map", chars!"forEach", chars!"some", chars!"every", chars!"find", chars!"findIndex", chars!"reduce"] do
    setP aTypedProto (.str n) (.data (← preludeFn env n) true false)
  setP aMapProto (.str chars!"forEach") (.data (← preludeFn env chars!"mapForEach") true false)
  setP aSetProto (.str chars!"forEach") (.data (← preludeFn env chars!"setForEach") true false)
  setP arr (.str chars!"from") (.data (← preludeFn env chars!"from") true false)
  setP aPromiseProto (.str chars!"finally") (.data (← preludeFn env chars!"promiseFinally") true false)

def realmB : B S Unit := do
  realmObj; realmFn; realmArr; realmIter; realmStr; realmMath; realmErr; realmColl; realmCtl; realmMisc; realmPrelude

end

/-- The realm with FFI state `ffi`, idle. -/
def realm {S : Type} (ffi : S) : St S :=
  (realmB.run ⟨.nil, 1, .ret .undef, [], ⟨[], ffi, [], []⟩⟩).2

end Host.Ts
