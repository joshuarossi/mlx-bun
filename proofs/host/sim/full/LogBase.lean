import host.sim.full.LogFrame
import host.sim.full.AcceptNESim

/-! # The relation with a log base

`BRel.log` and `BRel.programs` are exact, but one row's template relates to targets whose earlier forwards grew the
log and left lock flags set. Since no step reads either (`LogFrame`), the target only has to be a related state
`y0` with `L` after its log and its programs replaced up to lock flags (`fF`): `FRL L FR` over any native relation
`FR`, with `L` fixed along a chain. `BRel`, `BridgeA`, `BridgeX`, `FullRX` and `FullRXD` are unchanged and are
`L = []` with exact programs.

The full world's calls and continuations on `fF L ps y` are those on `y` with the frame put back
(`full_call_fF`, `full_back_fF`, `opRes_fF`), so every simulation over `FR` lifts to `FRL L FR`
(`FfiCallSim.frame`, `FfiBackSimS.frame`, `FRLaws.frame`, `NativeFacts.frame`), giving the checked runs' one-step
theorems `fullStepSimXLBNL` and `fullStepSimXLBXDJSL`. `BridgeXL` is the same frame at the bridge relation, for the
restart and compaction theorems generic over it; composition moves a row's effects into the base
(`bridgeXL_after`: `es.map M.effect ++ L`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.FfiAne (Effect Program)
open Host.Ts.Sim.BufSim (Lawful)
open Host.Mlx.Ffi.SymShape (symShapeCall)

/-- The Neural Engine world's state in the frame. -/
def fA (L : List Effect) (ps : List Program) (a : Host.Load.Ane.ASt) : Host.Load.Ane.ASt := ⟨a.base, fB L ps a.bridge⟩

/-- The full world's state in the frame. -/
def fF (L : List Effect) (ps : List Program) (y : FF.S) : FF.S := ((fA L ps y.1.1, y.1.2), y.2)

def mapA (L : List Effect) (ps : List Program) (o : Res Host.Load.Ane.ASt) : Res Host.Load.Ane.ASt :=
  o.map fun q => (fA L ps q.1, q.2)

def mapF (L : List Effect) (ps : List Program) (o : Res FF.S) : Res FF.S := o.map fun q => (fF L ps q.1, q.2)

section frame
variable {L : List Effect} {ps : List Program}

theorem mlxCall_fB {b : BSt} (h : SameP ps b) (s : Host.Mlx.Ffi.St) (name : Name) (args : List Arg) :
    Host.Mlx.FfiAne.mlxCall (fB L ps b) s name args =
      Host.Ts.M.bind (Host.Mlx.FfiAne.mlxCall b s name args) fun o =>
        Host.Ts.M.pure (o.map fun q => (q.1, fB L ps q.2.1, q.2.2)) := by
  unfold Host.Mlx.FfiAne.mlxCall
  cases hp : nameEq name Host.Mlx.FfiAne.payloadName
  · simp only [Bool.cond_false, G.mbind_assoc]
    congr 1
    funext o
    rcases o with _ | ⟨m, r, ws⟩
    · simp only [G.mbind_pure, Option.map_none]
    · simp only [G.mbind_pure]
      have ha : (fB L ps b).active = b.active := rfl
      rw [ha]
      cases b.active
      · simp only [Bool.cond_false, Option.map_some]
      · simp only [Bool.cond_true]
        rw [after_fB h]
        cases Host.Mlx.FfiAne.after b s m name args <;> rfl
  · simp only [Bool.cond_true, G.mbind_pure]
    rw [wrap_fB]
    cases Host.Mlx.FfiAne.wrap b s args <;> rfl

theorem ane_call_fA {a : Host.Load.Ane.ASt} (h : SameP ps a.bridge) {name : Name} (hm : Host.Load.isMlx name = true)
    (args : List Arg) :
    Host.Load.Ane.call (fA L ps a) name args =
      Host.Ts.M.bind (Host.Load.Ane.call a name args) fun o => Host.Ts.M.pure (mapA L ps o) := by
  simp only [Host.Load.Ane.call, hm, Bool.cond_true]
  show Host.Ts.M.bind (Host.Mlx.FfiAne.mlxCall (fB L ps a.bridge) a.base.mlx name args) _ = _
  rw [mlxCall_fB h, G.mbind_assoc, G.mbind_assoc]
  congr 1
  funext o
  rcases o with _ | ⟨m, b, r, ws⟩ <;> simp only [G.mbind_pure] <;> rfl

theorem symFB_fA_none {a : Host.Load.Ane.ASt} (h : SameP ps a.bridge) (name : Name) (args : List Arg) :
    symFB (fA L ps a) name args none =
      Host.Ts.M.bind (symFB a name args none) fun o => Host.Ts.M.pure (mapA L ps o) := by
  unfold symFB
  cases (Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName)
  · simp only [Bool.cond_false, G.mbind_pure]; rfl
  · simp only [Bool.cond_true, G.mbind_assoc]
    show Host.Ts.M.bind (symShapeCall a.base.mlx name args) _ = Host.Ts.M.bind (symShapeCall a.base.mlx name args) _
    congr 1
    funext o
    rcases o with _ | ⟨m, r, ws⟩
    · simp only [G.mbind_pure]; rfl
    · simp only [G.mbind_pure]
      have ha : (fA L ps a).bridge.active = a.bridge.active := rfl
      have he : Host.Mlx.FfiAne.after (fA L ps a).bridge (fA L ps a).base.mlx m name args =
          (Host.Mlx.FfiAne.after a.bridge a.base.mlx m name args).map (fB L ps) := after_fB h _ _ _ _
      rw [ha, he]
      cases a.bridge.active
      · simp only [Bool.cond_false]; rfl
      · simp only [Bool.cond_true]
        cases Host.Mlx.FfiAne.after a.bridge a.base.mlx m name args <;> rfl

theorem symCall_fA {a : Host.Load.Ane.ASt} (h : SameP ps a.bridge) {name : Name} (hm : Host.Load.isMlx name = true)
    (args : List Arg) :
    Host.Load.Layers.symCall (fA L ps a) name args =
      Host.Ts.M.bind (Host.Load.Layers.symCall a name args) fun o => Host.Ts.M.pure (mapA L ps o) := by
  have e : ∀ a', Host.Load.Layers.symCall a' name args =
      Host.Ts.M.bind (Host.Load.Ane.call a' name args) (symFB a' name args) := fun _ => rfl
  rw [e, e, ane_call_fA h hm, G.mbind_assoc, G.mbind_assoc]
  congr 1
  funext o
  rw [G.mbind_pure]
  rcases o with _ | q
  · exact symFB_fA_none h name args
  · show Host.Ts.M.pure _ = Host.Ts.M.bind (Host.Ts.M.pure (some q)) _
    rw [G.mbind_pure]
    rfl

theorem liftF_fF (y : FF.S) (name : Name) (args : List Arg) (o : Res Host.Load.Ane.ASt) :
    liftF (fF L ps y) name args (mapA L ps o) = mapF L ps (liftF y name args o) := by
  rcases o with _ | ⟨a', r, ws⟩
  · rfl
  · show liftF _ _ _ (some (fA L ps a', r, ws)) = mapF L ps (liftF y name args (some (a', r, ws)))
    rw [liftF_some, liftF_some]
    rfl

/-- **An mlx call in the frame** is the call on the state without it, with the frame put back. -/
theorem full_call_fF {y : FF.S} (h : SameP ps (bridgeOf y)) {name : Name} (hm : Host.Load.isMlx name = true)
    (args : List Arg) :
    FF.call (fF L ps y) name args =
      Host.Ts.M.bind (FF.call y name args) fun o => Host.Ts.M.pure (mapF L ps o) := by
  rw [full_call_eq, full_call_eq]
  show Host.Ts.M.bind (Host.Load.Layers.symCall (fA L ps y.1.1) name args) _ = _
  rw [symCall_fA h hm, G.mbind_assoc, G.mbind_assoc]
  congr 1
  funext o
  simp only [G.mbind_pure]
  rw [liftF_fF]

theorem back_fB (b : BSt) (s : Host.Mlx.Ffi.St) (x : Arg) :
    Host.Mlx.FfiAne.back (fB L ps b) s x =
      Host.Ts.M.bind (Host.Mlx.FfiAne.back b s x) fun o =>
        Host.Ts.M.pure (o.map fun q => (q.1, fB L ps q.2.1, q.2.2)) := by
  unfold Host.Mlx.FfiAne.back
  simp only [G.mbind_assoc]
  congr 1
  funext o
  rcases o with _ | ⟨m, r, ws⟩
  · simp only [G.mbind_pure, Option.map_none]
  · simp only [G.mbind_pure]
    have ha : (fB L ps b).active = b.active := rfl
    rw [ha]
    cases b.active
    · simp only [Bool.cond_false, Option.map_some]
    · simp only [Bool.cond_true]
      rw [classify_fB]
      cases Host.Mlx.FfiAne.classify b m (m.nnext - s.nnext) s.nnext <;> rfl

theorem full_back_eq (p : FF.S) (a : Arg) :
    FF.back p a = Host.Ts.M.bind (Host.Load.Ane.back p.1.1 a) fun o => Host.Ts.M.pure (liftB p a o) := by
  funext γ k
  rw [Observer.back_eq kern.total, Observer.back_eq live.total]
  rfl

theorem liftB_fF (y : FF.S) (x : Arg) (o : Res Host.Load.Ane.ASt) :
    liftB (fF L ps y) x (mapA L ps o) = mapF L ps (liftB y x o) := by
  rcases o with _ | ⟨a', r, ws⟩
  · rfl
  · show liftB _ _ (some (fA L ps a', r, ws)) = mapF L ps (liftB y x (some (a', r, ws)))
    rw [liftB_some, liftB_some]
    rfl

/-- **A continuation in the frame.** -/
theorem full_back_fF (y : FF.S) (x : Arg) :
    FF.back (fF L ps y) x = Host.Ts.M.bind (FF.back y x) fun o => Host.Ts.M.pure (mapF L ps o) := by
  rw [full_back_eq, full_back_eq]
  have e : Host.Load.Ane.back (fF L ps y).1.1 x =
      Host.Ts.M.bind (Host.Load.Ane.back y.1.1 x) fun o => Host.Ts.M.pure (mapA L ps o) := by
    show Host.Ts.M.bind (Host.Mlx.FfiAne.back (fB L ps y.1.1.bridge) y.1.1.base.mlx x) _ = _
    unfold Host.Load.Ane.back
    rw [back_fB, G.mbind_assoc, G.mbind_assoc]
    congr 1
    funext o
    rcases o with _ | ⟨m, b, r, ws⟩ <;> simp only [G.mbind_pure] <;> rfl
  rw [e, G.mbind_assoc, G.mbind_assoc]
  congr 1
  funext o
  simp only [G.mbind_pure]
  rw [liftB_fF]

theorem bridgeOp_fB {name : Name} {as : List Arg} {h : Arg} {F : BSt → Nat → Option (BSt × Ret)}
    (e : bridgeOp name as = some (h, F)) {b : BSt} (hs : SameP ps b) {n : Nat} {b1 : BSt} {r : Ret}
    (he : F b n = some (b1, r)) : ∃ ps1, F (fB L ps b) n = some (fB L ps1 b1, r) ∧ SameP ps1 b1 := by
  unfold bridgeOp at e
  cases h1 : nameEq name chars!"mbane_input"
  · simp only [h1, Bool.cond_false] at e
    cases h2 : nameEq name chars!"mbane_output" <;> simp only [h2, Bool.cond_false, Bool.cond_true] at e
    · cases h3 : nameEq name chars!"mbane_eval_async" <;> simp only [h3, Bool.cond_false, Bool.cond_true] at e
      · cases h4 : nameEq name chars!"mbane_wait" <;> simp only [h4, Bool.cond_false, Bool.cond_true] at e
        · cases h5 : nameEq name chars!"mbane_free" <;> simp only [h5, Bool.cond_false, Bool.cond_true] at e
          · cases e
          · match as, e with
            | [a], e => cases e; exact free_fB hs he
        · match as, e with
          | [a, _, _], e => cases e; exact wait_fB hs he
      · match as, e with
        | [a], e => cases e; exact evalAsync_fB hs he
    · match as, e with
      | [a], e => cases e; exact output_fB hs he
  · simp only [h1, Bool.cond_true] at e
    match as, e with
    | [a, i], e => cases e; exact input_fB hs he

/-- A bridge call's arguments' images name the same call. -/
theorem bridgeOp_map_isSome (f : Arg → Arg) {name : Name} {as : List Arg} (e : (bridgeOp name as).isSome = true) :
    (bridgeOp name (as.map f)).isSome = true := by
  unfold bridgeOp at e ⊢
  cases h1 : nameEq name chars!"mbane_input"
  · simp only [h1, Bool.cond_false] at e ⊢
    cases h2 : nameEq name chars!"mbane_output" <;> simp only [h2, Bool.cond_false, Bool.cond_true] at e ⊢
    · cases h3 : nameEq name chars!"mbane_eval_async" <;> simp only [h3, Bool.cond_false, Bool.cond_true] at e ⊢
      · cases h4 : nameEq name chars!"mbane_wait" <;> simp only [h4, Bool.cond_false, Bool.cond_true] at e ⊢
        · cases h5 : nameEq name chars!"mbane_free" <;> simp only [h5, Bool.cond_false, Bool.cond_true] at e ⊢
          · cases e
          · match as, e with
            | [_], _ => rfl
        · match as, e with
          | [_, _, _], _ => rfl
      · match as, e with
        | [_], _ => rfl
    · match as, e with
      | [_], _ => rfl
  · simp only [h1, Bool.cond_true] at e ⊢
    match as, e with
    | [_, _], _ => rfl

/-- A bridge call's result in the frame. -/
theorem opRes_fF {name : Name} {as : List Arg} {h : Arg} {F : BSt → Nat → Option (BSt × Ret)}
    (e : bridgeOp name as = some (h, F)) {a a1 : Host.Load.Ane.ASt} (hs : SameP ps a.bridge) {r : Ret}
    {ws : List (Nat × Nat × List Byte)} (he : opRes a h (F a.bridge) = some (a1, r, ws)) :
    ∃ ps1, opRes (fA L ps a) h (F (fB L ps a.bridge)) = some (fA L ps1 a1, r, ws) ∧ SameP ps1 a1.bridge := by
  unfold opRes at he ⊢
  rw [show Host.Load.Ane.handleN (fA L ps a).base.host h = Host.Load.Ane.handleN a.base.host h from rfl]
  cases hn : Host.Load.Ane.handleN a.base.host h with
  | none => rw [hn] at he; cases he
  | some n =>
    rw [hn] at he
    dsimp only at he ⊢
    cases hF : F a.bridge n with
    | none => rw [hF] at he; cases he
    | some q =>
      obtain ⟨b1, r1⟩ := q
      rw [hF] at he
      simp only [Option.map_some, Option.some.injEq, Prod.mk.injEq] at he
      obtain ⟨rfl, rfl, rfl⟩ := he
      obtain ⟨ps1, e1, hs1⟩ := bridgeOp_fB e hs hF
      exact ⟨ps1, by rw [e1]; rfl, hs1⟩

theorem fF_self (y : FF.S) : fF [] (bridgeOf y).programs y = y := by
  obtain ⟨⟨⟨base, b⟩, v⟩, k⟩ := y
  show (((⟨base, { b with programs := b.programs, log := b.log ++ [] }⟩ : Host.Load.Ane.ASt), v), k) = _
  rw [List.append_nil]

/-- An mlx call keeps the programs. -/
theorem full_call_programsC {y y' : FF.S} {name : Name} (hm : Host.Load.isMlx name = true) {args : List Arg}
    {C C' : CSrv} {q : Ret} {ws : List (Nat × Nat × List Byte)}
    (hr : interpC (FF.call y name args).run C = some (some (y', q, ws), C')) :
    (bridgeOf y').programs = (bridgeOf y).programs := by
  have e := full_call_fF (L := []) (ps := (bridgeOf y).programs) (y := y) rfl hm args
  rw [fF_self] at e
  have hl : Lawful (FF.call y name args) := fullLawful.call y name args
  have key : interpC (Host.Ts.M.bind (FF.call y name args)
      fun o => Host.Ts.M.pure (mapF [] (bridgeOf y).programs o)).run C = some (some (y', q, ws), C') := by
    rw [← e]; exact hr
  rw [run_bindC hl, hr] at key
  have key2 : some (mapF [] (bridgeOf y).programs (some (y', q, ws)), C') = some (some (y', q, ws), C') := key
  simp only [mapF, Option.map_some, Option.some.injEq, Prod.mk.injEq, and_true] at key2
  exact (congrArg (fun z => (bridgeOf z).programs) key2).symm

theorem full_back_programsC {y y' : FF.S} {a : Arg} {C C' : CSrv} {q : Ret} {ws : List (Nat × Nat × List Byte)}
    (hr : interpC (FF.back y a).run C = some (some (y', q, ws), C')) :
    (bridgeOf y').programs = (bridgeOf y).programs := by
  have e := full_back_fF (L := []) (ps := (bridgeOf y).programs) y a
  rw [fF_self] at e
  have hl : Lawful (FF.back y a) := fullLawful.back y a
  have key : interpC (Host.Ts.M.bind (FF.back y a)
      fun o => Host.Ts.M.pure (mapF [] (bridgeOf y).programs o)).run C = some (some (y', q, ws), C') := by
    rw [← e]; exact hr
  rw [run_bindC hl, hr] at key
  have key2 : some (mapF [] (bridgeOf y).programs (some (y', q, ws)), C') = some (some (y', q, ws), C') := key
  simp only [mapF, Option.map_some, Option.some.injEq, Prod.mk.injEq, and_true] at key2
  exact (congrArg (fun z => (bridgeOf z).programs) key2).symm

end frame

/-! ## The relation in the frame -/

/-- **A native relation with a log base and programs up to lock flags.** -/
def FRL (L : List Effect) (FR : Map → Nat → FF.S → FF.S → Prop) : Map → Nat → FF.S → FF.S → Prop :=
  fun M n x y => ∃ y0 ps, y = fF L ps y0 ∧ SameP ps (bridgeOf y0) ∧ FR M n x y0

/-- `FR` is its own frame at the empty base. -/
theorem FRL.nil {FR : Map → Nat → FF.S → FF.S → Prop} {M : Map} {n : Nat} {x y : FF.S} (h : FR M n x y) :
    FRL [] FR M n x y := ⟨y, (bridgeOf y).programs, (fF_self y).symm, rfl, h⟩

theorem MSim.map_right {α β γ : Type} {P : Map → SSrv → CSrv → α → β → Prop} {Q : Map → SSrv → CSrv → α → γ → Prop}
    {S : SSrv} {C : CSrv} {m : Host.Ts.M α} {m' : Host.Ts.M β} {f : β → γ} (h : MSim P S C m m')
    (hq : ∀ M' S' C' a b, P M' S' C' a b → Q M' S' C' a (f b)) :
    MSim Q S C m (Host.Ts.M.bind m' fun b => Host.Ts.M.pure (f b)) :=
  fun δ ε R k k' hk => h δ ε R k (fun b => k' (f b)) fun M' S' C' a b hp => hk M' S' C' a (f b) (hq _ _ _ _ _ hp)

theorem MSim.pure_right {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {Q : Map → SSrv → CSrv → α → β → Prop}
    {S : SSrv} {C : CSrv} {m : Host.Ts.M α} {b b' : β} (h : MSim P S C m (Host.Ts.M.pure b)) (hm : Lawful m)
    (hq : ∀ M' S' a, P M' S' C a b → Q M' S' C a b') : MSim Q S C m (Host.Ts.M.pure b') := by
  intro δ ε R k k' hk r S2 hu
  rw [hm.1] at hu
  cases hrun : interpS m.run S with
  | none => rw [hrun] at hu; cases hu
  | some p =>
    obtain ⟨a, S1⟩ := p
    rw [hrun] at hu
    obtain ⟨M1, b1, C1, hc, hp⟩ := MSim.run h a S1 hrun
    have hc' : some (b, C) = some (b1, C1) := hc
    simp only [Option.some.injEq, Prod.mk.injEq] at hc'
    obtain ⟨rfl, rfl⟩ := hc'
    exact hk M1 S1 C a b' (hq _ _ _ hp) r S2 hu

theorem callR_frame {FR : Map → Nat → FF.S → FF.S → Prop} {L : List Effect} {ps : List Program} {M : Map} {n : Nat}
    {r r' : Res FF.S} (h : CallR (F := FF) FR M n r r')
    (hs : ∀ y' q ws, r' = some (y', q, ws) → SameP ps (bridgeOf y')) :
    CallR (F := FF) (FRL L FR) M n r (mapF L ps r') := by
  rcases r with _ | ⟨x', r1, ws⟩ <;> rcases r' with _ | ⟨y', r2, ws'⟩
  · trivial
  · trivial
  · exact h
  · exact ⟨⟨y', ps, rfl, hs _ _ _ rfl, h.1⟩, h.2⟩

/-- The calls a native relation in the frame covers: mlx calls and the bridge's program calls. -/
def AccName (name : Name) (args : List Arg) : Prop :=
  Host.Load.isMlx name = true ∨ (Host.Load.isMlx name = false ∧ nameEq name chars!"mbane_program_create" = false ∧
    (bridgeOp name args).isSome = true)

theorem FfiCallSim.frame {FR : Map → Nat → FF.S → FF.S → Prop} {ok : FF.S → Name → List Arg → Bool}
    {small : (Nat → F64) → SSrv → FF.S → Name → List Arg → Prop} (h : FfiCallSim FF FR ok small)
    (hA : ∀ x name args, ok x name args = true → AccName name args) (L : List Effect) :
    FfiCallSim FF (FRL L FR) ok small where
  call := by
    rintro M ν S C x y name args hsrv ⟨y0, ps, rfl, hps, hr⟩ hok hsupp hsm
    have hs := h.call M ν S C x y0 name args hsrv hr hok hsupp hsm
    rcases hA x name args hok with hm | ⟨hm, hc, hop⟩
    · rw [full_call_fF hps hm]
      refine MSim.map_right (MSim.both hs (fullLawful.call _ _ _) (fullLawful.call _ _ _)) ?_
      rintro M' S' C' a b ⟨⟨hg, hc⟩, -, hb⟩
      refine ⟨hg, callR_frame hc ?_⟩
      rintro y' q ws rfl
      show ps.map stripP = (bridgeOf y').programs.map stripP
      rw [full_call_programsC hm hb]
      exact hps
    · obtain ⟨⟨h1, F⟩, hb⟩ := Option.isSome_iff_exists.mp (bridgeOp_map_isSome M.arg hop)
      rw [full_call_op y0 hm hc hb] at hs
      show MSim _ S C (FF.call x name args) (FF.call (fF L ps y0) name (args.map M.arg))
      rw [full_call_op (fF L ps y0) hm hc hb]
      refine MSim.pure_right hs (fullLawful.call _ _ _) ?_
      rintro M' S' a ⟨hg, hc'⟩
      refine ⟨hg, ?_⟩
      show CallR (F := FF) (FRL L FR) M' S'.tab.length a
        (liftF (fF L ps y0) name (args.map M.arg) (opRes (fA L ps y0.1.1) h1 (F (fB L ps y0.1.1.bridge))))
      cases hR : opRes y0.1.1 h1 (F y0.1.1.bridge) with
      | none =>
        rw [hR] at hc'
        rcases a with _ | ⟨x', r1, ws⟩
        · trivial
        · exact hc'.elim
      | some q =>
        obtain ⟨a1, r2, ws2⟩ := q
        obtain ⟨ps1, e1, hs1⟩ := opRes_fF (L := L) hb hps hR
        rw [hR] at hc'
        rw [e1]
        rw [liftF_some] at hc' ⊢
        rcases a with _ | ⟨x', r1, ws⟩
        · trivial
        · exact ⟨⟨_, ps1, rfl, hs1, hc'.1⟩, hc'.2⟩

theorem FfiBackSimS.frame {FR : Map → Nat → FF.S → FF.S → Prop} {ok : FF.S → Arg → Bool}
    {small : (Nat → F64) → SSrv → FF.S → Arg → Prop} (h : FfiBackSimS FF FR ok small) (L : List Effect) :
    FfiBackSimS FF (FRL L FR) ok small where
  back := by
    rintro M ν S C x y a hsrv ⟨y0, ps, rfl, hps, hr⟩ hok hsupp hsm
    have hs := h.back M ν S C x y0 a hsrv hr hok hsupp hsm
    rw [full_back_fF]
    refine MSim.map_right (MSim.both hs (fullLawful.back _ _) (fullLawful.back _ _)) ?_
    rintro M' S' C' o b ⟨⟨hg, hc⟩, -, hb⟩
    refine ⟨hg, callR_frame hc ?_⟩
    rintro y' q ws rfl
    show ps.map stripP = (bridgeOf y').programs.map stripP
    rw [full_back_programsC hb]
    exact hps

theorem FRLaws.frame {FR : Map → Nat → FF.S → FF.S → Prop} (h : FRLaws (F := FF) FR) (L : List Effect) :
    FRLaws (F := FF) (FRL L FR) where
  stable := by
    rintro M M' n x y ⟨y0, ps, rfl, hps, hr⟩ he
    exact ⟨y0, ps, rfl, hps, h.stable M M' n x y0 hr he⟩
  mono := by
    rintro M n n' x y ⟨y0, ps, rfl, hps, hr⟩ hn
    exact ⟨y0, ps, rfl, hps, h.mono M n n' x y0 hr hn⟩

theorem FfiSim.frameFalse {FR : Map → Nat → FF.S → FF.S → Prop}
    (h : FfiSim FF FR (fun _ _ _ => false) (fun _ _ => false)) (L : List Effect) :
    FfiSim FF (FRL L FR) (fun _ _ _ => false) (fun _ _ => false) where
  call := fun _ _ _ _ _ _ _ _ _ _ h => absurd h (by simp)
  back := fun _ _ _ _ _ _ _ _ _ h => absurd h (by simp)
  read := by
    rintro M n x y r off k bs ⟨y0, ps, rfl, hps, hr⟩ hx
    exact h.read M n x y0 r off k bs hr hx

theorem NativeFacts.frame {FR : Map → Nat → FF.S → FF.S → Prop} {J : Disp.JSP FF} (h : Disp.NativeFacts FF FR J)
    (L : List Effect) : Disp.NativeFacts FF (FRL L FR) J where
  zero := by rintro M n x y ⟨y0, ps, -, -, hr⟩; exact h.zero M n x y0 hr
  inj := by rintro M n x y ⟨y0, ps, -, -, hr⟩; exact h.inj M n x y0 hr
  region := by rintro M n x y ⟨y0, ps, -, -, hr⟩; exact h.region M n x y0 hr
  range := by rintro M n x y ⟨y0, ps, -, -, hr⟩; exact h.range M n x y0 hr
  host := by rintro M n x y ⟨y0, ps, -, -, hr⟩; exact h.host M n x y0 hr
  cb := by rintro M n x y ⟨y0, ps, -, -, hr⟩; exact h.cb M n x y0 hr

end Host.Ts.Sim.Full
