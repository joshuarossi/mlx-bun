import host.ts.Stream
namespace Host.Ts.Tests.Stream.ScalarNames
open Lean Elab Command Host.Ts Host.Ts.Stream

-- Empty lists and tries are immediate values with the same native address.
-- Each named definition must retain the type requested by its serializer.
run_cmd liftTermElabM do
  let (_, g) ← ((do
    discard <| named (toTypeExpr (List Nat)) "l" ([] : List Nat) (fun x => pure (toExpr x))
    discard <| named (toTypeExpr (Trie Nat)) "t" (Trie.nil : Trie Nat) (fun x => pure (toExpr x))
    ).run { pre := `Host.Ts.Tests.Stream.ScalarNames })
  for (n, t, v) in g.defs do
    addDecl (Declaration.defnDecl { name := n, levelParams := [], type := t, value := v, hints := .regular 0, safety := .safe })

theorem empty_list : l0_0 = ([] : List Nat) := rfl
theorem empty_trie : t0_1 = (Trie.nil : Trie Nat) := rfl
end Host.Ts.Tests.Stream.ScalarNames
