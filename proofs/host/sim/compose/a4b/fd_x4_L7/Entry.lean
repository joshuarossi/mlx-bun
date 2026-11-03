import host.sim.compose.a4b.fd_x4_L7.Forward
import host.sim.compose.a4b.PL4L7
import host.sim.compose.a4b.PinVals
import host.sim.compose.PostCut
import host.sim.compose.PadTab
import host.sim.compose.TailVals
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Ts.Sim.Compose.FDX4L7
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

/-! # The final forward's return at x4_L7's POST entry

The walked copy (`PL4L7.facts`) at the padded table: the chunk kept, the buffer and view dropped, the pre-final ghosts and the memo
the wide frames. The row count is a literal; the offset is the forward's plus one. -/

kernel_rfl θKeys : (PLW4L7.R.theta ++ PL4L7.thetaX).map Prod.fst = [11, 14, 21, 22, 24, 28, 10]
kernel_rfl θ10 : PL4L7.θ 10 = .lit (F64.ofNat 1)
kernel_rfl θ11 : PL4L7.θ 11 = .bin .add (.var 11) (.lit (F64.ofNat 1))
kernel_rfl θ14 : PL4L7.θ 14 = .var 17
kernel_rfl θ21 : PL4L7.θ 21 = .lit (F64.ofNat 6)
kernel_rfl θ22 : PL4L7.θ 22 = .lit (F64.ofNat 5)
kernel_rfl θ24 : PL4L7.θ 24 = .lit (F64.ofNat 5)
kernel_rfl θ28 : PL4L7.θ 28 = .var 11
kernel_rfl anchorA : PLW4L7.R.data.a 2590 = 2590
kernel_rfl anchorB : PLW4L7.R.data.a 2586 = 2586
kernel_rfl anchorC : PLW4L7.R.data.a 2589 = 2589
kernel_rfl anchorE : PLW4L7.R.data.a 12504 = 12504
kernel_rfl inputNode : PLW4L7.R.data.nodeF 19265 = 19265
kernel_rfl sameNext : PRE_fd_x4_L7_r0_body.s451.next = PRE_plx4_L7_entry.s0.next
kernel_rfl sameHandles : (mlxOf PRE_fd_x4_L7_r0_body.s451.ffi).next = (mlxOf PRE_plx4_L7_entry.s0.ffi).next
kernel_rfl sameNodes : (mlxOf PRE_fd_x4_L7_r0_body.s451.ffi).nnext = (mlxOf PRE_plx4_L7_entry.s0.ffi).nnext
kernel_rfl walkNN : PLW4L7.R.data.nn0 = PLW4L7.R.data.nn1
kernel_rfl walkNK : PTrie.keys PLW4L7.R.data.node = []
kernel_rfl nodesBelow : Nat.ble (mlxOf PRE_fd_x4_L7_r0_body.s451.ffi).nnext PL4L7.P0.NL = true

theorem θ_off {j : Nat} (hj : j ∉ [11, 14, 21, 22, 24, 28, 10]) : PL4L7.θ j = .var j :=
  Pf.thetaOf_off (by rw [θKeys]; exact hj)

/-- The wide frames are the typed frames' off the buffer and the view. -/
theorem wide_typed (bs : List Byte) : ∀ a w, wideGPf a = some w → fr.typedW bs a = some w := by
  intro a w hw
  have hm : (a, w) ∈ wideListPf := Pf.lookupW_mem hw
  simp only [wideListPf, wideListOf, ghostPf, List.map_cons, List.map_nil, List.mem_cons, List.not_mem_nil, or_false,
    Prod.mk.injEq] at hm
  rcases hm with ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ | ⟨rfl, -⟩ <;> exact hw

theorem kwHead : ∀ b ∈ 4910 :: ghostPf, wideGPf b ≠ none := by
  have h : (4910 :: ghostPf).all (fun b => (wideListPf.map Prod.fst).contains b) = true := by decide
  intro b hb
  exact Pf.lookupW_ne (List.contains_iff_mem.mp (List.all_eq_true.mp h b hb))

/-- The typed frames, in the link's order. -/
theorem frames_link (a : Nat) :
    a ∈ [2665, fr.chunk, fr.buffer, fr.view] ++ framedOf fr.memo fr.ghosts ↔
      a ∈ 2665 :: ([2834123] ++ ((4910 :: ghostPf) ++ [2834128, 2834129])) := by
  have e : [2665, fr.chunk, fr.buffer, fr.view] ++ framedOf fr.memo fr.ghosts =
      [2665, 2834123, 2834128, 2834129, 4910, 1824, 1834, 1852, 1993, 2001] := rfl
  rw [e]
  simp only [ghostPf, List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil, or_false]
  constructor <;> (intro h; rcases h with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> simp)

kernel_rfl keysSmall : ([11, 14, 21, 22, 24, 28, 10].all fun j => [11].contains j || Post.imgSmall [1, 6, 5] (PL4L7.θ j)) = true

theorem entryVal {ν : Nat → F64} {L : Nat} (hv : VBOkF loopVB ν) (h2 : 2 ≤ L) (hL : L ≤ 224)
    (h11 : ν 11 = F64.ofNat (L - 1)) :
    VBOkF loopVB (Shift.valuation PL4L7.θ ν) := by
  refine Post.valOf (cand := [1, 6, 5]) (keys := [11, 14, 21, 22, 24, 28, 10]) (off := [11]) hv
    (fun _ hj => θ_off hj) keysSmall ?_
  intro j hj
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hj
  subst hj
  refine ⟨L, by omega, ?_⟩
  rw [θ11]
  change F64.bin .add (ν 11) (F64.ofNat 1) = _
  rw [h11, bin_add_ofNat (L - 1) 1 (by omega), show L - 1 + 1 = L by omega]

/-- The entry's POST variables: the trace ids and payloads literal, the offset's copy the forward's. -/
theorem entryPin {ν : Nat → F64} {L : Nat} (h11 : ν 11 = F64.ofNat (L - 1)) :
    Post.PinVals 6 5 5 (L - 1) (Shift.valuation PL4L7.θ ν) where
  v21 := by change (PL4L7.θ 21).eval ν = _; rw [θ21]; rfl
  v22 := by change (PL4L7.θ 22).eval ν = _; rw [θ22]; rfl
  v24 := by change (PL4L7.θ 24).eval ν = _; rw [θ24]; rfl
  v28 := by change (PL4L7.θ 28).eval ν = _; rw [θ28]; exact h11

/-- **The forward's return at x4_L7's POST entry.** -/
theorem toEntry {NB T cap capE H N : Nat} {tk : Nat → Nat} {π : List Nat} {Mem Mem' : SegInst FF → Prop}
    (hcap : cap ≤ capE) (hbound : capE < Sim.bound) (hH : H ≤ 4096) (hN : N ≤ 4096) (hL : π.length ≤ 224)
    (hMem : ∀ x y, NTrack x y → Post.PinVals 6 5 5 (π.length - 1) y.ν → Mem x → Mem' y) :
    CutConv (withMem Mem (returnCut NB T tk π cap H N))
      (withMem Mem' (Post.indexedCut0 [2834123] NB T tk capE 19265 π PRE_plx4_L7_entry.s0 PRE_plx4_L7_entry.S0)) := by
  rintro x ⟨K0, hr, hb, hip, hem⟩ ⟨⟨hf, hc, hnat⟩, hm⟩
  have h2 := hb.length2
  have hlen1 : (lastRows π).length = 1 := lastRows_length (by omega)
  have hctx := hb.context
  have hfr : ∀ a, x.K.fr a ≠ none ↔ a ∈ 2665 :: ([2834123] ++ ((4910 :: ghostPf) ++ [2834128, 2834129])) :=
    fun a => (hctx.1.2.2 a).trans (frames_link a)
  have hP : x.K.fr 2665 = some ([], π.map natV) := by
    rw [hb.frames]
    change (g1Framed K0 π).fr 2665 = _
    exact hb.incomingPrompt
  have hC : x.K.fr 2834123 = some ([], (lastRows π).map natV) := by
    rw [hb.frames]
    rfl
  have hK : ∀ b ∈ [2834123], ∃ q, x.K.fr b = some ([], q) := by
    intro b hb'
    obtain rfl := List.mem_singleton.mp hb'
    exact ⟨_, hC⟩
  have hlo : x.K.lo = 18151 := hctx.1.1
  have hhi : x.K.hi = 131072 := hctx.1.2.1
  have hDK : x.K.D ≤ cap := hctx.2
  have top := hr.ffi.1.top (by rfl)
  have hNL : ({ setupP with rest := machReads T tk }.raise (mlxOf PRE_fd_x4_L7_r0_body.s451.ffi).nnext).NL ≤ PL4L7.P0.NL := by
    change (mlxOf PRE_fd_x4_L7_r0_body.s451.ffi).nnext ≤ PL4L7.P0.NL
    exact Nat.le_of_ble_eq_true nodesBelow
  have hNB : NB ≤ PL4L7.P0.NL := Nat.le_trans top.1.load.mlx.nbl hNL
  have hsame : PRE_fd_x4_L7_r0_body.s451.next - PRE_plx4_L7_entry.s0.next = 0 := by rw [sameNext]; omega
  have hD : x.K.D + (PRE_fd_x4_L7_r0_body.s451.next - PRE_plx4_L7_entry.s0.next) < Sim.bound := by
    rw [hsame]
    omega
  let laws := fullRXD_laws { setupP with rest := machReads T tk } NB
  obtain ⟨M1, hext, hp⟩ := relB_pad laws.stable laws.mono (PRE_plx4_L7_entry.S0.tab.map (·.subst PL4L7.θ)) hr.ofJ
  have hrP : RelB FF (Disp.FRJ (FullRXD { setupP with rest := machReads T tk } NB)) (fr.typedW (tokenBytes (lastRows π))) []
      M1 x.ν x.K PRE_fd_x4_L7_r0_body.s451 ⟨PRE_fd_x4_L7_r0_body.S451.tab ++ PRE_plx4_L7_entry.S0.tab.map (·.subst PL4L7.θ), []⟩ x.t x.C :=
    hp.toJ (hr.ffi.2.ext hext)
  have hrel := Pf.pfRel PL4L7.facts (π := π) (kw := 4910 :: ghostPf) hrP hfr kwHead
    (fun a w hw => .inr (wide_typed _ a w hw)) hlo hhi hP hK
    (Pf.linkRoomLe hr (Nat.le_of_eq sameHandles) (Nat.le_of_eq sameNodes)) hNB hD (by rw [sameNext]; omega)
  have hoff : x.t.next = PRE_fd_x4_L7_r0_body.s451.next + x.K.D := hr.offset
  let y : SegInst FF := ⟨((M1.after PLW4L7.R.data.map).rebig (mlxOf PRE_plx4_L7_entry.s0.ffi).next setupP.E
      (mlxOf x.t.ffi).next).withJs, Shift.valuation PL4L7.θ x.ν,
    ⟨frW M1 x.K (Pf.keepOf [2834123]) wideGPf PRE_fd_x4_L7_r0_body.s451, PRE_plx4_L7_entry.s0.trace, x.t.trace,
      x.t.next - PRE_plx4_L7_entry.s0.next, x.K.lo, x.K.hi⟩, x.t, x.C⟩
  have hnode : y.M.node = x.M.node :=
    funext fun k => (congrFun hext.node (PLW4L7.R.data.nodeF k)).trans (congrArg x.M.node (nodeF_id walkNN walkNK k))
  have hvar : ∀ {j : Nat}, j ∉ [11, 14, 21, 22, 24, 28, 10] → y.ν j = x.ν j := by
    intro j hj
    change (PL4L7.θ j).eval x.ν = _
    rw [θ_off hj]
    rfl
  refine ⟨y, rfl, rfl, ⟨lastRows π, hrel, ?_⟩, ⟨hf, ?_, ?_⟩,
    hMem x y (NTrack.conv rfl rfl hnode (by change M1.a (PLW4L7.R.data.a 12504) = _; rw [anchorE, hext.a]))
      (entryPin hb.offsetValue) hm⟩
  · refine
      { nonempty := by omega
        vocab := hb.vocab
        lastRows := rfl
        rowsLength := hlen1
        rowsVocab := fun k hk => hb.vocab k (List.mem_of_mem_drop hk)
        valuation := entryVal hb.valuation h2 hL hb.offsetValue
        promptValue := (hvar (by decide)).trans hb.promptValue
        rowValue := by change (PL4L7.θ 10).eval x.ν = _; rw [θ10]; rfl
        offsetValue := ?_
        capValue := ?_
        context := ⟨⟨hlo, hhi, fun a => Pf.framed_after PL4L7.facts.toPfCore M1 x.K (L := wideListPf) (fun _ => rfl) hP hK a⟩, ?_⟩
        offsetLow := ?_
        prompt := (Pf.frames_prompt PL4L7.facts.toPfCore M1 x.K).trans hP
        reserved := fun j hj => (hvar (by simp only [List.mem_cons, List.not_mem_nil, or_false]; omega)).trans (hb.reserved j hj)
        emittedAnchor := by change M1.a (PLW4L7.R.data.a 2590) = 2590; rw [anchorA, hext.a]; exact hem
        input := ?_
        dims := trivial
        hand := trivial }
    · change (PL4L7.θ 11).eval x.ν = _
      rw [θ11]
      change F64.bin .add (x.ν 11) (F64.ofNat 1) = _
      rw [hb.offsetValue, bin_add_ofNat (π.length - 1) 1 (by omega), show π.length - 1 + 1 = π.length by omega]
    · rw [hvar (by decide), hb.capValue, show capL (π.length - 1) = capL π.length by unfold capL; omega]
    · change x.t.next - PRE_plx4_L7_entry.s0.next ≤ capE
      rw [hoff, sameNext]
      omega
    · have h18 := hb.offsetLow
      change 13 ≤ x.t.next - PRE_plx4_L7_entry.s0.next
      rw [hoff, sameNext]
      omega
    · have e : y.M.node 19265 = x.M.node 19265 := by rw [hnode]
      have hi := hip
      unfold InputAt at hi
      rw [hlen1] at hi
      change y.M.node 19265 < (mlxOf x.t.ffi).nnext ∧
        Host.Mlx.SimGraph.HostInt32 (Host.Mlx.FfiEval.concrete x.C.val) (mlxOf x.t.ffi) (y.M.node 19265)
          ((lastRows π).map Int.ofNat) [1, 1]
      rw [e]
      exact hi
  · change M1.a (PLW4L7.R.data.a 2586) = 2586 ∧ M1.a (PLW4L7.R.data.a 2589) = 2589
    rw [anchorB, anchorC, hext.a]
    exact hc
  · have h1 : (mlxOf x.t.ffi).next ≤ (mlxOf PRE_fd_x4_L7_r0_body.s451.ffi).next + H := hnat.1
    have h2' : (mlxOf x.t.ffi).nnext ≤ (mlxOf PRE_fd_x4_L7_r0_body.s451.ffi).nnext + N := hnat.2
    rw [sameHandles] at h1
    rw [sameNodes] at h2'
    refine ⟨?_, ?_⟩
    · change (mlxOf x.t.ffi).next ≤ (mlxOf PRE_plx4_L7_entry.s0.ffi).next + 4096
      omega
    · change (mlxOf x.t.ffi).nnext ≤ (mlxOf PRE_plx4_L7_entry.s0.ffi).nnext + 4096
      omega

end Host.Ts.Sim.Compose.FDX4L7
