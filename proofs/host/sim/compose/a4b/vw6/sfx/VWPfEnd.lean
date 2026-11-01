import host.sim.compose.a4b.VWPf
import host.sim.compose.a4b.PF6
import host.sim.compose.a4b.vw6.sfx.VWBodyChain
import host.sim.compose.a4b.vw6.sfx.VWBodyMap
import host.sim.compose.a4b.VWFirstRows
import host.sim.template.a4pre_first_tail_x6_r0_suffix.m.B0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW6.Sfx
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl pfKeys : (PFW6.R.theta ++ PF6.thetaX).map Prod.fst = [11, 14, 16, 30, 31]
kernel_rfl pf14 : PF6.θ 14 = .var 17
kernel_rfl pf30 : (fun ν : Nat → F64 => (PF6.θ 30).eval ν) = fun _ => F64.ofNat 24
kernel_rfl pf31 : (fun ν : Nat → F64 => (PF6.θ 31).eval ν) = fun _ => F64.ofNat 24
kernel_rfl pfRow11 : (fwdRows.all fun r => resChk r bodyM (PF6.θ 11) (some Q.n)) = true
kernel_rfl pfRow16 : (fwdRows.all fun r => resChk r bodyM (PF6.θ 16) (some Q.cap1)) = true
kernel_rfl pfNN : PFW6.R.data.nn0 = PFW6.R.data.nn1
kernel_rfl pfNK : PTrie.keys PFW6.R.data.node = []
kernel_rfl pfNext : PRE_first_tail_x6_r0_suffix.s8.next = PRE_pf_vw.s0.next
kernel_rfl pfH : (mlxOf PRE_first_tail_x6_r0_suffix.s8.ffi).next = (mlxOf PRE_pf_vw.s0.ffi).next
kernel_rfl pfNodes : (mlxOf PRE_first_tail_x6_r0_suffix.s8.ffi).nnext = (mlxOf PRE_pf_vw.s0.ffi).nnext
kernel_rfl pfBelow : Nat.ble (mlxOf PRE_first_tail_x6_r0_suffix.s8.ffi).nnext PF6.P0.NL = true
kernel_rfl pfA : PFW6.R.data.a 2590 = 2590
kernel_rfl pfB : PFW6.R.data.a 2586 = 2586
kernel_rfl pfC : PFW6.R.data.a 2589 = 2589

/-- The rows' last quantities. -/
theorem rowCap {r : Row} {i : Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) : i.cap1 = capL (i.L - 1) := by
  simp only [fwdRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  subst hr
  all_goals
    obtain ⟨_, x, hx, hq⟩ := hi
    simp only [first_tail_x6.r0, InBox, QOk, Inst.get, eval_mk, dot] at hx hq
    unfold capL
    omega

/-- **The step's end at the pre-final cut.** -/
theorem toPfEnd (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (cap : Nat) (hcap : 68833 ≤ cap)
    (hbound : cap < Sim.bound) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y)
    {r : Row} {i : Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) (htail : r ∈ firstTailRows) :
    CutConv (withMem Tr (bodyCore NB T tk π i bodyΘ ⟨68833, 1254, 0, 0⟩ bodyM PRE_first_tail_x6_r0_suffix.s8 PRE_first_tail_x6_r0_suffix.S8))
      (withMem Tr (Pf.cut NB T tk π cap 1254 0 PRE_pf_vw.s0 PRE_pf_vw.S0)) := by
  obtain ⟨hL, hLmax, hn, _⟩ := firstTailFacts htail hi
  have hcapR := rowCap hr hi
  have h9 : ∀ ν, MapOk ν i bodyM → ν 9 = F64.ofNat i.L := fun ν hm =>
    (Conv.mapOk_iff'.1 hm) (9, Q.L) (by simp [bodyM])
  have h10n : ∀ ν, MapOk ν i bodyM → ν 10 = F64.ofNat i.n := fun ν hm =>
    (Conv.mapOk_iff'.1 hm) (10, Q.n) (by simp [bodyM])
  exact toPf (c30 := 24) (c31 := 24) PF6.facts hT hLmax (Nat.le_of_ble_eq_true pfBelow) pfNN pfNK pfNext pfH pfNodes
    (fun j h1 h2 h3 h4 h5 => Pf.thetaOf_off (by
      rw [pfKeys]
      simp only [List.mem_cons, List.not_mem_nil, or_false]
      omega))
    pf14 h9 (fun ν hm => by rw [h10n ν hm, hn])
    (fun ν hm => by
      rw [← hn]
      exact (resChk_sound (List.all_eq_true.mp pfRow11 r hr) hi hm).2 Q.n rfl)
    (fun ν hm => by
      rw [← hcapR]
      exact (resChk_sound (List.all_eq_true.mp pfRow16 r hr) hi hm).2 Q.cap1 rfl)
    (fun ν => congrFun pf30 ν) (fun ν => congrFun pf31 ν) (by decide) (by decide) pfA pfB pfC hcap hbound

end Host.Ts.Sim.Compose.VWFirst.VW6.Sfx
