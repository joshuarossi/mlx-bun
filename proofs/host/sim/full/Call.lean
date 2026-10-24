import host.sim.full.Obs
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep AllX KRes)
open Host.Ts.Sim.BufSim (Lawful)

/-! # The full world's native-call simulation with the bridge inactive

`fullCallSim`: an accepted call of the full world, from states related by `FullR`, gives related
results. The call is the load world's (`full_call_mlx`: with the bridge inactive, an mlx call other
than a surface wrap is `Host.Load.call` on the load-world projection, as `Ane.call_mlx_inactive`
states), followed by the layers:

* the symbolic-shape layer is reached only when the load world's call is stuck; outside
  `mlx_array_size`, `mlx_reshape` and `mlx_conv1d` it is stuck as well (`symShapeCall_stuck`), and for
  those three the acceptance requires the template's load-world call to have a result
  (`smallF`, decided by evaluation in `smallFB`), so the target's has one (`CallR`);
* the observers are pure in the state before, the arguments and the return (`live_step`,
  `kern_step`); their facts about the states after come from both runs (`MSim.both`): every mlx
  call keeps the model's objects (`FullKeep.call_k`), and a configuration's creation is computed.

The simulation is generic in the load world's (`fullCallSimG`); `fullCallSim` is its instance at the
general relation's (`G.loadFfiCallSim`), unchanged. -/

/-- `MSim.withRun` with the target's run too. -/
theorem MSim.both {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {S : SSrv} {C : CSrv}
    {m : Host.Ts.M α} {m' : Host.Ts.M β} (h : MSim P S C m m') (hs : Lawful m) (ht : Lawful m') :
    MSim (fun M' S' C' a b => P M' S' C' a b ∧ interpS m.run S = some (a, S') ∧ interpC m'.run C = some (b, C'))
      S C m m' := by
  intro γ δ Q k k' hk r S2 hu
  rw [hs.1] at hu
  cases hrun : interpS m.run S with
  | none => rw [hrun] at hu; cases hu
  | some p =>
    obtain ⟨a, S1⟩ := p
    rw [hrun] at hu
    obtain ⟨M1, b, C1, hc, hp⟩ := MSim.run h a S1 hrun
    obtain ⟨M2, r', C2, hc', hq⟩ := hk M1 S1 C1 a b ⟨hp, hrun, hc⟩ r S2 hu
    exact ⟨M2, r', C2, by rw [ht.2, hc]; exact hc', hq⟩

/-! ## The call through the layers -/

/-- The layers' result for a Neural Engine world result of a call from `p` (the observers' posts). -/
def liftF (p : FF.S) (name : Name) (args : List Arg) (o : Res Host.Load.Ane.ASt) : Res FF.S :=
  kern.total.post (fun x' r => kern.total.onCall p.2 p.1 x' name args r)
    (live.total.post (fun x' r => live.total.onCall p.1.2 p.1.1 x' name args r) o)

theorem liftF_some (p : FF.S) (name : Name) (args : List Arg) (a' : Host.Load.Ane.ASt) (r : Ret)
    (ws : List (Nat × Nat × List Byte)) :
    liftF p name args (some (a', r, ws)) = some (((a', p.1.2.bind fun e => liveCall e p.1.1.base.mlx name args),
      p.2.bind fun k => kernCall k p.1.1.base.mlx name args r), r, ws) := by
  simp only [liftF, Observer.post, Option.map]

theorem liftF_none (p : FF.S) (name : Name) (args : List Arg) : liftF p name args none = none := rfl

theorem full_call_eq (p : FF.S) (name : Name) (args : List Arg) :
    FF.call p name args = Host.Ts.M.bind (symCall p.1.1 name args) fun o => .pure (liftF p name args o) := by
  funext γ k
  rw [Observer.call_eq kern.total, Observer.call_eq live.total]
  rfl

/-- The symbolic-shape layer after the load world's call, with the bridge inactive. -/
def symK (a : Host.Load.Ane.ASt) (name : Name) (args : List Arg) :
    Res Host.Load.LSt → Host.Ts.M (Res Host.Load.Ane.ASt)
  | some (l, r, ws) => .pure (some (⟨l, a.bridge⟩, r, ws))
  | none => .bind (Host.Mlx.Ffi.SymShape.symShapeCall a.base.mlx name args) fun
    | some (m, r, ws) => .pure (some (⟨{ a.base with mlx := m }, a.bridge⟩, r, ws))
    | none => .pure none

/-- With the bridge inactive, the symbolic-shape world's mlx call (not a wrap) is the load world's
call, completed by the symbolic-shape layer where it is stuck. -/
theorem symCall_inactive (a : Host.Load.Ane.ASt) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : a.bridge.active = false) :
    symCall a name args = Host.Ts.M.bind (Host.Load.call a.base name args) (symK a name args) := by
  unfold symCall
  rw [Host.Load.Ane.call_mlx_inactive _ _ _ hm ha hp]
  unfold Host.Load.Ane.baseCall
  funext γ k
  simp only [Host.Ts.M.bind]
  refine congrArg (Host.Load.call a.base name args γ) (funext fun o => ?_)
  rcases o with _ | ⟨l, r, ws⟩
  · have e1 : (Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName) = true := by rw [hm, hp]; rfl
    have e2 : ∀ (X Y : Host.Ts.M (Res Host.Load.Ane.ASt)),
        (bif (Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName) then X else Y) = X :=
      fun X Y => by rw [e1]; rfl
    show (bif (Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName) then _ else _ :
      Host.Ts.M (Res Host.Load.Ane.ASt)) γ k = _
    rw [e2]
    simp only [symK]
    refine congrArg (fun F => Host.Ts.M.bind (Host.Mlx.Ffi.SymShape.symShapeCall a.base.mlx name args) F γ k)
      (funext fun o => ?_)
    rcases o with _ | ⟨m, r, ws⟩
    · rfl
    · simp only [ha, Bool.cond_false]
  · rfl

/-- The layers after the load world's call, with the bridge inactive. -/
def fullCont (p : FF.S) (name : Name) (args : List Arg) (o : Res Host.Load.LSt) : Host.Ts.M (Res FF.S) :=
  .bind (symK p.1.1 name args o) fun o' => .pure (liftF p name args o')

/-- **With the bridge inactive, an mlx call other than a wrap is the load world's call followed by
the layers.** -/
theorem full_call_mlx (p : FF.S) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : (bridgeOf p).active = false) :
    FF.call p name args = Host.Ts.M.bind (Host.Load.call (toLoad p) name args) (fullCont p name args) := by
  rw [full_call_eq, symCall_inactive _ _ _ hm hp ha]
  rfl

theorem fullCont_some (p : FF.S) (name : Name) (args : List Arg) (l : Host.Load.LSt) (r : Ret)
    (ws : List (Nat × Nat × List Byte)) :
    fullCont p name args (some (l, r, ws)) = .pure (liftF p name args (some (⟨l, bridgeOf p⟩, r, ws))) := rfl

/-! ## The symbolic-shape layer -/

/-- The calls the symbolic-shape layer completes. -/
def isSymShape (name : Name) : Bool :=
  match Host.Mlx.Ffi.symOf name with
  | some .arraySize | some .reshape | some .conv1d => true
  | _ => false

/-- Outside the three, the symbolic-shape layer is stuck. -/
theorem symShapeCall_stuck (s : Host.Mlx.Ffi.St) (name : Name) (args : List Arg) (h : isSymShape name = false) :
    Host.Mlx.Ffi.SymShape.symShapeCall s name args = Host.Mlx.Ffi.stuck := by
  unfold Host.Mlx.Ffi.SymShape.symShapeCall
  unfold isSymShape at h
  cases hs : Host.Mlx.Ffi.symOf name with
  | none => rfl
  | some x =>
    rw [hs] at h
    cases x
    case arraySize => cases h
    case reshape => cases h
    case conv1d => cases h
    all_goals rfl

theorem fullCont_none (p : FF.S) (name : Name) (args : List Arg) (h : isSymShape name = false) :
    fullCont p name args none = Host.Ts.M.pure none := by
  unfold fullCont
  simp only [symK]
  rw [symShapeCall_stuck _ _ _ h]
  rfl

/-! ## Acceptance -/

/-- **The accepted calls of the full world with the bridge inactive**: an mlx call other than a
surface wrap, from an inactive bridge, that the load world's general relation accepts
(`G.okCallSG`), with the liveness layer's condition (`obsOk`). -/
def okCallF (P : LoadP) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName && !(bridgeOf x).active &&
    G.okCallSG P (toLoad x) name args && obsOk (mlxOf x) name args

/-- **The numeric premise**: the load world's, and for the calls the symbolic-shape layer completes,
the template's load-world call has a result. -/
def smallF (ν : Nat → F64) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  smallLoad ν S (toLoad x) name args ∧
    (isSymShape name = true → ∀ a S', interpS (Host.Load.call (toLoad x) name args).run S = some (a, S') →
      a.isSome = true)

/-- The template's load-world call at the server `S` has a result (decided by evaluation;
irreducible, so that unification never evaluates it). -/
@[irreducible] def symRunOk (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  match interpS (Host.Load.call (toLoad x) name args).run S with
  | some (some _, _) => true
  | _ => false

theorem symRunOk_sound {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (h : symRunOk S x name args = true) :
    ∀ a S', interpS (Host.Load.call (toLoad x) name args).run S = some (a, S') → a.isSome = true := by
  intro a S' ha
  unfold symRunOk at h
  rw [ha] at h
  rcases a with _ | _
  · cases h
  · rfl

/-- The decider of `smallF` (irreducible, so that unifying a parameter set's decider with it does not
unfold the load world's). -/
@[irreducible] def smallFB (VB : Nat → Nat) (S : SSrv) (x : FF.S) (name : Name) (args : List Arg) : Bool :=
  smallLoadB VB S (toLoad x) name args && (!isSymShape name || symRunOk S x name args)

theorem smallFB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : FF.S} {name : Name} {args : List Arg}
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) (h : smallFB VB S x name args = true) : smallF ν S x name args := by
  unfold smallFB at h
  simp only [Bool.and_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at h
  refine ⟨smallLoadB_sound h.1 hν, fun hs => ?_⟩
  rcases h.2 with h2 | h2
  · rw [hs] at h2; cases h2
  · exact symRunOk_sound h2

/-! ## The load world's acceptance read by the observers -/

theorem okCallSG_sym {P : LoadP} {l : Host.Load.LSt} {name : Name} {args : List Arg} {s : Host.Mlx.Ffi.Sym}
    (h : G.okCallSG P l name args = true) (hs : Host.Mlx.Ffi.symOf name = some s)
    (hg : G.NativeOkS.symG P l.mlx s args = false) : NativeOk.sym P l.mlx name s args = true := by
  unfold G.okCallSG okCall at h
  rw [hs] at h
  simp only [hg, Bool.and_false, Bool.or_false, Bool.and_eq_true] at h
  exact h.2

theorem kernAcc_of {P : LoadP} {l : Host.Load.LSt} {name : Name} {args : List Arg}
    (h : G.okCallSG P l name args = true) : KernAcc P l.mlx name args := by
  intro s hs
  refine ⟨fun e => ?_, fun e => ?_⟩
  · subst e
    have := okCallSG_sym h hs rfl
    simp [NativeOk.sym] at this
  · rcases e with rfl | rfl | rfl <;> exact okCallSG_sym h hs rfl

theorem arrAcc_of {P : LoadP} {l : Host.Load.LSt} {name : Name} {args : List Arg}
    (h : G.okCallSG P l name args = true) :
    Host.Mlx.Ffi.symOf name = some .arrayFree → ∀ a, args = [a] → hdOk l.mlx a = true := by
  intro hs a ha
  subst ha
  exact okCallSG_sym h hs rfl

/-! ## Facts of the runs -/

theorem load_call_keep (x : Host.Load.LSt) (name : Name) (args : List Arg) (hm : Host.Load.isMlx name = true) :
    AllX (fun o => ∀ l r ws, o = some (l, r, ws) → Keep x.mlx l.mlx) (Host.Load.call x name args) := by
  rw [Host.Load.call_mlx x name args hm]
  refine Host.Mlx.Ffi.FullKeep.AllX.bind (NativeLawful.mlx_call_l _ _ _) (Host.Mlx.Ffi.FullKeep.call_k _ _ _)
    fun o ho => ?_
  rcases o with _ | ⟨m, r, ws⟩
  · exact Host.Mlx.Ffi.FullKeep.AllX.pure fun _ _ _ e => by cases e
  · exact Host.Mlx.Ffi.FullKeep.AllX.pure fun _ _ _ e => by cases e; exact ho _ rfl

theorem mlx_call_cfgNew (s : Host.Mlx.Ffi.St) (name : Name) (hs : Host.Mlx.Ffi.symOf name = some .cfgNew) :
    Host.Mlx.Ffi.call s name [] = Host.Mlx.Ffi.ok (s.newObj (.cfg .empty)).2 (.big (Int.ofNat s.next)) := by
  unfold Host.Mlx.Ffi.call
  rw [hs]
  rfl

theorem load_call_cfgNew (x : Host.Load.LSt) (name : Name) (hm : Host.Load.isMlx name = true)
    (hs : Host.Mlx.Ffi.symOf name = some .cfgNew) :
    Host.Load.call x name [] = Host.Ts.M.pure (some ({ x with mlx := (x.mlx.newObj (.cfg .empty)).2 },
      .big (Int.ofNat x.mlx.next), [])) := by
  rw [Host.Load.call_mlx x name [] hm, mlx_call_cfgNew _ _ hs]
  rfl

/-- `mlx_fast_metal_kernel_new`. -/
def kernNewProg (s : Host.Mlx.Ffi.St) (nm ins outs src hdr : Arg) : Host.Mlx.Ffi.R :=
  match Host.Mlx.Ffi.cstrArg nm, (Host.Mlx.Ffi.argNat ins).bind s.obj?, (Host.Mlx.Ffi.argNat outs).bind s.obj?,
    Host.Mlx.Ffi.cstrArg src, Host.Mlx.Ffi.cstrArg hdr with
  | some n, some (.vstr a), some (.vstr b), some sc, some hd =>
    Host.Mlx.Ffi.ok { s with next := s.next + 1, objs := s.objs.set s.next (.kernel n sc hd a b) } (.big s.next)
  | _, _, _, _, _ => Host.Mlx.Ffi.stuck

theorem call_kernelNew {name : Name} (hs : Host.Mlx.Ffi.symOf name = some .kernelNew) (s : Host.Mlx.Ffi.St)
    (nm ins outs src hdr rc ao : Arg) :
    Host.Mlx.Ffi.call s name [nm, ins, outs, src, hdr, rc, ao] = kernNewProg s nm ins outs src hdr := by
  unfold Host.Mlx.Ffi.call; rw [hs]; try rfl

/-- A created kernel is the handle counter's object. -/
theorem mlx_kernelNew_res (s : Host.Mlx.Ffi.St) {name : Name} (hs : Host.Mlx.Ffi.symOf name = some .kernelNew)
    (hb : s.next < 2 ^ 64) (nm ins outs src hdr rc ao : Arg) :
    AllX (fun o => ∀ m r ws, o = some (m, r, ws) → r = .big (Int.ofNat s.next) ∧ (m.objs.get s.next).isSome = true)
      (Host.Mlx.Ffi.call s name [nm, ins, outs, src, hdr, rc, ao]) := by
  rw [call_kernelNew hs]
  unfold kernNewProg
  split
  · refine Host.Mlx.Ffi.FullKeep.AllX.pure fun m r ws e => ?_
    cases e
    refine ⟨rfl, ?_⟩
    show ((s.objs.set s.next _).get s.next).isSome = true
    rw [PTrie.get_set_u64 _ _ _ hb]; simp
  · exact Host.Mlx.Ffi.FullKeep.AllX.pure fun _ _ _ e => by cases e

theorem load_kernelNew_res (x : Host.Load.LSt) {name : Name} (hm : Host.Load.isMlx name = true)
    (hs : Host.Mlx.Ffi.symOf name = some .kernelNew) (hb : x.mlx.next < 2 ^ 64) (nm ins outs src hdr rc ao : Arg) :
    AllX (fun o => ∀ l r ws, o = some (l, r, ws) →
        r = .big (Int.ofNat x.mlx.next) ∧ (l.mlx.objs.get x.mlx.next).isSome = true)
      (Host.Load.call x name [nm, ins, outs, src, hdr, rc, ao]) := by
  rw [Host.Load.call_mlx x name _ hm]
  refine Host.Mlx.Ffi.FullKeep.AllX.bind (NativeLawful.mlx_call_l _ _ _)
    (mlx_kernelNew_res _ hs hb nm ins outs src hdr rc ao) fun o ho => ?_
  rcases o with _ | ⟨m, r, ws⟩
  · exact Host.Mlx.Ffi.FullKeep.AllX.pure fun _ _ _ e => by cases e
  · exact Host.Mlx.Ffi.FullKeep.AllX.pure fun _ _ _ e => by cases e; exact ho _ _ _ rfl

/-! ## The simulation -/

theorem keep_of_run {x : Host.Load.LSt} {name : Name} {args : List Arg} {S S' : SSrv} {l : Host.Load.LSt}
    {r : Ret} {ws : List (Nat × Nat × List Byte)} (hm : Host.Load.isMlx name = true)
    (h : interpS (Host.Load.call x name args).run S = some (some (l, r, ws), S')) : Keep x.mlx l.mlx :=
  (load_call_keep x name args hm).1 S _ S' h l r ws rfl

theorem keep_of_runC {x : Host.Load.LSt} {name : Name} {args : List Arg} {C C' : CSrv} {l : Host.Load.LSt}
    {r : Ret} {ws : List (Nat × Nat × List Byte)} (hm : Host.Load.isMlx name = true)
    (h : interpC (Host.Load.call x name args).run C = some (some (l, r, ws), C')) : Keep x.mlx l.mlx :=
  (load_call_keep x name args hm).2 C _ C' h l r ws rfl

/-- The full world's accepted calls over a load-world acceptance `ok` (`okCallF` at `G.okCallSG`). -/
def okCallFG (ok : LoadP → Host.Load.LSt → Name → List Arg → Bool) (P : LoadP) (x : FF.S) (name : Name)
    (args : List Arg) : Bool :=
  Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName && !(bridgeOf x).active &&
    ok P (toLoad x) name args && obsOk (mlxOf x) name args

/-- The full world's numeric premise over a load-world premise `sm` (`smallF` at `smallLoad`). -/
def smallFG (sm : (Nat → F64) → SSrv → Host.Load.LSt → Name → List Arg → Prop) (ν : Nat → F64) (S : SSrv)
    (x : FF.S) (name : Name) (args : List Arg) : Prop :=
  sm ν S (toLoad x) name args ∧
    (isSymShape name = true → ∀ a S', interpS (Host.Load.call (toLoad x) name args).run S = some (a, S') →
      a.isSome = true)

/-- **The layers after related load-world results**: the observers' relations follow. -/
theorem full_some_post {P : LoadP} {NB : Nat} {M M' : Map} {ν : Nat → F64} {S S' : SSrv} {C C' : CSrv}
    {x y : FF.S} {name : Name} {args : List Arg} {l l' : Host.Load.LSt} {r r' : Ret}
    {ws ws' : List (Nat × Nat × List Byte)}
    (hr : FullR P NB M S.tab.length x y) (hgr : Grow M ν S C M' S' C')
    (hcr : CallR (F := Host.Load.ffi) (G.LoadR P NB) M' S'.tab.length (some (l, r, ws)) (some (l', r', ws')))
    (kx : Keep (mlxOf x) l.mlx) (ky : Keep (mlxOf y) l'.mlx) (hobs : obsOk (mlxOf x) name args = true)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hka : KernAcc P (mlxOf x) name args)
    (haa : Host.Mlx.Ffi.symOf name = some .arrayFree → ∀ a, args = [a] → hdOk (mlxOf x) a = true)
    (hnew : Host.Mlx.Ffi.symOf name = some .cfgNew → args = [] →
      r = .big (Int.ofNat (mlxOf x).next) ∧ (l.mlx.objs.get (mlxOf x).next).isSome = true)
    (hnewK : Host.Mlx.Ffi.symOf name = some .kernelNew → args.length = 7 →
      r = .big (Int.ofNat (mlxOf x).next) ∧ (l.mlx.objs.get (mlxOf x).next).isSome = true) :
    MSim (fun M'' S'' C'' r r' => Grow M ν S C M'' S'' C'' ∧ CallR (F := FF) (FullR P NB) M'' S''.tab.length r r')
      S' C' (Host.Ts.M.pure (liftF x name args (some (⟨l, bridgeOf x⟩, r, ws))))
      (Host.Ts.M.pure (liftF y name (args.map M.arg) (some (⟨l', bridgeOf y⟩, r', ws')))) := by
  obtain ⟨hlr, hr', hws⟩ := hcr
  have hob : ObsPost P NB M M' S.tab.length S'.tab.length (mlxOf x) (mlxOf y) l.mlx l'.mlx :=
    ⟨hr.load.mlx, hlr.mlx, hgr.ext, hgr.len, kx, ky⟩
  rw [liftF_some, liftF_some]
  refine MSim.pure ⟨hgr, ⟨hlr, ⟨hr.bridge.1, hr.bridge.2⟩, ?_, ?_, hr.pend.step hr.load.mlx hlr.mlx hgr.ext kx⟩, hr', hws⟩
  · exact live_step hr.live hob hobs haa
  · rw [hr']
    exact kern_step hr.kern hob hsupp hka hnew hnewK

/-- **The layers after a load-world call simulation**: an mlx call (not a wrap, the bridge inactive)
whose load-world calls simulate (`hg`) simulates in the full world, the observers reading it
(`hka`, `haa`), and the symbolic-shape layer reached only where the template's load-world call has a
result (`hsm`). -/
theorem fullCallOf {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hr : FullR P NB M S.tab.length x y)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hact : (bridgeOf x).active = false) (hobs : obsOk (mlxOf x) name args = true)
    (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) (hka : KernAcc P (mlxOf x) name args)
    (haa : Host.Mlx.Ffi.symOf name = some .arrayFree → ∀ a, args = [a] → hdOk (mlxOf x) a = true)
    (hsm : isSymShape name = true → ∀ a S', interpS (Host.Load.call (toLoad x) name args).run S = some (a, S') →
      a.isSome = true)
    (hg : MSim (G.LPost P NB M ν S C) S C (Host.Load.call (toLoad x) name args)
      (Host.Load.call (toLoad y) name (args.map M.arg))) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullR P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  have hacty : (bridgeOf y).active = false := by rw [hr.bridge.1]; exact hact
  rw [full_call_mlx x name args hm hp hact, full_call_mlx y name _ hm hp hacty]
  have hg2 := MSim.both hg (loadFfiLawful.call _ _ _) (loadFfiLawful.call _ _ _)
  refine MSim.bind hg2 fun M' S' C' a b hab => ?_
  obtain ⟨⟨hgr, hcr⟩, hra, hrb⟩ := hab
  rcases a with _ | ⟨l, r, ws⟩
  · cases hsym : isSymShape name
    · rw [fullCont_none _ _ _ hsym]
      rcases b with _ | ⟨l', r', ws'⟩
      · rw [fullCont_none _ _ _ hsym]
        exact MSim.pure ⟨hgr, trivial⟩
      · rw [fullCont_some]
        exact MSim.pure ⟨hgr, trivial⟩
    · have := hsm hsym none S' hra
      cases this
  · rcases b with _ | ⟨l', r', ws'⟩
    · exact hcr.elim
    · rw [fullCont_some, fullCont_some]
      have hb : (toLoad x).mlx.next < 2 ^ 64 := by
        have := hr.load.mlx.hnext; have := hr.load.mlx.hroom; omega
      refine full_some_post hr hgr hcr (keep_of_run hm hra) (keep_of_runC hm hrb) hobs hsupp hka haa
        (fun hs ha => ?_) (fun hs hl => ?_)
      · subst ha
        have hra' : interpS (Host.Load.call (toLoad x) name []).run S = some (some (l, r, ws), S') := hra
        rw [load_call_cfgNew _ _ hm hs] at hra'
        simp only [Host.Ts.M.run, Host.Ts.M.pure, interpS_pure, Option.some.injEq, Prod.mk.injEq] at hra'
        obtain ⟨⟨rfl, rfl, -⟩, -⟩ := hra'
        refine ⟨rfl, ?_⟩
        show ((((toLoad x).mlx.objs.set (toLoad x).mlx.next _)).get (toLoad x).mlx.next).isSome = true
        rw [PTrie.get_set_u64 _ _ _ hb]
        simp
      · rcases args with _ | ⟨a0, _ | ⟨a1, _ | ⟨a2, _ | ⟨a3, _ | ⟨a4, _ | ⟨rc, _ | ⟨ao, _ | ⟨_, _⟩⟩⟩⟩⟩⟩⟩⟩ <;>
          try (simp only [List.length_cons, List.length_nil] at hl; omega)
        exact (load_kernelNew_res (toLoad x) hm hs hb a0 a1 a2 a3 a4 rc ao).1 S _ S' hra l r ws rfl

/-- **The full world's native-call simulation over a load-world simulation** `hsim` whose accepted
calls the observers read (`hka`, `haa`). -/
theorem fullCallSimG {ok : LoadP → Host.Load.LSt → Name → List Arg → Bool}
    {sm : (Nat → F64) → SSrv → Host.Load.LSt → Name → List Arg → Prop} (P : LoadP) (NB : Nat)
    (hsim : FfiCallSim Host.Load.ffi (G.LoadR P NB) (ok P) sm)
    (hka : ∀ l name args, ok P l name args = true → KernAcc P l.mlx name args)
    (haa : ∀ l name args, ok P l name args = true →
      Host.Mlx.Ffi.symOf name = some .arrayFree → ∀ a, args = [a] → hdOk l.mlx a = true) :
    FfiCallSim FF (FullR P NB) (okCallFG ok P) (smallFG sm) where
  call := by
    intro M ν S C x y name args hsrv hr hok hsupp hsm
    simp only [okCallFG, Bool.and_eq_true, Bool.not_eq_true'] at hok
    obtain ⟨⟨⟨⟨hm, hp⟩, hact⟩, hsg⟩, hobs⟩ := hok
    exact fullCallOf hr hm hp hact hobs hsupp (hka _ _ _ hsg) (haa _ _ _ hsg) hsm.2
      (hsim.call M ν S C (toLoad x) (toLoad y) name args hsrv hr.load hsg hsupp hsm.1)

/-- **The full world's native-call simulation** with the bridge inactive. -/
theorem fullCallSim (P : LoadP) (NB : Nat) : FfiCallSim FF (FullR P NB) (okCallF P) smallF :=
  fullCallSimG P NB (G.loadFfiCallSim P NB) (fun _ _ _ => kernAcc_of) (fun _ _ _ => arrAcc_of)

end Host.Ts.Sim.Full
