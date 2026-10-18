import host.ts.Stream

namespace Host.Ts.Tests.Stream.Sweep
open Lean Elab Command Host.Ts Host.Ts.Stream

run_cmd liftTermElabM do
  let child : List Nat := [17, 18]
  let parent : List (List Nat) := [child]
  let ty := toTypeExpr (List Nat)
  let ((c, p), g) ← ((do
    let c ← named ty "c" child (fun x => pure (toExpr x))
    let p ← named (toTypeExpr (List (List Nat))) "p" parent (fun _ => pure
      (mkApp3 (mkConst ``List.cons [.zero]) ty c (mkApp (mkConst ``List.nil [.zero]) ty)))
    discard <| named ty "dead" ([99] : List Nat) (fun x => pure (toExpr x))
    pure (c, p)).run { pre := `Host.Ts.Tests.Stream.Sweep })
  for (n, t, v) in g.defs do
    addDecl (.defnDecl { name := n, levelParams := [], type := t, value := v, hints := .regular 0, safety := .safe })
  let g := sweep { g with defs := #[] } #[p]
  unless g.memo.size == 2 && g.deps.size == 2 do
    throwError "sweep failed to retain exactly the parent and its child"
  let (c', g) ← (named ty "childAgain" child (fun x => pure (toExpr x))).run g
  unless c' == c && g.defs.isEmpty do
    throwError "reusing a whole group lost its unvisited child alias"
  let tyParent := toTypeExpr (List (List Nat))
  let (wrapped, imported) ← (named (toTypeExpr (List (List (List Nat)))) "wrapped" [parent]
    (fun _ => pure (mkApp3 (mkConst ``List.cons [.zero]) tyParent p
      (mkApp (mkConst ``List.nil [.zero]) tyParent)))).run
    { g with pre := `Host.Ts.Tests.Stream.Sweep.Restored, idx := 1, count := 0, defs := #[] }
  for (n, t, v) in imported.defs do
    addDecl (.defnDecl { name := n, levelParams := [], type := t, value := v, hints := .regular 0, safety := .safe })
  let imported := sweep { imported with defs := #[] } #[wrapped]
  unless imported.memo.size == 3 && imported.deps.size == 3 do
    throwError "restored stream lost an imported parent or child alias"
  let (c'', imported) ← (named ty "importedChildAgain" child (fun x => pure (toExpr x))).run imported
  unless c'' == c && imported.defs.isEmpty do
    throwError "imported child alias was not retained transitively"
  let mut g := g
  for i in [1:1001] do
    Memo.reset
    let (e, g') ← (named ty "epoch" [i] (fun x => pure (toExpr x))).run
      { g with idx := i, count := 0, defs := #[] }
    g := sweep { g' with defs := #[] } #[e]
    unless g.memo.size == 1 && g.deps.size == 1 do
      throwError "obsolete native values retained at epoch {i}"
  Memo.reset

theorem parent_value : p0_1 = ([[17, 18]] : List (List Nat)) := rfl
theorem restored_value : Restored.wrapped1_0 = ([[[17, 18]]] : List (List (List Nat))) := rfl

end Host.Ts.Tests.Stream.Sweep
