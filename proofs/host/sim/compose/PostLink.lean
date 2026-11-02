import host.sim.compose.PostChain
import host.sim.compose.PfLink
import host.sim.compose.PadTab
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.Post
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Route
open Host.Load.Run.Tpl

/-! # A class's sampled cut at the shared tail

The class's table is padded with the template's images. The walked copy (`Pf.PfFacts`) carries the relation, its frames growing from the
pre-final ghosts to the tail's; the book crosses through the map's anchors and the walk's values. The target and server are kept, and the
bookkeeping changes by `hook`, reading the class's carriers through the walk's node map. -/

theorem kwTail : ∀ b ∈ 4910 :: ghostPf, wideG b ≠ none := by
  have h : (4910 :: ghostPf).all (fun b => (wideList.map Prod.fst).contains b) = true := by decide
  intro b hb
  exact Pf.lookupW_ne (List.contains_iff_mem.mp (List.all_eq_true.mp h b hb))

theorem wideAgree : ∀ b ∈ 4910 :: ghostPf, wideGPf b = wideG b := by
  intro b hb
  simp only [ghostPf, List.mem_cons, List.not_mem_nil, or_false] at hb
  rcases hb with rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

theorem toTail {NB T cap capT nI nIT : Nat} {tk : Nat → Nat} {π extra : List Nat} {s0 s1 : St FF.S} {S0 S1 : SSrv}
    {D : RData} {inv : PTrie Nat} {θ : Nat → SymE} {P0 : LoadP} {nJ : Nat} {Mem Mem' : SegInst FF → Prop}
    (F : Pf.PfFacts s0 s1 S0.tab (S1.tab ++ S0.tab.map (·.subst θ)) D inv θ P0 nJ [] extra wideG)
    (hxw : ∀ b ∈ extra, wideG b = none)
    (hNB : NB ≤ P0.NL)
    (hH : (mlxOf s1.ffi).next + 4096 ≤ (mlxOf s0.ffi).next + 65536)
    (hN : (mlxOf s1.ffi).nnext + 4096 ≤ (mlxOf s0.ffi).nnext + 65536)
    (hgrow : s0.next ≤ s1.next) (hcap : cap + (s1.next - s0.next) ≤ capT) (hbound : capT < Sim.bound)
    (h9 : θ 9 = .var 9) (h10 : θ 10 = .var 10) (h11 : θ 11 = .var 11) (h16 : θ 16 = .var 16)
    (hres : ∀ j, j < 9 → θ j = .var j)
    (hval : ∀ x : SegInst FF, Mem x → VBOkF loopVB x.ν → VBOkF loopVB (Shift.valuation θ x.ν))
    (hdims : ∀ x : SegInst FF, Mem x → tail.dims (Shift.valuation θ x.ν))
    (hhand : ∀ x : SegInst FF, Mem x → tail.hand π.length (Shift.valuation θ x.ν))
    (hA : D.a 2590 = 2590) (hB : D.a 2586 = 2586) (hC : D.a 2589 = 2589) (hE : D.a 12504 = 12504)
    (hI : D.nodeF nIT = nI)
    (hook : ∀ x y : SegInst FF, y.t = x.t → y.C = x.C → (∀ c, y.M.node c = x.M.node (D.nodeF c)) →
      y.M.a 12504 = x.M.a 12504 → Mem x → Mem' y) :
    CutConv (withMem Mem (indexedCut0 extra NB T tk cap nI π s1 S1)) (withMem Mem' (indexedCut NB T tk capT nIT π s0 S0)) := by
  rintro x ⟨γ, hr, hb⟩ ⟨⟨hfresh, hids, hnat⟩, hm⟩
  have hfr : ∀ a, x.K.fr a ≠ none ↔ a ∈ 2665 :: ([] ++ ((4910 :: ghostPf) ++ extra)) := hb.context.1.2.2
  have hwk : ∀ a w, wideG a = some w → x.K.fr a = none ∨ wideGPf a = some w := by
    intro a w hw
    by_cases hm : a ∈ 4910 :: ghostPf
    · exact .inr ((wideAgree a hm).trans hw)
    · refine .inl ?_
      cases e : x.K.fr a with
      | none => rfl
      | some p =>
        have h1 := (hfr a).mp (by rw [e]; exact Option.some_ne_none _)
        rcases List.mem_cons.mp h1 with h2 | h2
        · subst h2
          cases hw
        · have h2' : a ∈ (4910 :: ghostPf) ++ extra := h2
          rcases List.mem_append.mp h2' with h3 | h3
          · exact absurd h3 hm
          · rw [hxw a h3] at hw
            cases hw
  have hlo : x.K.lo = 18151 := hb.context.1.1
  have hhi : x.K.hi = 131072 := hb.context.1.2.1
  have hP := hb.prompt
  have hDK : x.K.D ≤ cap := hb.context.2
  have hD : x.K.D + (s1.next - s0.next) < Sim.bound := by omega
  have hroomN := Pf.linkRoomAt (s0 := s0) (s1 := s1) hnat (show 4096 ≤ 2 ^ 40 by decide) (show 4096 ≤ 2 ^ 40 by decide) F.hi1 F.nhi1
  let laws := fullRXD_laws { setupP with rest := machReads T tk } NB
  obtain ⟨M1, hext, hp⟩ := relB_pad laws.stable laws.mono (S0.tab.map (·.subst θ)) hr.ofJ
  have hrP : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) wideGPf [] M1 x.ν x.K s1
      ⟨S1.tab ++ S0.tab.map (·.subst θ), []⟩ x.t x.C := hp.toJ (hr.ffi.2.ext hext)
  have hrel := Pf.pfRel F (π := π) (kw := 4910 :: ghostPf) hrP hfr kwTail hwk hlo hhi hP (fun _ h => nomatch h) hroomN hNB hD (by omega)
  have hoff : x.t.next = s1.next + x.K.D := hr.offset
  let y : SegInst FF := ⟨((M1.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf x.t.ffi).next).withJs,
    Shift.valuation θ x.ν,
    ⟨frW M1 x.K (Pf.keepOf []) wideG s1, s0.trace, x.t.trace, x.t.next - s0.next, x.K.lo, x.K.hi⟩, x.t, x.C⟩
  have hnode : ∀ c, y.M.node c = x.M.node (D.nodeF c) := fun c => congrFun hext.node (D.nodeF c)
  have hvar : ∀ {j : Nat}, θ j = .var j → y.ν j = x.ν j := by
    intro j h
    change (θ j).eval x.ν = _
    rw [h]
    rfl
  refine ⟨y, rfl, rfl, ⟨γ, hrel, ?_⟩, ⟨hfresh, ?_, ?_⟩, hook x y rfl rfl hnode ?_ hm⟩
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
        input := ?_
        dims := hdims x hm
        hand := hhand x hm }
    · exact Pf.framed_after F M1 x.K (L := wideList) (fun _ => rfl) hP (fun _ h => nomatch h) a
    · change x.t.next - s0.next ≤ capT
      omega
    · have h13 : 13 ≤ x.K.D := hb.offsetLow
      change 13 ≤ x.t.next - s0.next
      omega
    · exact (Pf.frames_prompt F M1 x.K).trans hP
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
  · have ht : (mlxOf x.t.ffi).next ≤ (mlxOf s1.ffi).next + 4096 := hnat.1
    have hn : (mlxOf x.t.ffi).nnext ≤ (mlxOf s1.ffi).nnext + 4096 := hnat.2
    have hH' : (mlxOf s1.ffi).next + 4096 ≤ (mlxOf s0.ffi).next + 65536 := hH
    have hN' : (mlxOf s1.ffi).nnext + 4096 ≤ (mlxOf s0.ffi).nnext + 65536 := hN
    exact ⟨Nat.le_trans ht hH', Nat.le_trans hn hN'⟩
  · change M1.a (D.a 12504) = _
    rw [hE, hext.a]

end Host.Ts.Sim.Compose.Post
