import host.route.LoadedCut
import host.sim.compose.a4b.SetupD1CleanReads
set_option Elab.async false
namespace Host.Ts.Sim.Compose.SetupD1CleanInitial
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full
open Host.Load.Run.Prompt Host.Load.Run.Tpl Host.Route Host.Ts.Sim.Template

theorem producer (π : List Nat) (hπ : π.length = 1) (hlt : ∀ t ∈ π, t < 248320)
    {T : Nat} {tk : Nat → Nat} (hctx : 1 + T ≤ 262144)
    (hT : T ≤ 2 ^ 20) (htk : ∀ j, tk j ≤ 2 ^ 20) :
    ∃ x : SegInst FF,
      runC FF 3011 (ldStT (π.map natV) (machReads T tk)) (routeServer T tk) = some (x.t, x.C) ∧
      (SetupD1SavedCells.forwardSavedInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩ ∧
      (SetupD1SavedCells.forwardSavedInputCut 15235 T tk).B x ∧
      Host.Mlx.Ffi.NGrow (mlxOf (ldStT (π.map natV) (machReads T tk)).ffi) (mlxOf x.t.ffi) ∧
      CSrv.Le (routeServer T tk) x.C ∧
      (mlxOf (ldStT (π.map natV) (machReads T tk)).ffi).tokens.length = (mlxOf x.t.ffi).tokens.length ∧
      (mlxOf x.t.ffi).items = .nil := by
  apply SetupD1CleanReads.producer π hctx
  simpa only [hπ] using
    Host.Route.LoadedCut.ldCut_inv 15235 setupP (by decide) wideP (by rfl) π hlt T tk hT htk

end Host.Ts.Sim.Compose.SetupD1CleanInitial
