import host.ts.DecodeExpr
import host.ts.Memo
namespace Host.Ts.ConstructorDecodeTests
open Lean Elab Command Meta

private unsafe def roundtripExpr {α : Type} [ToExpr α] (name : Lean.Name) (original : Lean.Expr) : TermElabM Unit := do
  let ty := toTypeExpr α
  let started ← IO.monoMsNow
  let (raw, cache) ← (ConstructorDecode.decode original).run {}
  let restored : α := unsafeCast raw
  let chosen := toExpr restored
  let eq ← mkEq original chosen
  withOptions (·.setBool `Elab.async false) do
    addDecl (.thmDecl { name := `Host.Ts.ConstructorDecodeTests ++ name, levelParams := [], type := eq, value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) ty original })
  logInfo m!"Constructor roundtrip {name}: {cache.values.size} values, {cache.constructors.size} wrappers, {(← IO.monoMsNow) - started} ms"

private unsafe def roundtrip {α : Type} [ToExpr α] (name : Lean.Name) (x : α) : TermElabM Unit :=
  roundtripExpr (α := α) name (toExpr x)

private def aliasValue : List (Char × Option UInt32) := [('x', some 7), ('λ', none), ('z', some 42)]

set_option maxRecDepth 1000000
set_option maxHeartbeats 0
run_elab do
  unsafe roundtrip `mixed ([(('A', (0xffffffffffffffff : UInt64)), some (17 : UInt8)), (('λ', 5), none)])
  unsafe roundtrip `objects ([HObj.cell (some (.num (.lit (.fin false 13 (.negSucc 4))))),
    HObj.obj { proto := .obj 7, props := [(.str chars!"x", .data (.big (-19)) true false)], priv := [], extensible := true, kind := .array [.str chars!"abc", .num (.ref 3)] }] : List HObj)
  unsafe roundtrip `long_list (List.range 20000)
  unsafe roundtripExpr (α := List (Char × Option UInt32)) `named_alias (mkConst ``aliasValue)
  unsafe roundtripExpr (α := List (Char × Option UInt32)) `alias_drop
    (mkAppN (mkConst ``List.drop [.zero]) #[toTypeExpr (Char × Option UInt32), mkRawNatLit 1, mkConst ``aliasValue])

end Host.Ts.ConstructorDecodeTests
