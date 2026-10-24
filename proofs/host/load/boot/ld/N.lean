import host.load.boot.ld.S
import host.sim.template.NShiftGen
import host.load.run.tail.Command
set_option Elab.async false
namespace Host.Load.Run.Prompt
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
open Host.Mlx.Ffi (Node)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! Kernel checks of the native relation at `loadDone` (`host.load.boot.ld.LoadR`): the template's
native state `Ld.Xl` (the boot's at `loadDone` with no unread readback after the two known heads) and
the target's for every suffix `τ` (`Ld.Y τ`: only the token queue differs, `ld_Y`). -/

/-- The template's native state: the boot's at `loadDone` with the readbacks `.ref 1, .ref 2`. -/
noncomputable abbrev Ld.Xl : Host.Load.LSt := (P.at2818 [] []).ffi
noncomputable abbrev Ld.X0 : NSt := Ld.Xl.mlx

/-- The target's native state for the unread readback suffix `τ`. -/
noncomputable def Ld.Y (τ : List NumV) : Host.Load.LSt := (P.at2818 [] τ).ffi

kernel_rfl_eager Ld.Y_eq : ∀ τ : List NumV,
  Ld.Y τ = { Ld.Xl with mlx := { Ld.X0 with tokens := NumV.ref 1 :: NumV.ref 2 :: τ } }

kernel_rfl Ld.x0next : Ld.X0.next = 18151
kernel_rfl Ld.x0nnext : Ld.X0.nnext = 15235
kernel_rfl Ld.tokens_val : Ld.X0.tokens = [.ref 1, .ref 2]
kernel_rfl Ld.pending_val : Ld.X0.pending = []
kernel_rfl Ld.absent0a : Ld.X0.arrs.get 0 = none
kernel_rfl Ld.absent0b : Ld.X0.objs.get 0 = none
kernel_rfl Ld.hostLt_check : (entriesK Ld.Xl.host.objs 0 1).all (fun p => Nat.blt p.1 (2 ^ 46)) = true

end Host.Load.Run.Prompt
