import host.load.run.full.cached.expected2.Base
namespace Host.Load.Run.Full.Growth64.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option Elab.async false
abbrev stages := Cached.Expected2.stages
abbrev head := Cached.Expected2.head
abbrev embedded := Cached.Expected2.embedded
theorem embedded.eq_original : embedded = run (embedG (δ := Int) (κ := InKey) id) [] := Cached.Expected2.embedded.eq_original
theorem layer_count : stages.length = 64 := Cached.Expected2.layer_count
theorem stages_eq : layouts firstChoice = some stages := Cached.Expected2.stages_eq
theorem head_eq : linearLayout firstChoice.model.head = some head := Cached.Expected2.head_eq
end Host.Load.Run.Full.Growth64.Expected
