import host.sim.compose.StartBounded
import host.sim.compose.GraphData
set_option autoImplicit false
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full
open Host.Load.Layers
open Host.Mlx.SimGraph.Iter (TplInputs)

/-! # The decode iterations at a shorter fixed-address list

A decode chain is generated at a list `fixB`, its cuts carrying `IterGhostCW` at it: each address's image is `x0`'s, the
iteration's start pair's. Only the chain's first link reads the decode cut at `x0`, where `fixB`'s addresses are fixed
absolutely; the later links hold at every `x0`. So a chain runs from a decode cut at a sublist `fixS`: `startLinkS` is
the first link with the ghost at `fixB` (true at `x = x0` whatever `x0` maps those addresses to) and the decode cut at
`fixS`, and the end's ghost restricts to `fixS` (`IterEndW.restrict`, `IterGhostCW.restrict`). `itersS`: the route's
iterations at `fixS` from the cases' `TailFix`. -/

/-- The fixed addresses the bounded route keeps: `terminalFixP` without the `forwarded` array, whose target address
depends on the prompt and which nothing reads through the list. -/
def shortFixP : List Nat := [2586, 2589, 12504, 2590]

section
variable {Wd : World} {A : Addr} {P : Wd.Par} {s0 : St Wd.F.S} {tab0 : List SymE} {fixB fixS : List Nat}

/-- An iteration end at a sublist of its fixed addresses. -/
def _root_.Host.Ts.Sim.Prefill.IterEndW.restrict (e : IterEndW Wd A P s0 tab0 fixB) (h : ∀ a ∈ fixS, a ∈ fixB) : IterEndW Wd A P s0 tab0 fixS where
  s1 := e.s1
  S1 := e.S1
  σ := e.σ
  θ := e.θ
  grow := e.grow
  xs := e.xs
  eR := e.eR
  tlen := e.tlen
  noVarTab := e.noVarTab
  noVarOr := e.noVarOr
  nshift := e.nshift
  num := e.num
  hE := e.hE
  theta := e.theta
  fwd := e.fwd
  emit := e.emit
  fix := fun a ha => e.fix a (h a ha)

theorem _root_.Host.Ts.Sim.Prefill.IterGhostCW.restrict {Fr : LoopFramesA A} {θ : Nat → SymE} {g : GhostP} {x0 x : SegInst Wd.F}
    (h : IterGhostCW Wd A P Fr s0 tab0 fixB θ g x0 x) (hs : ∀ a ∈ fixS, a ∈ fixB) :
    IterGhostCW Wd A P Fr s0 tab0 fixS θ g x0 x :=
  { h with fix := fun a ha => h.fix a (hs a ha) }

/-- A case end's graph facts at the restricted end. -/
def EndGM.restrict {I : TplInputs} {e : IterEndW Wd A P s0 tab0 fixB} (en : EndGM I e) (h : ∀ a ∈ fixS, a ∈ fixB) :
    EndGM I (e.restrict h) where
  outT := en.outT
  outs := en.outs
  read := en.read
  fed := en.fed
  caches := en.caches
  h1read := en.h1read
  h1pread := en.h1pread
  s1tok := en.s1tok
  pout := en.pout
  pouts := en.pouts

end

section
variable (Wd : World) (A : Addr) (W : Nat → Option WFrame) (P : Wd.Par) (Fr : LoopFramesA A) (s0 : St Wd.F.S)
  (tab0 : List SymE) (fixB fixS : List Nat) (V : LoopVals) (tk : Nat → Nat) (toks : List NumV) (E0 : List Val)
  (B : LoopBase) (ΔJ ΔH ΔN : Nat)

/-- `iterGhostW` with the chain's ghost at `fixB` and the decode cut at `fixS`. -/
def iterGhostS (θ : Nat → SymE) (i : Nat) (x0 : SegInst Wd.F) : ICut Wd.F where
  s0 := s0
  tab0 := tab0
  R := fun x s S => relW Wd P W (toks.drop i) x.M x.ν x.K s S x.t x.C
  B := fun x => IterGhostCW Wd A P Fr s0 tab0 fixB θ (GhostP.init Wd s0) x0 x ∧ x.ν = x0.ν ∧ x.K = x0.K ∧
    (decCutW Wd A (fun _ _ _ _ => True) W P Fr s0 tab0 fixS V tk toks E0 B ΔJ ΔH ΔN i).B x0

/-- **A case's chain from the shorter decode cut**: the first link at `iterGhostS`, the others the chain's. -/
def TailFix {Sel : Nat → Prop} (c : IterCaseW Wd A W P Fr s0 tab0 fixB V tk toks E0 B ΔJ ΔH ΔN Sel) : Prop :=
  ∃ n, ∀ i x0, Sel i → CutStep (iterGhostS Wd A W P Fr s0 tab0 fixB fixS V tk toks E0 B ΔJ ΔH ΔN c.e.θ i x0)
    (iterEndCW Wd A W P Fr s0 tab0 fixB toks c.e c.g i x0) n

end

section
variable {Wd : World} {A : Addr} {Gx : Nat → Map → St Wd.F.S → CSrv → Prop} {W : Nat → Option WFrame} {P : Wd.Par}
  {Fr : LoopFramesA A} {s0 : St Wd.F.S} {tab0 : List SymE} {fixB fixS : List Nat} {V : LoopVals} {tk : Nat → Nat}
  {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}

/-- The iteration's first conversion: the ghost at `x = x0` holds at any list. -/
theorem iterStart_ghostS (hE : Wd.EndLaws) (θ : Nat → SymE) (i : Nat) (x0 : SegInst Wd.F)
    (hB0 : (decCutW Wd A Gx W P Fr s0 tab0 fixS V tk toks E0 B ΔJ ΔH ΔN i).B x0) :
    CutConv (iterStartW Wd A Gx W P Fr s0 tab0 fixS V tk toks E0 B ΔJ ΔH ΔN i x0)
      (iterGhostS Wd A W P Fr s0 tab0 fixB fixS V tk toks E0 B ΔJ ΔH ΔN θ i x0) := by
  rintro x hR rfl
  obtain ⟨nx, p1, hν, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, -⟩ := hB0
  exact ⟨x, rfl, rfl, hR, IterGhostCW.start hE hR hfr, rfl, rfl,
    ⟨nx, p1, hν, hfr, hlo, hhi, hbase, h79, hnx, hvals, hD, hHi, hNi, hfix, trivial⟩⟩

/-- The end cut at the sublist. -/
theorem iterEnd_restrict (e : IterEndW Wd A P s0 tab0 fixB) (g : GhostP) (i : Nat) (x0 : SegInst Wd.F)
    (h : ∀ a ∈ fixS, a ∈ fixB) :
    CutConv (iterEndCW Wd A W P Fr s0 tab0 fixB toks e g i x0)
      (iterEndCW Wd A W P Fr s0 tab0 fixS toks (e.restrict h) g i x0) :=
  fun x hR hB => ⟨x, rfl, rfl, hR, IterGhostCW.restrict hB h⟩

/-- **A decode case's iteration at the shorter list** (`IterCaseW.iter`). -/
theorem IterCaseW.iterS (hE : Wd.EndLaws) (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0) {Sel : Nat → Prop}
    {ρ : Nat → F64} {T L : Nat} (hsub : ∀ a ∈ fixS, a ∈ fixB)
    (c : IterCaseW Wd A W P Fr s0 tab0 fixB (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN Sel)
    (ht : TailFix Wd A W P Fr s0 tab0 fixB fixS (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN c)
    (hgr : ∀ i, Sel i → c.e.grow = decide ((L + i + 1) % 256 = 0)) {i : Nat} (hs : Sel i) (hi1 : 1 ≤ i)
    (hiT : i + 2 < T) (hLT : L + T < 2 ^ 29) (hlen : T - 2 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (hJ : T * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + T * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + T * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : LoopGStepGW Gx W Fr (c.e.restrict hsub) c.g (valL ρ T tk L) toks i) :
    ∃ n, DecodeIterW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixS (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) i n := by
  have hmul : ∀ D, i * D ≤ T * D := fun D => Nat.mul_le_mul_right D (by omega)
  obtain ⟨n, hn⟩ := ht
  exact ⟨_, decodeIter_piecesCW hE st (c.e.restrict hsub) c.g c.sh c.keep c.emit hi1 (by omega)
    (fun _ => by
      rw [hA]
      exact next_valL c.e.grow (fun j => by have h := c.e.theta j; rw [hA] at h; exact h) (by omega)
        (by have := capL_le (L + i + 1); omega) (hgr i hs))
    (htk (i + 2) (by omega)) c.within (by have := hmul ΔJ; omega) (by have := hmul ΔH; omega)
    (by have := hmul ΔN; omega) hG
    (fun x0 _ hB0 => ((iterStart_ghostS hE c.e.θ i x0 hB0).step.trans (hn i x0 hs)).trans
      (iterEnd_restrict c.e c.g i x0 hsub).step)⟩

/-- **The route's iterations at the shorter list** (`itersW`). -/
theorem itersS (hE : Wd.EndLaws) (hA : A.nxt = 17) (st : LoopStartW Wd A P s0 tab0) {ρ : Nat → F64} {T L : Nat}
    (hsub : ∀ a ∈ fixS, a ∈ fixB)
    (cs : (k : DecKind) → IterCaseW Wd A W P Fr s0 tab0 fixB (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN (DecSel T L tk k))
    (ht : ∀ k, TailFix Wd A W P Fr s0 tab0 fixB fixS (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN (cs k))
    (hgr : ∀ k, (cs k).e.grow = k.grows) (hLT : L + T < 2 ^ 29) (hlen : T - 2 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (htv : ∀ j, j ≤ T → tk j ≤ 248319) (hJ : T * ΔJ + B.D < Sim.bound)
    (hH : (Wd.toMlx s0.ffi).next + T * ΔH + B.H + (Wd.E P - (Wd.toMlx s0.ffi).next) < 2 ^ 46)
    (hN : (Wd.toMlx s0.ffi).nnext + T * ΔN + B.N + (Wd.NE P - (Wd.toMlx s0.ffi).nnext) < 2 ^ 62)
    (hG : ∀ k i, DecSel T L tk k i → (∀ j, 1 ≤ j → j ≤ i + 1 → tk j ≠ 248044) →
      LoopGStepGW Gx W Fr ((cs k).e.restrict hsub) (cs k).g (valL ρ T tk L) toks i) :
    DecodeItersW (DecodeInvW Wd A Gx W P Fr s0 tab0 fixS (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN) T tk := by
  intro i hi1 hiT hne
  obtain ⟨k, hk⟩ := DecKind.cover L i
  have hs : DecSel T L tk k i := ⟨⟨hi1, hiT, hk⟩, htv (i + 1) (by omega), hne (i + 1) (by omega) (Nat.le_refl _)⟩
  exact (cs k).iterS hE hA st hsub (ht k) (fun _ hs => (hgr k).trans (DecKind.grows_eq hs.1.2.2)) hs hi1 hiT hLT
    hlen htk hJ hH hN (hG k i hs hne)

/-- The tail of a chain past its first link. -/
theorem CutChain.tail {F : Ffi} {a c b : ICut F} {cs : List (ICut F)} {n : Nat} {ns : List Nat}
    (h : CutChain a (c :: cs) b (n :: ns)) : CutChain c cs b ns :=
  h.2

end

section
variable {b0 : BSt} {NB : Nat} {Pw : LoadP} {fr : List Nat} {wd : List (Nat × WFrame)} {W : Nat → Option WFrame} {A : Addr}
  {Fr : LoopFramesA A} {s0 : St FF.S} {tab0 : List SymE} {fixB fixS : List Nat} {toks : List NumV}
  {L T : Nat} {tk : Nat → Nat} {uses : List Row} {ΔJ ΔH ΔN : Nat}

/-- **The first decode link from the shorter decode cut** (`startLinkBounded` at `iterGhostS`). -/
def startLinkS {E0 : List Val} {B : LoopBase} {ρ : Nat → F64} {m : List (Nat × Q)} {θ : Nat → SymE}
    {sst : St FF.S} {Sst : SSrv} (O : List Ans) (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (hs : sst = s0) (hS : Sst.tab = tab0) (hfr : ∀ a, a ∈ A.fwd :: A.emit :: Fr.xs ↔ a ∈ fr)
    (hVB : ∀ i nx, i + 2 < T → nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx))
    (hMap : ∀ i nx, MapOk (valL ρ T tk L i nx) (decI L T i (tk (i + 1))) m) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62) :
    DLink (DecAt L T tk) uses m []
      (fun i x0 => iterGhostS (fullWorldFb b0 NB) A W Pw Fr s0 tab0 fixB fixS (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN θ i.k x0)
      (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixB toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) s0) m sst Sst) where
  n := 0
  O := O
  chk := hchk
  ok _ _ i _ _ hadm x0 := CutConv.step fun x hR hB => by
    obtain ⟨hg, hν, hK, nx, p1, hν0, hfr0, hlo, hhi, -, -, hnx, -, hD, hHx, hNx, -⟩ := hB
    have hk := hadm.2.1
    have mJ : (i.k - 1 + 1) * ΔJ ≤ T * ΔJ := Nat.mul_le_mul_right _ (by omega)
    have mH : (i.k - 1 + 1) * ΔH ≤ T * ΔH := Nat.mul_le_mul_right _ (by omega)
    have mN : (i.k - 1 + 1) * ΔN ≤ T * ΔN := Nat.mul_le_mul_right _ (by omega)
    rw [Nat.add_one_mul] at mJ mH mN
    refine ⟨x, rfl, rfl, ⟨?_, ?_, ?_, ?_⟩, hg, ?_, ?_, ?_⟩
    · show RelB FF (FLRb b0 Pw NB _) W [] x.M x.ν x.K sst ⟨Sst.tab, []⟩ x.t x.C
      rw [hs, hS]; exact hR
    · rw [hν, hν0]; exact hVB _ nx hk hnx
    · rw [hK]
      exact ⟨hlo, hhi, fun a => by rw [hfr0]; exact (frA_ne_none A s0 Fr _ _ a).trans (hfr a)⟩
    · have h := hMap i.k nx
      rw [← hadm.1] at h
      rw [hν, hν0]; exact h
    · show x0.K.D + ΔJ < Sim.bound; omega
    · show (mlxOf x0.t.ffi).next + ΔH + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46
      have : (mlxOf x0.t.ffi).next ≤ (mlxOf s0.ffi).next + (i.k - 1) * ΔH + B.H := hHx
      omega
    · show (mlxOf x0.t.ffi).nnext + ΔN + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62
      have : (mlxOf x0.t.ffi).nnext ≤ (mlxOf s0.ffi).nnext + (i.k - 1) * ΔN + B.N := hNx
      omega

end

end Host.Ts.Sim.Compose
