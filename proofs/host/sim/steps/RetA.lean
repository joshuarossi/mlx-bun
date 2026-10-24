import host.sim.steps.RetL
namespace Host.Ts.Sim

/-! # Assignment and update frames receiving a value

Targets are variables (`readVar`/`writeVar`), properties (`getV`/`putV`) or
private names (`privGetV`/`privPutV`); compound assignments combine through
`binOp`, updates through `numBin` (numbers) or bigint arithmetic. -/

/-! ## Side conditions -/

section
variable {F : Ffi} {K : Ctx} {W : Nat → Option WFrame} {stk : List Frame} {s : St F.S} {S S' : SSrv}

theorem CellRead.rfMono {A : Nat → Prop} {n n' : Nat} {k : EltK} {bs : List Byte} (hn : n ≤ n')
    (h : CellRead K A n k bs) : CellRead K A n' k bs :=
  fun c hc => ⟨Supp.cell_mono (fun _ h => h) hn (h c hc).1, (h c hc).2⟩

theorem TypedOK.rfMono {o : Obj} {k : PKey} (hn : S.tab.length ≤ S'.tab.length) (h : TypedOK F K s S o k) :
    TypedOK F K s S' o k :=
  fun kk b off n i hk hi hlt bs hb => (h kk b off n i hk hi hlt bs hb).rfMono hn

theorem ChainOK.rfMono {k : PKey} (hn : S.tab.length ≤ S'.tab.length) :
    ∀ f a, ChainOK F K W s S k f a → ChainOK F K W s S' k f a
  | 0, _, _ => trivial
  | f + 1, _, h => fun o ho =>
    ⟨⟨(h o ho).1.1, (h o ho).1.2.1.rfMono hn, (h o ho).1.2.2⟩, fun b hb => ChainOK.rfMono hn f b ((h o ho).2 b hb)⟩

theorem LookupOK.rfMono {recv : Val} {k : PKey} (hn : S.tab.length ≤ S'.tab.length)
    (h : LookupOK F K W s S recv k) : LookupOK F K W s S' recv k := by
  cases recv <;> first
    | exact ChainOK.rfMono hn 16 _ h
    | exact fun p hp => ChainOK.rfMono hn 16 p (h p hp)

theorem PutOK.rfMono {recv : Val} {k : PKey} {v : Val} (hn : S.tab.length ≤ S'.tab.length)
    (h : PutOK F K W s S recv k v) : PutOK F K W s S' recv k v :=
  fun a ha => ⟨(h a ha).1, fun o ho => ⟨fun p hp => ChainOK.rfMono hn 16 p (((h a ha).2 o ho).1 p hp),
    ((h a ha).2 o ho).2⟩⟩

/-- Stores of numbers need nothing of the number (`CellOK` is about bigints). -/
theorem PutOK.rfNum {recv : Val} {k : PKey} {x y : NumV} (h : PutOK F K W s S recv k (.num x)) :
    PutOK F K W s S recv k (.num y) :=
  fun a ha => ⟨(h a ha).1, fun o ho => ⟨((h a ha).2 o ho).1, fun kk _ _ _ _ => by cases kk <;> trivial⟩⟩

end

/-- Reading an assignment target: a local variable's cell under `CellNoW`, a global variable
reads the global object under `ChainOK`, a property under `LookupOK`, a private member under
`PrivOK`. -/
def ReadTargetOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) : Target → Prop
  | .var n env => (lookupEnv n env = none → ChainOK F K W s S (.str n) 16 aGlobal) ∧ CellNoW K W env n
  | .prop o k => LookupOK F K W s S o k
  | .priv o _ nm => PrivOK K W s o nm

/-- Storing into an assignment target: a local variable's cell under `CellNoW`, a property
under `PutOK`, a private member of an unframed object. -/
def StoreTargetOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) (x : Target) (v : Val) : Prop :=
  match x with
  | .var n env => CellNoW K W env n
  | .prop o k => PutOK F K W s S o k v
  | .priv o _ _ => ∀ a, o = .obj a → K.fr a = none

/-- Compound assignments read the target first. -/
def AsgReadOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) (op : AsgOp) (x : Target) : Prop :=
  match op with
  | .assign => True
  | _ => ReadTargetOK F K W s S x

/-- The property key of a computed member target. -/
def asgKey (v : Val) : Option PKey :=
  match numIndex v with
  | some i => some (.str (F64.natStr i))
  | none => keyOfVal v

/-- Side condition of the `put` frame: the operator's (`BinOK`) or the store's. -/
def PutFrameOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) (op : Option BinOp) (x : Target) (old v : Val) : Prop :=
  match op with
  | some bo => BinOK F K W s S bo old v
  | none => StoreTargetOK F K W s S x v

/-- The map hypothesis of the `put` frame (equality operators only). -/
def PutFrameMapOK (M : Map) (op : Option BinOp) (old v : Val) : Prop :=
  match op with
  | some bo => BinMapOK M bo old v
  | none => True

/-- Side condition of an update's old value: a bigint and its successor are fixed
by the map; the store is `StoreTargetOK` (for numbers, of any number). -/
def UpdOldOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) (inc : Bool) (x : Target) (v : Val) : Prop :=
  match v with
  | .big i => BigFixed K.lo K.hi i ∧ BigFixed K.lo K.hi (bif inc then i + 1 else i - 1) ∧
      StoreTargetOK F K W s S x (.big (bif inc then i + 1 else i - 1))
  | _ => StoreTargetOK F K W s S x (.num zeroN)

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

theorem StoreTargetOK.rfMono {S' : SSrv} {x : Target} {v : Val} (hn : S.tab.length ≤ S'.tab.length)
    (h : StoreTargetOK F K W s S x v) : StoreTargetOK F K W s S' x v := by
  cases x with
  | var _ _ => exact h
  | prop o k => exact PutOK.rfMono hn h
  | priv _ _ _ => exact h

theorem StoreTargetOK.rfNum {x : Target} {a b : NumV} (h : StoreTargetOK F K W s S x (.num a)) :
    StoreTargetOK F K W s S x (.num b) := by
  cases x with
  | var _ _ => exact h
  | prop o k => exact PutOK.rfNum h
  | priv _ _ _ => exact h

/-! ## Variables -/

theorem rf_readVar (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hn : s.next < Sim.bound)
    (hpRef : Present s aReferenceErrorProto) (hpG : Present s aGlobal) {n : Name} {env : Env}
    (hok : (lookupEnv n env = none → ChainOK F K W s S (.str n) 16 aGlobal) ∧ CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (readVar F s n env) (readVar F t n (M.env env)) := by
  cases hl : lookupEnv n env with
  | some c => exact rf_readVarLocal h hl hn hpRef (hok.2 c hl)
  | none =>
    have hl' : lookupEnv n (M.env env) = none := by rw [lookupEnv_map, hl]; rfl
    have hg : M.a aGlobal = aGlobal := h.intr _ (by decide)
    simp only [readVar, hl, hl']
    have hc := getChain_sim h hF (k := .str n) trivial 16 aGlobal (hok.1 hl)
    rw [hg] at hc
    refine MSim.bind hc ?_
    rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
    rw [hS, hC]
    cases r with
    | none =>
      cases hi : nameEq n (chars!"setImmediate")
      · simp only [Bool.cond_false]
        exact refErr_sim h h.intr hn hpRef _
      · simp only [Bool.cond_true]
        have h64 := rf_s64 hn
        obtain ⟨ha, hr⟩ := h.allocObj (.fn (.native (.ctl .setImmediate) [])) .null [] hn
          (fun _ hx => nomatch hx) trivial (fun _ hx => nomatch hx)
        have := rf_ret hr (.obj (s.allocObj (.fn (.native (.ctl .setImmediate) [])) .null []).1)
          (Present.alloc_next s _ h64)
        rw [show M.val (.obj (s.allocObj (.fn (.native (.ctl .setImmediate) [])) .null []).1) =
          .obj (M.a (s.allocObj (.fn (.native (.ctl .setImmediate) [])) .null []).1) from rfl, ← ha] at this
        exact this
    | some p =>
      have := h.read (recv := .obj aGlobal) (p := some p) hpG hsupp
      rw [show M.val (.obj aGlobal) = .obj aGlobal from congrArg Val.obj hg] at this
      exact rf_rel this

theorem rf_writeVar (h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) (hpRef : Present s aReferenceErrorProto)
    {n : Name} {env : Env} {v : Val} (he : Supp.env (Present s) S.tab.length env)
    (hv : Supp.val (Present s) S.tab.length v) (hcn : CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (writeVar F s n env v) (writeVar F t n (M.env env) (M.val v)) := by
  cases hl : lookupEnv n env with
  | some c => exact rf_writeVarLocal h hl hn hpRef (rf_lookupEnv_supp he hl) hv (hcn c hl)
  | none =>
    have hl' : lookupEnv n (M.env env) = none := by rw [lookupEnv_map, hl]; rfl
    simp only [writeVar, hl, hl']
    exact refErr_sim h h.intr hn hpRef _

/-! ## Targets -/

section
variable (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hn : s.next < Sim.bound)
  (hpT : Present s aTypeErrorProto) (hpRef : Present s aReferenceErrorProto) (hpG : Present s aGlobal)
include h hn hpT

include hF hpRef hpG in
theorem rf_readTarget {x : Target} (hx : Supp.target (Present s) S.tab.length x)
    (hok : ReadTargetOK F K W s S x) :
    MSim (StepPostB F FR W stk M ν K S C) S C (readTarget F s x) (readTarget F t (M.target x)) := by
  cases x with
  | var n env => exact rf_readVar h hF hn hpRef hpG hok
  | prop o k => exact getV_sim h hF h.intr hn hpT hx.1 hx.2 hok
  | priv o b nm => exact privGetV_sim h h.intr hn hpT hx.1 hx.2 hok

include hF hpRef in
theorem rf_storeTarget (hFR : FRLaws FR) (hpR : Present s aRangeErrorProto) {x : Target} {v : Val}
    (hx : Supp.target (Present s) S.tab.length x) (hv : Supp.val (Present s) S.tab.length v)
    (hok : StoreTargetOK F K W s S x v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (storeTarget F s x v) (storeTarget F t (M.target x) (M.val v)) := by
  cases x with
  | var n env => exact rf_writeVar h hn hpRef hx hv hok
  | prop o k => exact putV_sim h hF hFR h.intr hn hpT hpR hx.2 hv hok
  | priv o b nm => exact privPutV_sim h h.intr hn hpT hx.1 hx.2 hv hok

include hF hpRef hpG in
theorem rf_asgTarget {op : AsgOp} {x : Target} {val : Expr} {env : Env}
    (hx : Supp.target (Present s) S.tab.length x) (he : Supp.env (Present s) S.tab.length env)
    (hok : AsgReadOK F K W s S op x) :
    MSim (StepPostB F FR W stk M ν K S C) S C (asgTarget F s op x val env) (asgTarget F t op (M.target x) val (M.env env)) := by
  cases op with
  | assign => exact rf_rel ((h.push (.a (.put none x .undef)) ⟨hx, trivial⟩).go (.ev val env) he)
  | bin bo =>
    exact rf_readTarget (h.push (.a (.old (.bin bo) x val env)) ⟨hx, he⟩) hF hn hpT hpRef hpG hx hok
  | log lo =>
    exact rf_readTarget (h.push (.a (.old (.log lo) x val env)) ⟨hx, he⟩) hF hn hpT hpRef hpG hx hok

include hF hpRef in
/-- A numeric update: `x ± 1` stored, the old or new value kept. -/
theorem rf_updNum (hFR : FRLaws FR) (hpR : Present s aRangeErrorProto) {inc pre : Bool} {x : Target}
    {y : NumV} (hy : Supp.nv (Present s) S.tab.length y) (hx : Supp.target (Present s) S.tab.length x)
    (hst : StoreTargetOK F K W s S x (.num zeroN)) :
    MSim (StepPostB F FR W stk M ν K S C) S C
      (Host.Ts.M.bind (numBin (bif inc then .add else .sub) y one) fun z =>
        storeTarget F (s.push (.e (.const (bif pre then .num z else .num y)))) x (.num z))
      (Host.Ts.M.bind (numBin (bif inc then .add else .sub) (M.nv y) one) fun z =>
        storeTarget F (t.push (.e (.const (bif pre then .num z else .num (M.nv y))))) (M.target x) (.num z)) := by
  refine rf_bind (rf_numBin (A := Present s) h.srv _ y one) fun M' S' C' z z' hz g => ?_
  obtain ⟨rfl, hsupp⟩ := hz
  have h' := h.grow hFR g
  have hyM : M.nv y = M'.nv y := Map.nv_agree g.ext.agree hy
  have hx' := Supp.target_mono (fun _ h => h) g.len hx
  have hst' := (StoreTargetOK.rfNum (b := z) hst).rfMono g.len
  rw [hyM, g.rfTarget hx]
  cases pre
  · exact rf_storeTarget (h'.push (.e (.const (.num y))) (Supp.nv_mono (fun _ h => h) g.len hy)) hF hn hpT
      hpRef hFR hpR hx' hsupp hst'
  · exact rf_storeTarget (h'.push (.e (.const (.num z))) hsupp) hF hn hpT hpRef hFR hpR hx' hsupp hst'

end

end

/-! ## Steps -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
  {v : Val} {fs : List Frame}

theorem step_retA_pat (h : RelB F FR W stk M ν K s S t C) {p : Pat} {env : Env} (hc : s.ctl = .ret v)
    (hs : s.stack = .a (.pat p env) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have he : Supp.env (Present s) S.tab.length env := hf
  exact rf_rel ((hr.push (.e (.const v)) hv).go (.bind p v env .assign .let_) ⟨hv, he⟩)

theorem step_retA_put (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hn : s.next < Sim.bound) {op : Option BinOp} {x : Target} {old : Val} (hc : s.ctl = .ret v)
    (hs : s.stack = .a (.put op x old) :: fs) (hpT : Present s aTypeErrorProto)
    (hpR : Present s aRangeErrorProto) (hpRef : Present s aReferenceErrorProto)
    (hok : PutFrameOK F K W s S op x old v) (hM : PutFrameMapOK M op old v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hx, ho⟩ := hf
  cases op with
  | some bo =>
    exact rf_binOp (hr.push (.a (.put none x old)) ⟨hx, ho⟩) hF hFR hn hpT hpR bo ho hv hok hM
  | none => exact rf_storeTarget hr hF hn hpT hpRef hFR hpR hx hv hok

theorem step_retA_privObj (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {op : AsgOp} {b : Nat} {nm : Name} {val : Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .a (.privObj op b nm val env) :: fs)
    (hpT : Present s aTypeErrorProto) (hpRef : Present s aReferenceErrorProto) (hpG : Present s aGlobal)
    (hpk : PrivOK K W s v nm) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hb, he⟩ := hf
  have hok : AsgReadOK F K W { s with stack := fs } S op (.priv v b nm) := by
    cases op
    · trivial
    all_goals exact PrivOK.congr (fun _ => rfl) hpk
  exact rf_asgTarget hr hF hn hpT hpRef hpG (x := .priv v b nm) ⟨hv, hb⟩ he hok

theorem step_retA_obj (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {op : AsgOp} {k : Option PKey} {kexpr : Option Expr} {val : Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .a (.obj op k kexpr val env) :: fs)
    (hpT : Present s aTypeErrorProto) (hpRef : Present s aReferenceErrorProto) (hpG : Present s aGlobal)
    (hok : ∀ key, k = some key → AsgReadOK F K W s S op (.prop v key)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hk, he⟩ := hf
  cases k with
  | some key => exact rf_asgTarget hr hF hn hpT hpRef hpG (x := .prop v key) ⟨hv, hk⟩ he (hok key rfl)
  | none =>
    cases kexpr with
    | some ke => exact rf_rel ((hr.push (.a (.key op v val env)) ⟨hv, he⟩).go (.ev ke env) he)
    | none => exact MSim.fail _ _

theorem step_retA_key (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {op : AsgOp} {o : Val} {val : Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .a (.key op o val env) :: fs)
    (hpT : Present s aTypeErrorProto) (hpRef : Present s aReferenceErrorProto) (hpG : Present s aGlobal)
    (hl : NumLitV v) (hb : BigFixedV K v) (hok : ∀ key, asgKey v = some key → AsgReadOK F K W s S op (.prop o key)) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨ho, he⟩ := hf
  show MSim _ S C (match numIndex v with
      | some i => asgTarget F _ op (.prop o (.str (F64.natStr i))) val env
      | none => Host.Ts.M.bind (toKey v) _)
    (match numIndex (M.val v) with
      | some i => asgTarget F _ op (.prop (M.val o) (.str (F64.natStr i))) val (M.env env)
      | none => Host.Ts.M.bind (toKey (M.val v)) _)
  rw [rf_numIndex hl]
  cases hi : numIndex v with
  | some i =>
    have hk : asgKey v = some (.str (F64.natStr i)) := by simp only [asgKey, hi]
    exact rf_asgTarget hr hF hn hpT hpRef hpG (x := .prop o (.str (F64.natStr i))) ⟨ho, trivial⟩ he (hok _ hk)
  | none =>
    refine MSim.bind (rf_toKeyLit hr hv hl hb) ?_
    rintro M' S' C' r r' ⟨-, hS, hC, rfl, hks, hkey⟩
    rw [hS, hC]
    cases r with
    | none => exact MSim.fail _ _
    | some key =>
      have hk : asgKey v = some key := by simp only [asgKey, hi]; exact hkey.symm
      exact rf_asgTarget hr hF hn hpT hpRef hpG (x := .prop o key) ⟨ho, hks⟩ he (hok key hk)

theorem step_retA_old (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {op : AsgOp} {x : Target} {val : Expr}
    {env : Env} (hc : s.ctl = .ret v) (hs : s.stack = .a (.old op x val env) :: fs) (hb : BigFixedV K v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hx, he⟩ := hf
  have go : ∀ {M' : Map} {S' : SSrv} {C' : CSrv}, Grow M ν S C M' S' C' →
      MSim (StepPostB F FR W stk M' ν K S' C') S' C'
        (Host.Ts.M.pure (({ s with stack := fs }.push (.a (.put none x v))).go (.ev val env)))
        (Host.Ts.M.pure (({ t with stack := fs.map M.frame ++ stk }.push (.a (.put none (M.target x) (M.val v)))).go
          (.ev val (M.env env)))) := fun g => by
    rw [g.rfTarget hx, g.rfVal hv, g.rfEnv he]
    exact rf_rel (((hr.grow hFR g).push (.a (.put none x v)) ⟨Supp.target_mono (fun _ h => h) g.len hx,
      rf_vmono g.len hv⟩).go (.ev val env) (Supp.env_mono (fun _ h => h) g.len he))
  cases op with
  | assign => exact MSim.fail _ _
  | bin bo => exact rf_rel ((hr.push (.a (.put (some bo) x v)) ⟨hx, hv⟩).go (.ev val env) he)
  | log lo =>
    cases lo with
    | and =>
      show MSim _ S C (Host.Ts.M.bind (truthy v) _) (Host.Ts.M.bind (truthy (M.val v)) _)
      refine rf_bind (rf_truthy h.srv v (h.rfFixBig hb)) fun M' S' C' r r' hrr g => ?_
      subst hrr
      cases r'
      · rw [g.rfVal hv]
        exact rf_ret (hr.grow hFR g) v (rf_vmono g.len hv)
      · exact go g
    | or =>
      show MSim _ S C (Host.Ts.M.bind (truthy v) _) (Host.Ts.M.bind (truthy (M.val v)) _)
      refine rf_bind (rf_truthy h.srv v (h.rfFixBig hb)) fun M' S' C' r r' hrr g => ?_
      subst hrr
      cases r'
      · exact go g
      · rw [g.rfVal hv]
        exact rf_ret (hr.grow hFR g) v (rf_vmono g.len hv)
    | nullish =>
      show MSim _ S C (bif isNullish v then _ else _) (bif isNullish (M.val v) then _ else _)
      rw [rf_isNullish]
      exact MSim.cond _ (go (Grow.refl h.srv)) (rf_ret hr v hv)

theorem step_retA_updOld (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hn : s.next < Sim.bound) {inc pre : Bool} {x : Target} (hc : s.ctl = .ret v)
    (hs : s.stack = .a (.updOld inc pre x) :: fs) (hpT : Present s aTypeErrorProto)
    (hpR : Present s aRangeErrorProto) (hpRef : Present s aReferenceErrorProto)
    (hok : UpdOldOK F K W s S inc x v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have hx : Supp.target (Present s) S.tab.length x := hf
  rcases v with _ | _ | ⟨_ | _⟩ | y | i | cs | i | a | ⟨m, off⟩
  case big =>
    obtain ⟨hi, hi', hst⟩ := hok
    show MSim _ S C (storeTarget F _ x _) (storeTarget F ({ t with stack := fs.map M.frame ++ stk }.push
      (.e (.const (bif pre then Val.big (bif inc then M.big i + 1 else M.big i - 1) else Val.big (M.big i)))))
      (M.target x) (.big (bif inc then M.big i + 1 else M.big i - 1)))
    rw [h.bigFixed i hi]
    have e : Val.big (bif inc then i + 1 else i - 1) = M.val (.big (bif inc then i + 1 else i - 1)) := by
      show _ = Val.big (M.big _)
      rw [h.bigFixed _ hi']
    have e' : M.val (bif pre then Val.big (bif inc then i + 1 else i - 1) else .big i) =
        (bif pre then Val.big (bif inc then i + 1 else i - 1) else .big i) := by
      cases pre
      · show Val.big (M.big i) = _; rw [h.bigFixed i hi]; rfl
      · exact e.symm
    have := rf_storeTarget (hr.push (.e (.const (bif pre then Val.big (bif inc then i + 1 else i - 1) else .big i)))
      (by cases pre <;> trivial)) hF hn hpT hpRef hFR hpR hx (v := Val.big (bif inc then i + 1 else i - 1)) trivial hst
    rw [← e] at this
    rw [show M.frame (.e (.const (bif pre then Val.big (bif inc then i + 1 else i - 1) else .big i))) =
      .e (.const (bif pre then Val.big (bif inc then i + 1 else i - 1) else .big i)) from congrArg (fun w => Frame.e (.const w)) e'] at this
    exact this
  case num => exact rf_updNum hr hF hn hpT hpRef hFR hpR (inc := inc) (pre := pre) (y := y) hv hx hok
  case undef => exact rf_updNum hr hF hn hpT hpRef hFR hpR (inc := inc) (pre := pre) (y := .lit .nan) trivial hx hok
  case null => exact rf_updNum hr hF hn hpT hpRef hFR hpR (inc := inc) (pre := pre) (y := zeroN) trivial hx hok
  case bool.false =>
    exact rf_updNum hr hF hn hpT hpRef hFR hpR (inc := inc) (pre := pre) (y := zeroN) trivial hx hok
  case bool.true =>
    exact rf_updNum hr hF hn hpT hpRef hFR hpR (inc := inc) (pre := pre) (y := one) trivial hx hok
  case str =>
    exact rf_updNum hr hF hn hpT hpRef hFR hpR (inc := inc) (pre := pre) (y := .lit (F64.ofString cs)) trivial hx hok
  all_goals exact MSim.fail _ _

theorem step_retA_updObj (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {inc pre : Bool} {k : Option PKey} {kexpr : Option Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .a (.updObj inc pre k kexpr env) :: fs)
    (hpT : Present s aTypeErrorProto) (hok : ∀ key, k = some key → LookupOK F K W s S v key) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hk, he⟩ := hf
  cases k with
  | some key =>
    exact getV_sim (hr.push (.a (.updOld inc pre (.prop v key))) ⟨hv, hk⟩) hF h.intr hn hpT hv hk (hok key rfl)
  | none =>
    cases kexpr with
    | some ke => exact rf_rel ((hr.push (.a (.updKey inc pre v)) hv).go (.ev ke env) he)
    | none => exact MSim.fail _ _

theorem step_retA_updKey (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {inc pre : Bool} {o : Val} (hc : s.ctl = .ret v)
    (hs : s.stack = .a (.updKey inc pre o) :: fs) (hpT : Present s aTypeErrorProto)
    (hl : NumLitV v) (hb : BigFixedV K v) (hok : ∀ key, asgKey v = some key → LookupOK F K W s S o key) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have ho : Supp.val (Present s) S.tab.length o := hf
  have hkey : MSim (ReadPost M S C (fun r r' => r' = r.map M.key ∧ Supp.okey (Present s) S.tab.length r ∧
      r = asgKey v)) S C
      (match numIndex v with
        | some i => Host.Ts.M.pure (some (PKey.str (F64.natStr i)))
        | none => toKey v)
      (match numIndex (M.val v) with
        | some i => Host.Ts.M.pure (some (PKey.str (F64.natStr i)))
        | none => toKey (M.val v)) := by
    rw [rf_numIndex hl]
    cases hi : numIndex v with
    | some i => exact ReadPost.pure ⟨rfl, trivial, by simp only [asgKey, hi]⟩
    | none =>
      refine MSim.mono (rf_toKeyLit hr hv hl hb) ?_
      rintro M' S' C' r r' ⟨hM, hS, hC, h1, h2, h3⟩
      exact ⟨hM, hS, hC, h1, h2, by simp only [asgKey, hi]; exact h3⟩
  show MSim _ S C (Host.Ts.M.bind (match numIndex v with
        | some i => Host.Ts.M.pure (some (PKey.str (F64.natStr i)))
        | none => toKey v) _)
    (Host.Ts.M.bind (match numIndex (M.val v) with
        | some i => Host.Ts.M.pure (some (PKey.str (F64.natStr i)))
        | none => toKey (M.val v)) _)
  refine MSim.bind hkey ?_
  rintro M' S' C' r r' ⟨-, hS, hC, rfl, hks, hk⟩
  rw [hS, hC]
  cases r with
  | none => exact MSim.fail _ _
  | some key =>
    exact getV_sim (hr.push (.a (.updOld inc pre (.prop o key))) ⟨ho, hks⟩) hF h.intr hn hpT ho hks
      (hok key hk.symm)

theorem step_retA_updPrivObj (h : RelB F FR W stk M ν K s S t C) (hn : s.next < Sim.bound) {inc pre : Bool}
    {b : Nat} {nm : Name} (hc : s.ctl = .ret v) (hs : s.stack = .a (.updPrivObj inc pre b nm) :: fs)
    (hpT : Present s aTypeErrorProto) (hpk : PrivOK K W s v nm) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have hb : Present s b := hf
  exact privGetV_sim (hr.push (.a (.updOld inc pre (.priv v b nm))) ⟨hv, hb⟩) h.intr hn hpT hv hb
    (PrivOK.congr (fun _ => rfl) hpk)

end
end Host.Ts.Sim
