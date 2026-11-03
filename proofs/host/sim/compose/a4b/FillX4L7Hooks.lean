import host.sim.compose.a4b.FillOne
import host.sim.compose.a4b.FillX4L7Post
import host.sim.compose.a4b.PLT4L7Link
import host.route.cert.Head.X4L7.Hsmp
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FillPost
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Ts.Sim.Compose.Post
open Host.Load.Run.Tpl Host.Route Host.Route.PrefGraph Host.Route.Cert Host.Route.Cert.Fin
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # x4 L7's POST bookkeeping

The class's sampled cut holds the reference at its head certificate's carriers; the link carries them to the shared tail's
through the walk's node map. -/

kernel_rfl x4L7LinkCr : Row.R1.ps.map (fun p => (p.1.map PLTW4L7.R.data.nodeF, p.2.map PLTW4L7.R.data.nodeF)) =
  carriersOf (certAt Head.X4L7.headCert.cert)
kernel_rfl x4L7LinkTok : PLTW4L7.R.data.nodeF 17776 = certAt Head.X4L7.headCert.cert Tpl.Ordinary.tokenNode

/-- The handles' carriers at x4 L7's sampled cut. -/
noncomputable def x4L7Cr (_ : Nat) : List (Option Nat × Option Nat) := carriersOf (certAt Head.X4L7.headCert.cert)

/-- The sampled token's carrier at x4 L7's sampled cut. -/
noncomputable def x4L7Toks (_ _ : Nat) : Nat := certAt Head.X4L7.headCert.cert Tpl.Ordinary.tokenNode

/-- The final forward's nodes x4 L7's sampled cut names. -/
noncomputable def x4L7Kept (_ : Nat) : List (Nat × Nat) := keptOf (certAt Head.X4L7.headCert.cert)

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)

/-- x4 L7's first bookkeeping: the final forward's end and the values the link reads. -/
def memX4L70 (L : Nat) (x : SegInst FF) : Prop :=
  memFinE P KR NE net env π T tk x4L7Kept (fun _ => 4010) L x ∧ PinVals 6 5 5 (π.length - 1) x.ν

/-- x4 L7's sampled cut, at its own carriers. -/
def memX4L7S (L : Nat) (x : SegInst FF) : Prop :=
  (memPost P KR NE net env π 0 x4L7Toks x4L7Cr L x ∧ x.M.a 12504 = 12504 ∧ FromLoad T tk x) ∧ PinVals 6 5 5 (π.length - 1) x.ν

variable {P KR NE net env π T tk}

theorem memX4L70_enter {L : Nat} {x y : SegInst FF} (h : NTrack x y) (hv : PinVals 6 5 5 (π.length - 1) y.ν)
    (hm : memFinE P KR NE net env π T tk x4L7Kept (fun _ => 4010) L x) : memX4L70 P KR NE net env π T tk L y :=
  ⟨⟨memFin_keep L x y h hm.1, h.emit.trans hm.2.1, hm.2.2.grow h.nodes⟩, hv⟩

theorem memX4L70_keep {L : Nat} {x y : SegInst FF} (h : NTrackV x y) (hm : memX4L70 P KR NE net env π T tk L x) :
    memX4L70 P KR NE net env π T tk L y :=
  ⟨⟨memFin_keep L x y h.toNTrack hm.1.1, h.emit.trans hm.1.2.1, hm.1.2.2.grow h.nodes⟩, h.val ▸ hm.2⟩

end

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {T : Nat} {tk : Nat → Nat} {π : List Nat}

/-- **x4 L7's hooks.** The class's cuts at `capC` and the input node `19265`; the shared tail's at `cap`. -/
noncomputable def hooksX4L7 {cap nI capC : Nat} (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, Host.Mlx.SimGraph.Mach.RefTokens P KR NE KR.inPlace net env π tab)
    (hL : π.length = 7) (hcapC : capC ≤ 4096 + 1593835520) (hcap : capC + 156211 ≤ cap)
    (hbound : cap < Sim.bound) (hT : 1 ≤ T)
    (htkR : ∀ tab j, j < T → ∃ hs, Host.Mlx.SimGraph.Mach.refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk1 : tk 1 < 2 ^ 31) :
    Hooks 15235 T tk π cap nI (classX4L7 15235 T tk π capC 19265 hcapC) where
  Mem0 := memX4L70 P KR NE net env π T tk
  MemS := memX4L7S P KR NE net env π T tk
  MemP := memP P KR NE net env π T tk
  hMP _ _ _ _ h hm := memP_keep h hm
  hsmp L x y hy htr hm :=
    ⟨⟨Head.X4L7.hsmp P KR NE net env leaves typed hRT hL x4L7Cr rfl x4L7Kept rfl (fun _ => 4010) rfl x4L7Toks rfl
        (Nat.le_refl _) hy L (memFin_keep L x y htr.toNTrack hm.1.1), htr.emit.trans hm.1.2.1, hm.1.2.2.grow htr.nodes⟩,
      htr.val ▸ hm.2⟩
  hlink _ := hlink4L7 hcap hbound hL (fun _ hm => hm.2)
    (fun x y ht hC hn ha' hm => ⟨memPost_link (toksC := x4L7Toks) (CrC := x4L7Cr) (σ := PLTW4L7.R.data.nodeF) ht hC hn x4L7LinkTok x4L7LinkCr hm.1.1, ha'.trans hm.1.2.1,
      hm.1.2.2.grow (by rw [ht]; exact Host.Mlx.Ffi.NGrow.refl _)⟩)
  hpop L x y hx hy hle hn ha' hg hm :=
    ⟨PrefGraph.hpop hT htkR htk1 Row.rowToks rfl (Row.rowCr 0) L x y hx hy hle hn hg hm.1, ha'.trans hm.2.1, hm.2.2.grow hg⟩
  hfw0 L x y hy hle hn hg ht ha' hm :=
    ⟨Row.hfw0 leaves typed hRT (Nat.le_refl _) (by omega) (by omega) L x y hy hle hn hg ht hm.1, ha'.trans hm.2.1, hm.2.2.grow hg⟩
  hfw1 L x y hy hle hn hg ht ha' hm :=
    ⟨Row.hfw1 leaves typed hRT (Nat.le_refl _) (by omega) (by omega) L x y hy hle hn hg ht hm.1, ha'.trans hm.2.1, hm.2.2.grow hg⟩
  fixE _ _ _ h := h.2.1

end

end Host.Ts.Sim.Compose.FillPost
