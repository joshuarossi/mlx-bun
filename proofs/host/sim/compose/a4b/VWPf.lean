import host.sim.compose.a4b.VWBodyCut
import host.sim.compose.PfLink
import host.sim.compose.PadTab
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill
open Host.Ts.Sim.Template Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk Host.Ts.Sim.Compose.Pf

/-- **A tail's end at the pre-final cut.** The tail's table is padded with the template's images and the walked copy (`F`) carries the
relation. The chunk's frames go, the pre-final ghosts' come, and the template's two new variables are the offset and the capacity, read
off the tail's table at the row (`h11`, `h16`). The template is at or below every class's end, so the target stays above it. The node
map is untouched, so the retained property crosses. -/
theorem toPf {NB T : Nat} {tk : Nat → Nat} {π : List Nat} {i : Cls.Inst} {Θ : List Nat × List SymE} {O : BodyOff}
    {m : List (Nat × Q)} {s0 s1 : St FF.S} {S0 S1 : SSrv} {D : RData} {inv : PTrie Nat} {θ : Nat → SymE}
    {P0 : LoadP} {nJ cap : Nat} {Tr : SegInst FF → Prop}
    (F : PfFacts s0 s1 S0.tab (S1.tab ++ S0.tab.map (·.subst θ)) D inv θ P0 nJ [VWFrames.chunk, VWFrames.buffer, VWFrames.view] wideGPf)
    (hT : ∀ x y, NTrack x y → Tr x → Tr y)
    (hL : i.L ≤ 2048)
    (hnodes : (mlxOf s1.ffi).nnext ≤ P0.NL) (hNN : D.nn0 = D.nn1) (hNK : PTrie.keys D.node = [])
    (hgrow : s0.next ≤ s1.next) (sameH : (mlxOf s1.ffi).next ≤ (mlxOf s0.ffi).next)
    (sameN : (mlxOf s1.ffi).nnext ≤ (mlxOf s0.ffi).nnext)
    (hθ : ∀ j, j ≠ 11 → j ≠ 14 → j ≠ 16 → j ≠ 30 → j ≠ 31 → θ j = .var j) (hθ14 : θ 14 = .var 17)
    {c30 c31 : Nat} (h30 : ∀ ν : Nat → F64, (θ 30).eval ν = F64.ofNat c30)
    (h31 : ∀ ν : Nat → F64, (θ 31).eval ν = F64.ofNat c31) (hc30 : c30 ≤ 2 ^ 20) (hc31 : c31 ≤ 2 ^ 20)
    (h9 : ∀ ν, MapOk ν i m → ν 9 = F64.ofNat i.L)
    (h10 : ∀ ν, MapOk ν i m → ν 10 = F64.ofNat (i.L - 1))
    (h11 : ∀ ν, MapOk ν i m → (θ 11).eval ν = F64.ofNat (i.L - 1))
    (h16 : ∀ ν, MapOk ν i m → (θ 16).eval ν = F64.ofNat (capL (i.L - 1)))
    (hA : D.a 2590 = 2590) (hB : D.a 2586 = 2586) (hC : D.a 2589 = 2589) (hE : D.a 12504 = 12504)
    (hcap : O.D + (s1.next - s0.next) ≤ cap) (hbound : cap < Sim.bound) :
    CutConv (withMem Tr (bodyCore NB T tk π i Θ O m s1 S1)) (withMem Tr (Pf.cut NB T tk π cap O.H O.N s0 S0)) := by
  rintro x ⟨K0, hr, hb, hnat, hip, hins, hmap, hdf⟩ ⟨⟨hfresh, hids⟩, htr⟩
  have hlen : π.length = i.L := hb.length
  have hfr : ∀ a, x.K.fr a ≠ none ↔ a ∈ 2665 :: ([] ++ [VWFrames.chunk, VWFrames.buffer, VWFrames.view]) :=
    hb.context.1.2.2
  have hlo : x.K.lo = 18151 := hb.context.1.1
  have hhi : x.K.hi = 131072 := hb.context.1.2.1
  have hP := hb.prompt
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise (mlxOf s1.ffi).nnext).NL ≤ P0.NL := by
    change (mlxOf s1.ffi).nnext ≤ P0.NL
    exact hnodes
  have hNB : NB ≤ P0.NL := Nat.le_trans top.1.load.mlx.nbl hNL
  have hDK : x.K.D ≤ O.D := hb.offset
  have hD : x.K.D + (s1.next - s0.next) < Sim.bound := by omega
  let laws := fullRXD_laws { setupP with rest := machReads T tk } NB
  obtain ⟨M1, hext, hp⟩ := relB_pad laws.stable laws.mono (S0.tab.map (·.subst θ)) hr.ofJ
  have hrP : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) _ [] M1 x.ν x.K s1
      ⟨S1.tab ++ S0.tab.map (·.subst θ), []⟩ x.t x.C := hp.toJ (hr.ffi.2.ext hext)
  have hrel := pfRel F (π := π) (kw := []) hrP hfr (fun _ h => nomatch h)
    (newFrames (L := wideListPf) (fun _ => rfl) hfr (by decide)) hlo hhi hP (linkRoomLe hr sameH sameN) hNB hD
    (by omega)
  have hoff : x.t.next = s1.next + x.K.D := hr.offset
  let y : SegInst FF := ⟨((M1.after D.map).rebig (mlxOf s0.ffi).next setupP.E (mlxOf x.t.ffi).next).withJs,
    Shift.valuation θ x.ν,
    ⟨frW M1 x.K keepP wideGPf s1, s0.trace, x.t.trace, x.t.next - s0.next, x.K.lo, x.K.hi⟩, x.t, x.C⟩
  have hnode : y.M.node = x.M.node := funext fun k => (congrFun hext.node (D.nodeF k)).trans (congrArg x.M.node (nodeF_id hNN hNK k))
  have hval : ∀ j, j ≠ 11 → j ≠ 14 → j ≠ 16 → j ≠ 30 → j ≠ 31 → y.ν j = x.ν j := by
    intro j h1 h3 h2 h4 h5
    change (θ j).eval x.ν = _
    rw [hθ j h1 h3 h2 h4 h5]
    rfl
  have hval14 : y.ν 14 = x.ν 17 := by
    change (θ 14).eval x.ν = _
    rw [hθ14]
    rfl
  refine ⟨y, rfl, rfl, ⟨hrel, ?_⟩, ⟨hfresh, ?_, ?_⟩, hT x y (NTrack.conv rfl rfl hnode (by change M1.a (D.a 12504) = _; rw [hE, hext.a])) htr⟩
  · refine
      { vocab := hb.vocab
        valuation := ?_
        promptValue := by rw [hlen]; exact (hval 9 (by decide) (by decide) (by decide) (by decide) (by decide)).trans (h9 x.ν hmap)
        rowValue := by rw [hlen]; exact (hval 10 (by decide) (by decide) (by decide) (by decide) (by decide)).trans (h10 x.ν hmap)
        offsetValue := by rw [hlen]; exact h11 x.ν hmap
        capValue := by rw [hlen]; exact h16 x.ν hmap
        context := ⟨⟨hlo, hhi, fun a => framed_after F M1 x.K (L := wideListPf) (fun _ => rfl) hP a⟩, ?_⟩
        prompt := ?_
        inputs := ⟨?_, ?_⟩ }
    · intro j
      change ∃ k ≤ 2 ^ 20, y.ν j = F64.ofNat k
      by_cases h1 : j = 11
      · subst h1
        exact ⟨i.L - 1, by omega, h11 x.ν hmap⟩
      · by_cases h3 : j = 14
        · subst h3
          rw [hval14]
          exact hb.valuation 17
        · by_cases h2 : j = 16
          · subst h2
            refine ⟨capL (i.L - 1), ?_, h16 x.ν hmap⟩
            unfold capL
            omega
          · by_cases h4 : j = 30
            · subst h4
              exact ⟨c30, hc30, h30 x.ν⟩
            · by_cases h5 : j = 31
              · subst h5
                exact ⟨c31, hc31, h31 x.ν⟩
              · rw [hval j h1 h3 h2 h4 h5]
                exact hb.valuation j
    · change x.t.next - s0.next ≤ cap
      omega
    · have h := frames_after F M1 x.K 2665
      rw [if_pos rfl] at h
      exact h.trans hP
    · intro j hj
      rw [hval j (by omega) (by omega) (by omega) (by omega) (by omega)]
      exact hins.1 j hj
    · change M1.a (D.a 2590) = 2590
      rw [hA, hext.a]
      exact hins.2
  · change M1.a (D.a 2586) = 2586 ∧ M1.a (D.a 2589) = 2589
    rw [hB, hC, hext.a]
    exact hids
  · exact ⟨Nat.le_trans hnat.1 (Nat.add_le_add_right sameH _), Nat.le_trans hnat.2 (Nat.add_le_add_right sameN _)⟩

end Host.Ts.Sim.Compose.VWFirst
