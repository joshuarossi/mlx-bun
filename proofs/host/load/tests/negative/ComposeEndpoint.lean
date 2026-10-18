import host.load.tests.Micro

namespace Host.Load.Tests.ComposeEndpoint
open Host.Ts Lean Elab Command Meta

namespace Bad
def ks : List Nat := [20, 20, 40]
run_elab do
  for (target, source) in [("F", "F"), ("s0", "s0"), ("s1", "s1"), ("s2", "s2"),
      ("s3", "s0"), ("S0", "S0"), ("S1", "S1"), ("S2", "S2"), ("S3", "S3")] do
    let value := mkConst (`Host.Load.Tests.Micro.R ++ Name.mkSimple source)
    addDecl (.defnDecl { name := `Host.Load.Tests.ComposeEndpoint.Bad ++ Name.mkSimple target, levelParams := [], type := ← inferType value, value, hints := .regular 0, safety := .safe })
  for i in [0:3] do
    let name := Name.mkSimple s!"c{i}"
    let value := mkConst (`Host.Load.Tests.Micro.R ++ name)
    addDecl (.thmDecl { name := `Host.Load.Tests.ComposeEndpoint.Bad ++ name, levelParams := [], type := ← inferType value, value })
end Bad

-- The supplied final chunk reaches R.s3, while the advertised end is R.s0.
-- Staged composition must reject the final prefix in the ordinary kernel.
host_chain_run_staged Bad

end Host.Load.Tests.ComposeEndpoint
