import host.mlx.Ffi
namespace Host.Load
open Host.Ts

/-! # Safetensors headers as the MLX model's weight table

A safetensors file is an 8-byte little-endian header length, a JSON
header, then the tensor payload. `stHeader` reads the JSON header (as the
characters of the file's bytes) into the table `mlx_load_safetensors`
answers from (`Host.Mlx.Ffi.Header`: tensor name, shape, `mlx_dtype` code),
in the header's order, skipping `__metadata__`. It is the function the load
route's header literals are checked against (`Data.headers_eq`), so the
`load` nodes the weights become are keyed by the names the file declares. -/

inductive SJ where
  | obj (kvs : List (List Char × SJ))
  | arr (xs : List SJ)
  | str (s : List Char)
  | num (n : Nat)
  | lit

def sjWs : List Char → List Char
  | c :: cs => bif c == ' ' || c == '\n' || c == '\t' || c == '\r' then sjWs cs else c :: cs
  | [] => []

def sjStr : Nat → List Char → List Char → Option (List Char × List Char)
  | 0, _, _ => none
  | _ + 1, acc, '"' :: cs => some (acc.reverse, cs)
  | f + 1, acc, '\\' :: c :: cs => sjStr f (c :: '\\' :: acc) cs
  | f + 1, acc, c :: cs => sjStr f (c :: acc) cs
  | _, _, [] => none

def sjNat (cs : List Char) : Option (Nat × List Char) :=
  let ds := cs.takeWhile fun c => Nat.ble 48 c.toNat && Nat.ble c.toNat 57
  bif ds.isEmpty then none else some (ds.foldl (fun n c => n * 10 + (c.toNat - 48)) 0, cs.drop ds.length)

mutual
def sjVal : Nat → List Char → Option (SJ × List Char)
  | 0, _ => none
  | f + 1, cs => match sjWs cs with
    | '{' :: r => match sjWs r with
      | '}' :: r => some (.obj [], r)
      | r => sjMembers f [] r
    | '[' :: r => match sjWs r with
      | ']' :: r => some (.arr [], r)
      | r => sjElems f [] r
    | '"' :: r => (sjStr r.length [] r).map fun (s, r) => (.str s, r)
    | 't' :: 'r' :: 'u' :: 'e' :: r => some (.lit, r)
    | 'f' :: 'a' :: 'l' :: 's' :: 'e' :: r => some (.lit, r)
    | 'n' :: 'u' :: 'l' :: 'l' :: r => some (.lit, r)
    | r => (sjNat r).map fun (n, r) => (.num n, r)
def sjElems : Nat → List SJ → List Char → Option (SJ × List Char)
  | 0, _, _ => none
  | f + 1, acc, cs => (sjVal f cs).bind fun (v, r) => match sjWs r with
    | ',' :: r => sjElems f (v :: acc) r
    | ']' :: r => some (.arr (v :: acc).reverse, r)
    | _ => none
def sjMembers : Nat → List (List Char × SJ) → List Char → Option (SJ × List Char)
  | 0, _, _ => none
  | f + 1, acc, cs => match sjWs cs with
    | '"' :: r => (sjStr r.length [] r).bind fun (k, r) => match sjWs r with
      | ':' :: r => (sjVal f r).bind fun (v, r) => match sjWs r with
        | ',' :: r => sjMembers f ((k, v) :: acc) r
        | '}' :: r => some (.obj ((k, v) :: acc).reverse, r)
        | _ => none
      | _ => none
    | _ => none
end

def sjField (k : List Char) : List (List Char × SJ) → Option SJ
  | [] => none
  | (a, v) :: r => bif nameEq a k then some v else sjField k r

def sjNats : List SJ → Option (List Nat)
  | [] => some []
  | .num n :: r => (sjNats r).map (n :: ·)
  | _ => none

/-- `mlx_dtype` code of a safetensors dtype name. -/
def dtypeCode (d : List Char) : Option Nat :=
  [("BOOL", 0), ("U8", 1), ("U16", 2), ("U32", 3), ("U64", 4), ("I8", 5), ("I16", 6), ("I32", 7), ("I64", 8),
    ("F16", 9), ("F32", 10), ("F64", 11), ("BF16", 12)].findSome? fun (n, c) => bif nameEq (strOf n) d then some c else none

def sjEntries : List (List Char × SJ) → Option Host.Mlx.Ffi.Header
  | [] => some []
  | (k, v) :: r => bif nameEq k chars!"__metadata__" then sjEntries r else
    match v with
    | .obj fs => match sjField chars!"dtype" fs, sjField chars!"shape" fs with
      | some (.str d), some (.arr sh) => (dtypeCode d).bind fun c => (sjNats sh).bind fun sh =>
        (sjEntries r).map ((k, sh, c) :: ·)
      | _, _ => none
    | _ => none

/-- The weight table of a safetensors JSON header. -/
def stHeader (cs : List Char) : Option Host.Mlx.Ffi.Header :=
  match sjVal (4 * cs.length + 8) cs with
  | some (.obj kvs, r) => bif (sjWs r).isEmpty then sjEntries kvs else none
  | _ => none

end Host.Load

namespace Host.Load
open Lean Elab Command

/-- `data_chars c s`: `source_chars c s` (explicit cells for the kernel, `c.eq : s.toList = c`),
with `s.toList` as `c`'s native implementation. -/
elab "data_chars " c:ident src:ident : command => do
  elabCommand (← `(source_chars $c $src))
  let ns ← getCurrNamespace
  let cN := ns ++ c.getId
  let natN := cN ++ `native
  let ty := mkApp (mkConst ``List [.zero]) (mkConst ``Char)
  let v := mkApp (mkConst ``String.toList) (mkConst (ns ++ src.getId))
  liftCoreM do
    addDecl (.defnDecl { name := natN, levelParams := [], type := ty, value := v, hints := .opaque, safety := .safe })
    compileDecl (.defnDecl { name := natN, levelParams := [], type := ty, value := v, hints := .opaque, safety := .safe })
    match Compiler.implementedByAttr.setParam (← getEnv) cN natN with
    | .ok env => setEnv env
    | .error e => throwError e

end Host.Load
