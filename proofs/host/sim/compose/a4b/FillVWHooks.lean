import host.sim.compose.a4b.FillOne
import host.sim.compose.a4b.FillVWPost
import host.sim.compose.a4b.PLTVLink
import host.route.cert.Head.VW.Hsmp
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FillPost
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Ts.Sim.Compose.Post
open Host.Load.Run.Tpl Host.Route Host.Route.PrefGraph Host.Route.Cert Host.Route.Cert.Fin
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

/-! # VW's POST bookkeeping

The class's sampled cut holds the reference at its head certificate's carriers; the link carries them to the shared tail's
through the walk's node map. -/

kernel_rfl vwLinkCr : Row.R1.ps.map (fun p => (p.1.map PLTVW.R.data.nodeF, p.2.map PLTVW.R.data.nodeF)) =
  carriersOf (certAt Head.VW.headCert.cert)
kernel_rfl vwLinkTok : PLTVW.R.data.nodeF 17776 = certAt Head.VW.headCert.cert Tpl.Ordinary.tokenNode

/-- The handles' carriers at VW's sampled cut. -/
noncomputable def vwCr (_ : Nat) : List (Option Nat × Option Nat) := carriersOf (certAt Head.VW.headCert.cert)

/-- The sampled token's carrier at VW's sampled cut. -/
noncomputable def vwToks (_ _ : Nat) : Nat := certAt Head.VW.headCert.cert Tpl.Ordinary.tokenNode

/-- The final forward's nodes VW's sampled cut names. -/
noncomputable def vwKept (_ : Nat) : List (Nat × Nat) := keptOf (certAt Head.VW.headCert.cert)

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)

/-- VW's first bookkeeping: the final forward's end and the values the link reads. -/
def memVW0 (L : Nat) (x : SegInst FF) : Prop :=
  memFinE P KR NE net env π T tk vwKept (fun _ => 4010) L x ∧ VWVals π.length x.ν

/-- VW's sampled cut, at its own carriers. -/
def memVWS (L : Nat) (x : SegInst FF) : Prop :=
  (memPost P KR NE net env π 0 vwToks vwCr L x ∧ x.M.a 12504 = 12504 ∧ FromLoad T tk x) ∧ VWVals π.length x.ν

variable {P KR NE net env π T tk}

theorem memVW0_enter {L : Nat} {x y : SegInst FF} (h : NTrack x y) (hv : VWVals π.length y.ν)
    (hm : memFinE P KR NE net env π T tk vwKept (fun _ => 4010) L x) : memVW0 P KR NE net env π T tk L y :=
  ⟨⟨memFin_keep L x y h hm.1, h.emit.trans hm.2.1, hm.2.2.grow h.nodes⟩, hv⟩

theorem memVW0_keep {L : Nat} {x y : SegInst FF} (h : NTrackV x y) (hm : memVW0 P KR NE net env π T tk L x) :
    memVW0 P KR NE net env π T tk L y :=
  ⟨⟨memFin_keep L x y h.toNTrack hm.1.1, h.emit.trans hm.1.2.1, hm.1.2.2.grow h.nodes⟩, h.val ▸ hm.2⟩

end

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {T : Nat} {tk : Nat → Nat} {π : List Nat}

/-- **VW's hooks.** The class's cuts at `capC` and the input node `19057`; the shared tail's at `cap`. -/
noncomputable def hooksVW {cap nI capC : Nat} (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, Host.Mlx.SimGraph.Mach.RefTokens P KR NE KR.inPlace net env π tab)
    (h3 : 3 ≤ π.length) (hL : π.length ≤ 224) (hcapC : capC ≤ 4096 + 1593835520) (hcap : capC + 145989 ≤ cap)
    (hbound : cap < Sim.bound) (hT : 1 ≤ T)
    (htkR : ∀ tab j, j < T → ∃ hs, Host.Mlx.SimGraph.Mach.refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (tk (j + 1), hs))
    (htk1 : tk 1 < 2 ^ 31) :
    Hooks 15235 T tk π cap nI (classVW 15235 T tk π capC 19057 hcapC) where
  Mem0 := memVW0 P KR NE net env π T tk
  MemS := memVWS P KR NE net env π T tk
  MemP := memP P KR NE net env π T tk
  hMP _ _ _ _ h hm := memP_keep h hm
  hsmp L x y hy htr hm :=
    ⟨⟨Head.VW.hsmp P KR NE net env leaves typed hRT (by omega) hL vwCr rfl vwKept rfl (fun _ => 4010) rfl vwToks rfl
        (Nat.le_refl _) hy L (memFin_keep L x y htr.toNTrack hm.1.1), htr.emit.trans hm.1.2.1, hm.1.2.2.grow htr.nodes⟩,
      htr.val ▸ hm.2⟩
  hlink _ := hlinkVW hcap hbound h3 hL (fun _ hm => hm.2)
    (fun x y ht hC hn ha' hm => ⟨memPost_link (toksC := vwToks) (CrC := vwCr) (σ := PLTVW.R.data.nodeF) ht hC hn vwLinkTok vwLinkCr hm.1.1, ha'.trans hm.1.2.1,
      hm.1.2.2.grow (by rw [ht]; exact Host.Mlx.Ffi.NGrow.refl _)⟩)
  hpop L x y hx hy hle hn ha' hg hm :=
    ⟨PrefGraph.hpop hT htkR htk1 Row.rowToks rfl (Row.rowCr 0) L x y hx hy hle hn hg hm.1, ha'.trans hm.2.1, hm.2.2.grow hg⟩
  hfw0 L x y hy hle hn hg ht ha' hm :=
    ⟨Row.hfw0 leaves typed hRT (Nat.le_refl _) (by omega) hL L x y hy hle hn hg ht hm.1, ha'.trans hm.2.1, hm.2.2.grow hg⟩
  hfw1 L x y hy hle hn hg ht ha' hm :=
    ⟨Row.hfw1 leaves typed hRT (Nat.le_refl _) (by omega) hL L x y hy hle hn hg ht hm.1, ha'.trans hm.2.1, hm.2.2.grow hg⟩
  fixE _ _ _ h := h.2.1

end

end Host.Ts.Sim.Compose.FillPost
