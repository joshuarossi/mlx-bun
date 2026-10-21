import host.sim.LoadSim
import host.sim.extract.Grow
namespace Host.Ts.Sim
open Host.Ts

/-! # Target-only facts along checked runs

A property `Q` of target native states that every native call and continuation
keeps (`TargetPres`) joins the native relation (`FRQ FR Q`): the dispatcher's
interface lemmas lift to it, so a checked run keeps it (`runOk_targetQ`). For the
load world, `Q := NGrow y0 ·.mlx` gives the growth of the target's mlx state along
any checked run (`runOk_ngrow`). -/

/-- The native relation with a property of the target state. -/
def FRQ {F : Ffi} (FR : Map → Nat → F.S → F.S → Prop) (Q : F.S → Prop) : Map → Nat → F.S → F.S → Prop :=
  fun M n x y => FR M n x y ∧ Q y

/-- A target property every native call and continuation keeps, from target states the
native relation relates. -/
structure TargetPres (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (Q : F.S → Prop) : Prop where
  call : ∀ M n x y name args C y' r ws C', FR M n x y → Q y →
    interpC (F.call y name args).run C = some (some (y', r, ws), C') → Q y'
  back : ∀ M n x y a C y' r ws C', FR M n x y → Q y →
    interpC (F.back y a).run C = some (some (y', r, ws), C') → Q y'

/-- The target run, added to a simulation's postcondition. -/
theorem MSim.withRunT {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {S : SSrv} {C : CSrv}
    {m : Host.Ts.M α} {m' : Host.Ts.M β} (h : MSim P S C m m') (hs : BufSim.Lawful m) (ht : BufSim.Lawful m') :
    MSim (fun M' S' C' a b => P M' S' C' a b ∧ interpC m'.run C = some (b, C')) S C m m' := by
  intro γ δ Q k k' hk r S2 hu
  rw [hs.1] at hu
  cases hrun : interpS m.run S with
  | none => rw [hrun] at hu; cases hu
  | some p =>
    obtain ⟨a, S1⟩ := p
    rw [hrun] at hu
    obtain ⟨M1, b, C1, hc, hp⟩ := MSim.run h a S1 hrun
    obtain ⟨M2, r', C2, hc', hq⟩ := hk M1 S1 C1 a b ⟨hp, hc⟩ r S2 hu
    exact ⟨M2, r', C2, by rw [ht.2, hc]; exact hc', hq⟩

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {Q : F.S → Prop}

theorem CallR.liftQ {M : Map} {n : Nat} {r r' : Option (F.S × Ret × List (Nat × Nat × List Byte))}
    (h : CallR FR M n r r') (hq : ∀ y' rr ws, r' = some (y', rr, ws) → Q y') : CallR (FRQ FR Q) M n r r' :=
  match r, r', h with
  | none, _, _ => trivial
  | some _, some (y', rr', ws'), ⟨h1, h2, h3⟩ => ⟨⟨h1, hq y' rr' ws' rfl⟩, h2, h3⟩
  | some _, none, h => h.elim

theorem FfiSim.liftQ {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall okBack) (hL : BufSim.FfiLawful F) (hQ : TargetPres F FR Q) :
    FfiSim F (FRQ FR Q) okCall okBack where
  call M ν S C x y name args hs hr hok hsupp :=
    MSim.mono (MSim.withRunT (hF.call M ν S C x y name args hs hr.1 hok hsupp) (hL.call _ _ _) (hL.call _ _ _))
      fun _ _ C' _ _ ⟨⟨hg, hc⟩, hrun⟩ => ⟨hg, hc.liftQ fun y' rr ws e => by
        subst e; exact hQ.call M _ x y name _ C y' rr ws C' hr.1 hr.2 hrun⟩
  back M ν S C x y a hs hr hok hsupp :=
    MSim.mono (MSim.withRunT (hF.back M ν S C x y a hs hr.1 hok hsupp) (hL.back _ _) (hL.back _ _))
      fun _ _ C' _ _ ⟨⟨hg, hc⟩, hrun⟩ => ⟨hg, hc.liftQ fun y' rr ws e => by
        subst e; exact hQ.back M _ x y _ C y' rr ws C' hr.1 hr.2 hrun⟩
  read M n x y r off k bs hr h := hF.read M n x y r off k bs hr.1 h

theorem FfiCallSim.liftQ {okCall : F.S → Name → List Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    (hC : FfiCallSim F FR okCall small) (hL : BufSim.FfiLawful F) (hQ : TargetPres F FR Q) :
    FfiCallSim F (FRQ FR Q) okCall small where
  call M ν S C x y name args hs hr hok hsupp hsm :=
    MSim.mono (MSim.withRunT (hC.call M ν S C x y name args hs hr.1 hok hsupp hsm) (hL.call _ _ _) (hL.call _ _ _))
      fun _ _ C' _ _ ⟨⟨hg, hc⟩, hrun⟩ => ⟨hg, hc.liftQ fun y' rr ws e => by
        subst e; exact hQ.call M _ x y name _ C y' rr ws C' hr.1 hr.2 hrun⟩

theorem FRLaws.liftQ (h : FRLaws FR) : FRLaws (FRQ FR Q) :=
  ⟨fun M M' n x y hr he => ⟨h.stable M M' n x y hr.1 he, hr.2⟩,
    fun M n n' x y hr hn => ⟨h.mono M n n' x y hr.1 hn, hr.2⟩⟩

theorem Disp.NativeFacts.liftQ {P : Disp.JSP F} (h : Disp.NativeFacts F FR P) : Disp.NativeFacts F (FRQ FR Q) P where
  zero M n x y hr := h.zero M n x y hr.1
  inj M n x y hr := h.inj M n x y hr.1
  region M n x y hr := h.region M n x y hr.1
  range M n x y hr := h.range M n x y hr.1
  host M n x y hr := h.host M n x y hr.1
  cb M n x y hr := h.cb M n x y hr.1

/-- `Disp.stepSimXV` for the native relation with a kept target property. -/
theorem Disp.stepSimXV_Q {P : Disp.JSP F} {okCall0 : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop} {VBOk : (Nat → F64) → Prop}
    (hF : FfiSim F FR okCall0 okBack) (hC : FfiCallSim F FR P.okCall small)
    (hsmall : ∀ ν S x name args, VBOk ν → P.smallB S x name args = true → small ν S x name args)
    (hFR : FRLaws FR) (hL : BufSim.FfiLawful F) (hN : Disp.NativeFacts F FR P) (hQ : TargetPres F FR Q) :
    Disp.StepSimXV F (FRQ FR Q) (Disp.okJS P) (Disp.Kp P) VBOk :=
  Disp.stepSimXV (hF.liftQ hL hQ) (hC.liftQ hL hQ) hsmall hFR.liftQ hL hN.liftQ

theorem Rel.withQ {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
    (h : Rel F FR M ν K s S t C) (hq : Q t.ffi) : Rel F (FRQ FR Q) M ν K s S t C :=
  { h with ffi := ⟨h.ffi, hq⟩ }

theorem RelX.q {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
    (h : RelX F (FRQ FR Q) M ν K s S t C) : Q t.ffi := by
  rcases h with h | ⟨_, _, _, _, _, _, _, _, h⟩
  · exact h.ffi.2
  · exact h.ffi.2

/-- **A kept target property holds at the end of every checked run.** -/
theorem runOk_targetQ {ok : St F.S → SSrv → Bool} {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}
    (hsim : Disp.StepSimXV F (FRQ FR Q) ok Kp VBOk) {ν : Nat → F64} {K : Ctx} (hK : Kp K) (hν : VBOk ν)
    {n : Nat} {M : Map} {s t s' t' : St F.S} {S S' : SSrv} {C C' : CSrv}
    (hr : Rel F FR M ν K s S t C) (hq : Q t.ffi) (hok : ok s S = true) (hrun : runOk F ok n s S = some (s', S'))
    (ht : runC F n t C = some (t', C')) : Q t'.ffi := by
  obtain ⟨_, t1, C1, ht1, _, hr1⟩ :=
    Disp.runOk_simXV F _ ok Kp VBOk hsim ν K hK hν n M s S t C s' S' (.inl (hr.withQ hq)) hok hrun
  rw [ht] at ht1
  cases ht1
  exact hr1.q

end

/-! ## The load world -/

/-- The target's mlx state grows from `y0` under every native call and continuation. -/
theorem loadTargetPres (P : LoadP) (y0 : Host.Mlx.Ffi.St) :
    TargetPres LF (LoadR P) (fun y : Host.Load.LSt => Host.Mlx.Ffi.NGrow y0 y.mlx) where
  call _ _ _ _ name args C y' rr ws C' hr hq hrun :=
    hq.trans (Host.Load.call_g (fun h hh => (hr.mlx.yabsent h hh).2) name args C _ C' hrun y' rr ws rfl).2
  back _ _ _ _ a C y' rr ws C' hr hq hrun :=
    hq.trans (Host.Load.back_g (fun h hh => (hr.mlx.yabsent h hh).2) a C _ C' hrun y' rr ws rfl).2

/-- `loadStepSim` with the growth of the target's mlx state from `y0`. -/
theorem loadStepSimQ (framed : List Nat) (r : List NumV) (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXV LF (FRQ (LR loadP0 r) fun y : Host.Load.LSt => Host.Mlx.Ffi.NGrow y0 y.mlx)
      (Disp.okJS (loadJSP framed)) (Disp.Kp (loadJSP framed)) LoopVBOk := by
  have hC : FfiCallSim LF (LR loadP0 r) (loadJSP framed).okCall smallLoad := by
    show FfiCallSim LF (LR loadP0 r) (okCallS loadP0) smallLoad
    rw [← okCallS_rest loadP0 r]
    exact loadFfiCallSim _
  exact Disp.stepSimXV_Q (loadFfiSim _) hC (fun _ _ _ _ _ hν hb => smallLoadB_sound hb hν) (loadR_laws _)
    loadFfiLawful (loadNativeFacts framed r) (loadTargetPres _ y0)

/-- **The target's mlx state grows along every checked run of the load world.** -/
theorem runOk_ngrow (framed : List Nat) (r : List NumV) {M : Map} {ν : Nat → F64} {K : Ctx} {n : Nat}
    {s t s1 t1 : St Host.Load.LSt} {S S1 : SSrv} {C C1 : CSrv}
    (hK : Disp.Kp (loadJSP framed) K) (hν : LoopVBOk ν) (hr : Rel LF (LR loadP0 r) M ν K s S t C)
    (hok : Disp.okJS (loadJSP framed) s S = true)
    (hrun : runOk LF (Disp.okJS (loadJSP framed)) n s S = some (s1, S1))
    (ht : runC LF n t C = some (t1, C1)) : Host.Mlx.Ffi.NGrow t.ffi.mlx t1.ffi.mlx :=
  runOk_targetQ (Q := fun y : Host.Load.LSt => Host.Mlx.Ffi.NGrow t.ffi.mlx y.mlx)
    (loadStepSimQ framed r t.ffi.mlx) hK hν hr (Host.Mlx.Ffi.NGrow.refl _) hok hrun ht

end Host.Ts.Sim
