import host.sim.compose.a4b.PLT
import host.sim.compose.PostLink
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.Pf

/-! # The one-token class's sampled cut at the shared tail

The walk leaves the nodes alone and the offset. It moves one variable, and sets three. -/

kernel_rfl pltKeys : (PLTail.R.theta ++ PLT.thetaX).map Prod.fst = [14, 20, 21, 23, 25]
kernel_rfl plt14 : PLT.θ 14 = .var 17
kernel_rfl plt20 : (fun ν : Nat → F64 => (PLT.θ 20).eval ν) = fun _ => F64.ofNat 6
kernel_rfl plt21 : PLT.θ 21 = .bin .add (.var 21) (.lit (F64.ofNat 1))
kernel_rfl plt23 : (fun ν : Nat → F64 => (PLT.θ 23).eval ν) = fun _ => F64.ofNat 5
kernel_rfl plt25 : (fun ν : Nat → F64 => (PLT.θ 25).eval ν) = fun _ => F64.ofNat 5
kernel_rfl pltNN : PLTail.R.data.nn0 = PLTail.R.data.nn1
kernel_rfl pltNK : PTrie.keys PLTail.R.data.node = []
kernel_rfl pltNext : PRE_pl_common.s4.next = PRE_pl_tail.s0.next
kernel_rfl pltH : (mlxOf PRE_pl_common.s4.ffi).next = (mlxOf PRE_pl_tail.s0.ffi).next
kernel_rfl pltN : (mlxOf PRE_pl_common.s4.ffi).nnext = (mlxOf PRE_pl_tail.s0.ffi).nnext
kernel_rfl pltBelow : Nat.ble (mlxOf PRE_pl_common.s4.ffi).nnext PLT.P0.NL = true
kernel_rfl pltA : PLTail.R.data.a 2590 = 2590
kernel_rfl pltB : PLTail.R.data.a 2586 = 2586
kernel_rfl pltC : PLTail.R.data.a 2589 = 2589
kernel_rfl pltE : PLTail.R.data.a 12504 = 12504

theorem plt_off {j : Nat} (h : j ≠ 14 ∧ j ≠ 20 ∧ j ≠ 21 ∧ j ≠ 23 ∧ j ≠ 25) : PLT.θ j = .var j :=
  thetaOf_off (by
    rw [pltKeys]
    simp only [List.mem_cons, List.not_mem_nil, or_false]
    omega)

theorem pltValuation {ν : Nat → F64} (hv : VBOkF loopVB ν) {k : Nat} (hk : k + 1 ≤ 2 ^ 20) (h21 : ν 21 = F64.ofNat k) :
    VBOkF loopVB (Shift.valuation PLT.θ ν) := by
  intro j
  change ∃ n ≤ 2 ^ 20, (PLT.θ j).eval ν = F64.ofNat n
  by_cases h14 : j = 14
  · subst h14
    rw [plt14]
    exact hv 17
  by_cases h20 : j = 20
  · subst h20
    exact ⟨6, by decide, congrFun plt20 ν⟩
  by_cases h2 : j = 21
  · subst h2
    refine ⟨k + 1, hk, ?_⟩
    rw [plt21]
    change F64.bin .add (ν 21) (F64.ofNat 1) = _
    rw [h21]
    exact bin_add_ofNat k 1 (by omega)
  by_cases h23 : j = 23
  · subst h23
    exact ⟨5, by decide, congrFun plt23 ν⟩
  by_cases h25 : j = 25
  · subst h25
    exact ⟨5, by decide, congrFun plt25 ν⟩
  rw [plt_off ⟨h14, h20, h2, h23, h25⟩]
  exact hv j

/-- **The one-token class's link.** -/
theorem hlinkOne {NB T cap nI : Nat} {tk : Nat → Nat} {π : List Nat} {Mem Mem' : SegInst FF → Prop} (hbound : cap < Sim.bound)
    (h21 : ∀ x : SegInst FF, Mem x → ∃ k, k + 1 ≤ 2 ^ 20 ∧ x.ν 21 = F64.ofNat k)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut NB T tk cap nI π PRE_pl_common.s4 PRE_pl_common.S4))
      (withMem Mem' (indexedCut NB T tk cap nI π PRE_pl_tail.s0 PRE_pl_tail.S0)) :=
  toTail PLT.facts (Nat.le_of_ble_eq_true pltBelow) pltH pltN
    (by rw [pltNext]; omega) hbound
    (plt_off (by omega)) (plt_off (by omega)) (plt_off (by omega)) (plt_off (by omega))
    (fun j hj => plt_off (by omega))
    (fun x hm hv => by
      obtain ⟨k, hk, he⟩ := h21 x hm
      exact pltValuation hv hk he)
    pltA pltB pltC pltE (nodeF_id pltNN pltNK _)
    (fun x y ht hC hn ha hm => hook x y ht hC (funext fun c => (hn c).trans (congrArg x.M.node (nodeF_id pltNN pltNK c))) ha hm)

end Host.Ts.Sim.Compose.Post
