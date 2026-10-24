import host.load.nat.Lift
namespace Host.Load.Boot
open Host.Ts Host.Ts.Sim BufSim Host.Mlx Host.Load Host.Load.Layers Host.Load.LayerLift Host.Ts.FfiNat

/-! # The boot in the observer world

The boot runs in the load world (`Host.Load.ffi`). `W` is the load world with one observer
(`obs`) that keeps what `Layers.full` keeps beside the load world's state, read from the load
world's state before each call:

* the bridge's program creates, in a log (`BLog`: the create's number, its arguments and its
  share, as `aneBridge` computes them); the bridge is the log's replay (`replay`), so a run of
  `W` records each create without computing the bridge;
* the released handles (`liveCall`, `liveBack`) and the kernel record (`kernCall`), each verdict
  recorded (`none` from the first call the layer rejects).

* `w_proj_runS`: a run of `W` is a run of the load world (the observer dropped);
* `w_full_runS`: a run of `W` is a run of `full` from the same machine state with the native
  state `toFull` (the load world's state with the log's bridge, the liveness and kernel-recording
  states); the final states agree in the same way. -/

/-- The bridge's program creates, newest first: number, arguments, share. -/
abbrev BLog : Type := List (Nat × List Arg × Option Nat)

/-- The observer's state: the creates, the released handles, the kernel record. -/
abbrev OSt : Type := BLog × Option (PTrie Unit) × Option KRec

/-- The bridge of a log of creates. -/
def replay : BLog → FfiAne.St
  | [] => FfiAne.St.empty
  | (n, args, share) :: r => FfiAne.create (replay r) n args share

theorem replay_active : ∀ log : BLog, (replay log).active = false
  | [] => rfl
  | (n, args, share) :: r => by
    show (FfiAne.create (replay r) n args share).active = false
    rw [create_active]; exact replay_active r

/-- The share a create names (`aneBridge`'s). -/
def shareOf (l : LSt) (args : List Arg) : Option Nat :=
  match args with
  | [_, _, _, _, _, _, _, _, sh, _, _, _] => Ane.handleN l.host sh
  | _ => none

/-- The log after a call or trace continuation `a` from `l`. -/
def logStep (log : BLog) (l : LSt) : Act → BLog
  | .call name args => bif !isMlx name && nameEq name chars!"mbane_program_create" then
      (l.host.ane, args, shareOf l args) :: log
    else log
  | .back _ => log

theorem shareOf_eq (l : LSt) (args : List Arg) :
    (match args with
      | [_, _, _, _, _, _, _, _, sh, _, _, _] => Ane.handleN l.host sh
      | _ => none) = shareOf l args := by
  unfold shareOf
  split <;> rfl

/-- The log's replay follows the bridge. -/
theorem replay_logStep (log : BLog) (t : LayerLift.Step LSt) :
    replay (logStep log t.pre t.act) = aneBridge (replay log) t := by
  obtain ⟨l, a, _, _, _, _, _⟩ := t
  cases a with
  | back _ => rfl
  | call name args =>
    show replay (bif !isMlx name && nameEq name chars!"mbane_program_create" then
        (l.host.ane, args, shareOf l args) :: log else log) =
      (bif !isMlx name && nameEq name chars!"mbane_program_create" then
        FfiAne.create (replay log) l.host.ane args (match args with
          | [_, _, _, _, _, _, _, _, sh, _, _, _] => Ane.handleN l.host sh
          | _ => none) else replay log)
    rw [shareOf_eq]
    cases (!isMlx name && nameEq name chars!"mbane_program_create") <;> rfl

/-- The observer's update for a call or trace continuation `a` returning `r` from `l`: the log, the
liveness and kernel-recording layers' updates. -/
def obsUpd (w : OSt) (l : LSt) (a : Act) (r : Ret) : OSt :=
  (logStep w.1 l a,
    w.2.1.bind fun e => Observer.upd live e ⟨⟨l, FfiAne.St.empty⟩, a, ⟨l, FfiAne.St.empty⟩, r, [], .conc ⟨[]⟩, .conc ⟨[]⟩⟩,
    w.2.2.bind fun k => Observer.upd kern k ⟨(⟨l, FfiAne.St.empty⟩, w.2.1), a, (⟨l, FfiAne.St.empty⟩, w.2.1), r, [],
      .conc ⟨[]⟩, .conc ⟨[]⟩⟩)

def obs : Layers.Observer Host.Load.ffi :=
  ⟨OSt, fun w l _ name args r => some (obsUpd w l (.call name args) r), fun w l _ a r => some (obsUpd w l (.back a) r)⟩

/-- The load world with the observer. -/
abbrev W : Ffi := obs.ffi

/-- A load-world machine state with observer state `w`. -/
def obsSt (s : St LSt) (w : OSt) : St W.S := s.reFfi (s.ffi, w)

/-- The full world's native state of an observed load-world state. -/
def toFull (q : W.S) : full.S := ((⟨q.1, replay q.2.1⟩, q.2.2.1), q.2.2.2)

theorem wLawful : FfiLawful W := Observer.lawful obs loadFfiLawful

/-! ## Projection -/

theorem w_proj_runS (n : Nat) (s : St LSt) (w : OSt) (S : SSrv) (t : St LSt) (w' : OSt) (S' : SSrv)
    (h : runS W n (obsSt s w) S = some (obsSt t w', S')) : runS Host.Load.ffi n s S = some (t, S') :=
  proj_runS obs loadFfiLawful n (obsSt s w) S (obsSt t w') S' h

/-! ## The full world -/

/-- A load-world step without bridge calls or surface wraps, from an inactive bridge, in the full world:
the layers' states after it are the bridge's and the observers' updates. -/
theorem full_step_of (t : LayerLift.Step LSt) (b : FfiAne.St) (e : Option (PTrie Unit)) (k : Option KRec)
    (hb : b.active = false) (hf : aneFree t.act = true) (ht : t.ok Host.Load.ffi) :
    Step.ok full ⟨((⟨t.pre, b⟩, e), k), t.act, ((⟨t.post, aneBridge b t⟩, e.bind fun e => Observer.upd live e
        ⟨⟨t.pre, b⟩, t.act, ⟨t.post, aneBridge b t⟩, t.ret, t.ws, t.srv, t.srv'⟩),
      k.bind fun k => Observer.upd kern k ⟨(⟨t.pre, b⟩, e), t.act, (⟨t.post, aneBridge b t⟩, e.bind fun e =>
        Observer.upd live e ⟨⟨t.pre, b⟩, t.act, ⟨t.post, aneBridge b t⟩, t.ret, t.ws, t.srv, t.srv'⟩), t.ret, t.ws,
        t.srv, t.srv'⟩), t.ret, t.ws, t.srv, t.srv'⟩ := by
  have h1 := ane_step hb hf ht
  have h2 := sym_step h1
  have h3 := Observer.step_ok live.total symLawful (e := e) h2 (total_upd live _ _)
  exact Observer.step_ok kern.total (Observer.lawful live.total symLawful) (e := k) h3 (total_upd kern _ _)

/-- A step of `W` is a step of `full` between the `toFull` states. -/
theorem w_step {l l' : LSt} {w w' : OSt} {a : Act} {r : Ret} {ws : Writes} {X X' : Srv}
    (ht : Step.ok W ⟨(l, w), a, (l', w'), r, ws, X, X'⟩) :
    Step.ok full ⟨toFull (l, w), a, toFull (l', w'), r, ws, X, X'⟩ := by
  obtain ⟨hs, hu⟩ := Observer.step_proj obs loadFfiLawful ht
  have hs' : Step.ok Host.Load.ffi ⟨l, a, l', r, ws, X, X'⟩ := hs
  have hf : aneFree a = true := by
    cases a with
    | back _ => rfl
    | call name args =>
      cases hfa : aneFree (.call name args)
      · have e := load_stuck l name args hfa
        have hs2 : interp (Host.Load.call l name args).run X = some (some (l', r, ws), X') := hs'
        rw [e] at hs2
        rw [show (M.pure none : M (Res LSt)).run = Free.pure none from rfl, interp_pure] at hs2
        cases hs2
      · rfl
  have hw : w' = obsUpd w l a r := by
    cases a <;> exact (Option.some.inj hu).symm
  subst hw
  have hr : replay (logStep w.1 l a) = aneBridge (replay w.1) ⟨l, a, l', r, ws, X, X'⟩ :=
    replay_logStep w.1 ⟨l, a, l', r, ws, X, X'⟩
  show Step.ok full ⟨((⟨l, replay w.1⟩, w.2.1), w.2.2), a, ((⟨l', replay (logStep w.1 l a)⟩, (obsUpd w l a r).2.1),
    (obsUpd w l a r).2.2), r, ws, X, X'⟩
  rw [hr]
  exact full_step_of ⟨l, a, l', r, ws, X, X'⟩ (replay w.1) w.2.1 w.2.2 (replay_active w.1) hf hs'

/-- `W`'s and `full`'s native states: `toFull`. -/
def WR (q : W.S) (p : full.S) : Prop := p = toFull q

@[reducible] def wRel : FfiRel W full := ⟨WR⟩

attribute [local instance] wRel

theorem crel_w {r : Ret} {ws : Writes} {q : W.S} {p : full.S} (h : WR q p) :
    @CRel.r (Option (W.S × Ret × Writes)) (Option (full.S × Ret × Writes))
      (@CRel.option _ _ (@CRel.prod _ _ _ _ (@CRel.ffi _ _ wRel) CRel.eq)) (some (q, r, ws)) (some (p, r, ws)) := by
  show WR q p ∧ (r, ws) = (r, ws)
  exact ⟨h, rfl⟩

theorem w_act {q : W.S} {a : Act} {o : W.S × Ret × Writes} {X X' : Srv}
    (h : interp (runAct W q a).run X = some (some o, X')) :
    interp (runAct full (toFull q) a).run X = some (some (toFull o.1, o.2.1, o.2.2), X') := by
  obtain ⟨⟨l', w'⟩, r, ws⟩ := o
  obtain ⟨l, w⟩ := q
  exact w_step (a := a) (r := r) (ws := ws) (X := X) (X' := X') h

theorem wSim : FfiSim W full where
  read := fun q p hp => by
    have hp' : p = toFull q := hp
    subst hp'; rfl
  addr := rfl
  call := fun q p name args hp => by
    have hp' : p = toFull q := hp
    subst hp'
    refine callSim_of (wLawful.call _ _ _)
      ((Observer.lawful kern.total (Observer.lawful live.total symLawful)).call _ _ _) ?_ ?_
    · intro S o S' h
      exact ⟨(toFull o.1, o.2.1, o.2.2), interp_sym.mp (w_act (a := .call name args) (interp_sym.mpr h)), crel_w rfl⟩
    · intro C o C' h
      exact ⟨(toFull o.1, o.2.1, o.2.2), interp_conc.mp (w_act (a := .call name args) (interp_conc.mpr h)), crel_w rfl⟩
  back := fun q p a hp => by
    have hp' : p = toFull q := hp
    subst hp'
    refine callSim_of (wLawful.back _ _)
      ((Observer.lawful kern.total (Observer.lawful live.total symLawful)).back _ _) ?_ ?_
    · intro S o S' h
      exact ⟨(toFull o.1, o.2.1, o.2.2), interp_sym.mp (w_act (a := .back a) (interp_sym.mpr h)), crel_w rfl⟩
    · intro C o C' h
      exact ⟨(toFull o.1, o.2.1, o.2.2), interp_conc.mp (w_act (a := .back a) (interp_conc.mpr h)), crel_w rfl⟩

/-- **`W` in the full world.** A run of `W` is a run of `full` from the same machine state with native
state `toFull`, ending in the same machine state with native state `toFull` of the final one. -/
theorem w_full_runS (n : Nat) (s : St W.S) (S : SSrv) (t : St W.S) (S' : SSrv) (h : runS W n s S = some (t, S')) :
    runS full n (s.reFfi (toFull s.ffi)) S = some (t.reFfi (toFull t.ffi), S') := by
  obtain ⟨y, h1, h2⟩ := @runS_sim W full wRel wSim n s (toFull s.ffi) rfl S t S' h
  have h2' : y = toFull t.ffi := h2
  subst h2'
  exact h1

end Host.Load.Boot
