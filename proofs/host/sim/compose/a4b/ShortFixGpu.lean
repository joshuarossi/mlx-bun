import host.sim.compose.a4b.DecodeGpu
import host.sim.compose.ShortFix
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers
open Host.Ts.Sim.Template Host.Load.Run.Prompt

/-! # The four decode chains at the bounded route's list

`TailFix` of each chain `L ≤ 224` runs: its generated links past the first, at `terminalFixP`, after `startLinkS` from the
decode cut at `shortFixP`. `DEC.tailsGpu`: at every case of `DEC.piecesFramedGpu`. -/

section
variable {b0 : BSt} {NB : Nat} {toks : List NumV} {L T : Nat} {tk : Nat → Nat} {E0 : List Val} {B : LoopBase}
  {ΔJ ΔH ΔN : Nat} {ρ : Nat → F64}

theorem DEC_ord.tailS (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ) (hH) (hN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).next + T * ΔH + B.H + (DEC_ord.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).nnext + T * ΔN + B.N + (DEC_ord.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_ord.s0.ffi).nnext) < 2 ^ 62) :
    TailFix (fullWorldFb b0 NB) addrPrompt wideP DEC_ord.Pw (framesP Host.Load.Run.Tpl.DEC_ord.s0 q)
      Host.Load.Run.Tpl.DEC_ord.s0 Host.Load.Run.Tpl.DEC_ord.S0.tab terminalFixP shortFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DEC_ord.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb) :=
  by
    have st := startLinkS (b0 := b0) (NB := NB) (Pw := DEC_ord.Pw) (fr := DEC_ord.fr) (wd := DEC_ord.wd) (W := wideP) (A := addrPrompt)
      (Fr := framesP Host.Load.Run.Tpl.DEC_ord.s0 q) (s0 := Host.Load.Run.Tpl.DEC_ord.s0) (tab0 := Host.Load.Run.Tpl.DEC_ord.S0.tab)
      (fixB := terminalFixP) (fixS := shortFixP) (toks := toks) (uses := dec_ord.rows) (E0 := E0) (B := B)
      (m := DEC_ord.m0) (θ := Host.Load.Run.Tpl.DEC_ord.θ) (sst := Host.Load.Run.Tpl.DEC_ord.s0) (Sst := Host.Load.Run.Tpl.DEC_ord.S0)
      [] (by decide +kernel) rfl rfl (DEC_ord.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    refine ⟨st.n + ((DEC_ord.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb).chain.lens.drop 1).sum, fun i x0 hs => ?_⟩
    exact (st.link dec_ord.cover (fun _ h => h) (fun _ _ _ _ => trivial) h1 hctx i x0 hs).trans
      (CutChain.tail ((DEC_ord.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb).chain.links i x0 hs)).run

theorem DEC_clear.tailS (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ) (hH) (hN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).next + T * ΔH + B.H + (DEC_clear.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).nnext + T * ΔN + B.N + (DEC_clear.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_clear.s0.ffi).nnext) < 2 ^ 62) :
    TailFix (fullWorldFb b0 NB) addrPrompt wideP DEC_clear.Pw (framesP Host.Load.Run.Tpl.DEC_clear.s0 q)
      Host.Load.Run.Tpl.DEC_clear.s0 Host.Load.Run.Tpl.DEC_clear.S0.tab terminalFixP shortFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DEC_clear.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb) :=
  by
    have st := startLinkS (b0 := b0) (NB := NB) (Pw := DEC_clear.Pw) (fr := DEC_clear.fr) (wd := DEC_clear.wd) (W := wideP) (A := addrPrompt)
      (Fr := framesP Host.Load.Run.Tpl.DEC_clear.s0 q) (s0 := Host.Load.Run.Tpl.DEC_clear.s0) (tab0 := Host.Load.Run.Tpl.DEC_clear.S0.tab)
      (fixB := terminalFixP) (fixS := shortFixP) (toks := toks) (uses := dec_clear.rows) (E0 := E0) (B := B)
      (m := DEC_clear.m0) (θ := Host.Load.Run.Tpl.DEC_clear.θ) (sst := Host.Load.Run.Tpl.DEC_clear.s0) (Sst := Host.Load.Run.Tpl.DEC_clear.S0)
      [] (by decide +kernel) rfl rfl (DEC_clear.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    refine ⟨st.n + ((DEC_clear.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb).chain.lens.drop 1).sum, fun i x0 hs => ?_⟩
    exact (st.link dec_clear.cover (fun _ h => h) (fun _ _ _ _ => trivial) h1 hctx i x0 hs).trans
      (CutChain.tail ((DEC_clear.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb).chain.links i x0 hs)).run

theorem DEC_grow.tailS (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ) (hH) (hN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).next + T * ΔH + B.H + (DEC_grow.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).nnext + T * ΔN + B.N + (DEC_grow.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_grow.s0.ffi).nnext) < 2 ^ 62) :
    TailFix (fullWorldFb b0 NB) addrPrompt wideP DEC_grow.Pw (framesP Host.Load.Run.Tpl.DEC_grow.s0 q)
      Host.Load.Run.Tpl.DEC_grow.s0 Host.Load.Run.Tpl.DEC_grow.S0.tab terminalFixP shortFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DEC_grow.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb) :=
  by
    have st := startLinkS (b0 := b0) (NB := NB) (Pw := DEC_grow.Pw) (fr := DEC_grow.fr) (wd := DEC_grow.wd) (W := wideP) (A := addrPrompt)
      (Fr := framesP Host.Load.Run.Tpl.DEC_grow.s0 q) (s0 := Host.Load.Run.Tpl.DEC_grow.s0) (tab0 := Host.Load.Run.Tpl.DEC_grow.S0.tab)
      (fixB := terminalFixP) (fixS := shortFixP) (toks := toks) (uses := dec_grow.rows) (E0 := E0) (B := B)
      (m := DEC_grow.m0) (θ := Host.Load.Run.Tpl.DEC_grow.θ) (sst := Host.Load.Run.Tpl.DEC_grow.s0) (Sst := Host.Load.Run.Tpl.DEC_grow.S0)
      [] (by decide +kernel) rfl rfl (DEC_grow.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    refine ⟨st.n + ((DEC_grow.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb).chain.lens.drop 1).sum, fun i x0 hs => ?_⟩
    exact (st.link dec_grow.cover (fun _ h => h) (fun _ _ _ _ => trivial) h1 hctx i x0 hs).trans
      (CutChain.tail ((DEC_grow.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb).chain.links i x0 hs)).run

theorem DEC_fill.tailS (q : List Val)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx)) (h1 : 1 ≤ L) (hctx : L + T ≤ 262144)
    (hJ) (hH) (hN) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).next + T * ΔH + B.H + (DEC_fill.Pw.E - (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).nnext + T * ΔN + B.N + (DEC_fill.Pw.NE - (mlxOf Host.Load.Run.Tpl.DEC_fill.s0.ffi).nnext) < 2 ^ 62) :
    TailFix (fullWorldFb b0 NB) addrPrompt wideP DEC_fill.Pw (framesP Host.Load.Run.Tpl.DEC_fill.s0 q)
      Host.Load.Run.Tpl.DEC_fill.s0 Host.Load.Run.Tpl.DEC_fill.S0.tab terminalFixP shortFixP (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN
      (DEC_fill.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb) :=
  by
    have st := startLinkS (b0 := b0) (NB := NB) (Pw := DEC_fill.Pw) (fr := DEC_fill.fr) (wd := DEC_fill.wd) (W := wideP) (A := addrPrompt)
      (Fr := framesP Host.Load.Run.Tpl.DEC_fill.s0 q) (s0 := Host.Load.Run.Tpl.DEC_fill.s0) (tab0 := Host.Load.Run.Tpl.DEC_fill.S0.tab)
      (fixB := terminalFixP) (fixS := shortFixP) (toks := toks) (uses := dec_fill.rows) (E0 := E0) (B := B)
      (m := DEC_fill.m0) (θ := Host.Load.Run.Tpl.DEC_fill.θ) (sst := Host.Load.Run.Tpl.DEC_fill.s0) (Sst := Host.Load.Run.Tpl.DEC_fill.S0)
      [] (by decide +kernel) rfl rfl (DEC_fill.hfr q) hVB
      (fun i nx => MapOk.sub (mapOk_decM ρ T tk L i nx) (by decide +kernel)) hJb hHb hNb
    refine ⟨st.n + ((DEC_fill.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb).chain.lens.drop 1).sum, fun i x0 hs => ?_⟩
    exact (st.link dec_fill.cover (fun _ h => h) (fun _ _ _ _ => trivial) h1 hctx i x0 hs).trans
      (CutChain.tail ((DEC_fill.caseFixed (b0 := b0) (NB := NB) (toks := toks) (E0 := E0) (B := B) q hVB h1 hctx hJ hH hN hJb hHb hNb).chain.links i x0 hs)).run

/-- **Every decode case's chain from the decode cut at `shortFixP`.** -/
theorem DEC.tailsGpu (q : List Val) (hql : q.length = L)
    (hρ : ∀ j, ∃ n ≤ 2 ^ 20, ρ j = F64.ofNat n)
    (h1 : 1 ≤ L) (hL : L ≤ 224) (hT : 3 ≤ T) (hctx : L + T ≤ 262144)
    (htv : ∀ j, j ≤ T → tk j ≤ 248319)
    (hJ : DECG.ΔJ ≤ ΔJ) (hH : DECG.ΔH ≤ ΔH) (hN : DECG.ΔN ≤ ΔN)
    (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf DEC.s0.ffi).next + T * ΔH + B.H + (DEC.Pw.E - (mlxOf DEC.s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf DEC.s0.ffi).nnext + T * ΔN + B.N + (DEC.Pw.NE - (mlxOf DEC.s0.ffi).nnext) < 2 ^ 62) (k : DecKind) :
    TailFix (fullWorldFb b0 NB) addrPrompt wideP DEC.Pw (framesP DEC.s0 q) DEC.s0 DEC.tab0 terminalFixP shortFixP (valL ρ T tk L) tk toks
      [.num (.ref 1)] B ΔJ ΔH ΔN
      ((DEC.piecesFramedGpu (b0 := b0) (NB := NB) (ρ := ρ) (toks := toks) (B := B) q hql hρ h1 hL hT hctx htv hJ hH hN hJb hHb hNb).cs k) := by
  have hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx) :=
    fun i nx hi hnx => valL_vb_supported hρ hctx htv i nx hi hnx
  cases k
  · exact DEC_ord.tailS q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ) (by exact Nat.le_trans (by decide) hH)
      (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
  · exact DEC_clear.tailS q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ) (by exact Nat.le_trans (by decide) hH)
      (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
  · exact DEC_grow.tailS q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ) (by exact Nat.le_trans (by decide) hH)
      (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
  · exact DEC_fill.tailS q hVB h1 hctx (by exact Nat.le_trans (by decide) hJ) (by exact Nat.le_trans (by decide) hH)
      (by exact Nat.le_trans (by decide) hN) hJb hHb hNb
  · exact ⟨0, fun _ _ hs => (Gpu.clearFill_not hL hs.1.2.2).elim⟩
  · exact ⟨0, fun _ _ hs => (Gpu.clearGrow_not hL hs.1.2.2).elim⟩

end

end Host.Ts.Sim.Compose
