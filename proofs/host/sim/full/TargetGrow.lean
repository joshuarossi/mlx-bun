import host.sim.full.BackSim
import host.sim.extract.GrowRun
import host.sim.Loop
import host.sim.Seg

/-! # The target's mlx growth along checked runs of the full world

Every native call and continuation of the full world grows the mlx state (`NGrow`) from a state whose
object slots from the handle counter on are empty (`NInv`): the load world's (`Host.Load.call_g`), the
Neural Engine bridge's (a surface wrap adds a node and an array, the bridge's own calls keep the mlx
state), the symbolic-shape layer's (`symShapeCall_g`) and the model's continuation; the observers do
not touch it (`fullCall_g`, `fullBack_g`). A native relation whose targets have `NInv` keeps the
target's growth from any start (`fullTargetPres`), the full world's one-step simulation lifts to it
(`fullStepSimXLBQ`), and along a glue piece of a route chain (a checked run, and the step into the
next call) the target's mlx state grows (`full_glue_ngrow`, `full_glueCall_ngrow`): the full world's
`runOk_ngrow`. -/

namespace Host.Mlx.Ffi.NGrowCall
open Host.Ts

theorem opOutSym_g {s₀ s : St} (h : Good s₀ s) (o : Arg) (p : Prim) (ins : List Nat) :
    AllC (Res s₀) (SymShape.opOutSym s o p ins) := by
  unfold SymShape.opOutSym
  repeat' (first
    | with_reducible refine AllC.bind' (Host.Load.LayerLift.inferSym_l _ _) fun _ => ?_
    | grow_base)

/-- The symbolic-shape layer grows the mlx state. -/
theorem symShapeCall_g {s : St} (hi : NInv s) (name : Name) (args : List Arg) :
    AllC (Res s) (SymShape.symShapeCall s name args) := by
  unfold SymShape.symShapeCall
  split
  · split
    · refine AllC.cond _ (AllC.bind' (Host.Ts.Sim.NativeLawful.dProd_l _) fun d => ?_) AllC_stuck
      cases d <;> exact AllC_ok (Good.refl hi)
    · exact AllC_stuck
  · split
    · exact opOutSym_g (Good.refl hi) _ _ _
    · exact AllC_stuck
  · split
    · exact opOutSym_g (Good.refl hi) _ _ _
    · exact AllC_stuck
  · exact AllC_stuck

/-- A surface wrap adds a node and an array. -/
theorem wrap_g {s : St} (hi : NInv s) (b : FfiAne.St) (args : List Arg) :
    ∀ s' b' r, FfiAne.wrap b s args = some (s', b', r) → Good s s' := by
  intro s' b' r
  unfold FfiAne.wrap
  split
  · split
    · split
      · rw [Bool.cond_eq_ite]
        split
        · split
          rename_i node s1 h1
          split
          rename_i hh s2 h2
          intro e
          simp only [Option.some.injEq, Prod.mk.injEq] at e
          obtain ⟨rfl, -, -⟩ := e
          rw [pair_eq_snd h2, pair_eq_snd h1]
          exact ((Good.refl hi).addNode _).setArr _ _
        · intro e; cases e
      · intro e; cases e
    · intro e; cases e
  · intro e; cases e

/-- The bridge's continuation grows the mlx state. -/
theorem aneBack_g {s : St} (hi : NInv s) (b : FfiAne.St) (a : Arg) :
    AllC (fun o => ∀ m b' r ws, o = some (m, b', r, ws) → Good s m) (FfiAne.back b s a) := by
  unfold FfiAne.back
  refine AllC.bind (Host.Ts.Sim.NativeLawful.traceBack_l _ _) (back_g hi a) fun o ho => ?_
  rcases o with _ | ⟨s', r, ws⟩
  · exact AllC.pure fun _ _ _ _ e => by cases e
  · refine AllC.pure fun m b' r' ws' e => ?_
    have hg : Good s s' := ho _ rfl
    cases hb : b.active
    · rw [hb, Bool.cond_false] at e; cases e; exact hg
    · rw [hb, Bool.cond_true] at e
      cases hc : FfiAne.classify b s' (s'.nnext - s.nnext) s.nnext with
      | none => rw [hc] at e; cases e
      | some b'' => rw [hc] at e; cases e; exact hg

/-- The bridge's mlx calls grow the mlx state. -/
theorem mlxCall_g {s : St} (hi : NInv s) (b : FfiAne.St) (name : Name) (args : List Arg) :
    AllC (fun o => ∀ m b' r ws, o = some (m, b', r, ws) → Good s m) (FfiAne.mlxCall b s name args) := by
  unfold FfiAne.mlxCall
  refine AllC.cond _ (AllC.pure fun m b' r ws e => ?_) ?_
  · cases hw : FfiAne.wrap b s args with
    | none => rw [hw] at e; cases e
    | some q =>
      obtain ⟨s', b'', r'⟩ := q
      rw [hw] at e
      cases e
      exact wrap_g hi b args _ _ _ hw
  · refine AllC.bind (Host.Ts.Sim.NativeLawful.mlx_call_l _ _ _) (call_g hi name args) fun o ho => ?_
    rcases o with _ | ⟨s', r, ws⟩
    · exact AllC.pure fun _ _ _ _ e => by cases e
    · refine AllC.pure fun m b' r' ws' e => ?_
      have hg : Good s s' := ho _ rfl
      cases hb : b.active
      · rw [hb, Bool.cond_false] at e; cases e; exact hg
      · rw [hb, Bool.cond_true] at e
        cases ha : FfiAne.after b s s' name args with
        | none => rw [ha] at e; cases e
        | some b'' => rw [ha] at e; cases e; exact hg

end Host.Mlx.Ffi.NGrowCall

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.NGrowCall (NInv AllC)
open Host.Ts.Sim.BufSim (Lawful)

/-- Results whose mlx state (read by `f`) grew from `s`. -/
def GRes {β : Type} (s : Host.Mlx.Ffi.St) (f : β → Host.Mlx.Ffi.St) :
    Option (β × Ret × List (Nat × Nat × List Byte)) → Prop :=
  fun o => ∀ b r ws, o = some (b, r, ws) → Host.Mlx.Ffi.NGrowCall.Good s (f b)

/-- The Neural Engine world's calls grow the mlx state. -/
theorem aneCall_g {a : Host.Load.Ane.ASt} (hi : NInv a.base.mlx) (name : Name) (args : List Arg) :
    AllC (GRes a.base.mlx fun a' : Host.Load.Ane.ASt => a'.base.mlx) (Host.Load.Ane.call a name args) := by
  have hon : ∀ (h : Arg) (f : Nat → Option (Host.Mlx.FfiAne.St × Ret)),
      AllC (GRes a.base.mlx fun a' : Host.Load.Ane.ASt => a'.base.mlx) (Host.Load.Ane.onHandle a h f) := by
    intro h f
    unfold Host.Load.Ane.onHandle
    split
    · split
      · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e; exact Host.Mlx.Ffi.NGrowCall.Good.refl hi
      · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e
    · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e
  have hload : ∀ f : Option (Host.Load.LSt × Ret × List (Nat × Nat × List Byte)) →
        Host.Ts.M (Option (Host.Load.Ane.ASt × Ret × List (Nat × Nat × List Byte))),
      (∀ o, (∀ l r ws, o = some (l, r, ws) → Host.Mlx.Ffi.NGrowCall.Good a.base.mlx l.mlx) →
        AllC (GRes a.base.mlx fun a' : Host.Load.Ane.ASt => a'.base.mlx) (f o)) →
      AllC (GRes a.base.mlx fun a' : Host.Load.Ane.ASt => a'.base.mlx) (Host.Ts.M.bind (Host.Load.call a.base name args) f) :=
    fun f hf => Host.Mlx.Ffi.NGrowCall.AllC.bind (loadFfiLawful.call _ _ _) (Host.Load.call_g hi name args) hf
  unfold Host.Load.Ane.call
  refine Host.Mlx.Ffi.NGrowCall.AllC.cond _ ?_ (Host.Mlx.Ffi.NGrowCall.AllC.cond _ ?_ ?_)
  · refine Host.Mlx.Ffi.NGrowCall.AllC.bind (Host.Load.LayerLift.mlxCall_l _ _ _ _)
      (Host.Mlx.Ffi.NGrowCall.mlxCall_g hi _ name args) fun o ho => ?_
    rcases o with _ | ⟨m, b, r, ws⟩
    · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e
    · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e; exact ho _ _ _ _ rfl
  · refine hload _ fun o ho => ?_
    rcases o with _ | ⟨l, r, ws⟩
    · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e
    · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e; exact ho _ _ _ rfl
  · repeat' (first
      | exact hon _ _
      | exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e
      | (unfold Host.Load.Ane.baseCall
         refine hload _ fun o ho => ?_
         rcases o with _ | ⟨l, r, ws⟩
         · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e
         · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e; exact ho _ _ _ rfl)
      | refine Host.Mlx.Ffi.NGrowCall.AllC.cond _ ?_ ?_
      | split)

/-- The symbolic-shape world's calls grow the mlx state. -/
theorem symCall_g {a : Host.Load.Ane.ASt} (hi : NInv a.base.mlx) (name : Name) (args : List Arg) :
    AllC (GRes a.base.mlx fun a' : Host.Load.Ane.ASt => a'.base.mlx) (symCall a name args) := by
  unfold symCall
  refine Host.Mlx.Ffi.NGrowCall.AllC.bind (Host.Load.LayerLift.aneLawful.call _ _ _) (aneCall_g hi name args)
    fun o ho => ?_
  rcases o with _ | r
  · refine Host.Mlx.Ffi.NGrowCall.AllC.cond _ ?_ (Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e)
    refine Host.Mlx.Ffi.NGrowCall.AllC.bind (Host.Load.LayerLift.symShapeCall_l _ _ _)
      (Host.Mlx.Ffi.NGrowCall.symShapeCall_g hi name args) fun o ho' => ?_
    rcases o with _ | ⟨m, r, ws⟩
    · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e
    · refine Host.Mlx.Ffi.NGrowCall.AllC.pure fun a' r' ws' e => ?_
      have hg : Host.Mlx.Ffi.NGrowCall.Good a.base.mlx m := ho' _ rfl
      cases hb : a.bridge.active
      · rw [hb, Bool.cond_false] at e; cases e; exact hg
      · rw [hb, Bool.cond_true] at e
        cases ha : Host.Mlx.FfiAne.after a.bridge a.base.mlx m name args with
        | none => rw [ha] at e; cases e
        | some b => rw [ha] at e; cases e; exact hg
  · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun a' r' ws' e => by cases e; exact ho _ _ _ rfl

/-- **The full world's calls grow the mlx state.** -/
theorem fullCall_g {p : FF.S} (hi : NInv (mlxOf p)) (name : Name) (args : List Arg) :
    AllC (GRes (mlxOf p) mlxOf) (FF.call p name args) := by
  rw [full_call_eq]
  refine Host.Mlx.Ffi.NGrowCall.AllC.bind (Host.Load.LayerLift.symLawful.call _ _ _) (symCall_g hi name args)
    fun o ho => ?_
  rcases o with _ | ⟨a', r, ws⟩
  · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by rw [liftF_none] at e; cases e
  · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by rw [liftF_some] at e; cases e; exact ho _ _ _ rfl

/-- **The full world's continuations grow the mlx state.** -/
theorem fullBack_g {p : FF.S} (hi : NInv (mlxOf p)) (a : Arg) : AllC (GRes (mlxOf p) mlxOf) (FF.back p a) := by
  have e : FF.back p a = Host.Ts.M.bind (Host.Load.Ane.back p.1.1 a) fun o => .pure (liftB p a o) := by
    funext γ k
    rw [Observer.back_eq kern.total, Observer.back_eq live.total]
    rfl
  rw [e]
  have hb : AllC (GRes (mlxOf p) fun a' : Host.Load.Ane.ASt => a'.base.mlx) (Host.Load.Ane.back p.1.1 a) := by
    unfold Host.Load.Ane.back
    refine Host.Mlx.Ffi.NGrowCall.AllC.bind (Host.Load.LayerLift.aneBack_l _ _ _)
      (Host.Mlx.Ffi.NGrowCall.aneBack_g hi _ a) fun o ho => ?_
    rcases o with _ | ⟨m, b, r, ws⟩
    · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e
    · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e; exact ho _ _ _ _ rfl
  refine Host.Mlx.Ffi.NGrowCall.AllC.bind (Host.Load.LayerLift.aneLawful.back _ _) hb fun o ho => ?_
  rcases o with _ | ⟨a', r, ws⟩
  · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by cases e
  · exact Host.Mlx.Ffi.NGrowCall.AllC.pure fun _ _ _ e => by rw [liftB_some] at e; cases e; exact ho _ _ _ rfl

/-- **The target's growth is kept** by every native call and continuation, from targets the native
relation gives empty object slots from the counter on. -/
theorem fullTargetPres {FR : Map → Nat → FF.S → FF.S → Prop} (hinv : ∀ M n x y, FR M n x y → NInv (mlxOf y))
    (y0 : Host.Mlx.Ffi.St) : TargetPres FF FR (fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) where
  call M n x y name args C y' r ws C' hr hq hrun :=
    hq.trans (fullCall_g (hinv M n x y hr) name args C _ C' hrun y' r ws rfl).2
  back M n x y a C y' r ws C' hr hq hrun :=
    hq.trans (fullBack_g (hinv M n x y hr) a C _ C' hrun y' r ws rfl).2

theorem fullR_ninv {P : LoadP} {NB : Nat} : ∀ M n x y, FullR P NB M n x y → NInv (mlxOf y) :=
  fun _ _ _ _ hr h hh => (hr.load.mlx.yabsent h hh).2

theorem fullRD_ninv {P : LoadP} {NB : Nat} : ∀ M n x y, FullRD P NB M n x y → NInv (mlxOf y) := by
  rintro M n x y ⟨P', -, hr⟩
  exact fullR_ninv M n x y hr

/-! ## Along checked runs -/

/-- `fullStepSimXLB` with the target's growth from `y0`. -/
theorem fullStepSimXLBQ (P : LoadP) (NB : Nat) (VB : Nat → Nat) (J : Disp.JSP FF) (hJ : J.okCall = okCallFS P)
    (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo) (hh : J.isHandle = fullIsHandle)
    (hg : J.isRegion = fullIsRegion) {W : Nat → Option WFrame} (stk : List Frame) (hW : Disp.Wp J W)
    (y0 : Host.Mlx.Ffi.St) :
    Disp.StepSimXLB FF (FRQ (FullR P NB) fun y => Host.Mlx.Ffi.NGrow y0 (mlxOf y)) (Disp.okJS J) (Disp.Kp J) W stk
      (VBOkF VB) := by
  have hC : FfiCallSim FF (FullR P NB) J.okCall smallFS := by rw [hJ]; exact fullCallSimS P NB
  have hQ := fullTargetPres (FR := FullR P NB) fullR_ninv y0
  exact Disp.stepSimXLB ((fullFfiSim P NB).liftQ fullLawful hQ) (hC.liftQ fullLawful hQ)
    (fun _ _ _ _ _ hν hb => smallFSB_sound hν (by rw [hsm] at hb; exact hb))
    (fullR_laws bridgeI_stable P NB).liftQ fullLawful (fullNativeFacts P NB J hlo hh hg).liftQ hW

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {Q : F.S → Prop} {W : Nat → Option WFrame}
  {stk : List Frame}

theorem relB_withQ {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
    (h : RelB F FR W stk M ν K s S t C) (hq : Q t.ffi) : RelB F (FRQ FR Q) W stk M ν K s S t C :=
  { h with ffi := ⟨h.ffi, hq⟩ }

theorem relXB_q {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
    (h : RelXB F (FRQ FR Q) W stk M ν K s S t C) : Q t.ffi := by
  rcases h with h | ⟨_, _, _, _, _, _, _, _, h⟩
  · exact h.ffi.2
  · exact h.ffi.2

end

section
variable {P : LoadP} {NB : Nat} {VB : Nat → Nat} {J : Disp.JSP FF} {W : Nat → Option WFrame}

/-- **The target's mlx state grows along a glue segment** (a checked run of `n` steps). -/
theorem full_glue_ngrow (hJ : J.okCall = okCallFS P) (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo)
    (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion) (hW : Disp.Wp J W) {sa sb : St FF.S}
    {Sa Sb : SSrv} {n : Nat} (hok : Disp.okJS J sa Sa = true) (hrun : runOk FF (Disp.okJS J) n sa Sa = some (sb, Sb))
    {M : Map} {ν : Nat → F64} {K : Ctx} {t t' : St FF.S} {C C' : CSrv} (hν : VBOkF VB ν) (hK : Disp.Kp J K)
    (hr : RelB FF (FullR P NB) W [] M ν K sa Sa t C) (ht : runC FF n t C = some (t', C')) :
    Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi) := by
  have hsim := fullStepSimXLBQ P NB VB J hJ hsm hlo hh hg [] hW (mlxOf t.ffi)
  obtain ⟨M1, t1, C1, hr1, -, hx1⟩ := Disp.runOk_simXVB FF _ _ (Disp.Kp J) W [] (VBOkF VB) hsim.xv
    (fun _ _ _ => .inl rfl) ν K hK hν n M sa Sa t C sb Sb (.inl (relB_withQ hr (Host.Mlx.Ffi.NGrow.refl _))) hok hrun
  rw [ht] at hr1
  cases hr1
  exact relXB_q hx1

/-- **The target's mlx state grows along a glue segment and the step into the next call.** -/
theorem full_glueCall_ngrow (hJ : J.okCall = okCallFS P) (hsm : J.smallB = smallFSB VB) (hlo : J.lo = P.lo)
    (hh : J.isHandle = fullIsHandle) (hg : J.isRegion = fullIsRegion) (hW : Disp.Wp J W) {sa sb sc : St FF.S}
    {Sa Sb Sc : SSrv} {n : Nat} (hok : Disp.okJS J sa Sa = true)
    (hrun : runOk FF (Disp.okJS J) n sa Sa = some (sb, Sb)) (hokb : Disp.okJS J sb Sb = true)
    (hhalt : isHalt sb.ctl = false) (hstep : interpS (step FF sb).run Sb = some (sc, Sc))
    {M : Map} {ν : Nat → F64} {K : Ctx} {t t' : St FF.S} {C C' : CSrv} (hν : VBOkF VB ν) (hK : Disp.Kp J K)
    (hr : RelB FF (FullR P NB) W [] M ν K sa Sa t C) (ht : runC FF (n + 1) t C = some (t', C')) :
    Host.Mlx.Ffi.NGrow (mlxOf t.ffi) (mlxOf t'.ffi) := by
  have hsim := fullStepSimXLBQ P NB VB J hJ hsm hlo hh hg [] hW (mlxOf t.ffi)
  obtain ⟨M1, t1, C1, hr1, -, hx1⟩ := Disp.runOk_simXVB FF _ _ (Disp.Kp J) W [] (VBOkF VB) hsim.xv
    (fun _ _ _ => .inl rfl) ν K hK hν n M sa Sa t C sb Sb (.inl (relB_withQ hr (Host.Mlx.Ffi.NGrow.refl _))) hok hrun
  obtain ⟨M2, t2, C2, ht2, -, hx2⟩ := hsim M1 ν K sb Sb t1 C1 sc Sc hK hν hx1 hhalt (.inl rfl) hokb hstep
  have hth : isHalt t1.ctl = false := by rw [hx1.isHalt, hhalt]
  rw [runC_trans hr1 (runC_one hth ht2)] at ht
  cases ht
  exact relXB_q hx2

end

end Host.Ts.Sim.Full
