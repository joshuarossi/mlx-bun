import host.sim.full.BridgeFrame

/-! # The symbolic-shape layer's calls with the target's bridge framed

The layer completes `mlx_reshape` and `mlx_conv1d` where the template's call is stuck over symbolic
shapes (`fullCallSymSim`). With the target's bridge active, the target's call is the model's call, its
bridge update, and the layer where either is stuck (`full_call_active`): it is the layer-completed call
followed by the bridge update (`symIdeal`) wherever the update after the model's call succeeds. It
does: the call adds at most one node, over the arguments' nodes (`opOut_newIns`), the images of the
template's, which a quiet bridge does not alias (`after_newIns`). So the target's call runs as
`symIdeal` (`MSim.bind_congrR`), which simulates the template's (`fullCallSymF`). -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep AllX)
open Host.Ts.Sim.BufSim (Lawful)
open Host.Mlx.Ffi.SymShape (callSym symShapeCall)
open Host.Mlx.Ffi (Prim)

/-! ## Running a computation through a congruent continuation -/

/-- The target's computation with a continuation agreeing on the results `R` of its first stage. -/
theorem MSim.bind_congrR {α β β' : Type} {P : Map → SSrv → CSrv → α → β' → Prop} {S : SSrv} {C : CSrv}
    {t : Host.Ts.M α} {m : Host.Ts.M β} {f g : β → Host.Ts.M β'} {R : β → Prop} (hm : Lawful m) (hR : AllX R m)
    (hfg : ∀ b, R b → f b = g b) (h : MSim P S C t (Host.Ts.M.bind m g)) : MSim P S C t (Host.Ts.M.bind m f) := by
  intro γ δ Q k k' hk a S' hu
  obtain ⟨M', b, C', hc, hq⟩ := h γ δ Q k k' hk a S' hu
  refine ⟨M', b, C', ?_, hq⟩
  have hc' : interpC (m δ fun x => g x δ k') C = some (b, C') := hc
  show interpC (m δ fun x => f x δ k') C = some (b, C')
  rw [hm.2] at hc' ⊢
  cases e : interpC m.run C with
  | none => rw [e] at hc'; cases hc'
  | some p =>
    rw [e] at hc'
    have hp := hfg p.1 (hR.2 C p.1 p.2 e)
    simp only [Option.bind_some] at hc' ⊢
    rw [hp]; exact hc'

/-! ## The model's new nodes -/

/-- The nodes a native result adds over the state `s` have inputs `ins`. -/
def NewIns (s : NSt) (ins : List Nat) (o : Option (NSt × Ret × List (Nat × Nat × List Byte))) : Prop :=
  ∀ s' r ws, o = some (s', r, ws) → ∀ m, s.nnext ≤ m → m < s'.nnext → ∀ nd, s'.nodes.get m = some nd → nd.ins = ins

theorem setArr_nodes (s : NSt) (slot n : Nat) :
    (s.setArr slot n).2.nodes = s.nodes ∧ (s.setArr slot n).2.nnext = s.nnext := by
  unfold Host.Mlx.Ffi.St.setArr; cases Nat.beq slot 0 <;> exact ⟨rfl, rfl⟩

/-- **An operation adds at most one node, over its inputs.** -/
theorem opOut_newIns (s : NSt) (hs : s.nnext < 2 ^ 62) (o : Arg) (p : Prim) (ins : List Nat) :
    AllX (NewIns s ins) (Host.Mlx.Ffi.opOut s o p ins) := by
  unfold Host.Mlx.Ffi.opOut
  split
  · refine AllX.bind' (Host.Ts.Sim.NativeLawful.infer_l _ _) fun r => ?_
    split
    · refine AllX.pure fun s' r ws e m h1 h2 nd hnd => ?_
      cases e
      have hm : m = s.nnext := by
        revert h2; split <;> (intro h2; dsimp only at h2; omega)
      subst hm
      revert hnd; split <;> (intro hnd; dsimp only at hnd; rw [get_set_eq_of_lt _ _ hs] at hnd; cases hnd; rfl)
    · split
      · refine AllX.pure fun s' r ws e m h1 h2 nd hnd => ?_
        cases e
        revert h2; split <;> (intro h2; dsimp only at h2; omega)
      · exact AllX.pure fun _ _ _ e => by cases e
    · exact AllX.pure fun _ _ _ e => by cases e
  · exact AllX.pure fun _ _ _ e => by cases e

theorem stuck_newIns (s : NSt) (ins : List Nat) : AllX (NewIns s ins) Host.Mlx.Ffi.stuck :=
  AllX.pure fun _ _ _ e => by cases e

/-- `mlx_reshape` adds at most one node, over the array argument's node. -/
theorem call_reshape_newIns {s : NSt} (hs : s.nnext < 2 ^ 62) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .reshape)
    {o a sh n e : Arg} {ins : List Nat} (h1 : Host.Mlx.Ffi.arrIns s [a] = some ins) :
    AllX (NewIns s ins) (Host.Mlx.Ffi.call s name [o, a, sh, n, e]) := by
  cases h2 : Host.Mlx.Ffi.dimsArg sh n with
  | none =>
    have : Host.Mlx.Ffi.call s name [o, a, sh, n, e] = Host.Mlx.Ffi.stuck := by
      unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [h1, h2]
    rw [this]; exact stuck_newIns s ins
  | some new => rw [(G.reshape_decode s hsym h1 h2).1]; exact opOut_newIns s hs _ _ ins

/-- `mlx_conv1d` adds at most one node, over the array arguments' nodes. -/
theorem call_conv1d_newIns {s : NSt} (hs : s.nnext < 2 ^ 62) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .conv1d)
    {o a w st pd dl gr e : Arg} {ins : List Nat} (h1 : Host.Mlx.Ffi.arrIns s [a, w] = some ins) :
    AllX (NewIns s ins) (Host.Mlx.Ffi.call s name [o, a, w, st, pd, dl, gr, e]) := by
  cases e1 : Host.Mlx.Ffi.argNat st with
  | none =>
    have : Host.Mlx.Ffi.call s name [o, a, w, st, pd, dl, gr, e] = Host.Mlx.Ffi.stuck := by
      unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [h1, e1]
    rw [this]; exact stuck_newIns s ins
  | some v1 =>
    cases e2 : Host.Mlx.Ffi.argNat pd with
    | none =>
      have : Host.Mlx.Ffi.call s name [o, a, w, st, pd, dl, gr, e] = Host.Mlx.Ffi.stuck := by
        unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [h1, e1, e2]
      rw [this]; exact stuck_newIns s ins
    | some v2 =>
      cases e3 : Host.Mlx.Ffi.argNat dl with
      | none =>
        have : Host.Mlx.Ffi.call s name [o, a, w, st, pd, dl, gr, e] = Host.Mlx.Ffi.stuck := by
          unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [h1, e1, e2, e3]
        rw [this]; exact stuck_newIns s ins
      | some v3 =>
        cases e4 : Host.Mlx.Ffi.argNat gr with
        | none =>
          have : Host.Mlx.Ffi.call s name [o, a, w, st, pd, dl, gr, e] = Host.Mlx.Ffi.stuck := by
            unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [h1, e1, e2, e3, e4]
          rw [this]; exact stuck_newIns s ins
        | some v4 => rw [(G.conv_decode s hsym h1 e1 e2 e3 e4).1]; exact opOut_newIns s hs _ _ ins

/-- **The bridge's update is the identity** after a result whose new nodes read nodes the bridge does not
alias, on a bridge with nothing scheduled or running. -/
theorem after_newIns {b : BSt} (hu : b.unscheduled = []) (hrun : b.running = []) {s s' : NSt} {ins : List Nat}
    (hins : ∀ i ∈ ins, b.aliases.get i = none) {r : Ret} {ws : List (Nat × Nat × List Byte)}
    (hn : NewIns s ins (some (s', r, ws))) (name : Name) (args : List Arg) :
    Host.Mlx.FfiAne.after b s s' name args = some b := by
  unfold Host.Mlx.FfiAne.after
  cases Host.Mlx.FfiAne.evalCall s name args with
  | roots ns bl => exact schedule_quiet hu hrun s ns bl
  | all => show some { b with running := [] } = some b; cases b; cases hrun; rfl
  | other =>
    refine classify_nil _ _ fun m h1 h2 h3 nd hnd i hi => ?_
    rw [hn s' r ws rfl m h1 h3 nd hnd] at hi
    exact hins i hi

theorem shapesOf_present {s : NSt} : ∀ {ins : List Nat} {sh : List (List Host.Mlx.Ffi.Dim × Nat)},
    Host.Mlx.Ffi.shapesOf s ins = some sh → ∀ j ∈ ins, (s.nodes.get j).isSome = true
  | [], _, _, j, hj => by cases hj
  | i :: is, sh, h, j, hj => by
    unfold Host.Mlx.Ffi.shapesOf at h
    obtain ⟨nd, hnd, h'⟩ := Option.bind_eq_some_iff.mp h
    obtain ⟨sh', hsh', -⟩ := Option.map_eq_some_iff.mp h'
    rcases List.mem_cons.mp hj with rfl | hj
    · rw [hnd]; rfl
    · exact shapesOf_present hsh' j hj

theorem AllX.imp {α : Type} {P Q : α → Prop} {m : Host.Ts.M α} (h : AllX P m) (hpq : ∀ a, P a → Q a) : AllX Q m :=
  ⟨fun S a S' e => hpq a (h.1 S a S' e), fun C a C' e => hpq a (h.2 C a C' e)⟩

/-- The bridge's update after the target's model call, at every result. -/
def AfterOk (b : BSt) (s : NSt) (name : Name) (args : List Arg)
    (o : Option (NSt × Ret × List (Nat × Nat × List Byte))) : Prop :=
  ∀ m r ws, o = some (m, r, ws) → Host.Mlx.FfiAne.after b s m name args = some b

/-- **The layer's calls of an accepted call update a quiet bridge by the identity**, at every result of
the target's model call: its new node reads the images of the template's argument nodes. -/
theorem symShapeOk_after {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} {b : BSt} (hr : G.MR P NB M n x y)
    (hq : Quiet M x y b) {name : Name} {args : List Arg} (hok : G.symShapeOk P x name args = true) :
    AllX (AfterOk b y name (args.map M.arg)) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  have himg : ∀ {ins : List Nat} {sh : List (List Host.Mlx.Ffi.Dim × Nat)}, Host.Mlx.Ffi.shapesOf x ins = some sh →
      ∀ i ∈ ins.map M.node, b.aliases.get i = none := fun hsh i hi => by
    obtain ⟨j, hj, rfl⟩ := List.mem_map.mp hi
    exact hq.img j (hr.nlt j (shapesOf_present hsh j hj))
  have hfin : ∀ {ins : List Nat} {sh : List (List Host.Mlx.Ffi.Dim × Nat)}, Host.Mlx.Ffi.shapesOf x ins = some sh →
      ∀ o, NewIns y (ins.map M.node) o → AfterOk b y name (args.map M.arg) o := fun hsh o hn m r ws e => by
    subst e
    exact after_newIns hq.unscheduled hq.running (himg hsh) hn name _
  unfold G.symShapeOk at hok
  split at hok
  · rename_i hsym
    unfold G.NativeOkX.conv1dS at hok
    split at hok
    · rename_i o a w st pd dl gr e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨⟨⟨⟨⟨ha, hw⟩, -⟩, -⟩, -⟩, -⟩, -⟩, hm⟩ := hok
      split at hm
      · rename_i ins pad dil g h1 e1 e2 e3 e4
        split at hm
        · rename_i _ _ _ _ _ _ _ _ hsh
          have h1' := hr.arrIns_some (as := [a, w]) (fun c hc => by
            rcases List.mem_cons.mp hc with rfl | hc
            · exact ha
            · rcases List.mem_singleton.mp hc with rfl; exact hw) h1
          exact AllX.imp (call_conv1d_newIns hr.ynnext_lt hsym h1') (hfin hsh)
        · cases hm
      · cases hm
    · cases hok
  · rename_i hsym
    unfold G.NativeOkX.reshapeS at hok
    split at hok
    · rename_i o a sh n e
      simp only [Bool.and_eq_true] at hok
      obtain ⟨⟨⟨ha, -⟩, -⟩, hm⟩ := hok
      split at hm
      · rename_i ins new h1 h2
        split at hm
        · rename_i _ _ hsh
          have h1' := hr.arrIns_some (as := [a]) (fun c hc => by rcases List.mem_singleton.mp hc with rfl; exact ha) h1
          exact AllX.imp (call_reshape_newIns hr.ynnext_lt hsym h1') (hfin hsh)
        · cases hm
      · cases hm
    · cases hok
  · cases hok

/-! ## The target's call as the layer-completed call and the bridge update -/

/-- The bridge update after a load-world result. -/
def addBA (b : BSt) (s : NSt) (name : Name) (args : List Arg) : Res Host.Load.LSt → Res Host.Load.Ane.ASt
  | some (l, r, ws) => (Host.Mlx.FfiAne.after b s l.mlx name args).map fun b' => (⟨l, b'⟩, r, ws)
  | none => none

/-- **The target's call with the bridge active, the update succeeding after the model's call**: the
layer-completed call followed by the bridge update and the observers. -/
def symIdeal (p : FF.S) (name : Name) (args : List Arg) : Host.Ts.M (Res FF.S) :=
  Host.Ts.M.bind (loadCallSym (toLoad p) name args) fun o =>
    Host.Ts.M.pure (liftF p name args (addBA (bridgeOf p) (mlxOf p) name args o))

/-- The load world's lift of a model result. -/
def liftLd (l : Host.Load.LSt) : Option (NSt × Ret × List (Nat × Nat × List Byte)) → Host.Ts.M (Res Host.Load.LSt)
  | some (m, r, ws) => Host.Ts.M.pure (some ({ l with mlx := m }, r, ws))
  | none => Host.Ts.M.pure none

/-- The layer's step after the model's call. -/
def symStepd (s : NSt) (name : Name) (args : List Arg) :
    Option (NSt × Ret × List (Nat × Nat × List Byte)) → Host.Ts.M (Option (NSt × Ret × List (Nat × Nat × List Byte)))
  | some r => Host.Ts.M.pure (some r)
  | none => symShapeCall s name args

theorem load_call_d (l : Host.Load.LSt) {name : Name} (hm : Host.Load.isMlx name = true) (args : List Arg) :
    Host.Load.call l name args = Host.Ts.M.bind (Host.Mlx.Ffi.call l.mlx name args) (liftLd l) := by
  unfold Host.Load.call
  rw [hm, Bool.cond_true]
  refine congrArg (Host.Ts.M.bind _) (funext fun o => ?_)
  rcases o with _ | ⟨m, r, ws⟩ <;> rfl

theorem loadCallSym_d (l : Host.Load.LSt) (name : Name) (args : List Arg) :
    loadCallSym l name args = Host.Ts.M.bind (Host.Mlx.Ffi.call l.mlx name args) fun o =>
      Host.Ts.M.bind (symStepd l.mlx name args o) (liftLd l) := by
  unfold loadCallSym callSym
  rw [G.mbind_assoc]
  refine congrArg (Host.Ts.M.bind _) (funext fun o => ?_)
  rcases o with _ | ⟨m, r, ws⟩
  · show Host.Ts.M.bind (symShapeCall l.mlx name args) _ = Host.Ts.M.bind (symShapeCall l.mlx name args) _
    refine congrArg (Host.Ts.M.bind _) (funext fun q => ?_)
    rcases q with _ | ⟨m', r', ws'⟩ <;> rfl
  · rfl

theorem symFB_none (a : Host.Load.Ane.ASt) {name : Name} {args : List Arg} (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) :
    symFB a name args none = Host.Ts.M.bind (symShapeCall a.base.mlx name args) fun
      | some (m, r, ws) => Host.Ts.M.pure (bif a.bridge.active then
          (Host.Mlx.FfiAne.after a.bridge a.base.mlx m name args).map fun b => (⟨{ a.base with mlx := m }, b⟩, r, ws)
        else some (⟨{ a.base with mlx := m }, a.bridge⟩, r, ws))
      | none => Host.Ts.M.pure none := by
  unfold symFB
  rw [show (Host.Load.isMlx name && !nameEq name Host.Mlx.FfiAne.payloadName) = true by rw [hm, hp]; rfl,
    Bool.cond_true]
  rfl

/-- **The target's call runs as `symIdeal`** where the bridge update after the model's call succeeds. -/
theorem msim_symIdeal {α : Type} {Q : Map → SSrv → CSrv → α → Res FF.S → Prop} {S : SSrv} {C : CSrv}
    {t : Host.Ts.M α} (p : FF.S) {name : Name} {args : List Arg} (hm : Host.Load.isMlx name = true)
    (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (ha : (bridgeOf p).active = true)
    (hR : AllX (AfterOk (bridgeOf p) (mlxOf p) name args) (Host.Mlx.Ffi.call (mlxOf p) name args))
    (h : MSim Q S C t (symIdeal p name args)) : MSim Q S C t (FF.call p name args) := by
  rw [full_call_active p name args hm hp ha, load_call_d _ hm, G.mbind_assoc]
  unfold symIdeal at h
  rw [loadCallSym_d, G.mbind_assoc] at h
  refine MSim.bind_congrR (Host.Ts.Sim.NativeLawful.mlx_call_l _ _ _) hR ?_ h
  intro o ho
  rcases o with _ | ⟨m, r, ws⟩
  · show Host.Ts.M.bind (symFB p.1.1 name args none) (fun o' => Host.Ts.M.pure (liftF p name args o')) =
      Host.Ts.M.bind (Host.Ts.M.bind (symShapeCall (mlxOf p) name args) (liftLd (toLoad p)))
        (fun o => Host.Ts.M.pure (liftF p name args (addBA (bridgeOf p) (mlxOf p) name args o)))
    rw [symFB_none p.1.1 hm hp, G.mbind_assoc, G.mbind_assoc]
    refine congrArg (Host.Ts.M.bind _) (funext fun q => ?_)
    rcases q with _ | ⟨m', r', ws'⟩
    · rfl
    · show Host.Ts.M.pure (liftF p name args (bif p.1.1.bridge.active then _ else _)) = _
      rw [show p.1.1.bridge.active = true from ha, Bool.cond_true]
      rfl
  · have hb := ho m r ws rfl
    show fullContA p name args (some ({ toLoad p with mlx := m }, r, ws)) = _
    rw [fullContA_some p name args (l := { toLoad p with mlx := m }) hb]
    show _ = Host.Ts.M.pure (liftF p name args (addBA (bridgeOf p) (mlxOf p) name args
      (some ({ toLoad p with mlx := m }, r, ws))))
    simp only [addBA, hb, Option.map_some]

/-- **The layer's completed calls with the target's bridge framed and active.** -/
theorem fullCallSymF {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : FF.S}
    {name : Name} {args : List Arg} (hsrv : Srv M ν S C) (hr : FullRF P NB M S.tab.length x y)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false)
    (hact : (bridgeOf x).active = false) (hact' : (bridgeOf y).active = true)
    (hq : Quiet M (mlxOf x) (mlxOf y) (bridgeOf y)) (hok : G.symShapeOk P (mlxOf x) name args = true)
    (hobs : obsOk (mlxOf x) name args = true) (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a)
    (hsm : G.symShapeSmall ν S (mlxOf x) name args) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR (F := FF) (FullRFb (bridgeOf y) P NB) M' S'.tab.length r r') S C
      (FF.call x name args) (FF.call y name (args.map M.arg)) := by
  refine msim_symIdeal y hm hp hact' (symShapeOk_after hr.load.mlx hq hok) ?_
  rw [full_call_sym x name args hm hp hact]
  have hg := mlx_liftS hr.load (G.mlx_simSS hsrv hr.load.mlx args hok hsm)
  have hg2 := MSim.both hg (loadCallSym_l _ _ _) (loadCallSym_l _ _ _)
  refine MSim.bind hg2 fun M' S' C' a o hab => ?_
  obtain ⟨⟨hgr, hcr⟩, hra, hrb⟩ := hab
  have hs := symShapeOk_sym hok
  rcases a with _ | ⟨l, r, ws⟩
  · exact MSim.pure ⟨hgr, trivial⟩
  · rcases o with _ | ⟨l', r', ws'⟩
    · exact hcr.elim
    · have kx := keepS_of_run hra
      have ky := keepS_of_runC hrb
      have haf := after_quiet hr.load.mlx hcr.1.mlx hgr.ext.node kx hq name (args.map M.arg)
      have e : addBA (bridgeOf y) (mlxOf y) name (args.map M.arg) (some (l', r', ws')) =
          some (⟨l', bridgeOf y⟩, r', ws') := by simp only [addBA, haf, Option.map_some]
      show MSim _ S' C' (Host.Ts.M.pure (liftF x name args (some (⟨l, bridgeOf x⟩, r, ws))))
        (Host.Ts.M.pure (liftF y name (args.map M.arg) (addBA (bridgeOf y) (mlxOf y) name (args.map M.arg)
          (some (l', r', ws')))))
      rw [e]
      refine full_some_postX hr hgr hcr kx ky hobs hsupp ?_ ?_ ?_ ?_
        (fun _ _ _ _ => ⟨⟨hr.bridge.1, .inr (hq.step hr.load.mlx hgr.ext.node ky)⟩, rfl⟩)
      · intro s' hs'
        rcases hs with e | e <;> rw [e] at hs' <;> cases hs' <;>
          exact ⟨(fun h => nomatch h), (fun h => by rcases h with h | h | h <;> cases h)⟩
      · intro hs'
        rcases hs with e | e <;> rw [e] at hs' <;> cases hs'
      · intro hs'
        rcases hs with e | e <;> rw [e] at hs' <;> cases hs'
      · intro hs'
        rcases hs with e | e <;> rw [e] at hs' <;> cases hs'

end Host.Ts.Sim.Full
