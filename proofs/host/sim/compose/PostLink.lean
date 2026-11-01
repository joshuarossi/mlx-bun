import host.sim.compose.PostChain
import host.sim.compose.PfLink
import host.sim.compose.PadTab
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route

/-! # A class's sampled cut at the shared tail

The class's table is padded with the template's images. The walked copy (`Pf.PfFacts`) carries the relation; the book crosses through
the map's anchors and the walk's values. The target and server are kept, and the bookkeeping changes by `hook`, reading the class's
carriers through the walk's node map. -/

theorem toTail {NB T cap capT nI nIT : Nat} {tk : Nat → Nat} {π : List Nat} {s0 s1 : St FF.S} {S0 S1 : SSrv}
    {D : RData} {inv : PTrie Nat} {θ : Nat → SymE} {P0 : LoadP} {nJ : Nat} {Mem Mem' : SegInst FF → Prop}
    (F : Pf.PfFacts s0 s1 S0.tab (S1.tab ++ S0.tab.map (·.subst θ)) D inv θ P0 nJ [])
    (hnodes : (mlxOf s1.ffi).nnext ≤ P0.NL)
    (sameH : (mlxOf s1.ffi).next = (mlxOf s0.ffi).next) (sameN : (mlxOf s1.ffi).nnext = (mlxOf s0.ffi).nnext)
    (hcap : cap + (s1.next - s0.next) ≤ capT) (hbound : capT < Sim.bound)
    (h9 : θ 9 = .var 9) (h10 : θ 10 = .var 10) (h11 : θ 11 = .var 11) (h16 : θ 16 = .var 16)
    (hres : ∀ j, j < 9 → θ j = .var j)
    (hval : ∀ x : SegInst FF, Mem x → VBOkF loopVB x.ν → VBOkF loopVB (Shift.valuation θ x.ν))
    (hA : D.a 2590 = 2590) (hB : D.a 2586 = 2586) (hC : D.a 2589 = 2589) (hE : D.a 12504 = 12504)
    (hI : D.nodeF nIT = nI)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → (∀ c, y.M.node c = x.M.node (D.nodeF c)) →
      y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut NB T tk cap nI π s1 S1)) (withMem Mem' (indexedCut NB T tk capT nIT π s0 S0)) := by
  rintro x ⟨γ, hr, hb⟩ ⟨⟨hfresh, hids⟩, hm⟩
  have hfr : ∀ a, x.K.fr a ≠ none ↔ a ∈ 2665 :: ([] : List Nat) := hb.context.1.2.2
  have hlo : x.K.lo = 18151 := hb.context.1.1
  have hhi : x.K.hi = 131072 := hb.context.1.2.1
  have hP := hb.prompt
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise (mlxOf s1.ffi).nnext).NL ≤ P0.NL := by
    change (mlxOf s1.ffi).nnext ≤ P0.NL
    exact hnodes
  have hNB : NB ≤ P0.NL := Nat.le_trans top.1.load.mlx.nbl hNL
  have hDK : x.K.D ≤ cap := hb.context.2
  have hD : x.K.D + (s1.next - s0.next) < Sim.bound := by omega
  let laws := fullRXD_laws { setupP with rest := machReads T tk } NB
  obtain ⟨M1, hext, hp⟩ := relB_pad laws.stable laws.mono (S0.tab.map (·.subst θ)) hr.ofJ
  have hrP : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideP [] M1 x.ν x.K s1
      ⟨S1.tab ++ S0.tab.map (·.subst θ), []⟩ x.t x.C := hp.toJ (hr.ffi.2.ext hext)
  have hrel := Pf.pfRel F (π := π) hrP hfr hlo hhi hP (Pf.linkRoomSame hr sameH sameN) hNB hD
  have hoff : x.t.next = s1.next + x.K.D := hr.offset
  have hgrow : s0.next ≤ s1.next := F.grows
  let y : SegInst FF := ⟨((M1.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf x.t.ffi).next).withJs,
    Shift.valuation θ x.ν,
    ⟨dropNext M1 x.K Pf.keepP noFrames s1, s0.trace, x.t.trace, x.t.next - s0.next, x.K.lo, x.K.hi⟩, x.t, x.C⟩
  have hnode : ∀ c, y.M.node c = x.M.node (D.nodeF c) := fun c => congrFun hext.node (D.nodeF c)
  have hfrY : ∀ a, y.K.fr a = if a = 2665 then x.K.fr 2665 else none := Pf.drop_prompt F M1 x.K
  have hvar : ∀ {j : Nat}, θ j = .var j → y.ν j = x.ν j := by
    intro j h
    change (θ j).eval x.ν = _
    rw [h]
    rfl
  refine ⟨y, rfl, rfl, ⟨γ, hrel, ?_⟩, ⟨hfresh, ?_⟩, hook x y rfl rfl hnode ?_ hm⟩
  · refine
      { nonempty := hb.nonempty
        vocab := hb.vocab
        lastRows := hb.lastRows
        rowsLength := hb.rowsLength
        rowsVocab := hb.rowsVocab
        valuation := hval x hm hb.valuation
        promptValue := (hvar h9).trans hb.promptValue
        rowValue := (hvar h10).trans hb.rowValue
        offsetValue := (hvar h11).trans hb.offsetValue
        capValue := (hvar h16).trans hb.capValue
        context := ⟨⟨hlo, hhi, fun a => ?_⟩, ?_⟩
        offsetLow := ?_
        prompt := ?_
        reserved := fun j hj => (hvar (hres j hj)).trans (hb.reserved j hj)
        emittedAnchor := ?_
        input := ?_ }
    · rw [hfrY a]
      by_cases ha : a = 2665
      · subst ha
        simp only [if_true, List.mem_cons, List.not_mem_nil, or_false, iff_true]
        rw [hP]
        exact Option.some_ne_none _
      · rw [if_neg ha]
        simp only [ne_eq, not_true_eq_false, List.mem_cons, List.not_mem_nil, or_false, false_iff]
        exact ha
    · change x.t.next - s0.next ≤ capT
      omega
    · have h13 : 13 ≤ x.K.D := hb.offsetLow
      change 13 ≤ x.t.next - s0.next
      omega
    · change y.K.fr 2665 = _
      rw [hfrY 2665, if_pos rfl]
      exact hP
    · change M1.a (D.a 2590) = 2590
      rw [hA, hext.a]
      exact hb.emittedAnchor
    · have e : y.M.node nIT = x.M.node nI := by
        rw [hnode, hI]
      have hi : SetupD1Input.InputAt γ (x.M.node nI) x.t x.C := hb.input
      change SetupD1Input.InputAt γ (y.M.node nIT) x.t x.C
      rw [e]
      exact hi
  · change M1.a (D.a 2586) = 2586 ∧ M1.a (D.a 2589) = 2589
    rw [hB, hC, hext.a]
    exact hids
  · change M1.a (D.a 12504) = _
    rw [hE, hext.a]

end Host.Ts.Sim.Compose.Post
