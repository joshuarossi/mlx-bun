import host.ts.tests.stream.Run
namespace Host.Ts.Tests.Stream
open Host.Ts

noncomputable def output : Option (List Val) := do
  let .obj a ← bindingOf P.s4 (entryEnv P.s0) chars!"out" | none
  let (_, es) ← arrayOf nullFfi P.s4 a
  pure es

set_option maxRecDepth 1000000 in
theorem output_eq : output = some [natV 3, natV 4, natV 2, .str chars!"a,aa,aa,z", .str chars!"first,second"] := by
  rfl
end Host.Ts.Tests.Stream
