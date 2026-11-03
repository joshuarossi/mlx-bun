import host.route.cert.Head.X4L9.Cert
import host.sim.compose.PostCut
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.Cert.Head.X4L9
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Tpl
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Route.PrefGraph Host.Route.Cert.Fin

/-! # The X4L9 class's sampled cut, from its certificate -/

theorem boxH_cases {j : Nat} {l h : Int} (hg : Box.get boxH j = some (l, h)) :
    (j = 9 ∧ l = 9 ∧ h = 9) ∨ (j = 10 ∧ l = 1 ∧ h = 1) ∨ (j = 11 ∧ l = 9 ∧ h = 9) ∨ (j = 16 ∧ l = 256 ∧ h = 256) := by
  unfold Box.get boxH at hg
  by_cases h9 : j = 9
  · subst h9; simp at hg; exact .inl ⟨rfl, hg.1.symm, hg.2.symm⟩
  by_cases h10 : j = 10
  · subst h10; simp at hg; exact .inr (.inl ⟨rfl, hg.1.symm, hg.2.symm⟩)
  by_cases h11 : j = 11
  · subst h11; simp at hg; exact .inr (.inr (.inl ⟨rfl, hg.1.symm, hg.2.symm⟩))
  by_cases h16 : j = 16
  · subst h16; simp at hg; exact .inr (.inr (.inr ⟨rfl, hg.1.symm, hg.2.symm⟩))
  simp [Ne.symm h9, Ne.symm h10, Ne.symm h11, Ne.symm h16] at hg

theorem nuH9 (L : Nat) : nuV varsH L 9 = L := by simp [nuV, varGet, varsH]
theorem nuH10 (L : Nat) : nuV varsH L 10 = 1 := by simp [nuV, varGet, varsH]
theorem nuH11 (L : Nat) : nuV varsH L 11 = L := by simp [nuV, varGet, varsH]
theorem nuH16 (L : Nat) : nuV varsH L 16 = 256 := by simp [nuV, varGet, varsH]

theorem inBoxH {L : Nat} (h1 : L = 9) : InBox boxH (nuV varsH L) := by
  intro j l h hg
  rcases boxH_cases hg with ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩
  · rw [nuH9]; omega
  · rw [nuH10]; omega
  · rw [nuH11]; omega
  · rw [nuH16]; omega

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) {π : List Nat}

/-- **`hsmp` of the X4L9 class**, at its sampled cut. -/
theorem hsmp (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, Host.Mlx.SimGraph.Mach.RefTokens P KR NE KR.inPlace net env π tab) (hL : π.length = 9)
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr π.length = carriersOf (certAt headCert.cert))
    (Kept : Nat → List (Nat × Nat)) (hKept : Kept π.length = keptOf (certAt headCert.cert)) (Kn : Nat → Nat) (hKn : Kn π.length = 4010)
    (toks : Nat → Nat → Nat) (htoks : toks π.length 0 = certAt headCert.cert Tpl.Ordinary.tokenNode)
    {NB T capC nI : Nat} {extra : List Nat} {tk : Nat → Nat} (hNB : 15235 ≤ NB) {y : SegInst FF}
    (hy : (Host.Ts.Sim.Compose.Post.indexedCut0 extra NB T tk capC nI π PRE_plx4_L9_common.s1 PRE_plx4_L9_common.S1).R y
      PRE_plx4_L9_common.s1 ⟨PRE_plx4_L9_common.S1.tab, []⟩)
    (L : Nat) (hm : memFin P KR NE net env π Kept Kn L y) : memPost P KR NE net env π 0 toks Cr L y := by
  obtain ⟨γ, hr, hb⟩ := hy
  obtain ⟨Pm, hP, r0⟩ := hr.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm NB y.M PRE_plx4_L9_common.S1.tab.length nativeH (mlxOf y.t.ffi) := r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 5554869888 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact (by decide : ((131072 : Nat) : Int) ≤ 5554869888)
  have hrope := hmr.bigFixHi 5554869888 hE (by decide)
  have hmem : π.getD (π.length - 1) 0 ∈ π := by
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega : π.length - 1 < π.length), Option.getD_some]
    exact List.getElem_mem _
  refine hsmpV P KR NE net env leaves typed hRT headCert hNB (by omega) (by omega) (inBoxH hL) (by have := hb.vocab _ hmem; omega)
    Cr hCr Kept hKept Kn hKn toks htoks hmr hband hrope ?_ (fun tab hC i e h => hC.val (hr.srv.num i e h)) L hm
  intro j l h hg
  rcases boxH_cases hg with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩
  · rw [nuH9]; exact hb.promptValue
  · rw [nuH10]; exact hb.rowValue
  · rw [nuH11]; exact hb.offsetValue
  · rw [nuH16, hb.capValue, show Host.Ts.Sim.capL π.length = 256 by unfold Host.Ts.Sim.capL; omega]
    rfl

end Host.Route.Cert.Head.X4L9
