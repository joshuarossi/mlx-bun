import host.route.cert.Fin.D1X0.Cert
import host.route.cert.Fin.D1X0.Tab
import host.route.FamFwd
import host.sim.compose.a4b.x0.sfx.VWForward
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.Cert.Fin.D1X0
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Tpl
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Lin.Cls (Row InRow)
open Host.Ts.Sim.Compose.VWFirst.X0 (fwdRows)
open Host.Ts.Sim.Compose.VWFirst.X0.Sfx (startCore)
open Host.Route.PrefGraph Host.Route.Cert.Fin

/-! # The x0 group's forward at the bookkeeping: the prompts of two tokens -/

open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls in
theorem rowN {r : Row} {i : Host.Ts.Sim.Lin.Cls.Inst} (hr : r ∈ fwdRows) (hi : InRow r i) : i.n = 1 := by
  simp only [fwdRows, List.mem_cons, List.not_mem_nil, or_false] at hr
  subst hr
  obtain ⟨_, x, hx, hq⟩ := hi
  simp only [first_tail_x0.r0, Host.Ts.Sim.Lin.InBox, QOk, Inst.get, eval_mk, dot] at hx hq
  omega

theorem nu9 (L : Nat) : nuV vars L 9 = L := by simp [nuV, varGet, vars]

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- **The x0 group's `hfwd`**: the cold one-row step, at its carriers. -/
theorem hfwd (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hstep : ∀ tab, ∃ t hs', stepTrace P.toMlxContract KR.toKernelContract (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) 0
      (π.getD 0 0) initialHandles = some (t, hs'))
    (Cr : Nat → List (Option Nat × Option Nat)) (hlt : ∀ t ∈ π, t < 2 ^ 31)
    (hCr : Cr 2 = Expected.cacheOutputs.map fun q => (some (certAt d1Cert.cert q.1), some (certAt d1Cert.cert q.2)))
    (hL : π.length = 2) (T : Nat) (tk : Nat → Nat) :
    ∀ r ∈ fwdRows, ∀ i, InRow r i → ∀ x y : SegInst FF,
      (startCore 15235 T tk π i).R y (startCore 15235 T tk π i).s0 ⟨(startCore 15235 T tk π i).tab0, []⟩ →
      Host.Ts.Sim.CSrv.Le x.C y.C → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) →
      (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens →
      memCold P KR net env π i.L x → memPre P KR NE net env π Cr i.L y := by
  intro r hr i hi x y hy hle hg ht hm
  have hn := rowN hr hi
  obtain ⟨K0, hrel, hb, -, hip, -, hmap, -⟩ := hy
  have hLen : π.length = i.L := hb.length
  obtain ⟨Pm, hP, r0⟩ := hrel.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm 15235 y.M PRE_first_tail_x0_r0_suffix.S0.tab.length native (mlxOf y.t.ffi) := r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 5554869888 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact (by decide : ((131072 : Nat) : Int) ≤ 5554869888)
  have hrope := hmr.bigFixHi 5554869888 hE (by decide)
  have hv9 : y.ν 9 = F64.ofNat i.L := hmap.1
  have hmem : π.getD 0 0 ∈ π := by
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega : 0 < π.length), Option.getD_some]
    exact List.getElem_mem _
  have htake : π.take i.n = [π.getD 0 0] := by
    rw [hn]
    obtain ⟨a, b, rfl⟩ : ∃ a b, π = [a, b] := by
      match π, hL with
      | [a, b], _ => exact ⟨a, b, rfl⟩
    rfl
  refine hfwdD1 P KR NE net env leaves typed hstep d1Cert (Nat.le_refl _) hL ?_ (hlt _ hmem) Cr (hL ▸ hCr) hmr hband hrope ?_
    (fun tab hC j e h => hC.val (hrel.srv.num j e (tab_eq ▸ h))) ?_ hle hg ht i.L hm
  · intro j l h hg'
    unfold Box.get box at hg'
    by_cases h9 : j = 9
    · subst h9
      simp at hg'
      rw [nu9, hL, ← hg'.1, ← hg'.2]
      exact ⟨Int.le_refl _, Int.le_refl _⟩
    · simp [Ne.symm h9] at hg'
  · intro j l h hg'
    unfold Box.get box at hg'
    by_cases h9 : j = 9
    · subst h9
      rw [nu9, hLen]
      exact hv9
    · simp [Ne.symm h9] at hg'
  · intro tab hC
    have h := (hip.grow (Host.Mlx.Ffi.NGrow.refl _) hC).2
    rw [htake] at h
    show HostInt32 _ _ (y.M.node 15235) _ _
    simpa using h

end Host.Route.Cert.Fin.D1X0
