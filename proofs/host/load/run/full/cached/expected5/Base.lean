import host.load.run.full.FirstChoice
import host.load.Inputs
import host.mlx.GraphBuildCommand
namespace Host.Load.Run.Full.Cached.Expected5
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal layoutData : (layouts firstChoice, linearLayout firstChoice.model.head)
ffi_value_literal_eq layoutData : (layouts firstChoice, linearLayout firstChoice.model.head)

def stages : List StageLayout := layoutData.1.getD []
def head : LinLayout := layoutData.2.getD ⟨.affineRow, 0, 0, 0⟩

theorem layer_count : stages.length = 64 := rfl

theorem stages_eq : layouts firstChoice = some stages := by
  have h := congrArg Prod.fst layoutData.eq_original.symm
  exact h.trans (by rfl)

theorem head_eq : linearLayout firstChoice.model.head = some head := by
  have h := congrArg Prod.snd layoutData.eq_original.symm
  exact h.trans (by rfl)

ffi_value_literal embedded : run (embedG (δ := Int) (κ := InKey) id) []
ffi_value_literal_eq embedded : run (embedG (δ := Int) (κ := InKey) id) []

end Host.Load.Run.Full.Cached.Expected5
