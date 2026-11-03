import host.route.cert.Fin.VW.Cert
import host.sim.compose.a4b.fd.Forward
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.Cert.Fin.VW
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Tpl
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Route.PrefGraph
open Host.Ts.Sim.Compose (NTrack)
open Host.Ts.Sim.Compose.FDVW (returnCut)

/-! # The VW class's final forward, at its return -/

theorem box_cases {j : Nat} {l h : Int} (hg : Box.get box j = some (l, h)) :
    (j = 9 ∧ l = 2 ∧ h = 224) ∨ (j = 10 ∧ l = 1 ∧ h = 223) ∨ (j = 11 ∧ l = 1 ∧ h = 223) ∨ (j = 12 ∧ l = 1 ∧ h = 1) ∨
      (j = 16 ∧ l = 256 ∧ h = 256) := by
  unfold Box.get box at hg
  by_cases h9 : j = 9
  · subst h9; simp at hg; exact .inl ⟨rfl, hg.1.symm, hg.2.symm⟩
  by_cases h10 : j = 10
  · subst h10; simp at hg; exact .inr (.inl ⟨rfl, hg.1.symm, hg.2.symm⟩)
  by_cases h11 : j = 11
  · subst h11; simp at hg; exact .inr (.inr (.inl ⟨rfl, hg.1.symm, hg.2.symm⟩))
  by_cases h12 : j = 12
  · subst h12; simp at hg; exact .inr (.inr (.inr (.inl ⟨rfl, hg.1.symm, hg.2.symm⟩)))
  by_cases h16 : j = 16
  · subst h16; simp at hg; exact .inr (.inr (.inr (.inr ⟨rfl, hg.1.symm, hg.2.symm⟩)))
  simp [Ne.symm h9, Ne.symm h10, Ne.symm h11, Ne.symm h12, Ne.symm h16] at hg

theorem nu9 (L : Nat) : nuV vars L 9 = L := by simp [nuV, varGet, vars]
theorem nu10 (L : Nat) : nuV vars L 10 = (L : Int) - 1 := by simp [nuV, varGet, vars]; omega
theorem nu11 (L : Nat) : nuV vars L 11 = (L : Int) - 1 := by simp [nuV, varGet, vars]; omega
theorem nu12 (L : Nat) : nuV vars L 12 = 1 := by simp [nuV, varGet, vars]
theorem nu16 (L : Nat) : nuV vars L 16 = 256 := by simp [nuV, varGet, vars]

theorem inBox {L : Nat} (h1 : 2 ≤ L) (h2 : L ≤ 224) : InBox box (nuV vars L) := by
  intro j l h hg
  rcases box_cases hg with ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩
  · rw [nu9]; omega
  · rw [nu10]; omega
  · rw [nu11]; omega
  · rw [nu12]; omega
  · rw [nu16]; omega

theorem lastRows_eq {π : List Nat} (h : 1 ≤ π.length) : Host.Ts.Sim.Compose.FDVW.lastRows π = [π.getD (π.length - 1) 0] := by
  obtain ⟨ρ, b, rfl⟩ : ∃ ρ b, π = ρ ++ [b] := by
    rcases List.eq_nil_or_concat π with e | ⟨ρ, b, e⟩
    · subst e; simp at h
    · exact ⟨ρ, b, by rw [e, List.concat_eq_append]⟩
  simp [Host.Ts.Sim.Compose.FDVW.lastRows]

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) {π : List Nat}

/-- **The VW class's final forward**: its return holds the reference's step through the forward. -/
theorem hfin (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hpre : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs)
    (hL1 : 2 ≤ π.length) (hL2 : π.length ≤ 224)
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr π.length = finCert.ps) (Kept : Nat → List (Nat × Nat))
    (hKept : ∀ q ∈ Kept π.length, q.1 < finCert.cert.length ∧ certAt finCert.cert q.1 = q.2) (Kn : Nat → Nat) (hKn : Kn π.length = 4010)
    {NB T : Nat} {tk : Nat → Nat} {cap H N : Nat} (hNB : 15235 ≤ NB) {x y : SegInst FF}
    (hy : (returnCut NB T tk π cap H N).R y PRE_fd_vw_r0_body.s900 ⟨PRE_fd_vw_r0_body.S900.tab, []⟩)
    (htr : NTrack x y) (L : Nat)
    (hm : memExit P KR NE net env π Cr L x) : memFin P KR NE net env π Kept Kn L y := by
  obtain ⟨K0, hr, hb, hip, -⟩ := hy
  obtain ⟨Pm, hP, r0⟩ := hr.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm NB y.M PRE_fd_vw_r0_body.S900.tab.length native (mlxOf y.t.ffi) := r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 5554869888 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact (by decide : ((131072 : Nat) : Int) ≤ 5554869888)
  have hrope := hmr.bigFixHi 5554869888 hE (by decide)
  have hlast := lastRows_eq (π := π) (by omega)
  have hmem : π.getD (π.length - 1) 0 ∈ π := by
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega : π.length - 1 < π.length), Option.getD_some]
    exact List.getElem_mem _
  refine hfinV P KR NE net env leaves typed hpre finCert finCert_below hNB hL1 hL2 (inBox hL1 hL2) Cr hCr Kept hKept Kn hKn
    hmr hband hrope ?_ (fun tab hC i e h => hC.val (hr.srv.num i e h)) ?_ (by have := hb.vocab _ hmem; omega)
    htr.server htr.map htr.nodes htr.tokens L hm
  · intro j l h hg
    rcases box_cases hg with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩
    · rw [nu9]; exact hb.promptValue
    · rw [nu10, show (π.length : Int) - 1 = ((π.length - 1 : Nat) : Int) by omega]; exact hb.rowValue
    · rw [nu11, show (π.length : Int) - 1 = ((π.length - 1 : Nat) : Int) by omega]; exact hb.offsetValue
    · rw [nu12]; exact hb.rowOne
    · rw [nu16, hb.capValue, show Host.Ts.Sim.capL (π.length - 1) = 256 by unfold Host.Ts.Sim.capL; omega]
      rfl
  · intro tab hC
    have h := (hip.grow (Host.Mlx.Ffi.NGrow.refl _) hC).2
    rw [hlast] at h
    show HostInt32 _ _ (y.M.node 19057) _ _
    simpa using h

end Host.Route.Cert.Fin.VW
