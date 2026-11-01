import host.route.PostSimulation
import host.sim.compose.PostTransport
import host.sim.compose.RoutePieces
import host.sim.template.a4pre_pl_selector.Good
import host.sim.template.a4pre_pl_call.Facts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.PostHead
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Compose Host.Ts.Sim.Template
open Host.Load.Run.Tpl

/-- The generated selector reaches the actual head call and retains the original prompt book. -/
theorem selector_to_head (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat)
    (hcap : cap ≤ 4096 + 1593835520) :
    CutStep (Post.indexedCut NB T tk cap nI π PRE_pl_head.s1 PRE_pl_head.S1)
      (Post.indexedCut NB T tk cap nI π PRE_pl_call.s1 PRE_pl_call.S1) 131 := by
  rintro t C ⟨x, rfl, rfl, ⟨γ, hr, hb⟩, hf, ha⟩
  have h0 : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB))
      wideP [] x.M x.ν x.K PRE_pl_selector.s0
      ⟨PRE_pl_selector.S0.tab, []⟩ x.t x.C := by
    rw [PRE_pl_selector.s0_eq, PRE_pl_selector.s0_tab]
    exact hr
  have hs := h0.withOracle (PRE_pl_selector.good hb.rowValue)
  have hq : RelB FF
      (Disp.FRJ (FRQ (FullRXD (PostSimulation.params T tk) NB)
        fun y => Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y)))
      wideP [] x.M x.ν x.K PRE_pl_selector.s0 PRE_pl_selector.S0 x.t x.C :=
    { hs with ffi := ⟨⟨hs.ffi.1, Host.Mlx.Ffi.NGrow.refl _⟩, hs.ffi.2⟩ }
  have hok := PostSimulation.accepted_signed hcap PRE_pl_call.accepted_selector
  have hrun := PostSimulation.run_signed hcap PRE_pl_call.selectorRun
  have hsim := PostSimulation.simulationQ NB T tk jsSignedLimit cap le_rfl [] (mlxOf x.t.ffi)
  obtain ⟨M', t', C', ht, he, hx⟩ :=
    Disp.runOk_simXVB FF _ _ _ _ [] _ hsim.xv (fun _ _ _ => .inl rfl) x.ν x.K
      hb.context ⟨hb.valuation, hb.rowValue⟩ 131 x.M PRE_pl_selector.s0 PRE_pl_selector.S0
      x.t x.C PRE_pl_call.s1 PRE_pl_call.S1 (.inl hq) hok hrun
  have htop : noRetBlock PRE_pl_call.s1 = true := by
    simp only [noRetBlock, PRE_pl_call.head_call]
  have hrel := hx.rel_noRet htop
  have hout : RelB FF (Disp.FRJ (FullRXD (PostSimulation.params T tk) NB))
      wideP [] M' x.ν x.K PRE_pl_call.s1 PRE_pl_call.S1 t' C' :=
    { hrel with ffi := ⟨hrel.ffi.1.1, hrel.ffi.2⟩ }
  have hbook := hb.grow he hrel.ffi.1.2 (runC_le _ _ _ _ _ ht)
  obtain ⟨_, _, r0⟩ := hs.ffi.1
  obtain ⟨_, _, r1⟩ := hout.ffi.1
  have hi : (bridgeOf PRE_pl_call.s1.ffi).active = false :=
    (congrArg (fun b : Host.Mlx.FfiAne.St => b.active) PRE_pl_call.head_bridge).trans
      PRE_pl_call.selector_inactive
  have hbridge : bridgeOf t'.ffi = bridgeOf x.t.ffi :=
    (r1.toR hi).bridge.1.trans
      (PRE_pl_call.head_bridge.trans (r0.toR PRE_pl_call.selector_inactive).bridge.1.symm)
  have hf' : AneFresh t' := by
    intro Cx Pc Kc weights kind NE IP G init
    rw [hbridge]
    exact hf Cx Pc Kc weights kind NE IP G init
  refine ⟨t', C', ht, ⟨M', x.ν, x.K, t', C'⟩, rfl, rfl,
    ⟨γ, hout.withOracle (fun _ h => nomatch h), hbook⟩, hf', ?_⟩
  exact ⟨(congrFun he.a 2586).trans ha.1, (congrFun he.a 2589).trans ha.2⟩

/-- The common selector glue owns an empty oracle; row-ten's singleton fact proves its checks. -/
noncomputable def post_g5 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat)
    (hcap : cap ≤ 4096 + 1593835520) (Adm : Lin.Cls.Inst → Prop) (uses : List Lin.Cls.Row) :
    RGluePiece FF Adm uses
      (fun _ => Post.indexedCut NB T tk cap nI π PRE_pl_head.s1 PRE_pl_head.S1)
      (fun _ => Post.indexedCut NB T tk cap nI π PRE_pl_call.s1 PRE_pl_call.S1) where
  m := []
  n := 131
  O := []
  chk _ _ := rfl
  ok _ _ _ _ _ _ := selector_to_head NB T tk cap nI π hcap

end Host.Route.PostHead
