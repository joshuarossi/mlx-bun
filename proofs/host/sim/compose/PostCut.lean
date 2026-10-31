import host.sim.compose.PreCall
import host.sim.template.a4pre_d1_dispatch.Frames
import host.simgraph.family.FoldedData
import host.sim.CasesL
set_option Elab.async false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl Host.Mlx.FfiEval Host.Mlx.SimGraph

def bytes (γ : List Nat) : List Byte := cellBytes .i32 ((γ.map F64.ofNat).map Disp.i32Cell)

structure Book (T : Nat) (tk : Nat → Nat) (cap : Nat) (π γ : List Nat) (x : SegInst FF) : Prop where
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
  context : Disp.KpJ (D1Frames.typedJ (bytes γ)) cap x.K
  prompt : x.K.fr 2665 = some ([], π.map natV)
  chunk : x.K.fr D1Frames.chunk = some ([], γ.map natV)
  reserved : ∀ j, j < 9 → x.ν j = machVal T tk j
  emittedAnchor : x.M.a 2590 = 2590
  input : x.M.node 15235 < (mlxOf x.t.ffi).nnext ∧
    HostInt32 (concrete x.C.val) (mlxOf x.t.ffi) (x.M.node 15235) (γ.map Int.ofNat) [1, 1]

def Anchors (x : SegInst FF) : Prop := x.M.a 2586 = 2586 ∧ x.M.a 2589 = 2589

/-- The GPU specialization, with the original prompt as an index for graph refinements. -/
noncomputable def indexedCut (NB T : Nat) (tk : Nat → Nat) (cap : Nat) (π : List Nat)
    (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ γ,
    RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB))
      (D1Frames.typedW (bytes γ)) [] x.M x.ν x.K s S x.t x.C ∧ Book T tk cap π γ x
  B := fun x => AneFresh x.t ∧ Anchors x

noncomputable def cut (NB T : Nat) (tk : Nat → Nat) (cap L : Nat)
    (s : St FF.S) (S : SSrv) : ICut FF where
  s0 := s
  tab0 := S.tab
  R := fun x s S => ∃ π, π.length = L ∧ (indexedCut NB T tk cap π s S).R x s S
  B := fun x => AneFresh x.t ∧ Anchors x

theorem indexed_to_cut {NB T cap L : Nat} {tk : Nat → Nat} {π : List Nat}
    {s : St FF.S} {S : SSrv} (hπ : π.length = L) :
    CutConv (indexedCut NB T tk cap π s S) (cut NB T tk cap L s S) := by
  intro x hx hb
  exact ⟨x, rfl, rfl, ⟨π, hπ, hx⟩, hb⟩

theorem Book.emit_unframed {T cap : Nat} {tk : Nat → Nat} {π γ : List Nat} {x : SegInst FF}
    (h : Book T tk cap π γ x) : x.K.fr 2590 = none := by
  by_contra hn
  exact (by decide : 2590 ∉ [2665, D1Frames.chunk, D1Frames.buffer, D1Frames.view]) ((h.context.1.2.2 2590).mp hn)

/-- Retain the caller's memory invariant, including active-NE memory ghosts. -/
noncomputable def indexedCutMem (Mem : SegInst FF → Prop) (NB T : Nat) (tk : Nat → Nat)
    (cap : Nat) (π : List Nat) (s : St FF.S) (S : SSrv) : ICut FF :=
  { indexedCut NB T tk cap π s S with B := fun x => Mem x ∧ Anchors x }

noncomputable def cutMem (Mem : SegInst FF → Prop) (NB T : Nat) (tk : Nat → Nat)
    (cap L : Nat) (s : St FF.S) (S : SSrv) : ICut FF :=
  { cut NB T tk cap L s S with B := fun x => Mem x ∧ Anchors x }

theorem indexed_to_cutMem {Mem : SegInst FF → Prop} {NB T cap L : Nat} {tk : Nat → Nat}
    {π : List Nat} {s : St FF.S} {S : SSrv} (hπ : π.length = L) :
    CutConv (indexedCutMem Mem NB T tk cap π s S) (cutMem Mem NB T tk cap L s S) := by
  intro x hx hb
  exact ⟨x, rfl, rfl, ⟨π, hπ, hx⟩, hb⟩

theorem indexedCutMem_gpu (NB T : Nat) (tk : Nat → Nat) (cap : Nat) (π : List Nat)
    (s : St FF.S) (S : SSrv) :
    indexedCutMem (fun x => AneFresh x.t) NB T tk cap π s S = indexedCut NB T tk cap π s S := rfl

end Host.Ts.Sim.Compose.Post
