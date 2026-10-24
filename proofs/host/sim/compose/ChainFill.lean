import host.sim.compose.Glue
import host.sim.compose.DecRows
import host.sim.compose.Compact
import host.sim.template.FullOk
import host.sim.full.BigJs
import host.sim.full.BridgeFrameCall
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Prefill Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Ts.Sim.Full Host.Load.Layers

/-! # A decode chain's links from its template run

A decode chain (`tpl_chain`, full world) fills `DecPieces_<chain>` (`host.sim.compose.DecBundle`) at its
template boundaries `(s<b>, S<b>)`, in the decode world with the target's bridge pinned to `b0` (`fullWorldFb b0`,
its relation `FLRb b0`; `b0` the hand-off's, A1's `Conv.full_handoffTb`):

* the cuts: `bdCut … m s S` at a boundary, the full world's relation at the template state under the
  iteration's readbacks, the run's predicate `DQ` (the valuation within the acceptance's bounds and at the
  iteration's quantities `m`, the context the acceptance's `decJ`) and the iteration's ghost at its data `g`;
* the first link `startLink` (no step: the ghost cut at the template start is the first call's cut);
* a glue piece `glueLinkCall` (its checked run `X.runSeg<k>` and the step into the next call `X.stepA<k>`,
  by `cut_glueCall` under the full world's simulation `decSim`), the last `glueLinkEnd` (to the end cut,
  `cut_glue`);
* a call is A3's `cut_site` and the compaction `cut_compactQ` (its statement: the `DLink` between the cuts).

`decSim`: `Full.fullStepSimXLBKFb` at the chain's acceptance (`decOk`: `Disp.okJSK` of `Template.fullJSPP` without
continuations, the decode chains'). A glue piece's
target mlx growth along its run is the full world's (`hgrow`, A1's: the full world's counterpart of
`runOk_ngrow`). `IterEndW.toFb`: an iteration end of the full world (A4's end facts) as the pinned world's. -/

theorem mapOk_iff {ρ : Nat → F64} {i : Cls.Inst} :
    ∀ {m : List (Nat × Q)}, MapOk ρ i m ↔ ∀ p ∈ m, ρ p.1 = F64.ofNat (i.get p.2)
  | [] => by simp [MapOk]
  | (j, q) :: m => by simp [MapOk, mapOk_iff (m := m)]

theorem MapOk.sub {ρ : Nat → F64} {i : Cls.Inst} {m m' : List (Nat × Q)} (h : MapOk ρ i m)
    (hs : ∀ p ∈ m', p ∈ m) : MapOk ρ i m' :=
  mapOk_iff.2 fun p hp => mapOk_iff.1 h p (hs p hp)

/-- The decode template's variables at the loop's valuation are the iteration's quantities. -/
theorem mapOk_decM (ρ : Nat → F64) (T : Nat) (tk : Nat → Nat) (L i nx : Nat) :
    MapOk (valL ρ T tk L i nx) (decI L T i (tk (i + 1))) decM :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, trivial⟩

/-- **An iteration end of the full world as one of the pinned decode world** (`fullWorldFb b0`): the worlds agree on
everything an end reads (the native shift, the counters' projection and bound). -/
def _root_.Host.Ts.Sim.Prefill.IterEndW.toFb {NB : Nat} {A : Addr} {P : LoadP} {s0 : St FF.S} {tab0 : List SymE}
    {fixA : List Nat} (e : IterEndW (fullWorld NB) A P s0 tab0 fixA) (b0 : BSt) :
    IterEndW (fullWorldFb b0 NB) A P s0 tab0 fixA :=
  ⟨e.s1, e.S1, e.σ, e.θ, e.grow, e.xs, e.eR, e.tlen, e.noVarTab, e.noVarOr, e.nshift, e.num, e.hE, e.theta, e.fwd,
    e.emit, e.fix⟩

section
variable (b0 : BSt) (NB : Nat) (Pw : LoadP) (fr : List Nat) (wd : List (Nat × WFrame)) (W : Nat → Option WFrame) (A : Addr)
  (Fr : LoopFramesA A) (s0 : St FF.S) (tab0 : List SymE) (fixA : List Nat) (toks : List NumV)

/-- The acceptance parameters of a decode chain (`tpl_chain`'s `okB<k>`: `Template.fullJSPP` at the chain's
load parameters, framed arrays and wide frames). -/
abbrev decJ : Disp.JSP FF := Template.fullJSPP Pw fr wd

/-- The decode chains' acceptance: `decJ`'s with `moreB` and no continuation (`Disp.okJSK … (fun _ _ => false)`). -/
abbrev decOk : St FF.S → SSrv → Bool := Disp.okJSK (decJ Pw fr wd) (fun _ _ => false)

/-- The run's predicate at a decode chain's cut (see the module doc). -/
def DQ (m : List (Nat × Q)) (i : Cls.Inst) (x : SegInst FF) : Prop :=
  VBOkF loopVB x.ν ∧ Disp.Kp (decJ Pw fr wd) x.K ∧ MapOk x.ν i m

/-- **The iteration's budget at its start pair** `x0`: the decode cut's bounds within the route's, one iteration's
growth to spare (a call's compaction's room for the target, `callLink`). -/
def Bud (ΔJ ΔH ΔN : Nat) (x0 : SegInst FF) : Prop :=
  x0.K.D + ΔJ < Sim.bound ∧ (mlxOf x0.t.ffi).next + ΔH + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46 ∧
    (mlxOf x0.t.ffi).nnext + ΔN + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62

/-- **A decode chain's cut at a template boundary** `(s, S)` (see the module doc). -/
def bdCut (ΔJ ΔH ΔN : Nat) (θ : Nat → SymE) (g : GhostP) (m : List (Nat × Q)) (s : St FF.S) (S : SSrv)
    (i : Cls.Inst) (x0 : SegInst FF) : ICut FF :=
  (Cut.mk s S.tab (Conv.relB FF (FLRb b0 Pw NB (toks.drop i.k)) W [] (DQ Pw fr wd m i))).with
    fun x => IterGhostCW (fullWorldFb b0 NB) A Pw Fr s0 tab0 fixA θ g x0 x ∧ Bud Pw s0 ΔJ ΔH ΔN x0

/-- **The pinned decode world's simulation at a decode chain's acceptance parameters.** -/
theorem decSim (hW : Disp.Wp (decJ Pw fr wd) W) (r : List NumV) :
    Disp.StepSimXLB FF (FLRb b0 Pw NB r) (decOk Pw fr wd) (Disp.Kp (decJ Pw fr wd)) W [] (VBOkF loopVB) :=
  fullStepSimXLBKFb { Pw with rest := r } NB loopVB (decJ Pw fr wd) (okCallFS_rest Pw r).symm rfl rfl rfl rfl b0 [] hW

end

section
variable {b0 : BSt} {NB : Nat} {Pw : LoadP} {fr : List Nat} {wd : List (Nat × WFrame)} {W : Nat → Option WFrame} {A : Addr}
  {Fr : LoopFramesA A} {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {toks : List NumV}
  {L T : Nat} {tk : Nat → Nat} {uses : List Row} {ΔJ ΔH ΔN : Nat}

/-- **A glue piece into the next call as a decode link** (see the module doc). -/
def glueLinkCall {m m' : List (Nat × Q)} {θ : Nat → SymE} {g : GhostP} {sa sb sc : St FF.S} {Sa Sb Sc : SSrv}
    {n : Nat} (O : List Ans) (hW : Disp.Wp (decJ Pw fr wd) W)
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true) (hO : Sa.oracle = O)
    (hok : decOk Pw fr wd sa Sa = true)
    (hrun : runOk FF (decOk Pw fr wd) n sa Sa = some (sb, Sb))
    (hokb : decOk Pw fr wd sb Sb = true) (hhalt : isHalt sb.ctl = false)
    (hstep : interpS (step FF sb).run Sb = some (sc, Sc)) (htop : noRetBlock sc = true)
    (hlen : tab0.length ≤ Sa.tab.length) (hsub : ∀ p ∈ m', p ∈ m)
    (hgrow : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VBOkF loopVB c.ν →
      Disp.Kp (decJ Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa Sa c.t c.C →
      runC FF (n + 1) c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi)) :
    DLink (DecAt L T tk) uses m [] (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ g m sa Sa)
      (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ g m' sc Sc) where
  n := n + 1
  O := O
  chk := hchk
  ok _ _ i _ hobl _ x0 := cut_glueCall (decSim b0 NB Pw fr wd W hW _) hok hrun hokb hhalt hstep htop
    (fun _ hq _ => ⟨hq.2.1, hq.1⟩) (fun c hq _ => by rw [hO]; exact hobl.1 c.ν hq.2.2)
    (fun c _ t' _ hq hb hc he hr h2 => ⟨⟨h2.withOracle (fun q hq => nomatch hq), hq.1, hq.2.1, MapOk.sub hq.2.2 hsub⟩,
      hb.1.conv (he.mono hlen) rfl (fun _ _ _ => rfl) (fun _ _ _ _ => rfl) (hgrow _ c t' _ hq.1 hq.2.1 hc hr), hb.2⟩)

/-- **The last glue piece as a decode link**, to the iteration's end cut at the end template `e`. -/
def glueLinkEnd {m : List (Nat × Q)} {e : IterEndW (fullWorldFb b0 NB) A Pw s0 tab0 fixA} {g : GhostP} {sa sb : St FF.S}
    {Sa Sb : SSrv} {n : Nat} (O : List Ans) (hW : Disp.Wp (decJ Pw fr wd) W)
    (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true) (hO : Sa.oracle = O)
    (hok : decOk Pw fr wd sa Sa = true)
    (hrun : runOk FF (decOk Pw fr wd) n sa Sa = some (sb, Sb))
    (htop : noRetBlock sb = true) (he1 : e.s1 = sb) (hS1 : e.S1 = Sb)
    (hlen : tab0.length ≤ Sa.tab.length)
    (hgrow : ∀ (r : List NumV) (c : SegInst FF) (t' : St FF.S) (C' : CSrv), VBOkF loopVB c.ν →
      Disp.Kp (decJ Pw fr wd) c.K → RelB FF (FLRb b0 Pw NB r) W [] c.M c.ν c.K sa Sa c.t c.C →
      runC FF n c.t c.C = some (t', C') → Host.Mlx.Ffi.NGrow (mlxOf c.t.ffi) (mlxOf t'.ffi)) :
    DLink (DecAt L T tk) uses m [] (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN e.θ g m sa Sa)
      (fun i x0 => iterEndCW (fullWorldFb b0 NB) A W Pw Fr s0 tab0 fixA toks e g i.k x0) where
  n := n
  O := O
  chk := hchk
  ok _ _ i _ hobl _ x0 := cut_glue (decSim b0 NB Pw fr wd W hW _) hok hrun htop
    (fun _ hq _ => ⟨hq.2.1, hq.1⟩) (fun c hq _ => by rw [hO]; exact hobl.1 c.ν hq.2.2)
    (fun c _ t' _ hq hb hc he hr h2 => ⟨by show RelF FF (FLRb b0 Pw NB _) W _ _ _ e.s1 e.S1 _ _; rw [he1, hS1]; exact h2,
      hb.1.conv (he.mono hlen) rfl (fun _ _ _ => rfl) (fun _ _ _ _ => rfl) (hgrow _ c t' _ hq.1 hq.2.1 hc hr)⟩)

/-- **The first link**, no step: the iteration's ghost cut at the template start is the first call's cut at the
chain's start `(sst, Sst)` (the template start, its table), the iteration's budget (`Bud`) from the decode cut's
bounds within the route's (`hJb`, `hHb`, `hNb`, `itersW`'s). -/
def startLink {E0 : List Val} {B : LoopBase} {ρ : Nat → F64} {m : List (Nat × Q)} {θ : Nat → SymE}
    {sst : St FF.S} {Sst : SSrv} (O : List Ans) (hchk : ∀ r ∈ uses, goodLin r.ps (varsOf r.V m) O = true)
    (hs : sst = s0) (hS : Sst.tab = tab0) (hfr : ∀ a, a ∈ A.fwd :: A.emit :: Fr.xs ↔ a ∈ fr)
    (hVB : ∀ i nx, nx ≤ 2 ^ 20 → VBOkF loopVB (valL ρ T tk L i nx))
    (hMap : ∀ i nx, MapOk (valL ρ T tk L i nx) (decI L T i (tk (i + 1))) m) (hJb : T * ΔJ + B.D < Sim.bound)
    (hHb : (mlxOf s0.ffi).next + T * ΔH + B.H + (Pw.E - (mlxOf s0.ffi).next) < 2 ^ 46)
    (hNb : (mlxOf s0.ffi).nnext + T * ΔN + B.N + (Pw.NE - (mlxOf s0.ffi).nnext) < 2 ^ 62) :
    DLink (DecAt L T tk) uses m []
      (fun i x0 => iterGhostW (fullWorldFb b0 NB) A W Pw Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN θ i.k x0)
      (bdCut b0 NB Pw fr wd W A Fr s0 tab0 fixA toks ΔJ ΔH ΔN θ (GhostP.init (fullWorldFb b0 NB) s0) m sst Sst) where
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
    · rw [hν, hν0]; exact hVB _ nx hnx
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
