import host.sim.LoopFrames
import host.sim.RestartDrop
import host.sim.FinalExtract
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Template

/-! # The loop under frames beyond framed arrays

The decode loop's interface (`LoopFrames.lean`) for the relation family with further frames `W`
(ghost slots: `RelF`, `Rel.lean`):

* `relRelF`: the family `relLW P W` is a `LoopRel` (`relLW P noFrames` is `relL P`);
* `LoopCase.ShiftFW`: the case's shift under the frames, the template fact `ShiftJS` at the loop's
  context without the frames' addresses (`Ctx.unW`) and, at each frame, the shift fixing the
  address and the frame's data (`WFix`); without frames it is `ShiftF` (`shiftFW_free`);
* `LoopCase.iterF_relF`: the case's iteration theorem `LoopCase.IterF` for `relLW P W`, from the
  checked runs under the frames (`Disp.stepSimXVW`) and the restart keeping every frame
  (`load_restart_drop`, `dropNext_keep`).

For halting cases: the boundary relations `relQW`, `relXQW` (`relQ`, `relXQ` under `W`,
definitionally at `noFrames`), the checked pieces under the frames (`PieceSim.ofRunOkW`,
`ofRunOkRelW`, `ofLastW`, `xOfRelW`, `relOfXW`) and the emitted tokens' readout
(`RelF.emitted`): `FinalSeg`/`ExitCase` over `relQW` give `DecodeHalt` as over `relQ`. -/

/-- The load world's relation family under the frames `W`. -/
abbrev relLW (P : LoadP) (W : Nat → Option WFrame) : LoopR := fun r => RelF LF (LR P r) W

theorem relLW_free (P : LoadP) : relLW P noFrames = relL P := rfl

theorem relRelF (P : LoadP) (W : Nat → Option WFrame) : LoopRel (relLW P W) where
  num h := h.srv.num
  swap h hS hs := h.srvSwap hS hs
  offset h := h.offset

section Case
variable {ok : St LF.S → SSrv → Bool} {P : LoadP} {s0 : St LF.S} {tab0 : List SymE} {fixA : List Nat}

/-- **The case's shift under the frames `Fr` and `W`**: `ShiftJS` for every loop context without
the addresses of `W`; at each frame of `W` (an address of `Fr`) the shift fixes the address and
the frame's data, the address present at the start. -/
def LoopCase.ShiftFW (c : LoopCase ok P s0 tab0 fixA) (Fr : LoopFrames) (W : Nat → Option WFrame) : Prop :=
  (∀ (p1 p2 : List Val) (K : Ctx), K.fr = frX s0 Fr.X p1 p2 → K.lo = P.lo → K.hi = P.E →
    ShiftJS LF c.σ c.θ (K.unW W) s0 c.S0 c.s1 ⟨c.S1.tab ++ [.var 17], c.S1.oracle⟩) ∧
  ∀ a w, W a = some w → a ∈ Fr.xs ∧ c.σ.a a = a ∧ Present s0 a ∧ WFix c.σ (Present s0) w

/-- Without frames beyond framed arrays `ShiftFW` is `ShiftF`. -/
theorem LoopCase.shiftFW_free (c : LoopCase ok P s0 tab0 fixA) {Fr : LoopFrames} (h : c.ShiftF Fr) :
    c.ShiftFW Fr noFrames :=
  ⟨fun p1 p2 K hfr hlo hhi => h p1 p2 K hfr hlo hhi, fun _ _ hw => nomatch hw⟩

/-- **The load world's iteration under the frames `W`** (`LoopCase.iterF_rel` for `RelF`): with the
case's shift under the frames and an acceptance framing exactly `forwarded`, `emitted` and `Fr`
whose one-step theorem holds under `W`. -/
theorem LoopCase.iterF_relF {jsP : Disp.JSP LF} {VBOk : (Nat → F64) → Prop} (Fr : LoopFrames)
    (W : Nat → Option WFrame) (hsim : ∀ r, Disp.StepSimXVW LF (LR P r) ok (Disp.Kp jsP) W VBOk)
    (hjlo : jsP.lo = P.lo) (hjhi : jsP.hi = P.E) (hjfr : ∀ a, a ∈ jsP.framed ↔ a ∈ 2673447 :: 12502 :: Fr.xs)
    (hng : ∀ (r : List NumV) (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St LF.S) (S S1 : SSrv)
      (C C1 : CSrv), Disp.Kp jsP K → VBOk ν → RelF LF (LR P r) W M ν K s S t C → ok s S = true →
      runOk LF ok n s S = some (s1, S1) → runC LF n t C = some (t1, C1) → Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx)
    (st : LoopStart P s0 tab0) (c : LoopCase ok P s0 tab0 fixA) (hsh : c.ShiftFW Fr W) :
    c.IterF (relLW P W) Fr VBOk := by
  intro r v M ν K t C x p1 p2 hν hfr hlo hhi h hx hD hroomH hroomN
  have hK : Disp.Kp jsP K := ⟨hlo.trans hjlo.symm, hhi.trans hjhi.symm, fun a => by
    rw [hjfr, hfr]; exact frX_ne_none s0 Fr p1 p2 a⟩
  obtain ⟨M1, t1, C1, hrc, he, hx1⟩ := Disp.runOk_simXVW LF (LR P (v :: r)) ok (Disp.Kp jsP) W VBOk
    (hsim (v :: r)) ν K hK hν c.n M s0 c.S0 t C c.s1 c.S1 (Or.inl h) c.ok0 c.run
  have h1 := hx1.rel c.ctl
  have hshift := ShiftD.ofJS (K1 := K) (FS := FSn { P with rest := v :: r } c.S0.tab.length s0.ffi)
    (hsh.1 p1 p2 K hfr hlo hhi) ⟨rfl, by rw [c.tab]; exact c.nshift.withRest _⟩
    (fun a w hw => by
      obtain ⟨hxs, hfix, hp, hwf⟩ := hsh.2 a w hw
      refine ⟨?_, hfix, hp, hwf⟩
      rw [hfr]
      exact (frX_ne_none s0 Fr p1 p2 a).2 (List.mem_cons_of_mem _ (List.mem_cons_of_mem _ hxs)))
    (fun _ _ => rfl) (fun _ ha hn => absurd hn ha) rfl rfl
  have hband : ∀ j : Int, (s0.ffi.mlx.next : Int) ≤ j ∧ j < P.E → ¬ BigFixed K.lo K.hi j ∧ 0 ≤ j ∧ j < 2 ^ 56 := by
    intro j hj
    have := st.lo; have := st.hi
    rw [hlo, hhi]
    refine ⟨fun hf => ?_, by omega, by omega⟩
    unfold BigFixed at hf
    omega
  obtain ⟨hoff, hH1, hN1, hrel⟩ := load_restart_drop h rfl hrc he h1 rfl rfl rfl c.noVarTab c.noVarOr hshift
    (fun _ _ hw => hw) c.num79 st.tok (by rw [c.tab]; exact st.h79) st.big st.free hband hx c.hE hD hroomH hroomN
  rw [dropNext_keep h1, c.tab] at hrel
  exact ⟨M1, t1, C1, hrc, he, hoff, hH1, hN1, hrel, h1, hng _ _ _ _ _ _ _ _ _ _ _ _ _ hK hν h c.ok0 c.run hrc⟩

end Case

/-! ## Halting cases under the frames -/

section
variable {F : Ffi}

/-- `relQ` under the frames `W`. -/
def relQW (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame)
    (Q : (Nat → F64) → Ctx → Prop) : SRel F :=
  fun x s S => RelF F FR W x.M x.ν x.K s S x.t x.C ∧ Q x.ν x.K

/-- `relXQ` under the frames `W`. -/
def relXQW (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame)
    (Q : (Nat → F64) → Ctx → Prop) : SRel F :=
  fun x s S => RelXF F FR W x.M x.ν x.K s S x.t x.C ∧ Q x.ν x.K

theorem relQW_free (FR : Map → Nat → F.S → F.S → Prop) (Q : (Nat → F64) → Ctx → Prop) :
    relQW F FR noFrames Q = relQ F FR Q := rfl

theorem relXQW_free (FR : Map → Nat → F.S → F.S → Prop) (Q : (Nat → F64) → Ctx → Prop) :
    relXQW F FR noFrames Q = relXQ F FR Q := rfl

/-- `RunTR` under the frames. -/
def RunTRW (L : SegLaws F) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame)
    (ok : St F.S → SSrv → Bool) (Q : (Nat → F64) → Ctx → Prop) : Prop :=
  ∀ (M : Map) (ν : Nat → F64) (K : Ctx) (n : Nat) (s t s1 t1 : St F.S) (S S1 : SSrv) (C C1 : CSrv), Q ν K →
    RelF F FR W M ν K s S t C → ok s S = true → runOk F ok n s S = some (s1, S1) → runC F n t C = some (t1, C1) →
    L.TR t t1

/-- `StepTR` under the frames. -/
def StepTRW (L : SegLaws F) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame)
    (ok : St F.S → SSrv → Bool) (Q : (Nat → F64) → Ctx → Prop) : Prop :=
  ∀ (M : Map) (ν : Nat → F64) (K : Ctx) (s t s1 t1 : St F.S) (S S1 : SSrv) (C C1 : CSrv), Q ν K →
    RelXF F FR W M ν K s S t C → isHalt s.ctl = false → ok s S = true → interpS (step F s).run S = some (s1, S1) →
    interpC (step F t).run C = some (t1, C1) → L.TR t t1

/-- `RelX.rel_frame` under the frames. -/
theorem RelXF.rel_frame {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {M : Map} {ν : Nat → F64}
    {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} (h : RelXF F FR W M ν K s S t C)
    (hs : ∀ r env fs, s.stack ≠ .s (.block r env) :: fs) : RelF F FR W M ν K s S t C := by
  rcases h with h | ⟨_, _, r, env, fs, _, _, hst, _⟩
  · exact h
  · exact absurd hst (hs r env fs)

end

section Pieces
variable {F : Ffi} {L : SegLaws F} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
  {Q : (Nat → F64) → Ctx → Prop} {ok : St F.S → SSrv → Bool} {Kp : Ctx → Prop} {VB : (Nat → F64) → Prop}
  {n : Nat} {s s' : St F.S} {S S' : SSrv}

/-- **A checked segment** under the frames (`PieceSim.ofRunOk`). -/
theorem PieceSim.ofRunOkW (hsim : Disp.StepSimXVW F FR ok Kp W VB) (hQ : ∀ ν K, Q ν K → Kp K ∧ VB ν)
    (htr : RunTRW L FR W ok Q) (hok : ok s S = true) (hrun : runOk F ok n s S = some (s', S')) :
    PieceSim L (relQW F FR W Q) (relXQW F FR W Q) n s S s' S' := by
  rintro ⟨M, ν, K, t, C⟩ ⟨h, hq⟩
  obtain ⟨hK, hν⟩ := hQ ν K hq
  obtain ⟨M', t', C', hr, he, hx⟩ :=
    Disp.runOk_simXVW F FR ok Kp W VB hsim ν K hK hν n M s S t C s' S' (Or.inl h) hok hrun
  exact ⟨⟨M', ν, K, t', C'⟩, ⟨hr, rfl, he, L.krefl K, htr M ν K n s t s' t' S S' C C' hq h hok hrun hr⟩, hx, hq⟩

/-- **A checked segment** under the frames ending at a state that does not return a value. -/
theorem PieceSim.ofRunOkRelW (hsim : Disp.StepSimXVW F FR ok Kp W VB) (hQ : ∀ ν K, Q ν K → Kp K ∧ VB ν)
    (htr : RunTRW L FR W ok Q) (hok : ok s S = true) (hrun : runOk F ok n s S = some (s', S'))
    (hctl : ∀ v, s'.ctl ≠ .ret v) : PieceSim L (relQW F FR W Q) (relQW F FR W Q) n s S s' S' := by
  intro x hx
  obtain ⟨x', hst, hx', hq⟩ := PieceSim.ofRunOkW hsim hQ htr hok hrun x hx
  exact ⟨x', hst, hx'.rel hctl, hq⟩

/-- **The last step of a segment** under the frames (`PieceSim.ofLast`). -/
theorem PieceSim.ofLastW (hsim : Disp.StepSimXLW F FR ok Kp W VB) (hQ : ∀ ν K, Q ν K → Kp K ∧ VB ν)
    (htr : StepTRW L FR W ok Q) (hok : ok s S = true) (hh : isHalt s.ctl = false)
    (hs : interpS (step F s).run S = some (s', S')) :
    PieceSim L (relXQW F FR W Q) (relXQW F FR W Q) 1 s S s' S' := by
  rintro ⟨M, ν, K, t, C⟩ ⟨h, hq⟩
  obtain ⟨hK, hν⟩ := hQ ν K hq
  obtain ⟨M', t1, C1, ht, he, hx⟩ := hsim M ν K s S t C s' S' hK hν h hh hok hs
  have hth : isHalt t.ctl = false := by rw [h.isHalt, hh]
  exact ⟨⟨M', ν, K, t1, C1⟩, ⟨runC_one hth ht, rfl, he, L.krefl K, htr M ν K s t s' t1 S S' C C1 hq h hh hok hs ht⟩,
    hx, hq⟩

/-- `RelF` is `RelXF`. -/
theorem PieceSim.xOfRelW : PieceSim L (relQW F FR W Q) (relXQW F FR W Q) 0 s S s S :=
  PieceSim.imp fun _ hx => ⟨Or.inl hx.1, hx.2⟩

/-- At a state whose top frame is not a statement list, `RelXF` is `RelF`. -/
theorem PieceSim.relOfXW (hs : ∀ r env fs, s.stack ≠ .s (.block r env) :: fs) :
    PieceSim L (relXQW F FR W Q) (relQW F FR W Q) 0 s S s S :=
  PieceSim.imp fun _ hx => ⟨hx.1.rel_frame hs, hx.2⟩

end Pieces

/-- **The emitted tokens under the frames** (`Rel.emitted`): the binding's cell and the framed
array carry no frame of `W`. -/
theorem RelF.emitted {FR : Map → Nat → Host.Load.LSt → Host.Load.LSt → Prop} {W : Nat → Option WFrame} {M : Map}
    {ν : Nat → F64} {K : Ctx} {s t : St Host.Load.LSt} {S : SSrv} {C : CSrv}
    (h : RelF Host.Load.ffi FR W M ν K s S t C)
    {env : Env} {n : Name} {cE b : Nat} {pre pre' xs : List Val} {o : Obj}
    (hl : lookupEnv n env = some cE) (hc : s.cell? cE = some (some (.obj b)))
    (hfa : M.a cE = cE) (hfb : M.a b = b) (hk : K.fr b = some (pre, pre'))
    (hg : s.heap.get b = some (.obj o)) (hkind : o.kind = .array (pre ++ xs))
    (hwc : W cE = none) (hwb : W b = none) :
    (bindingOf t env n).bind (Host.Load.Extract.elements t) = some (pre' ++ M.vals xs) := by
  have hc' : t.cell? cE = some (some (.obj b)) := by
    have := h.cell? hc (.inl hwc)
    rw [hfa] at this
    exact this.trans (by show some (some (Val.obj (M.a b))) = _; rw [hfb])
  obtain ⟨o', ho', ys, hys, rfl⟩ := h.obj?_framed (obj?_iff.2 hg) hk hwb
  rw [hkind] at hys
  have hxy : ys = xs := (List.append_cancel_left (Kind.array.inj hys)).symm
  subst hxy
  rw [hfb] at ho'
  unfold bindingOf
  rw [hl, Option.bind_some, hc']
  show Host.Load.Extract.elements t (.obj b) = _
  simp [Host.Load.Extract.elements, Host.Load.Extract.object]
  erw [ho']
  rfl

end Host.Ts.Sim
