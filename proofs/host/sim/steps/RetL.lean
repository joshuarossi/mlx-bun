import host.sim.steps.RetC
namespace Host.Ts.Sim

/-! # Literal frames receiving a value

Array literals (`arrayNext`, spread elements) and object literals (`objNext`:
data properties, shorthand properties, methods, computed keys, spread). -/

/-- Shorthand properties name local variables. -/
def shortLocal (env : Env) : Property → Bool
  | .short n => (lookupEnv n env).isSome
  | _ => true

/-- Side condition of `objNext` over `rest`: a bounded number of properties (each
method allocates its closure), shorthand properties name local variables (a global
shorthand would read the global object after the literal's methods were installed). -/
def ObjRestOK (rest : List Property) (env : Env) : Prop :=
  rest.length ≤ 2 ^ 20 ∧ rest.all (shortLocal env) = true

instance rfDecObjRestOK (rest : List Property) (env : Env) : Decidable (ObjRestOK rest env) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-- `defineProp`-free part of `methodProp`: install the accessor half or method `c`. -/
def rfMethodSet {S : Type} (s : St S) (o : Nat) (k : PKey) (kind : MethodKind) (c : Nat) (enum : Bool) : St S :=
  match s.obj? o with
  | some ob => s.setObj o { ob with props := setPropL k (accessorProp (findProp k ob.props) kind (.obj c) enum) ob.props }
  | none => s

theorem rf_methodProp_eq (F : Ffi) (s : St F.S) (o : Nat) (k : PKey) (kind : MethodKind) (fn : Func)
    (env : Env) (enum : Bool) :
    methodProp F s o k kind fn env enum =
      rfMethodSet (s.allocObj (.fn (.closure fn env false (.obj o))) (.obj aFunctionProto) []).2 o k kind
        (s.allocObj (.fn (.closure fn env false (.obj o))) (.obj aFunctionProto) []).1 enum := rfl

theorem rf_accessorProp (M : Map) (old : Option PropV) (kind : MethodKind) (f : Val) (enum : Bool) :
    M.prop (accessorProp old kind f enum) = accessorProp (old.map M.prop) kind (M.val f) enum := by
  rcases old with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩ <;> cases kind <;> rfl

theorem rf_accessorProp_supp {A : Nat → Prop} {n : Nat} {old : Option PropV} (kind : MethodKind) {f : Val}
    (enum : Bool) (hold : Supp.oprop A n old) (hf : Supp.val A n f) : Supp.prop A n (accessorProp old kind f enum) := by
  rcases old with _ | ⟨v, w, e⟩ | ⟨g, st, e⟩ <;> cases kind
  all_goals first
    | exact hf
    | exact ⟨hf, trivial⟩
    | exact ⟨trivial, hf⟩
    | exact ⟨hf, hold.2⟩
    | exact ⟨hold.1, hf⟩

theorem rf_keyOf {M : Map} {A : Nat → Prop} {n : Nat} {k : Key} {key : PKey} (hk : keyOf k = some key) :
    M.key key = key ∧ Supp.key A n key := by
  cases k with
  | id nm => cases hk; exact ⟨rfl, trivial⟩
  | str raw =>
    simp only [keyOf, Option.map_eq_some_iff] at hk
    obtain ⟨cs, -, rfl⟩ := hk
    exact ⟨rfl, trivial⟩
  | num raw =>
    simp only [keyOf, Option.bind_eq_some_iff, Option.map_eq_some_iff] at hk
    obtain ⟨_, -, cs, -, rfl⟩ := hk
    exact ⟨rfl, trivial⟩
  | priv _ => cases hk
  | computed _ => cases hk

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-! ## Arrays -/

theorem rf_newArrayRet (h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) (hp : Present s aArrayProto)
    {vs : List Val} (hvs : Supp.vals (Present s) S.tab.length vs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (retS F (newArray s vs).2 (.obj (newArray s vs).1))
      (retS F (newArray t (M.vals vs)).2 (.obj (newArray t (M.vals vs)).1)) := by
  have h64 := rf_s64 hn
  have hP : ∀ a, Present s a → Present (s.allocObj (.array vs) (.obj aArrayProto) []).2 a :=
    fun _ ha => Present.alloc _ h64 ha
  obtain ⟨ha, hr⟩ := h.allocObj (.array vs) (.obj aArrayProto) [] hn (Supp.vals_mono hP (Nat.le_refl _) hvs)
    (hP _ hp) (fun _ hx => nomatch hx)
  have e : M.val (.obj aArrayProto) = .obj aArrayProto := congrArg Val.obj (h.intr 3 (by decide))
  rw [e] at ha hr
  have := rf_ret hr (.obj (s.allocObj (.array vs) (.obj aArrayProto) []).1) (Present.alloc_next s _ h64)
  rw [show M.val (.obj (s.allocObj (.array vs) (.obj aArrayProto) []).1) =
    .obj (M.a (s.allocObj (.array vs) (.obj aArrayProto) []).1) from rfl, ← ha] at this
  exact this

theorem rf_arrayNext (h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) (hp : Present s aArrayProto)
    {env : Env} (he : Supp.env (Present s) S.tab.length env) :
    ∀ (rest : List Elem) {acc : List Val}, Supp.vals (Present s) S.tab.length acc →
      MSim (StepPostB F FR W stk M ν K S C) S C (arrayNext F s acc rest env)
        (arrayNext F t (M.vals acc) rest (M.env env))
  | [], acc, hacc => by
    have := rf_newArrayRet h hn hp (rf_vals_supp_reverse hacc)
    rw [← rf_vals_reverse] at this
    exact this
  | .hole :: r, acc, hacc =>
    rf_arrayNext h hn hp he r (acc := .undef :: acc) fun v hv => by
      rcases List.mem_cons.1 hv with rfl | hv
      · trivial
      · exact hacc v hv
  | .expr e :: r, acc, hacc => rf_rel ((h.push (.l (.array acc r env)) ⟨hacc, he⟩).go (.ev e env) he)
  | .spread e :: r, acc, hacc => rf_rel ((h.push (.l (.spread acc r env)) ⟨hacc, he⟩).go (.ev e env) he)

/-! ## Object literals -/

theorem RelB.rfSetMethod (h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) {o c : Nat} (ho : Present s o)
    (hc : Present s c) (hfr : K.fr o = none) {k : PKey} (hk : Supp.key (Present s) S.tab.length k)
    (kind : MethodKind) (enum : Bool) :
    RelB F FR W stk M ν K (rfMethodSet s o k kind c enum) S (rfMethodSet t (M.a o) (M.key k) kind (M.a c) enum) C := by
  unfold rfMethodSet
  cases hob : s.obj? o with
  | none =>
    rw [h.obj?_none ho hob]
    exact h
  | some ob =>
    rw [h.obj? hob hfr]
    have hso := h.obj?_supp hob
    have hold : Supp.oprop (Present s) S.tab.length (findProp k ob.props) := by
      cases hf : findProp k ob.props with
      | none => trivial
      | some p => exact findProp_supp hso.2.2.1 hf
    have := h.setObj { ob with props := setPropL k (accessorProp (findProp k ob.props) kind (.obj c) enum) ob.props }
      hn ho hfr ⟨hso.1, hso.2.1, setPropL_supp hk (rf_accessorProp_supp kind enum hold (f := .obj c) hc) hso.2.2.1, hso.2.2.2⟩
    rw [Map.obj_props, setPropL_map h.inj _ hk hso.2.2.1, rf_accessorProp,
      ← findProp_map h.inj hk hso.2.2.1] at this
    exact this

theorem rf_methodSet_pres {S' : Type} (s : St S') (o : Nat) (k : PKey) (kind : MethodKind) (c : Nat)
    (enum : Bool) (ho : o < 2 ^ 64) :
    (rfMethodSet s o k kind c enum).next = s.next ∧ ∀ a, Present s a → Present (rfMethodSet s o k kind c enum) a := by
  unfold rfMethodSet
  cases s.obj? o with
  | none => exact ⟨rfl, fun _ h => h⟩
  | some ob => exact ⟨rfl, fun _ h => Present.set _ ho h⟩

theorem RelB.rfMethodProp (h : RelB F FR W stk M ν K s S t C) (hn : s.next + 1 < Sim.bound) {o : Nat} (ho : Present s o)
    (hfr : K.fr o = none) {k : PKey} (hk : Supp.key (Present s) S.tab.length k) (kind : MethodKind) (fn : Func)
    {env : Env} (he : Supp.env (Present s) S.tab.length env) (enum : Bool) (hpF : Present s aFunctionProto) :
    RelB F FR W stk M ν K (methodProp F s o k kind fn env enum) S
        (methodProp F t (M.a o) (M.key k) kind fn (M.env env) enum) C ∧
      (methodProp F s o k kind fn env enum).next = s.next + 1 ∧
      ∀ a, Present s a → Present (methodProp F s o k kind fn env enum) a := by
  have hn0 : s.next < Sim.bound := by omega
  have h64 := rf_s64 hn0
  have hP1 : ∀ a, Present s a →
      Present (s.allocObj (.fn (.closure fn env false (.obj o))) (.obj aFunctionProto) []).2 a :=
    fun _ ha => Present.alloc _ h64 ha
  obtain ⟨ha, h1⟩ := h.allocObj (.fn (.closure fn env false (.obj o))) (.obj aFunctionProto) [] hn0
    ⟨Supp.env_mono hP1 (Nat.le_refl _) he, hP1 o ho⟩ (hP1 _ hpF) (fun _ hx => nomatch hx)
  have eF : M.val (.obj aFunctionProto) = .obj aFunctionProto := congrArg Val.obj (h.intr 2 (by decide))
  rw [eF] at ha h1
  rw [rf_methodProp_eq, rf_methodProp_eq]
  have hb : Sim.bound = 2 ^ 61 := rfl
  have ho64 : o < 2 ^ 64 := by have := h.presentBound o ho; omega
  refine ⟨?_, ?_, ?_⟩
  · have ha' : (t.allocObj (.fn (.closure fn (M.env env) false (.obj (M.a o)))) (.obj aFunctionProto) []).1 =
        M.a s.next := ha
    have := h1.rfSetMethod (by show s.next + 1 < Sim.bound; exact hn) (hP1 o ho) (Present.alloc_next s _ h64) hfr
      (Supp.key_mono hP1 (Nat.le_refl _) hk) kind enum
    rw [← ha'] at this
    exact this
  · exact (rf_methodSet_pres _ o k kind _ enum ho64).1
  · exact fun a hp => (rf_methodSet_pres _ o k kind _ enum ho64).2 a (hP1 a hp)

theorem rf_shortLocal {env : Env} {n : Name} {r : List Property}
    (hl : (Property.short n :: r).all (shortLocal env) = true) :
    ∃ c, lookupEnv n env = some c := by
  simp only [List.all_cons, Bool.and_eq_true] at hl
  have := hl.1
  simp only [shortLocal] at this
  cases hc : lookupEnv n env with
  | none => rw [hc] at this; cases this
  | some c => exact ⟨c, rfl⟩

theorem rf_all_tail {env : Env} {p : Property} {r : List Property}
    (hl : (p :: r).all (shortLocal env) = true) : r.all (shortLocal env) = true := by
  simp only [List.all_cons, Bool.and_eq_true] at hl
  exact hl.2

theorem rf_objNext {o : Nat} {env : Env} : ∀ (rest : List Property) {s t : St F.S},
    RelB F FR W stk M ν K s S t C → Present s o → K.fr o = none → Supp.env (Present s) S.tab.length env →
    Present s aFunctionProto → Present s aReferenceErrorProto → s.next + rest.length < Sim.bound →
    rest.all (shortLocal env) = true → (∀ n, Property.short n ∈ rest → CellNoW K W env n) →
    MSim (StepPostB F FR W stk M ν K S C) S C (objNext F s o rest env) (objNext F t (M.a o) rest (M.env env))
  | [], s, t, h, ho, _, _, _, _, _, _, _ => rf_ret h (.obj o) ho
  | p :: r, s, t, h, ho, hfr, he, hpF, hpRef, hn, hl, hcn => by
    have hn0 : s.next < Sim.bound := by simp only [List.length_cons] at hn; omega
    have computed : ∀ (k : Key) (q : Property), (keyOf k = none) →
        MSim (StepPostB F FR W stk M ν K S C) S C
          (match k with
            | .computed ke => Host.Ts.M.pure ((s.push (.l (.objKey o q r env))).go (.ev ke env))
            | _ => Host.Ts.M.fail "object literal key")
          (match k with
            | .computed ke => Host.Ts.M.pure ((t.push (.l (.objKey (M.a o) q r (M.env env)))).go (.ev ke (M.env env)))
            | _ => Host.Ts.M.fail "object literal key") := by
      intro k q _
      cases k with
      | computed ke => exact rf_rel ((h.push (.l (.objKey o q r env)) ⟨ho, he⟩).go (.ev ke env) he)
      | _ => exact MSim.fail _ _
    cases p with
    | init k e =>
      simp only [objNext]
      cases hk : keyOf k with
      | some key =>
        obtain ⟨hkm, hks⟩ := rf_keyOf (M := M) (A := Present s) (n := S.tab.length) hk
        have := rf_rel ((h.push (.l (.objVal o key r env)) ⟨ho, hks, he⟩).go (.ev e env) he)
        rw [show M.ctl (.ev e env) = .ev e (M.env env) from rfl,
          show M.frame (.l (.objVal o key r env)) = .l (.objVal (M.a o) key r (M.env env)) by
            show Frame.l (.objVal (M.a o) (M.key key) r (M.env env)) = _; rw [hkm]] at this
        exact this
      | none => exact computed k _ hk
    | short n =>
      obtain ⟨c, hc⟩ := rf_shortLocal hl
      exact rf_readVarLocal (h.push (.l (.objVal o (.str n) r env)) ⟨ho, trivial, he⟩) hc hn0 hpRef
        (hcn n (List.mem_cons_self ..) c hc)
    | method kind k fn =>
      simp only [objNext]
      cases hk : keyOf k with
      | some key =>
        obtain ⟨hkm, hks⟩ := rf_keyOf (M := M) (A := Present s) (n := S.tab.length) hk
        have hn1 : s.next + 1 < Sim.bound := by simp only [List.length_cons] at hn; omega
        obtain ⟨h1, hnext, hP⟩ := h.rfMethodProp hn1 ho hfr hks kind fn he true hpF
        rw [hkm] at h1
        refine rf_objNext r h1 (hP o ho) hfr (Supp.env_mono hP (Nat.le_refl _) he) (hP _ hpF) (hP _ hpRef) ?_
          (rf_all_tail hl) (fun n hn => hcn n (List.mem_cons_of_mem _ hn))
        rw [hnext]
        simp only [List.length_cons] at hn
        omega
      | none => exact computed k _ hk
    | spread e =>
      exact rf_rel ((h.push (.l (.objSpread o r env)) ⟨ho, he⟩).go (.ev e env) he)

theorem rf_defineData_foldl_pres (a : Nat) (ha : a < 2 ^ 64) :
    ∀ (kvs : List (PKey × Val)) (s : St F.S),
      (kvs.foldl (fun s (k, x) => Host.Ts.defineData F s a k x) s).next = s.next ∧
      ∀ b, Present s b → Present (kvs.foldl (fun s (k, x) => Host.Ts.defineData F s a k x) s) b
  | [], _ => ⟨rfl, fun _ h => h⟩
  | (k, v) :: kvs, s => by
    obtain ⟨hnext, hs⟩ := defineData_heap s a k v
    obtain ⟨ih1, ih2⟩ := rf_defineData_foldl_pres a ha kvs (Host.Ts.defineData F s a k v)
    have hP : ∀ b, Present s b → Present (Host.Ts.defineData F s a k v) b := by
      rcases hs with hs | ⟨o, hs⟩
      · rw [hs]; exact fun _ hb => hb
      · rw [hs]; exact fun _ hb => Present.set _ ha hb
    exact ⟨ih1.trans hnext, fun b hb => ih2 b (hP b hb)⟩

end

/-! ## Steps -/

/-- Side condition of an object spread source: an object is unframed and its own
keys are read under `TypedOK`. -/
def ObjSpreadOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) (v : Val) : Prop :=
  ∀ a, v = .obj a → K.fr a = none ∧ ∀ src, s.obj? a = some src → ∀ k ∈ ownKeys F s src,
    TypedOK F K s S src k ∧ NsOK K W s src k

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
  {v : Val} {fs : List Frame}

theorem step_retL_array (h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) {acc : List Val}
    {rest : List Elem} {env : Env} (hc : s.ctl = .ret v) (hs : s.stack = .l (.array acc rest env) :: fs)
    (hp : Present s aArrayProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hacc, he⟩ := hf
  exact rf_arrayNext hr hn hp he rest (acc := v :: acc) fun x hx => by
    rcases List.mem_cons.1 hx with rfl | hx
    · exact hv
    · exact hacc x hx

theorem step_retL_spread (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {acc : List Val} {rest : List Elem} {env : Env} (hc : s.ctl = .ret v)
    (hs : s.stack = .l (.spread acc rest env) :: fs) (hpA : Present s aArrayProto)
    (hpT : Present s aTypeErrorProto) (hok : SpreadOK F K W s S v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have hf' := hf
  obtain ⟨hacc, he⟩ := hf
  refine rf_spreadElems hr hF hn hpT hv hf' hok fun es hes => ?_
  have := rf_arrayNext hr hn hpA he rest (acc := es.reverse ++ acc) fun x hx => by
    rcases List.mem_append.1 hx with hx | hx
    · exact hes x (List.mem_reverse.1 hx)
    · exact hacc x hx
  rwa [show M.vals (es.reverse ++ acc) = (M.vals es).reverse ++ M.vals acc by simp [Map.vals]] at this

theorem step_retL_object (h : RelB F FR W stk M ν K s S t C) (hn : s.next + margin < Sim.bound) {o : Nat}
    {rest : List Property} {env : Env} (hc : s.ctl = .ret v) (hs : s.stack = .l (.object o rest env) :: fs)
    (hfr : K.fr o = none) (hpF : Present s aFunctionProto) (hpRef : Present s aReferenceErrorProto)
    (hok : ObjRestOK rest env) (hcn : ∀ n, Property.short n ∈ rest → CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨ho, he⟩ := hf
  have hm : margin = 2 ^ 30 := rfl
  exact rf_objNext rest hr ho hfr he hpF hpRef (by have := hok.1; show s.next + rest.length < _; omega) hok.2 hcn

theorem step_retL_objVal (h : RelB F FR W stk M ν K s S t C) (hn : s.next + margin < Sim.bound) {o : Nat} {k : PKey}
    {rest : List Property} {env : Env} (hc : s.ctl = .ret v) (hs : s.stack = .l (.objVal o k rest env) :: fs)
    (hfr : K.fr o = none) (hpF : Present s aFunctionProto) (hpRef : Present s aReferenceErrorProto)
    (hok : ObjRestOK rest env) (hcn : ∀ n, Property.short n ∈ rest → CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨ho, hk, he⟩ := hf
  have hm : margin = 2 ^ 30 := rfl
  have hn0 : s.next < Sim.bound := by omega
  have h1 := hr.defineData hn0 ho hfr hk hv
  obtain ⟨hnext, hsh⟩ := defineData_heap (F := F) { s with stack := fs } o k v
  have hb : Sim.bound = 2 ^ 61 := rfl
  have ho64 : o < 2 ^ 64 := by have := h.presentBound o ho; omega
  have hP : ∀ a, Present s a → Present (Host.Ts.defineData F { s with stack := fs } o k v) a := by
    rcases hsh with hsh | ⟨ob, hsh⟩
    · rw [hsh]; exact fun _ ha => ha
    · rw [hsh]; exact fun _ ha => Present.set _ ho64 ha
  exact rf_objNext rest h1 (hP o ho) hfr (Supp.env_mono hP (Nat.le_refl _) he) (hP _ hpF) (hP _ hpRef)
    (by rw [hnext]; have := hok.1; show s.next + rest.length < _; omega) hok.2 hcn

theorem step_retL_objSpread (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next + margin < Sim.bound) {o : Nat} {rest : List Property} {env : Env} (hc : s.ctl = .ret v)
    (hs : s.stack = .l (.objSpread o rest env) :: fs) (hfr : K.fr o = none) (hpF : Present s aFunctionProto)
    (hpRef : Present s aReferenceErrorProto) (hok : ObjRestOK rest env) (hsp : ObjSpreadOK F K W s S v)
    (hcn : ∀ n, Property.short n ∈ rest → CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨ho, he⟩ := hf
  have hm : margin = 2 ^ 30 := rfl
  have hn0 : s.next < Sim.bound := by omega
  have hrest : s.next + rest.length < Sim.bound := by have := hok.1; omega
  have hb : Sim.bound = 2 ^ 61 := rfl
  have ho64 : o < 2 ^ 64 := by have := h.presentBound o ho; omega
  cases v with
  | obj a =>
    obtain ⟨hfa, hkeys⟩ := hsp a rfl
    show MSim _ S C (match s.obj? a with
        | some src => Host.Ts.M.bind (dataProps F { s with stack := fs } src) _
        | none => Host.Ts.M.fail "dangling")
      (match t.obj? (M.a a) with
        | some src => Host.Ts.M.bind (dataProps F { t with stack := fs.map M.frame ++ stk } src) _
        | none => Host.Ts.M.fail "dangling")
    cases hsrc : s.obj? a with
    | none => exact MSim.fail _ _
    | some src =>
      rw [h.obj? hsrc hfa]
      refine MSim.bind (dataProps_sim hr hF (h.obj?_supp hsrc) (fun k hk => (hkeys src hsrc k hk).1)
        (fun k hk => (hkeys src hsrc k hk).2)) ?_
      rintro M' S' C' r r' ⟨-, hS, hC, rfl, hkvs⟩
      rw [hS, hC]
      cases r with
      | none => exact MSim.fail _ _
      | some kvs =>
        have h1 := hr.defineData_foldl hn0 ho hfr kvs (hkvs kvs rfl)
        obtain ⟨hnext, hP⟩ := rf_defineData_foldl_pres (F := F) o ho64 kvs { s with stack := fs }
        exact rf_objNext rest h1 (hP o ho) hfr (Supp.env_mono hP (Nat.le_refl _) he) (hP _ hpF) (hP _ hpRef)
          (by rw [hnext]; exact hrest) hok.2 hcn
  | str cs => exact MSim.fail _ _
  | _ => exact rf_objNext rest hr ho hfr he hpF hpRef hrest hok.2 hcn

theorem step_retL_objKey (h : RelB F FR W stk M ν K s S t C) (hn : s.next + margin < Sim.bound) {o : Nat}
    {p : Property} {rest : List Property} {env : Env} (hc : s.ctl = .ret v)
    (hs : s.stack = .l (.objKey o p rest env) :: fs) (hfr : K.fr o = none) (hpF : Present s aFunctionProto)
    (hpRef : Present s aReferenceErrorProto) (hok : ObjRestOK rest env) (hl : NumLitV v) (hb : BigFixedV K v)
    (hcn : ∀ n, Property.short n ∈ rest → CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨ho, he⟩ := hf
  have hm : margin = 2 ^ 30 := rfl
  have hrest : s.next + 1 + rest.length < Sim.bound := by have := hok.1; omega
  show MSim _ S C (Host.Ts.M.bind (toKey v) _) (Host.Ts.M.bind (toKey (M.val v)) _)
  refine MSim.bind (rf_toKeyLit hr hv hl hb) ?_
  rintro M' S' C' r r' ⟨-, hS, hC, rfl, hks, -⟩
  rw [hS, hC]
  cases r with
  | none => exact MSim.fail _ _
  | some key =>
    cases p with
    | init k e =>
      exact rf_rel ((hr.push (.l (.objVal o key rest env)) ⟨ho, hks, he⟩).go (.ev e env) he)
    | method kind k fn =>
      obtain ⟨h1, hnext, hP⟩ := hr.rfMethodProp (by show s.next + 1 < Sim.bound; omega) ho hfr hks kind fn he true hpF
      exact rf_objNext rest h1 (hP o ho) hfr (Supp.env_mono hP (Nat.le_refl _) he) (hP _ hpF) (hP _ hpRef)
        (by rw [hnext]; show s.next + 1 + rest.length < _; exact hrest) hok.2 hcn
    | _ => exact MSim.fail _ _

end
end Host.Ts.Sim
