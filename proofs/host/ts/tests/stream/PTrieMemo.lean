import host.ts.Memo

namespace Host.Ts.Tests.Stream.PTrieMemo
open Lean Elab Command Meta Host.Ts.Memo

private def fixture : PTrie Nat := (((PTrie.nil.set 0 17).set 64 23).set 8192 29)

set_option Elab.async false
run_elab do
  unsafe do
    reset
    let t := fixture
    let saved ← IO.mkRef t
    let chosen := toExpr t
    let key := (tagOf (toTypeExpr (Trie (Trie Nat))) 2, ptrAddrUnsafe t.root)
    unless (← memoRef.get).contains key do throwError "PTrie bypassed cached Trie serializer"
    beginEpoch
    let promoted := toExpr (← saved.get)
    unless chosen == promoted do throwError "PTrie epoch changed its expression"
    unless (← memoRef.get).contains key do throwError "PTrie root was not promoted"
    let original := mkConst ``fixture
    let type ← mkEq original promoted
    let value ← mkEqRefl original
    addDecl (.thmDecl { name := `Host.Ts.Tests.Stream.PTrieMemo.roundtrip, levelParams := [], type, value })
    reset

end Host.Ts.Tests.Stream.PTrieMemo
