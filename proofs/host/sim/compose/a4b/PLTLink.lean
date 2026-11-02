import host.sim.compose.a4b.PLT
import host.sim.compose.PostLink
import host.sim.compose.TailVals
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Ts.Sim.Compose.Pf

/-! # A short row's sampled cut at the shared tail

The walk leaves the nodes alone and the offset. The tail's variables take literals, or the class's own. -/

noncomputable abbrev pltKeys : List Nat := (PLTP.R.theta ++ PLT.thetaX).map Prod.fst

kernel_rfl pltKept : ((List.range 9) ++ [9, 10, 11, 16]).all (fun j => decide (PLT.θ j = SymE.var j)) = true
kernel_rfl pltSmall : (pltKeys.all fun j => [200].contains j || imgSmall [1, 3, 4, 5, 6, 7, 8, 1536] (PLT.θ j)) = true
kernel_rfl pltDims : dimsLitB PLT.θ = true
kernel_rfl plt20 : litAt PLT.θ 20 6 = true
kernel_rfl plt22 : PLT.θ 22 = .var 22
kernel_rfl plt23 : litAt PLT.θ 23 5 = true
kernel_rfl plt24 : PLT.θ 24 = .var 24
kernel_rfl plt25 : litAt PLT.θ 25 5 = true
kernel_rfl plt26 : PLT.θ 26 = .var 26
kernel_rfl plt200 : PLT.θ 200 = .bin .add (.var 21) (.lit (F64.ofNat 1))
kernel_rfl pltNN : PLTP.R.data.nn0 = PLTP.R.data.nn1
kernel_rfl pltNK : PTrie.keys PLTP.R.data.node = []
kernel_rfl pltNext : PRE_pl_common.s1.next = PRE_pl_tail.s0.next
kernel_rfl pltH : Nat.ble ((mlxOf PRE_pl_common.s1.ffi).next + 4096) ((mlxOf PRE_pl_tail.s0.ffi).next + 65536) = true
kernel_rfl pltN : Nat.ble ((mlxOf PRE_pl_common.s1.ffi).nnext + 4096) ((mlxOf PRE_pl_tail.s0.ffi).nnext + 65536) = true
kernel_rfl pltA : PLTP.R.data.a 2590 = 2590
kernel_rfl pltB : PLTP.R.data.a 2586 = 2586
kernel_rfl pltC : PLTP.R.data.a 2589 = 2589
kernel_rfl pltE : PLTP.R.data.a 12504 = 12504

theorem plt_kept {j : Nat} (h : j ∈ (List.range 9) ++ [9, 10, 11, 16]) : PLT.θ j = .var j :=
  of_decide_eq_true (List.all_eq_true.mp pltKept j h)

theorem pltImg : ShortImg PLT.θ := ⟨plt20, plt22, plt23, plt24, plt25, plt26, plt200⟩

/-- **The one-token class's link**: its chunk goes here. -/
theorem hlinkOne {NB T cap nI : Nat} {tk : Nat → Nat} {π : List Nat} {Mem Mem' : SegInst FF → Prop}
    (hNB : NB ≤ PLT.P0.NL) (hbound : cap < Sim.bound) (hL : π.length ≤ 2)
    (hs : ∀ x : SegInst FF, Mem x → ShortVals x.ν)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → y.M.node = x.M.node → y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut0 [2673479] NB T tk cap nI π PRE_pl_common.s1 PRE_pl_common.S1))
      (withMem Mem' (indexedCut NB T tk cap nI π PRE_pl_tail.s0 PRE_pl_tail.S0)) :=
  toTail PLT.facts (fun b hb => by obtain rfl := List.mem_singleton.mp hb; rfl) hNB (Nat.le_of_ble_eq_true pltH) (Nat.le_of_ble_eq_true pltN)
    (by rw [pltNext]) (by rw [pltNext]; omega) hbound
    (plt_kept (by decide)) (plt_kept (by decide)) (plt_kept (by decide)) (plt_kept (by decide))
    (fun j hj => plt_kept (List.mem_append_left _ (List.mem_range.mpr hj)))
    (fun x hm hv => valOf (off := [200]) hv (fun _ hj => thetaOf_off hj) pltSmall (by
      intro j hj
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
      subst hj
      exact ⟨5, by decide, pltImg.v200 (hs x hm)⟩))
    (fun _ _ => dimsLit pltDims _)
    (fun x hm => handShort hL pltImg (hs x hm))
    pltA pltB pltC pltE (nodeF_id pltNN pltNK _)
    (fun x y ht hC hn ha hm => hook x y ht hC (funext fun c => (hn c).trans (congrArg x.M.node (nodeF_id pltNN pltNK c))) ha hm)

end Host.Ts.Sim.Compose.Post
