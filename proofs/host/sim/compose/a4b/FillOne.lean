import host.sim.compose.a4b.FillPaths
import host.sim.compose.a4b.PLTLink
import host.route.cert.One.CertH
import host.route.cert.One.Tail
import host.route.cert.Row.Hooks
import host.route.PostPop
import host.route.PostGoals
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FillPost
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Ts.Sim.Compose.Post
open Host.Load.Run.Tpl Host.Route Host.Route.PrefGraph Host.Route.Cert
open Host.Load Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # POST's bookkeeping

The route's references, with the emitted array's address beside them. The shared tail's part serves every class; the
one-token class's first bookkeeping also holds the value the link needs. -/

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat)

/-- The reference held `j` times, at the tail's carriers. -/
def memP (j L : Nat) (x : SegInst FF) : Prop :=
  memPost P KR NE net env π j Row.rowToks (Row.rowCr j) L x ∧ x.M.a 12504 = 12504

/-- The final forward's end, with the emitted array's address. -/
def memFinE (Kept : Nat → List (Nat × Nat)) (Kn : Nat → Nat) (L : Nat) (x : SegInst FF) : Prop :=
  memFin P KR NE net env π Kept Kn L x ∧ x.M.a 12504 = 12504

/-- `memFinE`, and the variable the one-token link moves. -/
def memOne0 (Kept : Nat → List (Nat × Nat)) (Kn : Nat → Nat) (L : Nat) (x : SegInst FF) : Prop :=
  memFinE P KR NE net env π Kept Kn L x ∧ x.ν 21 = F64.ofNat 4

/-- The one-token class's sampled cut. -/
def memOneS (L : Nat) (x : SegInst FF) : Prop :=
  memP P KR NE net env π 0 L x ∧ x.ν 21 = F64.ofNat 4

variable {P KR NE net env π}

theorem memP_keep {j L : Nat} {x y : SegInst FF} (h : NTrack x y) (hm : memP P KR NE net env π j L x) :
    memP P KR NE net env π j L y :=
  ⟨memPost_keep L x y h hm.1, h.emit.trans hm.2⟩

/-- `g3f_first`'s entry. -/
theorem memOne_enter {Kept : Nat → List (Nat × Nat)} {Kn : Nat → Nat} {L : Nat} {x y : SegInst FF} (h : NTrack x y)
    (h21 : y.ν 21 = F64.ofNat 4) (hm : memFinE P KR NE net env π Kept Kn L x) : memOne0 P KR NE net env π Kept Kn L y :=
  ⟨⟨memFin_keep L x y h hm.1, h.emit.trans hm.2⟩, h21⟩

theorem memOne_keep {Kept : Nat → List (Nat × Nat)} {Kn : Nat → Nat} {L : Nat} {x y : SegInst FF} (h : NTrackV x y)
    (hm : memOne0 P KR NE net env π Kept Kn L x) : memOne0 P KR NE net env π Kept Kn L y :=
  ⟨⟨memFin_keep L x y h.toNTrack hm.1.1, h.emit.trans hm.1.2⟩, h.val.trans hm.2⟩

end

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey}
  {NB T cap : Nat} {tk : Nat → Nat} {a : Nat}
  {P' : MlxPrefillContract C} {π : List Nat} {nI capC nIC : Nat} {P : ClassPre NB T tk π capC nIC}

/-- **The one-token prompt's hooks.** -/
noncomputable def hooksOne {P : MlxPrefillContract C} (ha : a < 248320) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, Host.Mlx.SimGraph.Mach.RefTokens P KR NE KR.inPlace net env [a] tab)
    (Kept : Nat → List (Nat × Nat)) (hKept : Kept 1 = One.oneKept) (Kn : Nat → Nat) (hKn : Kn 1 = 4010)
    (hNB : 15235 ≤ NB) (hbound : cap < Sim.bound) (hcap : cap ≤ 4096 + 1593835520) (hT : 1 ≤ T)
    (htkR : ∀ tab j, j < T → ∃ hs, Host.Mlx.SimGraph.Mach.refPrompt P KR NE KR.inPlace net env [a] tab ([a].length + j) = some (tk (j + 1), hs))
    (htk1 : tk 1 < 2 ^ 31) :
    Hooks NB T tk [a] cap 15235 (classOne NB T tk [a] cap 15235 hcap) where
  Mem0 := memOne0 P KR NE net env [a] Kept Kn
  MemS := memOneS P KR NE net env [a]
  MemP := memP P KR NE net env [a]
  hMP _ _ _ _ h hm := memP_keep h hm
  hsmp L x y hy htr hm :=
    ⟨⟨One.hsmp P KR NE net env a ha leaves typed hRT (Row.rowCr 0) One.rowCr_one Kept hKept Kn hKn Row.rowToks One.rowToks_one hNB hy L
        (memFin_keep L x y htr.toNTrack hm.1.1), htr.emit.trans hm.1.2⟩, htr.val.trans hm.2⟩
  hlink _ := hlinkOne hbound (fun _ hm => ⟨4, by decide, hm.2⟩)
    (fun x y ht hC hn ha' hm => ⟨memPost_same ht hC hn hm.1.1, ha'.trans hm.1.2⟩)
  hpop L x y hx hy hle hn ha' hg hm :=
    ⟨PrefGraph.hpop hT htkR htk1 Row.rowToks rfl (Row.rowCr 0) L x y hx hy hle hn hg hm.1, ha'.trans hm.2⟩
  hfw0 L x y hy hle hn hg ht ha' hm :=
    ⟨Row.hfw0 leaves typed hRT hNB (by simp) (by simp) L x y hy hle hn hg ht hm.1, ha'.trans hm.2⟩
  hfw1 L x y hy hle hn hg ht ha' hm :=
    ⟨Row.hfw1 leaves typed hRT hNB (by simp) (by simp) L x y hy hle hn hg ht hm.1, ha'.trans hm.2⟩
  fixE _ _ _ h := h.2

/-- The readback's pop on the short paths. -/
noncomputable def popsOne (H : Hooks NB T tk π cap nI P) (hMem : H.MemP = memP P' KR NE net env π) (hT : 1 ≤ T)
    (htkR : ∀ tab j, j < T → ∃ hs, Host.Mlx.SimGraph.Mach.refPrompt P' KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk1 : tk 1 < 2 ^ 31) (htk2 : tk 2 < 2 ^ 31) : PopHooks H where
  t1 L x y hx hy hle hn ha' hg hm := by
    rw [hMem] at hm ⊢
    exact ⟨hpopT1 hT htkR htk1 Row.rowToks rfl (Row.rowCr 0) L x y hx hy hle hn hg hm.1, ha'.trans hm.2⟩
  t1e L x y hx hy hle hn ha' hg hm := by
    rw [hMem] at hm ⊢
    exact ⟨hpopT1Eos hT htkR htk1 Row.rowToks rfl (Row.rowCr 0) L x y hx hy hle hn hg hm.1, ha'.trans hm.2⟩
  ta L x y hx hy hle hn ha' hg hm := by
    rw [hMem] at hm ⊢
    exact ⟨hpopTa hT htkR htk1 Row.rowToks rfl (Row.rowCr 0) L x y hx hy hle hn hg hm.1, ha'.trans hm.2⟩
  t2 h2 L x y hx hy hle hn ha' hg hm := by
    rw [hMem] at hm ⊢
    exact ⟨hpopT2 h2 htkR htk2 Row.rowToks rfl (Row.rowCr 1) L x y hx hy hle hn hg hm.1, ha'.trans hm.2⟩
  t2e h2 L x y hx hy hle hn ha' hg hm := by
    rw [hMem] at hm ⊢
    exact ⟨hpopT2Eos h2 htkR htk2 Row.rowToks rfl (Row.rowCr 1) L x y hx hy hle hn hg hm.1, ha'.trans hm.2⟩

end

end Host.Ts.Sim.Compose.FillPost
