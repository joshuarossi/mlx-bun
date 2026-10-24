import host.load.Layers
import host.sim.native.Lawful
namespace Host.Load.LayerLift
open Host.Ts Host.Mlx Host.Ts.Sim BufSim Host.Load.Layers

/-! # Lifting load-world executions to the layer stack

An FFI execution is a list of native steps (`Step`): a call or a trace
continuation, the world state before and after, the return and writes, and the
number server (symbolic or concrete) before and after the step's requests.
`Exec F x ts y`: the steps chain from `x` to `y` and each is what `F` computes.

`full_lift`: an execution of the load world (`Host.Load.ffi`) that makes no
Neural Engine bridge call other than `mbane_program_create` and no surface
wrap (`aneFree`) is an execution of the full stack (`Layers.full`) from
`start` with an inactive bridge, with the same calls, returns, writes and
servers, and the same load-world state at every step (`Step.map toLoad`);
the layers' verdicts are the liveness and kernel-recording folds (`liveFold`,
`kernFold`: no double or wrong-kind free, every launch recorded in order).
Each layer gives a lemma of its own: `ane_exec`, `sym_exec` (agreement where
the world below is defined), `Observer.exec_lift` and its converse
`Observer.exec_proj` (an observed execution is one of the world below that
the observer accepts). Machine runs: `FfiNat.Lift`. -/

/-! ## Servers -/

inductive Srv where
  | sym (S : SSrv)
  | conc (C : CSrv)

def interp {α : Type} (t : Free α) : Srv → Option (α × Srv)
  | .sym S => (interpS t S).map fun p => (p.1, .sym p.2)
  | .conc C => (interpC t C).map fun p => (p.1, .conc p.2)

theorem interp_pure {α : Type} (a : α) (X : Srv) : interp (.pure a) X = some (a, X) := by cases X <;> rfl

theorem interp_lawful {α γ : Type} {m : M α} (h : Lawful m) (k : α → Free γ) (X : Srv) :
    interp (m γ k) X = (interp m.run X).bind fun p => interp (k p.1) p.2 := by
  cases X with
  | sym S =>
    simp only [interp]
    rw [h.1 γ k S]
    cases interpS m.run S <;> rfl
  | conc C =>
    simp only [interp]
    rw [h.2 γ k C]
    cases interpC m.run C <;> rfl

theorem interp_bind_pure {α β : Type} {m : M α} (hm : Lawful m) {g : α → M β} {X X' : Srv} {a : α} {b : β}
    (h : interp m.run X = some (a, X')) (hg : ∀ γ (k : β → Free γ), g a γ k = k b) :
    interp (M.bind m g).run X = some (b, X') := by
  show interp (m β fun a => g a β Free.pure) X = _
  rw [interp_lawful hm, h, Option.bind_some, hg, interp_pure]

theorem interp_bind_inv {α β : Type} {m : M α} (hm : Lawful m) {g : α → M β} {X X' : Srv} {b : β}
    (h : interp (M.bind m g).run X = some (b, X')) :
    ∃ a X1, interp m.run X = some (a, X1) ∧ interp (g a).run X1 = some (b, X') := by
  have h' : interp (m β fun a => g a β Free.pure) X = some (b, X') := h
  rw [interp_lawful hm] at h'
  cases hr : interp m.run X with
  | none => rw [hr] at h'; cases h'
  | some p => rw [hr, Option.bind_some] at h'; exact ⟨p.1, p.2, rfl, h'⟩

/-! ## Executions -/

inductive Act where
  | call (name : Name) (args : List Arg)
  | back (a : Arg)

def runAct (F : Ffi) (x : F.S) : Act → M (Res F.S)
  | .call name args => F.call x name args
  | .back a => F.back x a

structure Step (S : Type) where
  pre : S
  act : Act
  post : S
  ret : Ret
  ws : List (Nat × Nat × List Byte)
  srv : Srv
  srv' : Srv

def Step.map {S T : Type} (f : S → T) (t : Step S) : Step T :=
  ⟨f t.pre, t.act, f t.post, t.ret, t.ws, t.srv, t.srv'⟩

/-- What `F` computes for the step. -/
def Step.ok (F : Ffi) (t : Step F.S) : Prop :=
  interp (runAct F t.pre t.act).run t.srv = some (some (t.post, t.ret, t.ws), t.srv')

/-- Steps of `F` chaining from `x` to `y`. -/
def Exec (F : Ffi) : F.S → List (Step F.S) → F.S → Prop
  | x, [], y => x = y
  | x, t :: ts, y => t.pre = x ∧ t.ok F ∧ Exec F t.post ts y

/-! ## Observers -/

namespace Observer
open Layers.Observer
variable {F : Ffi} (O : Layers.Observer F)

/-- The observer's update for a step of the world below. -/
def upd (e : O.E) (t : Step F.S) : Option O.E :=
  match t.act with
  | .call name args => O.onCall e t.pre t.post name args t.ret
  | .back a => O.onBack e t.pre t.post a t.ret

def fold : O.E → List (Step F.S) → Option O.E
  | e, [] => some e
  | e, t :: ts => (upd O e t).bind fun e' => fold e' ts

/-- The steps with the observer's states (up to the first step it rejects). -/
def lift : O.E → List (Step F.S) → List (Step (F.S × O.E))
  | _, [] => []
  | e, t :: ts => match upd O e t with
    | some e' => ⟨(t.pre, e), t.act, (t.post, e'), t.ret, t.ws, t.srv, t.srv'⟩ :: lift e' ts
    | none => []

theorem fold_cons (e : O.E) (t : Step F.S) (ts : List (Step F.S)) :
    fold O e (t :: ts) = (upd O e t).bind fun e' => fold O e' ts := rfl

theorem lift_cons {e e' : O.E} {t : Step F.S} (ts : List (Step F.S)) (h : upd O e t = some e') :
    lift O e (t :: ts) = ⟨(t.pre, e), t.act, (t.post, e'), t.ret, t.ws, t.srv, t.srv'⟩ :: lift O e' ts := by
  simp only [lift, h]

theorem lawful (hF : FfiLawful F) : FfiLawful O.ffi where
  call := fun p name args => by
    show Lawful (Layers.Observer.call O p name args)
    unfold Layers.Observer.call
    exact Lawful.bind (hF.call _ _ _) fun _ => Lawful.pure _
  back := fun p a => by
    show Lawful (Layers.Observer.back O p a)
    unfold Layers.Observer.back
    exact Lawful.bind (hF.back _ _) fun _ => Lawful.pure _

theorem step_ok (hF : FfiLawful F) {t : Step F.S} {e e' : O.E} (ht : t.ok F) (hu : upd O e t = some e') :
    Step.ok O.ffi ⟨(t.pre, e), t.act, (t.post, e'), t.ret, t.ws, t.srv, t.srv'⟩ := by
  obtain ⟨pre, a, post, r, ws, X, X'⟩ := t
  cases a with
  | call name args =>
    have ht' : interp (F.call pre name args).run X = some (some (post, r, ws), X') := ht
    exact interp_bind_pure (hF.call pre name args) ht' fun γ k => by
      show k (O.post _ (some (post, r, ws))) = _
      simp only [Layers.Observer.post]
      simp only [upd] at hu
      rw [hu]; rfl
  | back b =>
    have ht' : interp (F.back pre b).run X = some (some (post, r, ws), X') := ht
    exact interp_bind_pure (hF.back pre b) ht' fun γ k => by
      show k (O.post _ (some (post, r, ws))) = _
      simp only [Layers.Observer.post]
      simp only [upd] at hu
      rw [hu]; rfl

/-- **Lift.** An execution of the world below that the observer accepts is an execution with the observer,
with the same steps below. -/
theorem exec_lift (hF : FfiLawful F) : ∀ {x : F.S} {ts : List (Step F.S)} {y : F.S} {e e' : O.E},
    Exec F x ts y → fold O e ts = some e' →
      Exec O.ffi (x, e) (lift O e ts) (y, e') ∧ (lift O e ts).map (Step.map Prod.fst) = ts
  | x, [], y, e, e', hx, hf => by
    have hx' : x = y := hx
    simp only [fold, Option.some.injEq] at hf
    subst hx' hf
    exact ⟨rfl, rfl⟩
  | x, t :: ts, y, e, e', hx, hf => by
    obtain ⟨hpre, hok, hrest⟩ := hx
    simp only [fold] at hf
    cases hu : upd O e t with
    | none => rw [hu] at hf; cases hf
    | some e1 =>
      rw [hu, Option.bind_some] at hf
      obtain ⟨h1, h2⟩ := exec_lift hF hrest hf
      simp only [lift, hu]
      refine ⟨⟨by rw [hpre], step_ok O hF hok hu, h1⟩, ?_⟩
      rw [List.map_cons, h2]
      rfl

theorem step_proj (hF : FfiLawful F) {t : Step (F.S × O.E)} (ht : Step.ok O.ffi t) :
    (t.map Prod.fst).ok F ∧ upd O t.pre.2 (t.map Prod.fst) = some t.post.2 := by
  obtain ⟨⟨pre, e⟩, a, ⟨post, e'⟩, r, ws, X, X'⟩ := t
  cases a with
  | call name args =>
    obtain ⟨o, X1, h1, h2⟩ := interp_bind_inv (hF.call pre name args) ht
    have h3 := Option.some.inj ((interp_pure _ X1).symm.trans h2)
    have h4 := congrArg Prod.fst h3
    have h5 : X1 = X' := congrArg Prod.snd h3
    subst h5
    obtain ⟨rfl, hu⟩ := (O.post_some).mp h4
    exact ⟨h1, hu⟩
  | back b =>
    obtain ⟨o, X1, h1, h2⟩ := interp_bind_inv (hF.back pre b) ht
    have h3 := Option.some.inj ((interp_pure _ X1).symm.trans h2)
    have h4 := congrArg Prod.fst h3
    have h5 : X1 = X' := congrArg Prod.snd h3
    subst h5
    obtain ⟨rfl, hu⟩ := (O.post_some).mp h4
    exact ⟨h1, hu⟩

/-- **Projection.** An execution with the observer is an execution of the world below that the
observer accepts. -/
theorem exec_proj (hF : FfiLawful F) : ∀ {p : F.S × O.E} {ts : List (Step (F.S × O.E))} {q : F.S × O.E},
    Exec O.ffi p ts q → Exec F p.1 (ts.map (Step.map Prod.fst)) q.1 ∧ fold O p.2 (ts.map (Step.map Prod.fst)) = some q.2
  | p, [], q, hx => by
    have hx' : p = q := hx
    subst hx'
    exact ⟨rfl, rfl⟩
  | p, t :: ts, q, hx => by
    obtain ⟨hpre, hok, hrest⟩ := hx
    obtain ⟨h1, h2⟩ := exec_proj hF hrest
    obtain ⟨hs, hu⟩ := step_proj O hF hok
    subst hpre
    refine ⟨⟨rfl, hs, h1⟩, ?_⟩
    simp only [List.map_cons, fold, hu, Option.bind_some]
    exact h2

end Observer

/-! ## Lawfulness of the Neural Engine and symbolic-shape worlds -/

theorem ffiBack_l (s : Ffi.St) (a : Arg) : Lawful (Ffi.back s a) := NativeLawful.traceBack_l s a

theorem mlxCall_l (b : FfiAne.St) (s : Ffi.St) (name : Name) (args : List Arg) :
    Lawful (FfiAne.mlxCall b s name args) := by
  unfold FfiAne.mlxCall
  refine Lawful.cond _ (Lawful.pure _) (Lawful.bind (NativeLawful.mlx_call_l _ _ _) fun o => ?_)
  split <;> exact Lawful.pure _

theorem aneBack_l (b : FfiAne.St) (s : Ffi.St) (a : Arg) : Lawful (FfiAne.back b s a) := by
  unfold FfiAne.back
  refine Lawful.bind (ffiBack_l _ _) fun o => ?_
  split <;> exact Lawful.pure _

theorem aneLawful : FfiLawful Ane.ffi where
  call := fun s name args => by
    show Lawful (Ane.call s name args)
    unfold Ane.call Ane.onHandle Ane.baseCall
    refine Lawful.cond _ (Lawful.bind (mlxCall_l _ _ _ _) fun o => by split <;> exact Lawful.pure _) ?_
    refine Lawful.cond _ (Lawful.bind (loadFfiLawful.call _ _ _) fun o => by split <;> exact Lawful.pure _) ?_
    repeat' (first
      | with_reducible exact Lawful.pure _
      | refine Lawful.cond _ ?_ ?_
      | exact Lawful.bind (loadFfiLawful.call _ _ _) fun o => by split <;> exact Lawful.pure _
      | split)
  back := fun s a => by
    show Lawful (Ane.back s a)
    unfold Ane.back
    exact Lawful.bind (aneBack_l _ _ _) fun o => by split <;> exact Lawful.pure _

theorem reshapeRest_l (nw gv rs : List Ffi.Dim) (d : Nat) : Lawful (Ffi.SymShape.reshapeRest nw gv rs d) :=
  Lawful.bind (NativeLawful.dProd_l _) fun _ => Lawful.bind (NativeLawful.dLt_l _ _) fun _ =>
    Lawful.cond _ (Lawful.bind (NativeLawful.dProd_l _) fun _ => Lawful.pure _) (Lawful.pure _)

theorem reshapeCancel_l (nw gv old : List Ffi.Dim) (d : Nat) : Lawful (Ffi.SymShape.reshapeCancel nw gv old d) := by
  unfold Ffi.SymShape.reshapeCancel
  split
  · exact reshapeRest_l _ _ _ _
  · exact Lawful.pure _

theorem inferSym_l (p) (ins) : Lawful (Ffi.SymShape.inferSym p ins) := by
  unfold Ffi.SymShape.inferSym
  split
  · dsimp only
    exact Lawful.cond _ (Lawful.pure _) (Lawful.bind (NativeLawful.allEq_l _ _) fun _ =>
      Lawful.cond _ (reshapeRest_l _ _ _ _) (reshapeCancel_l _ _ _ _))
  · split
    · exact Lawful.cond _ (Lawful.bind (NativeLawful.dSub_l _ _) fun _ =>
        Lawful.bind (NativeLawful.dLt_l _ _) fun _ => Lawful.pure _) (Lawful.pure _)
    · exact Lawful.pure _
  · exact Lawful.pure _

theorem opOutSym_l (s : Ffi.St) (o : Arg) (p) (ins : List Nat) : Lawful (Ffi.SymShape.opOutSym s o p ins) := by
  unfold Ffi.SymShape.opOutSym
  split
  · exact Lawful.bind (inferSym_l _ _) fun r => by split <;> exact Lawful.pure _
  · exact Lawful.pure _

theorem symShapeCall_l (s : Ffi.St) (name : Name) (args : List Arg) :
    Lawful (Ffi.SymShape.symShapeCall s name args) := by
  unfold Ffi.SymShape.symShapeCall
  split
  · split
    · exact Lawful.cond _ (Lawful.bind (NativeLawful.dProd_l _) fun d => by cases d <;> exact Lawful.pure _)
        (Lawful.pure _)
    · exact Lawful.pure _
  · split
    · exact opOutSym_l _ _ _ _
    · exact Lawful.pure _
  · split
    · exact opOutSym_l _ _ _ _
    · exact Lawful.pure _
  · exact Lawful.pure _

theorem symLawful : FfiLawful symFfi where
  call := fun s name args => by
    show Lawful (symCall s name args)
    unfold symCall
    refine Lawful.bind (aneLawful.call s name args) fun o => ?_
    split
    · exact Lawful.pure _
    · refine Lawful.cond _ (Lawful.bind (symShapeCall_l _ _ _) fun q => ?_) (Lawful.pure _)
      split <;> exact Lawful.pure _
  back := aneLawful.back

/-! ## Symbolic shapes agree with the Neural Engine world -/

theorem sym_step {t : Step Ane.ASt} (ht : Step.ok Ane.ffi t) : Step.ok symFfi t := by
  obtain ⟨pre, a, post, r, ws, X, X'⟩ := t
  cases a with
  | call name args =>
    have ht' : interp (Ane.call pre name args).run X = some (some (post, r, ws), X') := ht
    exact interp_bind_pure (aneLawful.call pre name args) ht' fun γ k => rfl
  | back b => exact ht

/-- **Agreement.** An execution of the Neural Engine world is one of the symbolic-shape world. -/
theorem sym_exec : ∀ {x : Ane.ASt} {ts : List (Step Ane.ASt)} {y : Ane.ASt}, Exec Ane.ffi x ts y → Exec symFfi x ts y
  | _, [], _, hx => hx
  | _, _ :: _, _, hx => ⟨hx.1, sym_step hx.2.1, sym_exec hx.2.2⟩

/-! ## The Neural Engine world over load-world executions -/

/-- Neither a surface wrap nor a bridge call the load world has no model of (all but the create). -/
def aneFree : Act → Bool
  | .call name _ => !nameEq name FfiAne.payloadName && (!Ane.bridgeSym name || nameEq name chars!"mbane_program_create")
  | .back _ => true

/-- The bridge after a load-world step: a create records its program. -/
def aneBridge (b : FfiAne.St) (t : Step LSt) : FfiAne.St :=
  match t.act with
  | .call name args => bif !isMlx name && nameEq name chars!"mbane_program_create" then
      FfiAne.create b t.pre.host.ane args (match args with
        | [_, _, _, _, _, _, _, _, sh, _, _, _] => Ane.handleN t.pre.host sh
        | _ => none)
    else b
  | .back _ => b

def aneLift : FfiAne.St → List (Step LSt) → List (Step Ane.ASt)
  | _, [] => []
  | b, t :: ts => ⟨⟨t.pre, b⟩, t.act, ⟨t.post, aneBridge b t⟩, t.ret, t.ws, t.srv, t.srv'⟩ :: aneLift (aneBridge b t) ts

theorem allocAll_active : ∀ (b : FfiAne.St) (ns : List Nat), (FfiAne.allocAll b ns).2.active = b.active
  | _, [] => rfl
  | b, n :: ns => by
    show (FfiAne.allocAll (FfiAne.alloc b n).2 ns).2.active = b.active
    rw [allocAll_active]; rfl

theorem cond_active {c : Bool} {x y : FfiAne.St} {v : Bool} (hx : x.active = v) (hy : y.active = v) :
    (bif c then x else y).active = v := by cases c <;> assumption

theorem create_active (b : FfiAne.St) (n : Nat) (args : List Arg) (share : Option Nat) :
    (FfiAne.create b n args share).active = b.active := by
  unfold FfiAne.create
  cases FfiAne.parseSpec args with
  | none => rfl
  | some p =>
    cases share with
    | none => exact allocAll_active b p.inputBytes
    | some m =>
      dsimp only
      split
      · rfl
      · split
        · rfl
        · exact cond_active rfl (cond_active rfl rfl)

theorem aneBridge_active (b : FfiAne.St) (t : Step LSt) : (aneBridge b t).active = b.active := by
  unfold aneBridge
  split
  · exact cond_active (create_active _ _ _ _) rfl
  · rfl

theorem ane_step {t : Step LSt} {b : FfiAne.St} (hb : b.active = false) (hf : aneFree t.act = true)
    (ht : t.ok Host.Load.ffi) :
    Step.ok Ane.ffi ⟨⟨t.pre, b⟩, t.act, ⟨t.post, aneBridge b t⟩, t.ret, t.ws, t.srv, t.srv'⟩ := by
  obtain ⟨l, a, l', r, ws, X, X'⟩ := t
  cases a with
  | call name args =>
    have ht' : interp (Host.Load.call l name args).run X = some (some (l', r, ws), X') := ht
    simp only [aneFree, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true] at hf
    obtain ⟨hp, hbr⟩ := hf
    show interp (Ane.call ⟨l, b⟩ name args).run X = some (some (⟨l', aneBridge b ⟨l, .call name args, l', r, ws, X, X'⟩⟩, r, ws), X')
    cases hm : isMlx name with
    | true =>
      have hbb : aneBridge b ⟨l, .call name args, l', r, ws, X, X'⟩ = b := by
        simp only [aneBridge, hm, Bool.not_true, Bool.false_and, Bool.cond_false]
      rw [hbb, Ane.call_mlx_inactive _ _ _ hm hb hp]
      exact interp_bind_pure (loadFfiLawful.call l name args) ht' fun γ k => rfl
    | false =>
      cases hc : nameEq name chars!"mbane_program_create" with
      | true =>
        unfold Ane.call
        simp only [hm, hc, Bool.cond_false, Bool.cond_true]
        exact interp_bind_pure (loadFfiLawful.call l name args) ht' fun γ k => by
          simp only [aneBridge, hm, hc, Bool.not_false, Bool.true_and, Bool.cond_true]
          rfl
      | false =>
        have hbs : Ane.bridgeSym name = false := by
          rcases hbr with h | h
          · exact h
          · rw [hc] at h; cases h
        have hbb : aneBridge b ⟨l, .call name args, l', r, ws, X, X'⟩ = b := by
          simp only [aneBridge, hm, hc, Bool.not_false, Bool.true_and, Bool.cond_false]
        rw [hbb, Ane.call_load _ _ _ hm hbs]
        exact interp_bind_pure (loadFfiLawful.call l name args) ht' fun γ k => rfl
  | back c =>
    have ht' : interp (Host.Load.back l c).run X = some (some (l', r, ws), X') := ht
    obtain ⟨o, X1, h1, h2⟩ := interp_bind_inv (ffiBack_l l.mlx c) ht'
    rcases o with _ | ⟨m, r1, ws1⟩
    · rw [show (M.pure none : M (Res LSt)).run = Free.pure none from rfl, interp_pure] at h2; cases h2
    · rw [show (M.pure (some ({ l with mlx := m }, r1, ws1)) : M (Res LSt)).run =
        Free.pure (some ({ l with mlx := m }, r1, ws1)) from rfl, interp_pure] at h2
      simp only [Option.some.injEq, Prod.mk.injEq] at h2
      obtain ⟨⟨rfl, rfl, rfl⟩, rfl⟩ := h2
      have h3 : interp (FfiAne.back b l.mlx c).run X = some (some (m, b, r1, ws1), X1) :=
        interp_bind_pure (ffiBack_l l.mlx c) h1 fun γ k => by
          show k (bif b.active then _ else _) = _
          rw [hb]; rfl
      exact interp_bind_pure (aneBack_l b l.mlx c) h3 fun γ k => rfl

theorem ane_exec : ∀ {l l' : LSt} {ts : List (Step LSt)} {b : FfiAne.St}, b.active = false →
    (∀ t ∈ ts, aneFree t.act = true) → Exec Host.Load.ffi l ts l' →
      ∃ b', Exec Ane.ffi ⟨l, b⟩ (aneLift b ts) ⟨l', b'⟩ ∧ b'.active = false ∧
        (aneLift b ts).map (Step.map Ane.ASt.base) = ts
  | l, l', [], b, hb, _, hx => by
    have hx' : l = l' := hx
    subst hx'
    exact ⟨b, rfl, hb, rfl⟩
  | l, l', t :: ts, b, hb, hf, hx => by
    obtain ⟨hpre, hok, hrest⟩ := hx
    have hb' : (aneBridge b t).active = false := by rw [aneBridge_active]; exact hb
    obtain ⟨b', h1, h2, h3⟩ := ane_exec hb' (fun u hu => hf u (List.mem_cons_of_mem _ hu)) hrest
    refine ⟨b', ⟨by rw [hpre], ane_step hb (hf t List.mem_cons_self) hok, h1⟩, h2, ?_⟩
    simp only [aneLift, List.map_cons, h3]
    rfl

/-! ## The stack -/

def liveStep (e : PTrie Unit) (t : Step LSt) : Option (PTrie Unit) :=
  match t.act with
  | .call name args => liveCall e t.pre.mlx name args
  | .back _ => liveBack e t.pre.mlx

/-- The liveness layer's verdict on a load-world execution (`none`: a free of a handle that is not live). -/
def liveFold : PTrie Unit → List (Step LSt) → Option (PTrie Unit)
  | e, [] => some e
  | e, t :: ts => (liveStep e t).bind fun e' => liveFold e' ts

def kernStep (k : KRec) (t : Step LSt) : Option KRec :=
  match t.act with
  | .call name args => kernCall k t.pre.mlx name args t.ret
  | .back _ => some k

/-- The kernel-recording layer's verdict on a load-world execution (`none`: a launch whose configuration
is not recorded in order). -/
def kernFold : KRec → List (Step LSt) → Option KRec
  | k, [] => some k
  | k, t :: ts => (kernStep k t).bind fun k' => kernFold k' ts

theorem total_upd {F : Ffi} (O : Layers.Observer F) (e : Option O.E) (t : Step F.S) :
    Observer.upd O.total e t = some (e.bind fun e => Observer.upd O e t) := by
  obtain ⟨_, a, _, _, _, _, _⟩ := t
  cases a <;> rfl

/-- A recording observer accepts every execution; its state is the observer's fold. -/
theorem total_fold {F : Ffi} (O : Layers.Observer F) : ∀ (e : Option O.E) (ts : List (Step F.S)),
    Observer.fold O.total e ts = some (e.bind fun e => Observer.fold O e ts)
  | e, [] => by cases e <;> rfl
  | e, t :: ts => by
    rw [Observer.fold_cons, total_upd, Option.bind_some, total_fold]
    cases e with
    | none => rfl
    | some e => rfl

theorem live_upd (b : FfiAne.St) (e : PTrie Unit) (t : Step LSt) (p : Ane.ASt) :
    Observer.upd live e ⟨⟨t.pre, b⟩, t.act, p, t.ret, t.ws, t.srv, t.srv'⟩ = liveStep e t := by
  obtain ⟨_, a, _, _, _, _, _⟩ := t
  cases a <;> simp only [Observer.upd, liveStep, live]

theorem kern_upd (b : FfiAne.St) (e e1 : Option (PTrie Unit)) (k : KRec) (t : Step LSt) (p : Ane.ASt) :
    Observer.upd kern k ⟨(⟨t.pre, b⟩, e), t.act, (p, e1), t.ret, t.ws, t.srv, t.srv'⟩ = kernStep k t := by
  obtain ⟨_, a, _, _, _, _, _⟩ := t
  cases a <;> simp only [Observer.upd, kernStep, kern]

theorem live_fold : ∀ (b : FfiAne.St) (e : PTrie Unit) (ts : List (Step LSt)),
    Observer.fold live e (aneLift b ts) = liveFold e ts
  | _, _, [] => rfl
  | b, e, t :: ts => by
    show Observer.fold live e (⟨⟨t.pre, b⟩, t.act, ⟨t.post, aneBridge b t⟩, t.ret, t.ws, t.srv, t.srv'⟩ ::
      aneLift (aneBridge b t) ts) = (liveStep e t).bind fun e' => liveFold e' ts
    rw [Observer.fold_cons, live_upd]
    congr 1
    funext e'
    exact live_fold _ _ _

theorem kern_fold : ∀ (b : FfiAne.St) (e : Option (PTrie Unit)) (k : KRec) (ts : List (Step LSt)),
    Observer.fold kern k (Observer.lift live.total e (aneLift b ts)) = kernFold k ts
  | _, _, _, [] => rfl
  | b, e, k, t :: ts => by
    show Observer.fold kern k (Observer.lift live.total e (⟨⟨t.pre, b⟩, t.act, ⟨t.post, aneBridge b t⟩, t.ret, t.ws,
      t.srv, t.srv'⟩ :: aneLift (aneBridge b t) ts)) = (kernStep k t).bind fun k' => kernFold k' ts
    rw [Observer.lift_cons live.total _ (total_upd _ _ _), Observer.fold_cons, kern_upd]
    congr 1
    funext k'
    exact kern_fold _ _ _ _

theorem map_map3 {A B C D : Type} (f : A → B) (g : B → C) (h : C → D) (l : List (Step A)) :
    ((l.map (Step.map f)).map (Step.map g)).map (Step.map h) = l.map (Step.map (h ∘ g ∘ f)) := by
  simp only [List.map_map]; rfl

/-- The load-world execution in the full world. -/
def fullLift (b : FfiAne.St) (ts : List (Step LSt)) : List (Step full.S) :=
  Observer.lift kern.total (some KRec.empty) (Observer.lift live.total (some .nil) (aneLift b ts))

/-- **The lifting theorem.** An execution of the load world from `l` to `l'` that makes no bridge call
other than a create and no surface wrap is an execution of the full world from `start ⟨l, b⟩` (any
inactive bridge `b`, e.g. `FfiAne.ofTrace` of the run's trace) to a state whose load-world state is
`l'`, with the same steps in the load world; its verdicts are the liveness and kernel-recording folds. -/
theorem full_lift {l l' : LSt} {ts : List (Step LSt)} {b : FfiAne.St}
    (hx : Exec Host.Load.ffi l ts l') (hb : b.active = false) (hf : ∀ t ∈ ts, aneFree t.act = true) :
    ∃ y, Exec full (start ⟨l, b⟩) (fullLift b ts) y ∧ toLoad y = l' ∧
      (fullLift b ts).map (Step.map toLoad) = ts ∧ y.1.2 = liveFold .nil ts ∧ y.2 = kernFold KRec.empty ts := by
  obtain ⟨b', h1, _, h1m⟩ := ane_exec hb hf hx
  have h2 := sym_exec h1
  have hl : Observer.fold live.total (some .nil) (aneLift b ts) = some (liveFold .nil ts) := by
    rw [total_fold]; exact congrArg some (live_fold b .nil ts)
  obtain ⟨h3, h3m⟩ := Observer.exec_lift live.total symLawful h2 hl
  have hk : Observer.fold kern.total (some KRec.empty) (Observer.lift live.total (some .nil) (aneLift b ts)) =
      some (kernFold KRec.empty ts) := by
    rw [total_fold]; exact congrArg some (kern_fold b _ KRec.empty ts)
  obtain ⟨h4, h4m⟩ := Observer.exec_lift kern.total (Observer.lawful live.total symLawful) h3 hk
  refine ⟨((⟨l', b'⟩, liveFold .nil ts), kernFold KRec.empty ts), h4, rfl, ?_, rfl, rfl⟩
  have e2 := (congrArg (List.map (Step.map Prod.fst)) h4m).trans h3m
  have e3 := (congrArg (List.map (Step.map Ane.ASt.base)) e2).trans h1m
  exact (map_map3 _ _ _ _).symm.trans e3

/-- The bridge `Ane.lift` rebuilds from a trace is inactive: `full_lift` applies from it. -/
theorem ofTrace_active (tr : List Host.Ts.Event) : (FfiAne.ofTrace tr).active = false := by
  have go : ∀ (es : List Host.Ts.Event) (b : FfiAne.St) (rs : List (Nat × Nat)) (n : Nat), b.active = false →
      (FfiAne.ofTrace.go es b rs n).active = false := by
    intro es
    induction es with
    | nil => intro b _ _ hb; exact hb
    | cons e es ih =>
      intro b rs n hb
      unfold FfiAne.ofTrace.go
      cases nameEq e.sym chars!"mbane_program_create"
      · exact ih _ _ _ hb
      · exact ih _ _ _ (by rw [create_active]; exact hb)
  exact go _ _ _ _ rfl

end Host.Load.LayerLift
