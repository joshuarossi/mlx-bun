import host.sim.compose.PreCall
import host.sim.compose.SetupKeep
import host.sim.template.a4pre_d1_dispatch.Frames
import host.sim.template.PostOk
import host.sim.template.PostOk0
import host.sim.template.DimVals
import host.sim.template.HandVals
import host.sim.template.a4pre_d1_input.Property
import host.simgraph.family.FoldedData
import host.sim.CasesL
set_option Elab.async false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Mlx.FfiEval Host.Mlx.SimGraph

/-! # POST's cuts

POST has two stretches. Up to its shared cut each class has its own numbering, and the head compiles the sampler, which writes the trace
registry, so only the pre-final ghosts are framed, and the class's chunk, which the caller's frame holds until it returns (`head`). From the
shared tail on, the registry and the other kernels are ghosts too, and the tail's convolution variables hold the row's literal dimensions
(`tail`). -/

/-- A stretch's frames, what its book says of the variables, and the native counters' room above its templates. -/
structure Stage where
  J : Disp.JSP FF
  W : Nat → Option WFrame
  dims : (Nat → F64) → Prop
  /-- The trace ids, payloads and dimensions the hand-off reads, by the prompt's length. -/
  hand : Nat → (Nat → F64) → Prop
  H : Nat
  N : Nat

abbrev head (extra : List Nat) : Stage := ⟨PostOk.J0F extra, wideGPf, fun _ => True, fun _ _ => True, 4096, 4096⟩
abbrev tail : Stage :=
  ⟨PostOk.J, wideG, fun ν => ∀ v k, tailVal v = some k → ν v = F64.ofNat k,
    fun L ν => ∀ v k, handVal L v = some k → ν v = F64.ofNat k, 65536, 65536⟩

structure Book (P : Stage) (T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π γ : List Nat) (x : SegInst FF) : Prop where
  nonempty : 1 ≤ π.length
  vocab : ∀ k ∈ π, k < 248320
  lastRows : γ = π.drop (π.length - 1)
  rowsLength : γ.length = 1
  rowsVocab : ∀ k ∈ γ, k < 248320
  valuation : VBOkF loopVB x.ν
  promptValue : x.ν 9 = F64.ofNat π.length
  rowValue : x.ν 10 = F64.ofNat 1
  offsetValue : x.ν 11 = F64.ofNat π.length
  capValue : x.ν 16 = F64.ofNat (capL π.length)
  context : Disp.KpJ P.J cap x.K
  /-- The target is at least this far above the template: the hand-off's restart needs the room. -/
  offsetLow : 13 ≤ x.K.D
  prompt : x.K.fr 2665 = some ([], π.map natV)
  reserved : ∀ j, j < 9 → x.ν j = machVal T tk j
  emittedAnchor : x.M.a 2590 = 2590
  input : x.M.node nI < (mlxOf x.t.ffi).nnext ∧
    HostInt32 (concrete x.C.val) (mlxOf x.t.ffi) (x.M.node nI) (γ.map Int.ofNat) [1, 1]
  dims : P.dims x.ν
  hand : P.hand π.length x.ν

def Anchors (x : SegInst FF) : Prop := x.M.a 2586 = 2586 ∧ x.M.a 2589 = 2589

/-- The GPU specialization, with the original prompt as an index for graph refinements. -/
noncomputable def indexedCutAt (P : Stage) (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat)
    (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ γ,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      P.W [] x.M x.ν x.K s S x.t x.C ∧ Book P T tk cap nI π γ x
  B := fun x => AneFresh x.t ∧ Anchors x ∧ NativeAt P.H P.N s x.t

/-- From POST's shared cut on. -/
noncomputable abbrev indexedCut := indexedCutAt tail
/-- Up to POST's shared cut. -/
noncomputable abbrev indexedCut0 (extra : List Nat) := indexedCutAt (head extra)

theorem Book.grow {P : Stage} {T cap nI n : Nat} {tk : Nat → Nat} {π γ : List Nat}
    {M M' : Map} {ν : Nat → F64} {K : Ctx} {t t' : St FF.S} {C C' : CSrv}
    (h : Book P T tk cap nI π γ ⟨M, ν, K, t, C⟩) (he : Ext M M' n)
    (hg : Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi)) (hc : CSrv.Le C C') :
    Book P T tk cap nI π γ ⟨M', ν, K, t', C'⟩ := by
  refine { h with emittedAnchor := (congrFun he.a 2590).trans h.emittedAnchor, input := ?_ }
  have hi : SetupD1Input.InputAt γ (M.node nI) t C := h.input
  change SetupD1Input.InputAt γ (M'.node nI) t' C'
  rw [he.node]
  exact hi.grow hg hc

end Host.Ts.Sim.Compose.Post
