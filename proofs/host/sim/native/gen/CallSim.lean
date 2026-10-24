import host.sim.native.CallSim
import host.sim.native.gen.CallS
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf Out)

/-! # `FfiCallSim` of the general relation

`okCallSG P` is `okCallS P` with compiled-closure applies checked by `NativeOk.clApplyG`
(the general replay: renamed trace nodes, symbolic recorded shapes). -/

namespace NativeOkS

/-- `Host.Ts.Sim.NativeOkS.sym` with the general closure-apply check. -/
def symG (P : LoadP) (x : NSt) : Host.Mlx.Ffi.Sym → List Arg → Bool
  | .slice => NativeOkS.slice P x
  | .sliceUpdate => NativeOkS.sliceUpdate P x
  | .concat => NativeOkS.concat P x
  | .sdpa => NativeOkS.sdpa P x
  | .closureApply => NativeOk.clApplyG P x
  | _ => fun _ => false
end NativeOkS

/-- **The accepted native calls** of the general relation. -/
def okCallSG (P : LoadP) (x : Host.Load.LSt) (name : Name) (args : List Arg) : Bool :=
  okCall P x name args || (Host.Load.isMlx name && match Host.Mlx.Ffi.symOf name with
    | some s => NativeOkS.symG P x.mlx s args
    | none => false)

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)

include hs hr

theorem mlx_simS (s : Host.Mlx.Ffi.Sym) (hsym : Host.Mlx.Ffi.symOf name = some s) (args : List Arg)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hok : NativeOkS.symG P x s args = true)
    (hsm : ∀ j ∈ smallRefs x name args, RefSmall ν S j) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name args) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  cases s
  case slice =>
    simp only [NativeOkS.symG] at hok; unfold NativeOkS.slice at hok; split at hok
    · rename_i o a st n1 sp n2 sr n3 e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨ha, k1⟩, k2⟩, k3⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a] <;> cases e1 : Host.Mlx.Ffi.dimsArg st n1 <;>
        cases e2 : Host.Mlx.Ffi.dimsArg sp n2 <;> cases e3 : Host.Mlx.Ffi.dimsArg sr n3 <;>
        simp only [h1, e1, e2, e3, reduceCtorEq] at hm
      rename_i ins d1 d2 d3
      simp only [Bool.and_eq_true] at hm
      obtain ⟨⟨⟨⟨ho, v1⟩, v2⟩, v3⟩, hm⟩ := hm
      split at hm
      · rename_i sh0 s0 dt0 hsh
        exact sim_sliceS hs hr hsym ha k1 k2 k3 h1 e1 e2 e3 ho v1 v2 v3 hsh hm hsm
      · cases hm
    · cases hok
  case sliceUpdate =>
    simp only [NativeOkS.symG] at hok; unfold NativeOkS.sliceUpdate at hok; split at hok
    · rename_i o a u st n1 sp n2 sr n3 e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨ha, hu⟩, k1⟩, k2⟩, k3⟩, hm⟩ := hok
      cases h1 : Host.Mlx.Ffi.arrIns x [a, u] <;> cases e1 : Host.Mlx.Ffi.dimsArg st n1 <;>
        cases e2 : Host.Mlx.Ffi.dimsArg sp n2 <;> cases e3 : Host.Mlx.Ffi.dimsArg sr n3 <;>
        simp only [h1, e1, e2, e3, reduceCtorEq] at hm
      rename_i ins d1 d2 d3
      simp only [Bool.and_eq_true] at hm
      obtain ⟨⟨⟨⟨ho, v1⟩, v2⟩, v3⟩, hm⟩ := hm
      split at hm
      · rename_i sh0 s0 dt0 u0 du0 hsh
        simp only [Bool.and_eq_true] at hm
        exact sim_sliceUpdateS hs hr hsym ha hu k1 k2 k3 h1 e1 e2 e3 ho v1 v2 v3 hsh hm.1 hm.2 hsm
      · cases hm
    · cases hok
  case concat =>
    simp only [NativeOkS.symG] at hok; unfold NativeOkS.concat at hok; split at hok
    · rename_i o v ax e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨hv, hax⟩, hm⟩ := hok
      split at hm
      · rename_i i rest h3
        cases hn : x.nodes.get i <;> cases hai : Host.Mlx.Ffi.argInt ax <;>
          simp only [hn, hai, reduceCtorEq] at hm
        rename_i nd a
        cases hb : Host.Mlx.Ffi.axisOf a (len nd.shape) <;> simp only [hb, reduceCtorEq] at hm
        simp only [Bool.and_eq_true] at hm
        obtain ⟨ho, hm⟩ := hm
        split at hm
        · rename_i sh0 s1 d1 s2 d2 hsh
          simp only [Bool.and_eq_true] at hm
          exact sim_concatS hs hr hsym hv hax h3 hn hai hb ho hsh hm.1 hm.2 hsm
        · cases hm
      · cases hm
    · cases hok
  case sdpa =>
    simp only [NativeOkS.symG] at hok; unfold NativeOkS.sdpa at hok; split at hok
    · rename_i o q k v scale mask mk sk e1 e2
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨hq, hk⟩, hv⟩, hmk⟩, hsk⟩, hm⟩ := hok
      split at hm
      · rename_i ins m h1 hcm h0 h0'
        simp only [Bool.and_eq_true] at hm
        obtain ⟨ho, hm⟩ := hm
        split at hm
        · rename_i sh0 p1 p2 p3 hsh
          obtain ⟨sq, dq⟩ := p1
          obtain ⟨sk', dk⟩ := p2
          obtain ⟨sv, dv⟩ := p3
          exact sim_sdpaS hs hr hsym hq hk hv hmk hsk
            (SN.of_supp (A := fun _ => True) (hsupp (.num scale) (by simp))) h1 hcm h0 h0' ho hsh
        · cases hm
      · cases hm
    · cases hok
  case closureApply =>
    simp only [NativeOkS.symG] at hok
    exact sim_closureApplyG hs hr hsym hok
  all_goals (unfold NativeOkS.symG at hok; cases hok)

end

/-- **The native-call simulation with the numeric premise.** -/
theorem loadFfiCallSim (P : LoadP) (NB : Nat) : FfiCallSim Host.Load.ffi (LoadR P NB) (okCallSG P) smallLoad where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    simp only [okCallSG, Bool.or_eq_true] at hok
    rcases hok with hok | hok
    · exact (loadFfiSim P NB).call M ν S C x y name args hsrv hr hok hsupp
    · simp only [Bool.and_eq_true] at hok
      obtain ⟨hm, hok⟩ := hok
      cases hsym : Host.Mlx.Ffi.symOf name with
      | none => rw [hsym] at hok; cases hok
      | some s =>
        rw [hsym] at hok
        exact mlx_lift hr hm (mlx_simS hsrv hr.mlx s hsym args hsupp hok hsm)

/-- The accepted calls do not depend on `P.rest`. -/
theorem okCallSG_rest (P : LoadP) (r : List NumV) : okCallSG { P with rest := r } = okCallSG P := by
  funext x name args
  unfold okCallSG okCall
  cases Host.Mlx.Ffi.symOf name with
  | none => rfl
  | some s => cases s <;> rfl

end Host.Ts.Sim.G
