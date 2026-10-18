import host.ts.renameOrdinary.RankOriginRemaining
import host.ts.RenameParameterEffects
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RankOrigin
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric

theorem getter_body_no_cells : blockNames GetterBody29.sourceBody = [] := by host_kernel_rfl

theorem getter_body_transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val)
    (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' P.micro3275.s29 s)
    (bound : s.next ≤ 2^64) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' P.micro3275.s30 result ∧ result.heap = s.heap := by
  have hb : s.next + (blockNames GetterBody29.sourceBody).length ≤ 2^64 := by rw [getter_body_no_cells]; exact bound
  obtain ⟨result,hr,hs⟩ := GetterBody29.transport NR FR R C₀ C live framed before after old old' s h hb
  change interpC (step P.F s).run C = some (result,C) at hr
  have hs' : StateR NR FR R live framed before after old old' P.micro3275.s30 result := by
    simp only [getter_body_no_cells,CellsLive] at hs
    exact hs
  obtain ⟨v,hc,_⟩ := (h.control_view GetterBody29.source_control).ret_view
  obtain ⟨f,fs,hf,hfr,_⟩ := h.stack_view GetterBody29.source_frame
  obtain ⟨args,hft,_⟩ := hfr.params_view
  rw [hft] at hf
  have exactRun := hr
  rw [step_parameter_body_eq P.F s v GetterBody29.sourceName GetterBody29.sourceParams GetterBody29.sourceBody
    args (R.env GetterBody29.sourceEnv) fs hc hf] at exactRun
  have he := congrArg Prod.fst (Option.some.inj exactRun)
  dsimp only at he
  have hh := congrArg St.heap he
  have inert : (enterBlock {s with stack := fs} GetterBody29.sourceBody (R.env GetterBody29.sourceEnv)).heap = s.heap := by
    change (hoist {s with stack := fs} GetterBody29.sourceBody (R.env GetterBody29.sourceEnv)).2.heap = s.heap
    rw [hoist_inert_eq _ _ _ GetterBody29.source_hoist,getter_body_no_cells]
    rfl
  exact ⟨result,hr,hs',hh.symm.trans inert⟩
end Host.Load.Run.Full.Ordinary.RankOrigin
