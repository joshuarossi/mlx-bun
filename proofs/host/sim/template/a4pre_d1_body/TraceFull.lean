import host.sim.template.a4pre_d1_body.TraceNative
import host.sim.full.BridgeJs
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Load.Layers

theorem fullSim {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv}
    {x y : FF.S} {name : Name} {args : List Arg}
    (hs : Srv M ν S C) (hr : FullR P NB M S.tab.length x y)
    (hsym : Host.Mlx.Ffi.symOf name = some .closureApply)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hi : (bridgeOf x).active = false) (hobs : obsOk (mlxOf x) name args = true)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a)
    (hok : applyOk P (mlxOf x) args = true) (hsm : ApplySmall ν S (mlxOf x) args) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧
      CallR (F := FF) (FullR P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hg := G.mlx_lift hr.load hm (nativeSim hs hr.load.mlx hr.pend hsym hok hsm)
  have hss : isSymShape name = false := by
    unfold isSymShape
    rw [hsym]
  refine fullCallOf hr hm hp hi hobs hsupp ?_ ?_ ?_ hg
  · intro s h
    rw [hsym] at h
    cases h
    constructor
    · intro h
      cases h
    · intro h
      rcases h with h | h | h <;> cases h
  · intro h
    rw [hsym] at h
    cases h
  · intro h
    rw [hss] at h
    cases h

def additionalOk (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName && !(bridgeOf x).active &&
    (match Host.Mlx.Ffi.symOf name with
      | some .closureApply => applyOk (P.raise (mlxOf x).nnext) (mlxOf x) args
      | _ => false) && obsOk (mlxOf x) name args

def callOk (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  okCallFXD P x name args || additionalOk P x name args

def small (P : LoadP) (ν : Nat → F64) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  smallFX2 ν S x name args ∧ (additionalOk P x name args = true → ApplySmall ν S (mlxOf x) args)

def smallB (P : LoadP) (VB : Nat → Nat) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  smallFX2B VB S x name args && (!additionalOk P x name args || applySmallB VB S (mlxOf x) args)

theorem smallB_sound {P : LoadP} {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : FF.S}
    {name : Name} {args : List Arg} (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k)
    (h : smallB P VB S x name args = true) : small P ν S x name args := by
  simp only [smallB, Bool.and_eq_true] at h
  refine ⟨smallFX2B_sound hν h.1, ?_⟩
  intro hok
  have hb : applySmallB VB S (mlxOf x) args = true := by
    simpa only [hok, Bool.not_true, Bool.false_or] using h.2
  exact applySmallB_sound hb hν

theorem callSim (P : LoadP) (NB : Nat) (hband : P.NL = P.N0) :
    FfiCallSim FF (FullRXD P NB) (callOk P) (small P) where
  call := by
    intro M ν S C x y name args hs hr hok hsupp hsm
    simp only [callOk, Bool.or_eq_true] at hok
    rcases hok with hold | hnew
    · exact (fullCallSimXD P NB).call M ν S C x y name args hs hr hold hsupp hsm.1
    · have hnew0 := hnew
      simp only [additionalOk, Bool.and_eq_true, Bool.not_eq_true'] at hnew
      obtain ⟨⟨⟨⟨hm, hp⟩, hi⟩, haccept⟩, hobs⟩ := hnew
      cases hsym : Host.Mlx.Ffi.symOf name with
      | none => rw [hsym] at haccept; cases haccept
      | some sym =>
        cases sym <;> simp only [hsym] at haccept
        all_goals first | cases haccept | skip
        obtain ⟨hrr, hP⟩ := hr.top hband
        refine MSim.mono (fullSim hs (hrr.toR hi) hsym hm hp hi hobs hsupp haccept (hsm.2 hnew0)) ?_
        rintro M' S' C' r r' ⟨gg, hrel⟩
        exact ⟨gg, callR_mono (fun _ _ _ _ h => ⟨_, hP, h.toX⟩) hrel⟩

end Host.Load.Run.Tpl.D1BodyTrace
