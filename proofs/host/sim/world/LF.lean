import host.sim.world.Top
import host.sim.PrefillDecodeA
import host.sim.extract.Stats
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The load world as a world

`lfWorld`: the load world `LF` with its native relation `LR P r` (`LoadR`), the mlx state
`x.mlx`, the look-ahead token appended to the mlx tokens (`LoadR.addToken`), the native shift
`NShift`, the start facts of `LoopStartA` and the restart `load_restart_dropA`; its end laws
`lfWorld_end` (`load_restart_dropE`: the restart from the end relation alone).

Every existing definition of the composition layer is its world-generic counterpart at
`lfWorld`, definitionally (`finalStartW_lf`, `relW_lf`, `LoopInvW_lf`, `DecodeInvW_lf`,
`loopCutW_lf`, `LoopGStepW_lf`, `IterFW_lf`, `KeepsW_lf`, `ShiftFWW_lf`, `CutGStepW_lf`,
`LastGStepW_lf`, `DecodeIterW_lf`, `DecodeHaltW_lf`, `haltLawsW_lf`), and every existing structure
converts (`LoopStartA.toW`, `LoopCaseA.toW`, `AccSimW.toG`, `HaltSegA.toW`, `ExitCaseA.toW`,
`LoopCasesA.toW` with `LoopCasesA.Facts.toW`, `PrefP.toW`, `CutBook.toW`/`CutBookW.ofW`,
`LoadPost.toW`, `BCase.toW`, `BCase.Ok.toW`, `PrefInvs.toW`, `PrefSteps.toW`). The existing
theorems are instances: `book_step_ofW`, `prefill_reach_ofW`, `source_tokens_promptA_ofW`,
`decode_sourceLA_ofW` restate `book_step`, `prefill_reach`, `source_tokens_promptA`,
`decode_sourceLA` and prove them from the generic ones. -/

/-- The load world's start facts at the token reference `k` (`LoopStartA`'s native facts). -/
def lfStart (P : LoadP) (k : Nat) (s0 : St LF.S) : Prop :=
  s0.ffi.mlx.tokens = [.ref k] ∧ bigsOutB s0.ffi.mlx.next P.E s0.ffi.mlx = true ∧
    NoBigSt (fun i => (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E) s0.trace s0

/-- The look-ahead token reference `n` appended to the source's mlx tokens (`finalStart`). -/
def lfPush (x : LF.S) (n : Nat) : LF.S := { x with mlx := { x.mlx with tokens := x.mlx.tokens ++ [.ref n] } }

/-- **The load world.** -/
def lfWorld : World where
  F := LF
  Par := LoadP
  lo P := P.lo
  E P := P.E
  NE P := P.NE
  R P r := LR P r
  toMlx x := x.mlx
  laws _ _ := loadR_laws _
  pushTok := lfPush
  addToken h := LoadR.addToken h
  NSh P n0 σ x y := NShift P n0 σ x y
  Start := lfStart
  -- the 25 implicit arguments are bound positionally
  restart := fun k w _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ hst h hr0 hrc hext h1 hKD hKlo hKhi htab hor
      hshift hW hσ hk hband hx hE hD hroomH hroomN =>
    load_restart_dropA k w h hr0 hrc hext h1 hKD hKlo hKhi htab hor
      { hshift with ffi := ⟨hshift.ffi.1, hshift.ffi.2.withRest _⟩ } hW hσ hst.1 hk hst.2.1 hst.2.2 hband hx hE hD
      hroomH hroomN

/-- **`load_restart_dropA` from the end relation alone** (`World.EndLaws.restartE` at `lfWorld`):
the room at the end, the readback's value at the end's server, the band at the end's context. -/
theorem load_restart_dropE (k w : Nat) {P : LoadP} {r0 : List NumV} {M1 : Map} {ν : Nat → F64} {K1 : Ctx}
    {W0 W1 : Nat → Option WFrame} {kp : Nat → Bool} {s0 s1 t1 : St LF.S} {S0 S1 : SSrv} {C1 : CSrv}
    {σ : Map} {θ : Nat → SymE} {v : NumV} {r : List NumV} {x : F64}
    (hst : lfStart P k s0) (hr0 : r0 = v :: r) (h1 : RelF LF (LR P r0) W1 M1 ν K1 s1 S1 t1 C1)
    (htab : ∀ e ∈ S1.tab, e.noVar w = true) (hor : ∀ q ∈ S1.oracle, q.noVar w = true)
    (hshift : ShiftD LF (fun σ x y => x = s0.ffi ∧ NShift P S0.tab.length σ x y) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩)
    (hW : ∀ a w, W0 a = some w → W1 a = some w) (hσ : σ.num k = .ref S1.tab.length) (hk : k < S0.tab.length)
    (hband : ∀ i : Int, (s0.ffi.mlx.next : Int) ≤ i ∧ i < P.E → ¬ BigFixed K1.lo K1.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hx : C1.val v = some x) (hroom : t1.next - s0.next < Sim.bound)
    (hroomH : t1.ffi.mlx.next + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hroomN : t1.ffi.mlx.nnext + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62) :
    RelF LF (LR P r) W0 (((M1.setNum S1.tab.length v).after σ).rebig s0.ffi.mlx.next P.E t1.ffi.mlx.next)
      (Shift.valuation θ (upd ν w x))
      ⟨dropNext (M1.setNum S1.tab.length v) K1 kp W0 s1, s0.trace, t1.trace, t1.next - s0.next, K1.lo, K1.hi⟩
      s0 ⟨S0.tab, []⟩ t1 C1 := by
  subst hr0
  obtain ⟨htok, hbig, hfree⟩ := hst
  have hns : NShift { P with rest := v :: r } S0.tab.length σ s0.ffi s1.ffi := hshift.ffi.2.withRest _
  have htk : t1.ffi.mlx.tokens = v :: r := by
    have := h1.ffi.mlx.tokensX
    rw [hns.mlx.tokens] at this
    simpa using this
  have hw : LoadRw { P with rest := v :: r } (M1.setNum S1.tab.length v) (S1.tab.length + 1)
      (clearTokens s1.ffi) t1.ffi := by
    rw [clearTokens_nil hns.mlx.tokens]
    exact (((loadR_laws _).stable _ _ _ _ _ h1.ffi (Map.setNum_ext M1 S1.tab.length v)).mono
      (Nat.le_succ _)).weak
  have hf : FRr { P with rest := v :: r } s0.ffi (M1.setNum S1.tab.length v) (S1.tab.length + 1) s1.ffi t1.ffi :=
    ⟨hw, hroomH, hroomN⟩
  have h2 := (h1.extendVar' (loadR_laws _) htab hor hx).mapFR' (FR' := FRr { P with rest := v :: r } s0.ffi)
    (by simpa using hf)
  have hshift' : ShiftD LF (FSn { P with rest := v :: r } S0.tab.length s0.ffi) σ θ kp W0 K1 s0 S0 s1
      ⟨S1.tab ++ [.var w], S1.oracle⟩ := { hshift with ffi := ⟨hshift.ffi.1, hns⟩ }
  have hrel := restartDrop (F := LF) (FR := FRr { P with rest := v :: r } s0.ffi)
    (FS := FSn { P with rest := v :: r } S0.tab.length s0.ffi)
    (fun x y z hxy hyz => by simpa using fsn_compose _ x y z hxy (by simpa using hyz)) h2
    (hshift'.withOracle []) hW (fun _ hq => by cases hq) hroom
  have hw0 := hrel.ffi.1
  have hz : t1.ffi.mlx.tokens = s0.ffi.mlx.tokens.map ((M1.setNum S1.tab.length v).after σ).nv ++ r := by
    rw [htk, htok]
    simp only [List.map_cons, List.map_nil, List.cons_append, List.nil_append, Map.nv]
    show v :: r = (M1.setNum S1.tab.length v).nv (σ.num k) :: r
    rw [hσ]
    simp [Map.nv, Map.setNum_self]
  have hffi := LoadRw.rebig hw0 hbig (fun t ht => by rw [htok] at ht; simp at ht; subst ht; exact hk) hz
  rw [Map.rebig_eq] at hffi ⊢
  exact hrel.rebig (fun i hi => by simp [hi]) (fun i hi => hband i hi) hfree hffi

/-- **The load world's end laws.** -/
theorem lfWorld_end : lfWorld.EndLaws where
  restartE k w := load_restart_dropE k w
  bigFresh h k hk := h.mlx.hfreshB k hk
  nodeFresh h k := h.mlx.nfresh k

/-! ## Definitional agreement -/

section Defs
variable {A : Addr} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}

theorem finalStartW_lf (n : Nat) : lfWorld.finalStartW s0 n = finalStart s0 n := rfl

theorem relW_lf (W : Nat → Option WFrame) : relW lfWorld P W = relLW P W := rfl

theorem haltLawsW_lf : haltLawsW lfWorld A = haltLaws A := rfl

theorem elementsW_lf (s : St Host.Load.LSt) (v : Val) : elementsW s v = Host.Load.Extract.elements s v := by
  cases v <;> rfl

theorem ownW_lf (s : St Host.Load.LSt) (v : Val) (k : List Char) : ownW s v k = Host.Load.Extract.own s v k := by
  cases v <;> rfl

theorem LoopInvW_lf {Gx : Nat → Map → St LF.S → CSrv → Prop} {R : LoopR} {Fr : LoopFramesA A} {V : LoopVals}
    {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN i : Nat} {t : St LF.S} {C : CSrv} :
    LoopInvW lfWorld A Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C ↔
      LoopInvA A Gx R P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN i t C := Iff.rfl

theorem DecodeInvW_lf {Gx : Nat → Map → St LF.S → CSrv → Prop} {W : Nat → Option WFrame} {Fr : LoopFramesA A}
    {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat} :
    DecodeInvW lfWorld A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN =
      DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN := rfl

theorem loopCutW_lf {Gx : Nat → Map → St LF.S → CSrv → Prop} {W : Nat → Option WFrame} {Fr : LoopFramesA A}
    {V : LoopVals} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} :
    Prefill.loopCutW lfWorld A Gx W P Fr s0 tab0 fixA V tk toks E0 B =
      Prefill.loopCutA A Gx W P Fr s0 tab0 fixA V tk toks E0 B := rfl

theorem DecodeIterW_lf (Inv : CutInv) (i n : Nat) : DecodeIterW (F := LF) Inv i n ↔ DecodeIter Inv i n := Iff.rfl

theorem DecodeHaltW_lf (Inv : CutInv) (J n : Nat) (Goal : St LF.S → CSrv → Prop) :
    DecodeHaltW (F := LF) Inv J n Goal ↔ DecodeHalt Inv J n Goal := Iff.rfl

theorem EmitGoalW_lf (env : Env) (nm : Name) (E0 : List Val) (toks : List NumV) (m : Nat) (G : St LF.S → CSrv → Prop) :
    EmitGoalW env nm E0 toks m G = EmitGoal env nm E0 toks m G := by
  funext tF CF
  unfold EmitGoalW EmitGoal
  have e : (bindingOf tF env nm).bind (elementsW tF) = (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) := by
    cases bindingOf tF env nm with
    | none => rfl
    | some v => exact elementsW_lf tF v
  rw [e]

theorem statsFieldW_lf (s : St Host.Load.LSt) (env : Env) (key : List Char) :
    statsFieldW s env key = (bindingOf s env chars!"generation").bind fun g =>
      (Host.Load.Extract.own s g chars!"stats").bind fun w => Host.Load.Extract.own s w key := by
  unfold statsFieldW
  simp only [ownW_lf]
  rfl

theorem SeamGoalW_lf (t0 : St LF.S) (C0 : CSrv) (Goal : St LF.S → CSrv → Prop) :
    Prefill.SeamGoalW t0 C0 Goal ↔ Prefill.SeamGoal t0 C0 Goal := Iff.rfl

end Defs

/-! ## The decode loop's structures -/

section Loop
variable {A : Addr} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}

/-- Today's start facts as the world's. -/
theorem LoopStartA.toW (st : LoopStartA A P s0 tab0) : LoopStartW lfWorld A P s0 tab0 :=
  ⟨st.htok, ⟨st.tok, st.big, st.free⟩, st.lo, st.hi⟩

/-- The world's start facts at `lfWorld` are today's. -/
theorem LoopStartW.toA (st : LoopStartW lfWorld A P s0 tab0) : LoopStartA A P s0 tab0 :=
  ⟨st.start.1, st.htok, st.start.2.1, st.start.2.2, st.lo, st.hi⟩

/-- Today's loop cases as the world's single-run cases. -/
def LoopCaseA.toW {ok : St LF.S → SSrv → Bool} (c : LoopCaseA A ok P s0 tab0 fixA) :
    LoopRunW lfWorld A ok P s0 tab0 fixA where
  S0 := c.S0
  n := c.n
  s1 := c.s1
  S1 := c.S1
  σ := c.σ
  θ := c.θ
  grow := c.grow
  xs := c.xs
  tab := c.tab
  tlen := interpS_runOk_len c.run
  noVarTab := c.noVarTab
  noVarOr := c.noVarOr
  nshift := c.nshift
  num := c.num
  hE := c.hE
  theta := c.theta
  fwd := c.fwd
  emit := c.emit
  fix := c.fix
  ok0 := c.ok0
  run := c.run
  ctl := c.ctl

variable {ok : St LF.S → SSrv → Bool} (c : LoopCaseA A ok P s0 tab0 fixA)

theorem IterFW_lf (R : LoopR) (Fr : LoopFramesA A) (VBOk : (Nat → F64) → Prop) :
    c.toW.IterFW R Fr VBOk ↔ c.IterFA R Fr VBOk := Iff.rfl

theorem KeepsW_lf (Fr : LoopFramesA A) : c.toW.KeepsW Fr ↔ c.KeepsA Fr := Iff.rfl

theorem ShiftFWW_lf (Fr : LoopFramesA A) (W : Nat → Option WFrame) : c.toW.ShiftFWW Fr W ↔ c.ShiftFWA Fr W :=
  Iff.rfl

theorem WithinW_lf (ΔJ ΔH ΔN : Nat) : c.toW.Within ΔJ ΔH ΔN ↔ c.Within ΔJ ΔH ΔN := Iff.rfl

theorem LoopGStepW_lf (Gx : Nat → Map → St LF.S → CSrv → Prop) (R : LoopR) (Fr : LoopFramesA A) (V : LoopVals)
    (toks : List NumV) (i : Nat) : LoopGStepW Gx R Fr c.toW.toLoopCaseW V toks i ↔ LoopGStepA Gx R Fr c V toks i :=
  Iff.rfl

end Loop

/-- Today's acceptances under the frames as the world's. -/
def AccSimW.toG {P : LoadP} {W : Nat → Option WFrame} {VBOk : (Nat → F64) → Prop} {ok : St LF.S → SSrv → Bool}
    {framed : List Nat} (S : AccSimW P W VBOk ok framed) : AccSimG lfWorld P W VBOk ok framed :=
  ⟨S.jsP, S.hj, S.sim, S.simL, S.ng, S.ngL⟩

/-- Today's six cases, with the loop acceptance's simulation, as the world's segments. -/
noncomputable def LoopCasesA.toW {A : Addr} {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} {W : Nat → Option WFrame} {VBOk : (Nat → F64) → Prop} {framed : List Nat}
    (cs : LoopCasesA A ok P s0 tab0 fixA) (S : AccSimW P W VBOk ok framed) : LoopCasesW lfWorld A P W s0 tab0 fixA :=
  ⟨cs.ord.toW.toSeg S.toG, cs.clear.toW.toSeg S.toG, cs.grow.toW.toSeg S.toG, cs.fill.toW.toSeg S.toG,
    cs.clearFill.toW.toSeg S.toG, cs.clearGrow.toW.toSeg S.toG⟩

section Cases
variable {A : Addr} {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}
  {W : Nat → Option WFrame} {VBOk : (Nat → F64) → Prop} {framed : List Nat}

theorem loopSelLW_toW (cs : LoopCasesA A ok P s0 tab0 fixA) (S : AccSimW P W VBOk ok framed) (L i : Nat) :
    loopSelLW (cs.toW S) L i = (loopSelLA cs L i).toW.toSeg S.toG := by
  unfold loopSelLW loopSelLA
  by_cases h1 : i % 256 = 0 <;> by_cases h2 : (L + i + 1) % 256 = 0 <;> by_cases h3 : (L + i + 1) % 256 = 255 <;>
    simp [h1, h2, h3, LoopCasesA.toW]

/-- Today's six cases' template facts are the world's. -/
theorem LoopCasesA.Facts.toW {cs : LoopCasesA A ok P s0 tab0 fixA} {ΔJ ΔH ΔN : Nat} (h : cs.Facts ΔJ ΔH ΔN)
    (S : AccSimW P W VBOk ok framed) : (cs.toW S).Facts ΔJ ΔH ΔN :=
  ⟨goodLin_sub Lin.ordL_check h.cOrd, goodLin_sub Lin.clearL_check h.cClear, goodLin_sub Lin.growL_check h.cGrow,
    goodLin_sub Lin.fillL_check h.cFill, goodLin_sub Lin.clearFillL_check h.cClearFill,
    goodLin_sub Lin.clearGrowL_check h.cClearGrow, h.gOrd, h.gClear, h.gGrow, h.gFill, h.gClearFill, h.gClearGrow,
    h.dOrd, h.dClear, h.dGrow, h.dFill, h.dClearFill, h.dClearGrow⟩

/-- Today's facts at `L` are the world's. -/
theorem LoopCasesA.OkAt.toW {cs : LoopCasesA A ok P s0 tab0 fixA} {L ΔJ ΔH ΔN : Nat} (h : cs.OkAt L ΔJ ΔH ΔN)
    (S : AccSimW P W VBOk ok framed) : (cs.toW S).OkAt L ΔJ ΔH ΔN where
  grow i := by rw [loopSelLW_toW]; exact h.grow i
  good ρ T tk i nx h1 h2 h3 h4 h5 := by rw [loopSelLW_toW]; exact h.good ρ T tk i nx h1 h2 h3 h4 h5
  within i := by rw [loopSelLW_toW]; exact h.within i

end Cases

/-! ## The halts -/

section Halts
variable {A : Addr} {W : Nat → Option WFrame} {P : LoadP} {r : List NumV} {s0 st0 : St LF.S} {tab1 : List SymE}
  {xs : List Val}

/-- Today's halting chains as the world's. -/
def HaltSegA.toW (hs : HaltSegA A W P r s0 st0 tab1 xs) : HaltSegW lfWorld A W P r s0 st0 tab1 xs :=
  ⟨hs.S0, hs.tab, hs.QA, hs.case, hs.QF, hs.rend, hs.emitG, hs.cell⟩

theorem CutGStepW_lf {Gx : Nat → Map → St LF.S → CSrv → Prop} {Fr : LoopFramesA A} {fixA : List Nat}
    {tab0 : List SymE} {toks : List NumV} {i : Nat} (hs : HaltSegA A W P (toks.drop i) s0 s0 tab0 []) (V : LoopVals)
    (G : St LF.S → CSrv → Prop) : CutGStepW (Wd := lfWorld) A Gx P W Fr fixA hs.toW V G ↔ CutGStepA A Gx P W Fr fixA hs V G :=
  Iff.rfl

theorem LastGStepW_lf {Gx : Nat → Map → St LF.S → CSrv → Prop} {Fr : LoopFramesA A} {fixA : List Nat}
    {tab0 : List SymE} {toks : List NumV} {T : Nat}
    (hs : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt]) xs)
    (V : LoopVals) (tk : Nat → Nat) (G : St LF.S → CSrv → Prop) :
    LastGStepW (Wd := lfWorld) A Gx P W Fr fixA hs.toW V tk G ↔ LastGStepA A Gx P W Fr fixA hs V tk G := Iff.rfl

/-- Today's checked halting cases as the world's. -/
def ExitCaseA.toW {okA okB : St LF.S → SSrv → Bool} {aN : Nat} (ec : ExitCaseA A okA okB s0 st0 tab1 aN xs) :
    ExitCaseW lfWorld A okA okB s0 st0 tab1 aN xs :=
  ⟨ec.S0, ec.tab, ec.nA, ec.sP, ec.SP, ec.okA0, ec.runA, ec.okP, ec.haltP, ec.sA, ec.SA, ec.stepA, ec.acc, ec.env,
    ec.fs, ec.ctlA, ec.stackA, ec.roomA, ec.arrA, ec.newA, ec.sB, ec.SB, ec.stepB, ec.okB0, ec.nB, ec.sF, ec.SF,
    ec.runB, ec.halt, ec.emitG, ec.cell⟩

/-- **The finish reason of a load-world halting chain without frames**: its end relation is
`Rel`, so a `generation.stats` string the template's end reads is the target's (`own2_str_map`). -/
theorem HaltStopW.ofRel {hs : HaltSegW lfWorld A noFrames P r s0 st0 tab1 xs} {fixA : List Nat} {env : Env}
    (hgf : A.gen ∈ fixA) (hgen : lookupEnv chars!"generation" env = some A.gen)
    (hsrc : statsFieldW hs.case.sF env chars!"finishReason" = some (.str chars!"stop")) : HaltStopW hs fixA env := by
  intro x hx hfix
  have hfa := hfix _ hgf
  have h := (hs.rend x _ _ hx).1
  exact (statsFieldW_lf x.t env _).trans (ExtractSim.own2_str_map (FR := LR P r) h hgen hfa _ _ _
    ((statsFieldW_lf hs.case.sF env _).symm.trans hsrc))

end Halts

end Host.Ts.Sim

namespace Host.Ts.Sim.Prefill
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! ## The prefill's structures -/

/-- Today's prefill parameters as the world's. -/
def PrefP.toW (Q : PrefP) : PrefPW lfWorld := ⟨Q.P, Q.aP, Q.π, Q.fixA⟩

section Book
variable {Q : PrefP} {s0 : St LF.S} {frs : List Nat} {D H N : Nat} {x : SegInst LF}

theorem CutBook.toW (h : CutBook Q s0 frs D H N x) : CutBookW lfWorld Q.toW s0 frs D H N x :=
  ⟨h.prompt, h.framed, h.lo, h.hi, h.base, h.D, h.H, h.N, h.fix⟩

theorem CutBookW.ofW (h : CutBookW lfWorld Q.toW s0 frs D H N x) : CutBook Q s0 frs D H N x :=
  ⟨h.prompt, h.framed, h.lo, h.hi, h.base, h.D, h.H, h.N, h.fix⟩

theorem bookB_iff {ν : Nat → F64} {G : SegInst LF → Prop} :
    bookB Q s0 frs ν D H N G x ↔ bookBW lfWorld Q.toW s0 frs ν D H N G x :=
  ⟨fun ⟨hv, hb, hg⟩ => ⟨hv, hb.toW, hg⟩, fun ⟨hv, hb, hg⟩ => ⟨hv, hb.ofW, hg⟩⟩

theorem LoadPost.toW {sA sF sB : St LF.S} {aP : Nat} {frsB fixA : List Nat} {x1 x' : SegInst LF}
    (h : LoadPost sA sF sB aP frsB fixA x x1 x') : LoadPostW lfWorld sA sF sB aP frsB fixA x x1 x' :=
  ⟨h.off, h.grows, h.mgrows, h.ngrows, h.next, h.mnext, h.mnnext, h.t, h.D, h.lo, h.hi, h.base, h.prompt, h.framed,
    h.fix⟩

end Book

/-- Today's bookkept cases as the world's. -/
def BCase.toW {L : SegLaws LF} {A B : Cut LF} {Q : PrefP} {frsB : List Nat} (c : BCase L A B Q frsB) :
    BCaseW lfWorld L A B Q.toW frsB :=
  { c.toXCase with
    θ := c.θ
    post := fun x x1 x' h0 hP => ⟨(c.post x x1 x' h0 hP).1.toW, (c.post x x1 x' h0 hP).2⟩ }

section Ok
variable {L : SegLaws LF} {A B : Cut LF} {Q : PrefP} {frsA frsB : List Nat} {c : BCase L A B Q frsB}
  {νA νB : Nat → F64} {DA HA NA DB HB NB : Nat} {GA GB : SegInst LF → Prop}

/-- Today's case obligations as the world's. -/
theorem BCase.Ok.toW (h : c.Ok frsA νA νB DA HA NA DB HB NB GA GB) :
    c.toW.Ok frsA νA νB DA HA NA DB HB NB GA GB where
  entry x hv hb hg := h.entry x hv hb.ofW hg
  good := h.good
  val := h.val
  D := h.D
  H := h.H
  N := h.N
  graph x x1 x' hR hB h0 hst hend ht hC hR' hP := h.graph x x1 x' hR (bookB_iff.2 hB) h0 hst hend ht hC hR' hP

/-- **`book_step` is `book_stepW` at the load world.** -/
theorem book_step_ofW (h : c.Ok frsA νA νB DA HA NA DB HB NB GA GB) :
    CutStep (A.with (bookB Q A.s0 frsA νA DA HA NA GA)) (B.with (bookB Q B.s0 frsB νB DB HB NB GB)) c.n :=
  (book_stepW c.toW h.toW).congr rfl rfl (fun _ hb => bookB_iff.1 hb) (fun _ hb => bookB_iff.2 hb)

end Ok

/-- Today's prefill invariants as the world's. -/
def PrefInvs.toW (I : PrefInvs) : PrefInvsW LF := ⟨I.ld, I.pc0, I.pc, I.pf, I.ps, I.dec⟩

theorem PrefInvs.toW_pre (I : PrefInvs) (L : Nat) (s : PFSrc) : I.toW.pre L s = I.pre L s := by
  cases s <;> rfl

/-- Today's prefill steps as the world's. -/
def PrefSteps.toW {I : PrefInvs} (S : PrefSteps I) : PrefStepsW I.toW where
  nSetup := S.nSetup
  setup c L _ _ h := S.setup c L h
  nFirst := S.nFirst
  firstDrain C L _ _ h := S.firstDrain C L h
  firstTail X L _ _ h := S.firstTail X L h
  nDrain := S.nDrain
  drain d L j _ _ h := S.drain d L j h
  nTail := S.nTail
  tail c L _ _ h := S.tail c L h
  nFinal := S.nFinal
  final c L _ _ h := by rw [PrefInvs.toW_pre]; exact S.final c L h
  nPost := S.nPost
  post c L _ _ h := S.post c L h

theorem PrefSteps.toW_n {I : PrefInvs} (S : PrefSteps I) (L : Nat) : S.toW.n L = S.n L := rfl

/-- **`prefill_reach` is `prefill_reachW` at the load world.** -/
theorem prefill_reach_ofW {I : PrefInvs} (S : PrefSteps I) {L : Nat} (h1 : 1 ≤ L) (h2 : L ≤ 262143) :
    CutStep (I.ld L) (I.dec L) (S.n L) :=
  prefill_reachW S.toW h1 h2

/-- **`source_tokens_promptA` is `source_tokens_promptAW` at the load world.** -/
theorem source_tokens_promptA_ofW {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {W : Nat → Option WFrame}
    {P : LoadP} {Fr : LoopFramesA A} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat} {V : LoopVals} {T : Nat}
    {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {ΔJ ΔH ΔN : Nat}
    {Goal : St LF.S → CSrv → Prop} {I : PrefInvs} (S : PrefSteps I) {L : Nat} (hL1 : 1 ≤ L) (hL2 : L ≤ 262143)
    {N0 : Nat} {t0 tL : St LF.S} {C0 CL : CSrv} (hboot : runC LF N0 t0 C0 = some (tL, CL))
    (hld : (I.ld L).Inv tL CL) (hdec : I.dec L = loopCutA A Gx W P Fr s0 tab0 fixA V tk toks E0 B) (hT : 3 ≤ T)
    (hit : ∀ i, 1 ≤ i → i + 2 < T → ∃ n, DecodeIter (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) i n)
    (hfin : ∃ n, DecodeHalt (DecodeInvA A Gx W P Fr s0 tab0 fixA V tk toks E0 B ΔJ ΔH ΔN) (T - 2) n Goal) :
    SeamGoal t0 C0 Goal :=
  source_tokens_promptAW (Wd := lfWorld) S.toW hL1 hL2 hboot hld (hdec.trans loopCutW_lf.symm) hT hit hfin

end Host.Ts.Sim.Prefill

namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-- **`decode_sourceLA` is `decode_sourceLW` at the load world**: today's six single-run cases are
one-piece segments (`LoopCasesA.toW`), today's halting chains the world's. -/
theorem decode_sourceLA_ofW {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {ok : St LF.S → SSrv → Bool} {W : Nat → Option WFrame} {P : LoadP} {Fr : LoopFramesA A} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop} (hA : A.nxt = 17)
    (S : AccSimW P W VBOk ok (A.fwd :: A.emit :: Fr.xs)) (st : LoopStartA A P s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (cs : LoopCasesA A ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
    {env : Env} {nm : Name}
    (hsh : ∀ i, 1 ≤ i → i + 2 < T → (loopSelLA cs L i).ShiftFWA Fr W)
    (hkeep : ∀ i, 1 ≤ i → i + 2 < T → (loopSelLA cs L i).KeepsA Fr)
    (F0 F1 F2 : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok), .num (.ref tab0.length)])
    (c0 : F0.S0.oracle.all (fun q => (finalDG false false).contains q) = true)
    (c1 : F1.S0.oracle.all (fun q => (finalDG true false).contains q) = true)
    (c2 : F2.S0.oracle.all (fun q => (finalDG false true).contains q) = true)
    (hQA : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      F0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ F1.QA (valL ρ T tk L (T - 2) (tk T)) K ∧
        F2.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) (notEos : ∀ k, 2 ≤ k → k ≤ T → tk k ≠ 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 2 < T → LoopGStepA Gx (relLW P W) Fr (loopSelLA cs L i) (valL ρ T tk L) toks i)
    (hF : (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 → LastGStepA A Gx P W Fr fixA F0 (valL ρ T tk L) tk G)
    (hF0 : (T - 2) % 256 = 0 → LastGStepA A Gx P W Fr fixA F1 (valL ρ T tk L) tk G)
    (hF1 : (T - 1) % 256 = 0 → LastGStepA A Gx P W Fr fixA F2 (valL ρ T tk L) tk G)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvA A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (T - 1)).map Val.num) ∧
      CSrv.Le C1 CF ∧ G tF CF := by
  obtain ⟨N, tF, CF, hrun, hv, hle, hgoal⟩ := decode_sourceLW (Wd := lfWorld) hA st.toW hfrN hcE hb hwc hwe
    (fun i hi1 hiT => ⟨_, decodeIter_selLW hA st.toW (cs.toW S) (hcs.toW S) hi1 hiT hLT (by omega) htk
      (notEos (i + 1) (by omega) (by omega)) (by rw [loopSelLW_toW]; exact LoopRunW.toSeg_entry _ S.toG)
      (by rw [loopSelLW_toW]; exact hsh i hi1 hiT) (by rw [loopSelLW_toW]; exact hkeep i hi1 hiT)
      (fun nx hnx => hVB i nx hi1 (by omega) hnx) hJ hH hN (by rw [loopSelLW_toW]; exact hG i hi1 hiT)⟩)
    F0.toW F1.toW F2.toW (FinalOk.of_sub Lin.fin00_check c0) (FinalOk.of_sub Lin.fin10_check c1)
    (FinalOk.of_sub Lin.fin01_check c2) hQA henv hT hLT hlen htk notEos hF hF0 hF1 hpre h1
  have hg : EmitGoal env nm E0 toks (T - 1) G tF CF := by rw [← EmitGoalW_lf]; exact hgoal
  exact ⟨N, tF, CF, hrun, hv, hg.1, hle, hg.2⟩

/-- **`decode_source_eosLA` is `decode_source_eosLW` at the load world** (the chains' end fact
`True`). -/
theorem decode_source_eosLA_ofW {A : Addr} {Gx : Nat → Map → St LF.S → CSrv → Prop} {G : St LF.S → CSrv → Prop}
    {ok : St LF.S → SSrv → Bool} {W : Nat → Option WFrame} {P : LoadP} {Fr : LoopFramesA A} {s0 : St LF.S}
    {tab0 : List SymE} {fixA : List Nat} {VBOk : (Nat → F64) → Prop} (hA : A.nxt = 17)
    (S : AccSimW P W VBOk ok (A.fwd :: A.emit :: Fr.xs)) (st : LoopStartA A P s0 tab0)
    (hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true) (hcE : A.cE ∈ fixA) (hb : A.emit ∈ fixA)
    (hwc : W A.cE = none) (hwe : W A.emit = none)
    (cs : LoopCasesA A ok P s0 tab0 fixA) {L ΔJ ΔH ΔN : Nat} (hcs : cs.OkAt L ΔJ ΔH ΔN)
    {ρ : Nat → F64} {T : Nat} {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase}
    {env : Env} {nm : Name} (k : Nat) (hk2 : 2 ≤ k) (hkT : k ≤ T)
    (hsh : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T → (loopSelLA cs L i).ShiftFWA Fr W)
    (hkeep : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T → (loopSelLA cs L i).KeepsA Fr)
    (X : HaltSegA A W P (toks.drop (k - 1)) s0 s0 tab0 [])
    (cX : X.S0.oracle.all (fun q => eosD.contains q) = true)
    (FE0 FE1 : HaltSegA A W P (toks.drop (T - 1)) s0 (finalStart s0 tab0.length) (tab0 ++ [.var A.nxt])
      [.num (.ref A.tok)])
    (c0 : FE0.S0.oracle.all (fun q => (finalEDG false).contains q) = true)
    (c1 : FE1.S0.oracle.all (fun q => (finalEDG true).contains q) = true)
    (hQX : k < T → ∀ nx (K : Ctx), nx ≤ 2 ^ 20 → (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) →
      K.lo = P.lo → K.hi = P.E → X.QA (valL ρ T tk L (k - 1) nx) K)
    (hQE : ∀ K : Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Fr.xs) → K.lo = P.lo → K.hi = P.E →
      FE0.QA (valL ρ T tk L (T - 2) (tk T)) K ∧ FE1.QA (valL ρ T tk L (T - 2) (tk T)) K)
    (henv : lookupEnv nm env = some A.cE)
    (hT : 3 ≤ T) (hLT : L + T < 2 ^ 29) (hlen : T - 1 ≤ toks.length) (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20)
    (notEos : ∀ j, 2 ≤ j → j < k → tk j ≠ 248044) (eos : tk k = 248044)
    (hVB : ∀ i nx, 1 ≤ i → i + 2 ≤ T → nx ≤ 2 ^ 20 → VBOk (valL ρ T tk L i nx))
    (hJ : T * ΔJ + B.D < Sim.bound) (hH : s0.ffi.mlx.next + T * ΔH + B.H + (P.E - s0.ffi.mlx.next) < 2 ^ 46)
    (hN : s0.ffi.mlx.nnext + T * ΔN + B.N + (P.NE - s0.ffi.mlx.nnext) < 2 ^ 62)
    (hG : ∀ i, 1 ≤ i → i + 1 < k → i + 2 < T →
      LoopGStepA Gx (relLW P W) Fr (loopSelLA cs L i) (valL ρ T tk L) toks i)
    (hX : k < T → CutGStepA A Gx P W Fr fixA X (valL ρ T tk L) G)
    (hF : k = T → (T - 2) % 256 ≠ 0 → LastGStepA A Gx P W Fr fixA FE0 (valL ρ T tk L) tk G)
    (hF0 : k = T → (T - 2) % 256 = 0 → LastGStepA A Gx P W Fr fixA FE1 (valL ρ T tk L) tk G)
    {N0 : Nat} {t0 t1 : St LF.S} {C0 C1 : CSrv} (hpre : runC LF N0 t0 C0 = some (t1, C1))
    (h1 : DecodeInvA A Gx W P Fr s0 tab0 fixA (valL ρ T tk L) tk toks E0 B ΔJ ΔH ΔN 1 t1 C1) :
    ∃ N tF CF, (∀ n, N ≤ n → runC LF n t0 C0 = some (tF, CF)) ∧ (∃ v, tF.ctl = .halt (.normal v)) ∧
      (bindingOf tF env nm).bind (Host.Load.Extract.elements tF) = some (E0 ++ (toks.take (k - 2)).map Val.num) ∧
      CSrv.Le C1 CF ∧ G tF CF := by
  have htrue : ∀ {r : List NumV} {st0 : St LF.S} {tab1 : List SymE} {xs : List Val}
      (hs : HaltSegW lfWorld A W P r s0 st0 tab1 xs), HaltFinW hs fixA (fun _ => True) := fun _ _ _ _ => trivial
  obtain ⟨N, tF, CF, hrun, hv, hle, ⟨hgoal, -⟩⟩ := decode_source_eosLW (Wd := lfWorld) (Fin := fun _ => True) hA
    st.toW hfrN hcE hb hwc hwe k hk2 hkT
    (fun i hi1 hik hiT => ⟨_, decodeIter_selLW hA st.toW (cs.toW S) (hcs.toW S) hi1 hiT hLT (by omega) htk
      (notEos (i + 1) (by omega) (by omega)) (by rw [loopSelLW_toW]; exact LoopRunW.toSeg_entry _ S.toG)
      (by rw [loopSelLW_toW]; exact hsh i hi1 hik hiT) (by rw [loopSelLW_toW]; exact hkeep i hi1 hik hiT)
      (fun nx hnx => hVB i nx hi1 (by omega) hnx) hJ hH hN (by rw [loopSelLW_toW]; exact hG i hi1 hik hiT)⟩)
    X.toW (ExitOk.of_sub cX) FE0.toW FE1.toW (FinalEOk.of_sub Lin.finE0_check c0) (FinalEOk.of_sub Lin.finE1_check c1)
    hQX hQE (fun _ => htrue _) (fun _ => htrue _) (fun _ => htrue _) henv hT hLT hlen htk notEos eos hX hF hF0 hpre h1
  have hg : EmitGoal env nm E0 toks (k - 2) G tF CF := by rw [← EmitGoalW_lf]; exact hgoal
  exact ⟨N, tF, CF, hrun, hv, hg.1, hle, hg.2⟩

end Host.Ts.Sim
