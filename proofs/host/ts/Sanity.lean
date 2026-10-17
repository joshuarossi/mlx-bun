import host.ts.sources.mlx.Array
namespace Host.Ts.Sanity
open Host.Ts

/-! The parser's output is meaningful: the `MlxArray.shape` getter parsed
from the embedded `packages/mlx/src/array.ts` is the expected erased AST,
and mutated sources fail to parse or parse differently. -/

deriving instance DecidableEq for BinOp

def classMembers (cls : Name) : Module → Option (List Member)
  | .export_ (.cls (.mk (some n) _ ms)) :: items => if n == cls then some ms else classMembers cls items
  | .stmt (.cls (.mk (some n) _ ms)) :: items => if n == cls then some ms else classMembers cls items
  | _ :: items => classMembers cls items
  | [] => none

def getterOf (name : Name) : List Member → Option Member
  | .method false .get (.id k) f :: ms => if k == name then some (.method false .get (.id k) f) else getterOf name ms
  | _ :: ms => getterOf name ms
  | [] => none

def getter (cls name : Name) (m : Module) : Option Member := (classMembers cls m).bind (getterOf name)

/-- ```
get shape(): number[] {
  const n = this.ndim;
  if (n === 0) return [];
  const shapePtr = C.mlx_array_shape(this.handle);
  return [...new Int32Array(toArrayBuffer(shapePtr!, 0, n * 4))];
}
``` -/
def shapeGetter (op : BinOp) : Member :=
  .method false .get (.id chars!"shape") (.mk none [] none (.block [
    .decl .const [(.id chars!"n", some (.member .this chars!"ndim" false))],
    .if_ (.bin .seq (.id chars!"n") (.lit (.num chars!"0"))) (.ret (some (.array []))) none,
    .decl .const [(.id chars!"shapePtr", some (.call (.member (.id chars!"C") chars!"mlx_array_shape" false)
      [.expr (.member .this chars!"handle" false)] false))],
    .ret (some (.array [.spread (.new (.id chars!"Int32Array") [.expr (.call (.id chars!"toArrayBuffer")
      [.expr (.id chars!"shapePtr"), .expr (.lit (.num chars!"0")), .expr (.bin op (.id chars!"n") (.lit (.num chars!"4")))]
      false)])]))]) false false [])

kernel_rfl shapeTokens :
  ((parseTokens Sources.Mlx.Array.tokens).getLeft?).bind (getter chars!"MlxArray" chars!"shape") = some (shapeGetter .mul)

theorem shape :
    (parse Sources.Mlx.Array.source.toList).bind (getter chars!"MlxArray" chars!"shape") = some (shapeGetter .mul) := by
  rw [Sources.Mlx.Array.chars.eq, parse_of_lex Sources.Mlx.Array.lex_eq]; exact shapeTokens

/-- The operator in the getter's last statement. -/
def lastOp : Member → Option BinOp
  | .method _ _ _ (.mk _ _ _ (.block [_, _, _, .ret (some (.array [.spread (.new _ [.expr (.call _
      [_, _, .expr (.bin op _ _)] _)])]))]) _ _ _) => some op
  | _ => none

def broken : String := r#"class MlxArray {
  get shape(): number[] {
    const n = this.ndim;
    if (n === 0) return [];
    const shapePtr = C.mlx_array_shape(this.handle);
    return [...new Int32Array(toArrayBuffer(shapePtr!, 0, n * * 4))];
  }
}"#

def changed : String := r#"class MlxArray {
  get shape(): number[] {
    const n = this.ndim;
    if (n === 0) return [];
    const shapePtr = C.mlx_array_shape(this.handle);
    return [...new Int32Array(toArrayBuffer(shapePtr!, 0, n + 4))];
  }
}"#

source_chars brokenChars broken
source_chars changedChars changed

kernel_rfl brokenFails : (parse brokenChars).isSome = false

kernel_rfl changedParses : (parse changedChars).bind (getter chars!"MlxArray" chars!"shape") = some (shapeGetter .add)

theorem brokenRejected : parse broken.toList = none := by
  rw [brokenChars.eq]
  cases h : parse brokenChars with
  | none => rfl
  | some _ => have := brokenFails; simp [h] at this

/-- A one-character change to the getter yields a different AST. -/
theorem changedDiffers :
    (parse changed.toList).bind (getter chars!"MlxArray" chars!"shape") ≠
      (parse Sources.Mlx.Array.source.toList).bind (getter chars!"MlxArray" chars!"shape") := by
  rw [changedChars.eq, changedParses, shape]
  intro h
  have := congrArg (fun m => m.bind lastOp) h
  simp [shapeGetter, lastOp] at this

end Host.Ts.Sanity
