import host.route.cert.Fin.X4L7.Cert
import host.sim.compose.a4b.fd_x4_L7.Forward
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.Cert.Fin.X4L7
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Load.Run.Tpl
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Route.PrefGraph Host.Route.Cert.Fin
open Host.Ts.Sim.Compose (NTrack)

/-! # The X4L7 class's final forward, at its return -/

theorem nu9 : nuV vars 7 9 = 7 := by decide
theorem nu10 : nuV vars 7 10 = 6 := by decide
theorem nu11 : nuV vars 7 11 = 6 := by decide
theorem nu16 : nuV vars 7 16 = 256 := by decide

theorem inBox : InBox box (nuV vars 7) := by
  intro j l h hg
  unfold Box.get box at hg
  by_cases h9 : j = 9
  · subst h9
    simp at hg
    rw [nu9, ← hg.1, ← hg.2]
    exact ⟨Int.le_refl _, Int.le_refl _⟩
  by_cases h10 : j = 10
  · subst h10
    simp at hg
    rw [nu10, ← hg.1, ← hg.2]
    exact ⟨Int.le_refl _, Int.le_refl _⟩
  by_cases h11 : j = 11
  · subst h11
    simp at hg
    rw [nu11, ← hg.1, ← hg.2]
    exact ⟨Int.le_refl _, Int.le_refl _⟩
  by_cases h16 : j = 16
  · subst h16
    simp at hg
    rw [nu16, ← hg.1, ← hg.2]
    exact ⟨Int.le_refl _, Int.le_refl _⟩
  simp [Ne.symm h9, Ne.symm h10, Ne.symm h11, Ne.symm h16] at hg

theorem lastRows_eq {π : List Nat} (h : 1 ≤ π.length) : Host.Ts.Sim.Compose.FDX4L7.lastRows π = [π.getD (π.length - 1) 0] := by
  obtain ⟨ρ, b, rfl⟩ : ∃ ρ b, π = ρ ++ [b] := by
    rcases List.eq_nil_or_concat π with e | ⟨ρ, b, e⟩
    · subst e; simp at h
    · exact ⟨ρ, b, by rw [e, List.concat_eq_append]⟩
  simp [Host.Ts.Sim.Compose.FDX4L7.lastRows]

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) {π : List Nat}

/-- **The X4L7 class's final forward**: its return holds the reference's step through the forward. -/
theorem hfin (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hpre : ∀ tab, ∃ s, Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π tab = some s ∧
      List.Forall₂ (Host.Mlx.SimGraph.Mach.StagePre (π.length - 1))
        (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) s.hs)
    (hL : π.length = 7)
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr π.length = finCert.ps) (Kept : Nat → List (Nat × Nat))
    (hKept : ∀ q ∈ Kept π.length, q.1 < finCert.cert.length ∧ certAt finCert.cert q.1 = q.2) (Kn : Nat → Nat) (hKn : Kn π.length = 4010)
    {NB T : Nat} {tk : Nat → Nat} {cap H N : Nat} (hNB : 15235 ≤ NB) {x y : SegInst FF}
    (hy : (Host.Ts.Sim.Compose.FDX4L7.returnCut NB T tk π cap H N).R y PRE_fd_x4_L7_r0_body.s451 ⟨PRE_fd_x4_L7_r0_body.S451.tab, []⟩)
    (htr : NTrack x y) (L : Nat)
    (hm : memExit P KR NE net env π Cr L x) : memFin P KR NE net env π Kept Kn L y := by
  obtain ⟨K0, hr, hb, hip, -⟩ := hy
  obtain ⟨Pm, hP, r0⟩ := hr.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm NB y.M PRE_fd_x4_L7_r0_body.S451.tab.length native (mlxOf y.t.ffi) := r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 5554869888 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact (by decide : ((131072 : Nat) : Int) ≤ 5554869888)
  have hrope := hmr.bigFixHi 5554869888 hE (by decide)
  have hlast := lastRows_eq (π := π) (by omega)
  have hmem : π.getD (π.length - 1) 0 ∈ π := by
    rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega : π.length - 1 < π.length), Option.getD_some]
    exact List.getElem_mem _
  refine hfinV P KR NE net env leaves typed hpre finCert finCert_below hNB (by omega) (by omega) (hL ▸ inBox) Cr hCr Kept hKept
    Kn hKn hmr hband hrope ?_ (fun tab hC i e h => hC.val (hr.srv.num i e h)) ?_ (by have := hb.vocab _ hmem; omega)
    htr.server htr.map htr.nodes htr.tokens L hm
  · intro j l h hg
    rw [hL]
    unfold Box.get box at hg
    by_cases h9 : j = 9
    · subst h9
      rw [nu9, hb.promptValue, hL]
      rfl
    by_cases h10 : j = 10
    · subst h10
      rw [nu10, hb.rowValue, hL]
      rfl
    by_cases h11 : j = 11
    · subst h11
      rw [nu11, hb.offsetValue, hL]
      rfl
    by_cases h16 : j = 16
    · subst h16
      rw [nu16, hb.capValue, hL]
      rfl
    simp [Ne.symm h9, Ne.symm h10, Ne.symm h11, Ne.symm h16] at hg

  · intro tab hC
    have h := (hip.grow (Host.Mlx.Ffi.NGrow.refl _) hC).2
    rw [hlast] at h
    show HostInt32 _ _ (y.M.node 19265) _ _
    simpa using h

end Host.Route.Cert.Fin.X4L7
