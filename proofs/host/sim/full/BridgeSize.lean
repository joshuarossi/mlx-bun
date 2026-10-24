import host.sim.dispatch.BridgeNewData
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim BufSim

/-! # Bridge B-size: `Number(C.mlx_array_size(h))`

`get size()` (`packages/mlx/src/array.ts:238`) is `Number(C.mlx_array_size(this.handle))`. Over a
symbolic shape the template's native call returns a number (the symbolic-shape layer's product,
`Ret.num`) where the target's returns a bigint (`Ret.big`): the two returns are not related, but
their `Number` conversions are (`numRet`: a number unchanged, a bigint `i` to `intV i`). The bridge
is the block of three steps at the call state: the native call, the argument frame of `Number`
receiving its return (`argsNext`) and `Number` (`numN .number`) (`sizeS`). The template's
transition is that block, which produces the number directly (its call returns it and `Number`
keeps it); the target runs the same block. The native side is the interface `SizeCallSim`: the
calls give related native states and returns related through `Number` (`SizeR`). The frames
stay, the event bases restart at the call, and the two events are exported with their returns
related through `Number`. -/

/-- The value `Number` makes of a native return. -/
def numRet : Ret → Option Val
  | .num x => some (.num x)
  | .big i => some (intV i)
  | _ => none

theorem numRet_nocb {ret : Ret} {v : Val} (h : numRet ret = some v) : ∀ f cs, ret ≠ .callback f cs := by
  intro f cs he; subst he; cases h

/-- The results of a size call: related native states, no buffer writes, returns related through
`Number`, the template's value supported by `A`. -/
def SizeR {F : Ffi} (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (n : Nat) (A : Nat → Prop) :
    Option (F.S × Ret × List (Nat × Nat × List Byte)) → Option (F.S × Ret × List (Nat × Nat × List Byte)) → Prop
  | none, _ => True
  | some (x, ret, ws), some (y, ret', ws') =>
    FR M n x y ∧ ws = [] ∧ ws' = [] ∧ ∃ v, numRet ret = some v ∧ numRet ret' = some (M.val v) ∧ Supp.val A n v
  | some _, none => False

/-- The native side of B-size (to be supplied by the native relation): calling `name` gives results
related by `SizeR`, under the premise `Pre ν S x as` the template's run discharges. -/
def SizeCallSim (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (name : Name) (A : Nat → Prop)
    (Pre : (Nat → F64) → SSrv → F.S → List Arg → Prop) : Prop :=
  ∀ M ν S C x y (as : List Arg), Srv M ν S C → FR M S.tab.length x y → (∀ a ∈ as, Supp.arg A S.tab.length a) →
    Pre ν S x as →
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ SizeR FR M' S'.tab.length A r r') S C
      (F.call x name as) (F.call y name (as.map M.arg))

/-- **B-size's transition**: the native call, the argument frame of `Number` and `Number`. -/
def sizeS (F : Ffi) (s : St F.S) : RS F :=
  Host.Ts.M.bind (step F s) fun s1 => Host.Ts.M.bind (step F s1) (step F)

section
variable {F : Ffi}

/-- After the native call: the return received by `Number`'s argument frame, then `Number`. -/
theorem size_tail {u : St F.S} {ret : Ret} {w : Val} {nf : Nat} {thisN : Val} {env : Env} {fs : List Frame}
    {o : Obj} {data : List Val} (hc : u.ctl = .ret (retVal ret)) (hs : u.stack = .c (.args 0 (.obj nf) thisN [] [] env) :: fs)
    (ho : u.obj? nf = some o) (hk : o.kind = .fn (.native (.num .number) data)) (hw : numRet ret = some w) :
    Host.Ts.M.bind (step F u) (step F) = Host.Ts.M.pure ({ u with stack := fs }.ret w) := by
  have e1 : step F u = Host.Ts.M.pure ({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret])) := by
    simp only [step, hc, stepRet, hs]
    rfl
  rw [e1]
  have ho' : ({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret]) : St F.S).obj? nf = some o := ho
  show step F ({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret])) = _
  have hc2 : ({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret]) : St F.S).ctl =
      .call (.obj nf) thisN [retVal ret] := rfl
  have e2 : step F ({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret])) =
      numN F ({ u with stack := fs }.go (.call (.obj nf) thisN [retVal ret])) thisN [retVal ret] .number := by
    simp only [step, hc2, callStep, ho', hk]
    rfl
  rw [e2]
  cases ret with
  | num x => cases hw; rfl
  | big i => cases hw; rfl
  | _ => cases hw

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

theorem mbind_assoc' {α β γ : Type} (m : Host.Ts.M α) (f : α → Host.Ts.M β) (g : β → Host.Ts.M γ) :
    Host.Ts.M.bind (Host.Ts.M.bind m f) g = Host.Ts.M.bind m fun a => Host.Ts.M.bind (f a) g := rfl

/-- **B-size.** A `dlopen` symbol called as the only argument of `Number` (`Number(C.f(…))`): the
template's and the target's blocks (`sizeS`) end related, the template's `Number` value mapped to
the target's; the frames stay, the event bases restart at the call, and the two events are
exported with their returns related through `Number`. -/
theorem bridge_size (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack)
    {fsym ta nf : Nat} {this thisN : Val} {args : List Val} {fo oa no : Obj} {name rt : Name} {tys : List Val}
    {ndata : List Val} {env : Env} {fs : List Frame} {Pre : (Nat → F64) → SSrv → F.S → List Arg → Prop}
    (hc : s.ctl = .call (.obj fsym) this args) (hfo : s.obj? fsym = some fo)
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]))
    (hta : s.obj? ta = some oa) (htk : oa.kind = .array tys) (hfr : K.fr ta = none)
    (hst : s.stack = .c (.args 0 (.obj nf) thisN [] [] env) :: fs) (hno : s.obj? nf = some no)
    (hnk : no.kind = .fn (.native (.num .number) ndata))
    (hbuf : ∀ v ∈ args, ArgBufOK F K W s S.tab.length v) (hbool : ∀ ty v, Val.str ty ∈ tys → v ∈ args → BoolOK K ty v)
    (hpre : ∀ asR S1, interpS (decodeArgs F s tys args).run S = some (some asR, S1) → Pre ν S1 s.ffi asR)
    (hcall : SizeCallSim F FR name (Present s) Pre) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB F FR W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
        numRet ret = some v ∧ numRet ret' = some (M'.val v)) S C
      (sizeS F s) (sizeS F t) := by
  -- the callee, its signature and `Number`, unframed
  have hfrS : K.fr fsym = none :=
    h.bi_fr hfo (by rw [hk]; intro es he; cases he) (by rw [hk]; exact fun hw => hw)
  have hto : t.obj? (M.a fsym) = some (M.obj fo) := h.obj? hfo hfrS
  have htk' : (M.obj fo).kind = .fn (.native (.ffi .symbol) (M.vals [.str name, .obj ta, .str rt])) := by
    show M.kind fo.kind = _; rw [hk]; rfl
  have htc : t.ctl = .call (.obj (M.a fsym)) (M.val this) (M.vals args) := by
    rw [show t.ctl = _ from h.ctl, hc]; rfl
  have htt : t.obj? (M.a ta) = some (M.obj oa) := h.obj? hta hfr
  have hfrN : K.fr nf = none :=
    h.bi_fr hno (by rw [hnk]; intro es he; cases he) (by rw [hnk]; exact fun hw => hw)
  have htN : t.obj? (M.a nf) = some (M.obj no) := h.obj? hno hfrN
  have htNk : (M.obj no).kind = .fn (.native (.num .number) (M.vals ndata)) := by
    show M.kind no.kind = _; rw [hnk]; rfl
  have hso : Supp.vals (Present s) S.tab.length tys := by
    have := (h.obj?_supp hta).1; rw [htk] at this; exact this
  have hargs := (call_supp h hc).2
  obtain ⟨hts, -⟩ := h.pop hst
  obtain ⟨kd, pr, ps, pv, ex⟩ := oa
  simp only at htk
  subst htk
  have htA : t.obj? (M.a ta) = some ⟨.array (M.vals tys), M.val pr, M.props ps, M.privs pv, ex⟩ := by
    rw [htt]; rfl
  -- the native calls
  have es : step F s = Host.Ts.M.bind (decodeArgs F s tys args) (symK F s name rt) := by
    have e : step F s = callNative F s (.ffi .symbol) [.str name, .obj ta, .str rt] this args := by
      simp only [step, hc, callStep, hfo, hk]
    rw [e]
    show ffiN F s this args [.str name, .obj ta, .str rt] .symbol = _
    exact ffiN_symbol_eq hta
  have et : step F t = Host.Ts.M.bind (decodeArgs F t (M.vals tys) (M.vals args)) (symK F t name rt) := by
    have e : step F t = callNative F t (.ffi .symbol) (M.vals [.str name, .obj ta, .str rt]) (M.val this)
        (M.vals args) := by
      simp only [step, htc, callStep, hto, htk']
    rw [e]
    show ffiN F t (M.val this) (M.vals args) [.str name, .obj (M.a ta), .str rt] .symbol = _
    exact ffiN_symbol_eq htA
  unfold sizeS
  rw [es, et, mbind_assoc', mbind_assoc']
  refine MSim.bind (MSim.withRun (decodeArgs_sim hFR hF tys args h hso hargs hbuf hbool)
    (decodeArgs_lawful _ _ _ _) (decodeArgs_lawful _ _ _ _)) ?_
  rintro M1 S1 C1 r r' ⟨⟨rfl, g1, hs1⟩, hrun⟩
  cases r with
  | none => exact MSim.fail _ _
  | some asR =>
    have h1 := h.grow hFR g1
    have hc1 := hcall M1 ν S1 C1 s.ffi t.ffi asR h1.srv h1.ffi (hs1 asR rfl) (hpre asR S1 hrun)
    show MSim _ S1 C1 (Host.Ts.M.bind (symK F s name rt (some asR)) _)
      (Host.Ts.M.bind (symK F t name rt (some (asR.map M1.arg))) _)
    simp only [symK]
    rw [mbind_assoc', mbind_assoc']
    refine MSim.bind hc1 ?_
    rintro M2 S2 C2 cr cr' ⟨g2, hd⟩
    cases cr with
    | none => exact MSim.fail _ _
    | some p =>
      obtain ⟨x, ret, ws⟩ := p
      cases cr' with
      | none => exact hd.elim
      | some p' =>
        obtain ⟨y, ret', ws'⟩ := p'
        obtain ⟨hxy, rfl, rfl, v, hv, hv', hsv⟩ := hd
        rw [ffiDone_nocb (numRet_nocb hv), ffiDone_nocb (numRet_nocb hv')]
        have g := g1.trans g2
        let es := (⟨name, asR, ret⟩ : Event) :: s.trace
        let et' := (⟨name, asR.map M1.arg, ret'⟩ : Event) :: t.trace
        show MSim _ S2 C2 (Host.Ts.M.bind (step F (((s.setFfi x).setTrace es).ret (retVal ret))) (step F))
          (Host.Ts.M.bind (step F (((t.setFfi y).setTrace et').ret (retVal ret'))) (step F))
        have h2 := ((h.grow hFR g).setFfi x y hxy).setTraceBase es et'
        obtain ⟨hts2, h3⟩ := h2.pop hst
        have htN2 : ((t.setFfi y).setTrace et').obj? (M2.a nf) = some (M.obj no) := by
          rw [g.ext.a]; exact htN
        rw [size_tail (u := ((s.setFfi x).setTrace es).ret (retVal ret)) rfl hst hno hnk hv,
          size_tail (u := ((t.setFfi y).setTrace et').ret (retVal ret')) (nf := M2.a nf) rfl hts2 htN2 htNk hv']
        exact MSim.pure ⟨g, h3.ret v hsv, asR, ret, _, ret', v, rfl, rfl, hv, hv'⟩

end
/-! ## The bridge state -/

/-- B-size's call state: the callee symbol and its signature array, `Number`'s object, the
symbol's name and return type, the signature's argument types and the call's arguments. -/
def sizeParts {S : Type} (s : St S) : Option (Nat × Nat × Nat × Name × Name × List Val × List Val) :=
  match s.ctl, s.stack with
  | .call (.obj fsym) _ args, .c (.args 0 (.obj nf) _ [] [] _) :: _ => match s.obj? fsym, s.obj? nf with
    | some fo, some no => match fo.kind, no.kind with
      | .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]), .fn (.native (.num .number) _) =>
        match s.obj? ta with
        | some oa => match oa.kind with
          | .array tys => some (fsym, ta, nf, name, rt, tys, args)
          | _ => none
        | none => none
      | _, _ => none
    | _, _ => none
  | _, _ => none

/-- The call's arguments are bigints (handles) and no parameter is a `bool`. -/
def sizeArgsOk {S : Type} (s : St S) : Bool :=
  match sizeParts s with
  | some (_, _, _, _, _, tys, args) =>
    args.all (fun v => match v with | .big _ => true | _ => false) &&
      tys.all fun t => match t with | .str ty => !nameEq ty (chars!"bool") | _ => true
  | none => false

theorem sizeParts_spec {S : Type} {s : St S} {fsym ta nf : Nat} {name rt : Name} {tys args : List Val}
    (h : sizeParts s = some (fsym, ta, nf, name, rt, tys, args)) :
    ∃ this thisN env fs fo no oa ndata, s.ctl = .call (.obj fsym) this args ∧ s.obj? fsym = some fo ∧
      fo.kind = .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]) ∧ s.obj? ta = some oa ∧
      oa.kind = .array tys ∧ s.stack = .c (.args 0 (.obj nf) thisN [] [] env) :: fs ∧ s.obj? nf = some no ∧
      no.kind = .fn (.native (.num .number) ndata) := by
  unfold sizeParts at h
  split at h
  · rename_i fsym' this args' nf' thisN env fs hc hs
    split at h
    · rename_i fo no hfo hno
      split at h
      · rename_i name' ta' rt' ndata hk hnk
        split at h
        · rename_i oa hta
          split at h
          · rename_i tys' htk
            simp only [Option.some.injEq, Prod.mk.injEq] at h
            obtain ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩ := h
            exact ⟨this, thisN, env, fs, fo, no, oa, ndata, hc, hfo, hk, hta, htk, hs, hno, hnk⟩
          · cases h
        · cases h
      · cases h
    · cases h
  · cases h

theorem sizeArgs_spec {F : Ffi} {K : Ctx} {W : Nat → Option WFrame} {s : St F.S} {n : Nat} {fsym ta nf : Nat}
    {name rt : Name} {tys args : List Val} (hp : sizeParts s = some (fsym, ta, nf, name, rt, tys, args))
    (h : sizeArgsOk s = true) :
    (∀ v ∈ args, ArgBufOK F K W s n v) ∧ (∀ ty v, Val.str ty ∈ tys → v ∈ args → BoolOK K ty v) := by
  unfold sizeArgsOk at h
  rw [hp] at h
  simp only [Bool.and_eq_true, List.all_eq_true] at h
  refine ⟨fun v hv => ?_, fun ty v hty _ hb => ?_⟩
  · have := h.1 v hv
    cases v <;> first | trivial | cases this
  · have := h.2 _ hty
    simp only [Bool.not_eq_true'] at this
    rw [this] at hb; cases hb

/-- **B-size at a call state** (`sizeParts`, `sizeArgsOk`). -/
theorem bridge_size_at {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack)
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val} {Pre : (Nat → F64) → SSrv → F.S → List Arg → Prop}
    (hp : sizeParts s = some (fsym, ta, nf, name, rt, tys, args)) (hargs : sizeArgsOk s = true)
    (hfr : K.fr ta = none)
    (hpre : ∀ asR S1, interpS (decodeArgs F s tys args).run S = some (some asR, S1) → Pre ν S1 s.ffi asR)
    (hcall : SizeCallSim F FR name (Present s) Pre) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB F FR W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
        numRet ret = some v ∧ numRet ret' = some (M'.val v)) S C
      (sizeS F s) (sizeS F t) := by
  obtain ⟨this, thisN, env, fs, fo, no, oa, ndata, hc, hfo, hk, hta, htk, hst, hno, hnk⟩ := sizeParts_spec hp
  obtain ⟨hbuf, hbool⟩ := sizeArgs_spec (K := K) (W := W) (n := S.tab.length) hp hargs
  exact bridge_size h hFR hF hc hfo hk hta htk hfr hst hno hnk hbuf hbool hpre hcall

end Host.Ts.Sim.Disp
