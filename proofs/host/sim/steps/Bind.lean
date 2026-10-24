import host.sim.steps.Loop
namespace Host.Ts.Sim

/-! # Pattern binding

`bind` control binds a pattern to a value: identifiers initialize or assign
cells, defaults evaluate when the value is `undefined`, array patterns read the
value's elements (`elemsOf`; framed arrays are not destructured, typed-array
elements need `CellRead`) or collect an iterator, object patterns read
properties with `getV` (each key's lookup is a side condition). Rest elements
allocate arrays (`newArray`). -/

namespace StmtSim
section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-- A new array (prototype `%Array.prototype%`). -/
theorem newArray_rel (h : RelB F FR W stk M ν K s S t C) (vs : List Val) (hvs : Supp.vals (Present s) S.tab.length vs)
    (hpa : Present s aArrayProto) (hn : s.next < Sim.bound) :
    (newArray t (M.vals vs)).1 = M.a (newArray s vs).1 ∧
    RelB F FR W stk M ν K (newArray s vs).2 S (newArray t (M.vals vs)).2 C := by
  have h64 := lt64 h hn
  have hP : ∀ a, Present s a → Present (s.allocObj (.array vs) (.obj aArrayProto) []).2 a :=
    fun _ hp => Present.alloc _ h64 hp
  obtain ⟨ha, hr⟩ := h.allocObj (.array vs) (.obj aArrayProto) [] hn
    (Supp.vals_mono hP (Nat.le_refl _) hvs) (hP _ hpa) (fun _ hx => nomatch hx)
  have hv : M.val (.obj aArrayProto) = .obj aArrayProto := by
    show Val.obj (M.a aArrayProto) = _
    rw [h.intr _ (by decide)]
  rw [hv] at ha hr
  exact ⟨ha, hr⟩

theorem vals_tail (M : Map) (vs : List Val) : (M.vals vs).tail = M.vals vs.tail := by
  cases vs <;> rfl

theorem nthD_img (M : Map) (vs : List Val) : nthD .undef (M.vals vs) 0 = M.val (nthD .undef vs 0) := by
  cases vs <;> rfl

theorem supp_tail {A : Nat → Prop} {n : Nat} {vs : List Val} (h : Supp.vals A n vs) : Supp.vals A n vs.tail := by
  cases vs with
  | nil => exact h
  | cons v vs => exact fun x hx => h x (List.mem_cons_of_mem _ hx)

theorem supp_nthD {A : Nat → Prop} {n : Nat} {vs : List Val} (h : Supp.vals A n vs) :
    Supp.val A n (nthD .undef vs 0) := by
  cases vs with
  | nil => trivial
  | cons v vs => exact h v (List.mem_cons_self ..)

/-- The next element pattern of an array pattern. -/
theorem arrNext_sim (rest : Option Pat) (env : Env) (mode : BindMode) (kind : DeclKind) :
    ∀ (ps : List (Option Pat)) (vs : List Val) {s t : St F.S} (_h : RelB F FR W stk M ν K s S t C),
    Supp.vals (Present s) S.tab.length vs → Supp.env (Present s) S.tab.length env →
    (rest ≠ none → Present s aArrayProto) → s.next < Sim.bound →
    MSim (StepPostB F FR W stk M ν K S C) S C (arrNext F s ps rest vs env mode kind)
      (arrNext F t ps rest (M.vals vs) (M.env env) mode kind)
  | [], vs, s, t, h, hvs, he, hpa, hn => by
    cases rest with
    | none => exact MSim.pure ⟨Grow.refl h.srv, h.ret .undef trivial⟩
    | some r =>
      obtain ⟨ea, h1⟩ := newArray_rel h vs hvs (hpa (by simp)) hn
      have es : arrNext F s [] (some r) vs env mode kind =
          Host.Ts.M.pure ((newArray s vs).2.go (.bind r (.obj (newArray s vs).1) env mode kind)) := rfl
      have et : arrNext F t [] (some r) (M.vals vs) (M.env env) mode kind =
          Host.Ts.M.pure ((newArray t (M.vals vs)).2.go
            (.bind r (.obj (newArray t (M.vals vs)).1) (M.env env) mode kind)) := rfl
      rw [es, et, ea]
      have h64 := lt64 h hn
      exact MSim.pure ⟨Grow.refl h.srv, h1.go (.bind r (.obj _) env mode kind)
        ⟨Present.alloc_next s _ h64, Supp.env_mono (fun _ hp => Present.alloc _ h64 hp) (Nat.le_refl _) he⟩⟩
  | none :: ps, vs, s, t, h, hvs, he, hpa, hn => by
    have := arrNext_sim rest env mode kind ps vs.tail h (supp_tail hvs) he hpa hn
    rw [← vals_tail] at this
    exact this
  | some p :: ps, vs, s, t, h, hvs, he, hpa, hn => by
    have e : arrNext F t (some p :: ps) rest (M.vals vs) (M.env env) mode kind =
        Host.Ts.M.pure ((t.push (M.frame (.b (.arr ps rest vs.tail env mode kind)))).go
          (M.ctl (.bind p (nthD .undef vs 0) env mode kind))) := by
      show Host.Ts.M.pure ((t.push (.b (.arr ps rest (M.vals vs).tail (M.env env) mode kind))).go
        (.bind p (nthD .undef (M.vals vs) 0) (M.env env) mode kind)) = _
      rw [vals_tail, nthD_img]
      rfl
    rw [e]
    exact MSim.pure ⟨Grow.refl h.srv, (h.push (.b (.arr ps rest vs.tail env mode kind))
      ⟨supp_tail hvs, he⟩).go (.bind p (nthD .undef vs 0) env mode kind) ⟨supp_nthD hvs, he⟩⟩

theorem keyOf_isStr {k : Key} {key : PKey} (hk : keyOf k = some key) : ∃ cs, key = .str cs := by
  cases k with
  | id n => cases hk; exact ⟨n, rfl⟩
  | str raw =>
    simp only [keyOf] at hk
    cases hc : cook raw with
    | none => rw [hc] at hk; cases hk
    | some cs => rw [hc] at hk; cases hk; exact ⟨cs, rfl⟩
  | num raw =>
    simp only [keyOf] at hk
    obtain ⟨x, -, hx⟩ := Option.bind_eq_some_iff.1 hk
    obtain ⟨cs, -, rfl⟩ := Option.map_eq_some_iff.1 hx
    exact ⟨cs, rfl⟩
  | priv n => cases hk
  | computed e => cases hk

/-- The lookups an object pattern's next property reads. -/
def ObjPatOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) (src : Val) (ps : List (Key × Pat)) : Prop :=
  ∀ k p ps' key, ps = (k, p) :: ps' → keyOf k = some key → LookupOK F K W s S src key

/-! ## Object rest elements -/

theorem any_congr_mem {α : Type} {p q : α → Bool} : ∀ {l : List α}, (∀ a ∈ l, p a = q a) → l.any p = l.any q
  | [], _ => rfl
  | a :: l, h => by
    simp only [List.any_cons]
    rw [h a (List.mem_cons_self ..), any_congr_mem (l := l) fun b hb => h b (List.mem_cons_of_mem _ hb)]

theorem foldl_defineData_keeps (r : Nat) (hr : r < 2 ^ 64) : ∀ (kvs : List (PKey × Val)) (s : St F.S),
    (kvs.foldl (fun s (k, x) => defineData F s r k x) s).next = s.next ∧
      ∀ b, Present s b → Present (kvs.foldl (fun s (k, x) => defineData F s r k x) s) b
  | [], _ => ⟨rfl, fun _ hb => hb⟩
  | (k, x) :: kvs, s => by
    obtain ⟨e1, h1⟩ := foldl_defineData_keeps r hr kvs (defineData F s r k x)
    obtain ⟨e2, h2⟩ := defineData_heap s r k x
    have hP : ∀ b, Present s b → Present (defineData F s r k x) b := by
      rcases h2 with h2 | ⟨o, h2⟩
      · rw [h2]; exact fun _ hb => hb
      · rw [h2]; exact fun b hb => Present.set _ hr hb
    exact ⟨by rw [List.foldl_cons, e1, e2], fun b hb => h1 b (hP b hb)⟩

/-- The source of an object rest element is unframed and its own typed-array elements are readable. -/
def RestOK (F : Ffi) (K : Ctx) (W : Nat → Option WFrame) (s : St F.S) (S : SSrv) (src : Val) : Prop :=
  ∀ a, src = .obj a → K.fr a = none ∧ ∀ o, s.obj? a = some o → ∀ k ∈ ownKeys F s o, TypedOK F K s S o k ∧ NsOK K W s o k

/-- Results of `restObj`: none, or a new present object with related states. -/
def RestR (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame) (M : Map) (ν : Nat → F64) (K : Ctx) (S : SSrv)
    (C : CSrv) (s : St F.S) (r r' : Option (Nat × St F.S)) : Prop :=
  (r = none ∧ r' = none) ∨ ∃ o o' s2 t2, r = some (o, s2) ∧ r' = some (o', t2) ∧ o' = M.a o ∧
    RelB F FR W stk M ν K s2 S t2 C ∧ Present s2 o ∧ ∀ x, Present s x → Present s2 x

theorem restObj_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (src : Val) (used : List PKey)
    (hsrc : Supp.val (Present s) S.tab.length src) (hused : Supp.keys (Present s) S.tab.length used)
    (hok : RestOK F K W s S src) (hpo : Present s aObjectProto) (hn : s.next + 1 < Sim.bound) :
    MSim (ReadPost M S C (RestR F FR W stk M ν K S C s)) S C (restObj F s src used)
      (restObj F t (M.val src) (used.map M.key)) := by
  cases src
  case obj a =>
    obtain ⟨hfr, hty⟩ := hok a rfl
    show MSim _ S C (restObj F s (.obj a) used) (restObj F t (.obj (M.a a)) (used.map M.key))
    simp only [restObj]
    cases ho : s.obj? a with
    | none =>
      rw [h.obj?_none hsrc ho]
      exact ReadPost.pure (.inl ⟨rfl, rfl⟩)
    | some o =>
      rw [h.obj? ho hfr]
      refine read_bind (dataProps_sim h hF (h.obj?_supp ho) (fun k hk => (hty o ho k hk).1)
        (fun k hk => (hty o ho k hk).2)) ?_
      rintro r r' ⟨rfl, hkv⟩
      cases r with
      | none => exact ReadPost.pure (.inl ⟨rfl, rfl⟩)
      | some kvs =>
        have hn0 : s.next < Sim.bound := by omega
        have h64 := lt64 h hn0
        have hP1 : ∀ x, Present s x → Present (s.allocObj .ordinary (.obj aObjectProto) []).2 x :=
          fun _ hp => Present.alloc _ h64 hp
        obtain ⟨hal, h1⟩ := h.allocObj .ordinary (.obj aObjectProto) [] hn0 trivial (hP1 _ hpo)
          (fun _ hx => nomatch hx)
        have hv : M.val (.obj aObjectProto) = .obj aObjectProto := by
          show Val.obj (M.a aObjectProto) = _
          rw [h.intr _ (by decide)]
        rw [hv] at hal h1
        let r0 := (s.allocObj .ordinary (.obj aObjectProto) []).1
        have hr0 : Present (s.allocObj .ordinary (.obj aObjectProto) []).2 r0 := Present.alloc_next s _ h64
        have hfr0 : K.fr r0 = none := fresh_fr_none h (Nat.le_refl _)
        have hn1 : (s.allocObj .ordinary (.obj aObjectProto) []).2.next < Sim.bound := by
          exact hn
        let kf := kvs.filter fun x => !(used.any (keyEq x.1))
        have hkf : ∀ x ∈ kf, Supp.key (Present (s.allocObj .ordinary (.obj aObjectProto) []).2) S.tab.length x.1 ∧
            Supp.val (Present (s.allocObj .ordinary (.obj aObjectProto) []).2) S.tab.length x.2 := fun x hx =>
          ⟨Supp.key_mono hP1 (Nat.le_refl _) (hkv kvs rfl x (List.mem_filter.1 hx).1).1,
            Supp.val_mono hP1 (Nat.le_refl _) (hkv kvs rfl x (List.mem_filter.1 hx).1).2⟩
        have h2 := h1.defineData_foldl hn1 hr0 hfr0 kf hkf
        have hfilt : (M.kvs kvs).filter (fun x => !((used.map M.key).any (keyEq x.1))) = M.kvs kf := by
          unfold Map.kvs
          rw [List.filter_map]
          congr 1
          apply List.filter_congr
          intro x hx
          simp only [Function.comp, List.any_map]
          congr 1
          apply any_congr_mem
          intro u hu
          exact keyEq_map h.inj (hkv kvs rfl x hx).1 (hused u hu)
        obtain ⟨_, hP2⟩ := foldl_defineData_keeps r0 h64 kf (s.allocObj .ordinary (.obj aObjectProto) []).2
        have hal' : (t.allocObj .ordinary (.obj aObjectProto) []).1 = M.a r0 := hal
        refine ReadPost.pure (.inr ⟨r0, _, _, _, rfl, rfl, hal, ?_, hP2 _ hr0, fun x hx => hP2 x (hP1 x hx)⟩)
        show RelB F FR W stk M ν K _ S (List.foldl _ _ ((M.kvs kvs).filter (fun x => !((used.map M.key).any (keyEq x.1))))) C
        rw [hfilt, hal']
        exact h2
  all_goals exact ReadPost.pure (.inl ⟨rfl, rfl⟩)

/-- The next property pattern of an object pattern, or its rest element. -/
theorem objPatNext_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (src : Val)
    (ps : List (Key × Pat)) (rest : Option Pat) (used : List PKey) (env : Env) (mode : BindMode) (kind : DeclKind)
    (hsrc : Supp.val (Present s) S.tab.length src) (hused : Supp.keys (Present s) S.tab.length used)
    (he : Supp.env (Present s) S.tab.length env) (hn : s.next + 1 < Sim.bound)
    (hP : Present s aTypeErrorProto) (hok : ObjPatOK F K W s S src ps)
    (hrest : ps = [] → rest ≠ none → RestOK F K W s S src ∧ Present s aObjectProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (objPatNext F s src ps rest used env mode kind)
      (objPatNext F t (M.val src) ps rest (used.map M.key) (M.env env) mode kind) := by
  match ps with
  | [] =>
    cases rest with
    | none => exact MSim.pure ⟨Grow.refl h.srv, h.ret .undef trivial⟩
    | some r =>
      obtain ⟨hro, hpo⟩ := hrest rfl (by simp)
      show MSim _ S C (Host.Ts.M.bind (restObj F s src used) _)
        (Host.Ts.M.bind (restObj F t (M.val src) (used.map M.key)) _)
      refine read_step (restObj_sim h hF src used hsrc hused hro hpo hn) ?_
      rintro q q' (⟨rfl, rfl⟩ | ⟨o, o', s2, t2, rfl, rfl, rfl, h2, hpo2, hP2⟩)
      · exact MSim.fail _ _
      · exact MSim.pure ⟨Grow.refl h.srv, h2.go (.bind r (.obj o) env mode kind)
          ⟨hpo2, Supp.env_mono hP2 (Nat.le_refl _) he⟩⟩
  | (k, p) :: ps' =>
    cases hk : keyOf k with
    | some key =>
      obtain ⟨cs, rfl⟩ := keyOf_isStr hk
      have es : objPatNext F s src ((k, p) :: ps') rest used env mode kind =
          getV F (s.push (.b (.objVal src (.str cs) p ps' rest (.str cs :: used) env mode kind))) src (.str cs) := by
        simp only [objPatNext, hk]
      have et : objPatNext F t (M.val src) ((k, p) :: ps') rest (used.map M.key) (M.env env) mode kind =
          getV F (t.push (M.frame (.b (.objVal src (.str cs) p ps' rest (.str cs :: used) env mode kind))))
            (M.val src) (M.key (.str cs)) := by
        simp only [objPatNext, hk]
        rfl
      rw [es, et]
      exact getV_sim (h.push (.b (.objVal src (.str cs) p ps' rest (.str cs :: used) env mode kind))
        ⟨hsrc, trivial, fun x hx => by
          rcases List.mem_cons.1 hx with rfl | hx
          · trivial
          · exact hused x hx, he⟩) hF h.intr (by dsimp only [St.push]; omega) hP hsrc trivial (hok k p ps' _ rfl hk)
    | none =>
      cases k with
      | computed e =>
        have es : objPatNext F s src ((.computed e, p) :: ps') rest used env mode kind =
            Host.Ts.M.pure ((s.push (.b (.objKey src p ps' rest used env mode kind))).go (.ev e env)) := by
          simp only [objPatNext, hk]
        have et : objPatNext F t (M.val src) ((.computed e, p) :: ps') rest (used.map M.key) (M.env env) mode kind =
            Host.Ts.M.pure ((t.push (M.frame (.b (.objKey src p ps' rest used env mode kind)))).go
              (M.ctl (.ev e env))) := by
          simp only [objPatNext, hk]
          rfl
        rw [es, et]
        exact MSim.pure ⟨Grow.refl h.srv, (h.push (.b (.objKey src p ps' rest used env mode kind))
          ⟨hsrc, hused, he⟩).go (.ev e env) he⟩
      | id n => cases hk
      | str raw =>
        have es : objPatNext F s src ((.str raw, p) :: ps') rest used env mode kind =
            Host.Ts.M.fail "pattern key" := by
          simp only [objPatNext, hk]
        rw [es]
        exact MSim.fail _ _
      | num raw =>
        have es : objPatNext F s src ((.num raw, p) :: ps') rest used env mode kind =
            Host.Ts.M.fail "pattern key" := by
          simp only [objPatNext, hk]
        rw [es]
        exact MSim.fail _ _
      | priv n =>
        have es : objPatNext F s src ((.priv n, p) :: ps') rest used env mode kind =
            Host.Ts.M.fail "pattern key" := by
          simp only [objPatNext, hk]
        rw [es]
        exact MSim.fail _ _

end
end StmtSim

open StmtSim

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-- Bind control on both sides. -/
theorem bindTop (h : RelB F FR W stk M ν K s S t C) {p : Pat} {v : Val} {env : Env} {m : BindMode} {k : DeclKind}
    (hc : s.ctl = .bind p v env m k) :
    step F s = bindStep F s p v env m k ∧ step F t = bindStep F t p (M.val v) (M.env env) m k ∧
      Supp.val (Present s) S.tab.length v ∧ Supp.env (Present s) S.tab.length env := by
  have htc : t.ctl = .bind p (M.val v) (M.env env) m k := by rw [h.ctl, hc]; rfl
  have hs := h.ctlSupp
  rw [hc] at hs
  exact ⟨step_bind_eq hc, step_bind_eq htc, hs.1, hs.2⟩

/-! ## Bind control -/

/-- Initializing a binding: the bound address must hold a cell (`hcell`, a source fact). -/
theorem step_bind_id_init (h : RelB F FR W stk M ν K s S t C) {n : Name} {v : Val} {env : Env} {kind : DeclKind}
    (hc : s.ctl = .bind (.id n) v env .init kind) (hn : s.next + margin < Sim.bound)
    (hcell : ∀ c, lookupEnv n env = some c → (s.cell? c).isSome = true) (hcn : CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hv, he⟩ := bindTop h hc
  rw [e1, e2]
  cases hl : lookupEnv n env with
  | none =>
    have es : bindStep F s (.id n) v env .init kind = Host.Ts.M.fail "binding without a cell" := by
      simp only [bindStep, hl]
    rw [es]
    exact MSim.fail _ _
  | some c =>
    obtain ⟨w, hw⟩ := Option.isSome_iff_exists.1 (hcell c hl)
    have hg := cell?_iff.1 hw
    have es : bindStep F s (.id n) v env .init kind = retS F (s.setCell c v) .undef := by
      simp only [bindStep, hl]
    have et : bindStep F t (.id n) (M.val v) (M.env env) .init kind =
        retS F (t.setCell (M.a c) (M.val v)) .undef := by
      simp only [bindStep, lookupEnv_img_some hl]
    rw [es, et]
    exact MSim.pure ⟨Grow.refl h.srv, (h.setCell v (lt_of_margin hn) (Present.of_get hg) (h.fr_cell hg (.of_or (hcn c hl))) hv).ret
      .undef trivial⟩

/-- Assigning to an identifier (`writeVar`): an uninitialized or unbound name throws a
`ReferenceError`. -/
theorem step_bind_id_assign (h : RelB F FR W stk M ν K s S t C) {n : Name} {v : Val} {env : Env} {kind : DeclKind}
    (hc : s.ctl = .bind (.id n) v env .assign kind) (hn : s.next + margin < Sim.bound)
    (hP : Present s aReferenceErrorProto) (hcn : CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hv, he⟩ := bindTop h hc
  rw [e1, e2]
  have hn0 := lt_of_margin hn
  show MSim _ S C (writeVar F s n env v) (writeVar F t n (M.env env) (M.val v))
  unfold writeVar
  cases hl : lookupEnv n env with
  | none =>
    rw [lookupEnv_img_none hl]
    exact refErr_sim h h.intr hn0 hP _
  | some c =>
    rw [lookupEnv_img_some hl]
    simp only
    have hpc : Present s c := env_lookup_supp he hl
    rw [cell_img h hpc (.of_or (hcn c hl))]
    cases hw : s.cell? c with
    | none => exact MSim.fail _ _
    | some w =>
      cases w with
      | none => exact refErr_sim h h.intr hn0 hP _
      | some w0 =>
        have hg := cell?_iff.1 hw
        exact MSim.pure ⟨Grow.refl h.srv, (h.setCell v hn0 hpc (h.fr_cell hg (.of_or (hcn c hl))) hv).ret v
          (Supp.val_mono (fun _ hp => Present.set _ (by have := h.presentBound c hpc; have := lt64 h hn0; omega) hp)
            (Nat.le_refl _) hv)⟩

/-- A pattern with a default: evaluate the default when the value is `undefined`. -/
theorem step_bind_dflt (h : RelB F FR W stk M ν K s S t C) {q : Pat} {d : Expr} {v : Val} {env : Env}
    {mode : BindMode} {kind : DeclKind} (hc : s.ctl = .bind (.dflt q d) v env mode kind) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hv, he⟩ := bindTop h hc
  rw [e1, e2]
  cases v
  case undef => exact MSim.pure ⟨Grow.refl h.srv, (h.push (.b (.dflt q env mode kind)) he).go (.ev d env) he⟩
  all_goals exact MSim.pure ⟨Grow.refl h.srv, h.go (.bind q _ env mode kind) ⟨hv, he⟩⟩

theorem step_bind_expr (h : RelB F FR W stk M ν K s S t C) {e : Expr} {v : Val} {env : Env}
    {mode : BindMode} {kind : DeclKind} (hc : s.ctl = .bind (.expr e) v env mode kind) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _, _⟩ := bindTop h hc
  rw [e1, e2]
  exact MSim.fail _ _

/-- An array pattern: elements of arrays, typed arrays and strings (`hok`: not framed,
typed-array cells readable), else the value's iterator collected; non-iterables throw. -/
theorem step_bind_array (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {ps : List (Option Pat)}
    {rest : Option Pat} {v : Val} {env : Env} {mode : BindMode} {kind : DeclKind}
    (hc : s.ctl = .bind (.array ps rest) v env mode kind) (hn : s.next + margin < Sim.bound)
    (hok : ElemsOK F K s S v) (hpa : rest ≠ none → Present s aArrayProto)
    (hP : Present s aTypeErrorProto) (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hv, he⟩ := bindTop h hc
  rw [e1, e2]
  have hn0 := lt_of_margin hn
  show MSim _ S C (Host.Ts.M.bind (elemsOf F s v) _) (Host.Ts.M.bind (elemsOf F t (M.val v)) _)
  refine read_step (elemsOf_sim h hF hv hok) ?_
  rintro r r' ⟨rfl, hsupp⟩
  cases r with
  | some vs => exact arrNext_sim rest env mode kind ps vs h (hsupp vs rfl) he hpa hn0
  | none =>
    cases v
    case obj a =>
      exact iterGet_sim (h.push (.b (.arrSrc ps rest env mode kind)) he) hF (.b (.collectIt []))
        a 0 (by decide) (fun _ hx => nomatch hx) hv hn0 hP (ChainNoW.congr (fun _ => rfl) 16 a hnw)
    all_goals exact typeErr_sim h h.intr hn0 hP _

/-- An object pattern: nullish values throw, else read the first key (or build the rest object). -/
theorem step_bind_object (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {ps : List (Key × Pat)}
    {rest : Option Pat} {v : Val} {env : Env} {mode : BindMode} {kind : DeclKind}
    (hc : s.ctl = .bind (.object ps rest) v env mode kind) (hn : s.next + margin < Sim.bound)
    (hP : Present s aTypeErrorProto) (hok : ObjPatOK F K W s S v ps)
    (hrest : ps = [] → rest ≠ none → RestOK F K W s S v ∧ Present s aObjectProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hv, he⟩ := bindTop h hc
  rw [e1, e2]
  have hn0 := lt_of_margin hn
  have hnul : isNullish (M.val v) = isNullish v := by cases v <;> rfl
  show MSim _ S C (bif isNullish v then _ else _) (bif isNullish (M.val v) then _ else _)
  rw [hnul]
  cases isNullish v
  · exact objPatNext_sim h hF v ps rest [] env mode kind hv (fun _ hx => nomatch hx) he (margin_bound hn (by decide)) hP hok hrest
  · exact typeErr_sim h h.intr hn0 hP _

/-! ## Values returning to pattern frames -/

theorem step_ret_bdflt (h : RelB F FR W stk M ν K s S t C) {v : Val} {p : Pat} {env : Env} {mode : BindMode}
    {kind : DeclKind} {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .b (.dflt p env mode kind) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.go (.bind p v env mode kind) ⟨hv, hf⟩⟩

theorem step_ret_arr (h : RelB F FR W stk M ν K s S t C) {v : Val} {ps : List (Option Pat)} {rest : Option Pat}
    {vs : List Val} {env : Env} {mode : BindMode} {kind : DeclKind} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .b (.arr ps rest vs env mode kind) :: fs) (hn : s.next + margin < Sim.bound)
    (hpa : rest ≠ none → Present s aArrayProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact arrNext_sim rest env mode kind ps vs hr hf.1 hf.2 hpa (lt_of_margin hn)

/-- The collected elements of an iterator bound by an array pattern. -/
theorem step_ret_arrSrc (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {v : Val}
    {ps : List (Option Pat)} {rest : Option Pat} {env : Env} {mode : BindMode} {kind : DeclKind}
    {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .b (.arrSrc ps rest env mode kind) :: fs)
    (hn : s.next + margin < Sim.bound) (hok : ElemsOK F K s S v) (hpa : rest ≠ none → Present s aArrayProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  show MSim _ S C (Host.Ts.M.bind (elemsOf F _ v) _) (Host.Ts.M.bind (elemsOf F _ (M.val v)) _)
  refine read_step (elemsOf_sim hr hF hv hok) ?_
  rintro r r' ⟨rfl, hsupp⟩
  cases r with
  | some vs => exact arrNext_sim rest env mode kind ps vs hr (hsupp vs rfl) hf hpa (lt_of_margin hn)
  | none => exact MSim.fail _ _

/-- The next property (or the rest element) of an object pattern. -/
theorem step_ret_obj (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {v src : Val}
    {ps : List (Key × Pat)} {rest : Option Pat} {used : List PKey} {env : Env} {mode : BindMode} {kind : DeclKind}
    {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .b (.obj src ps rest used env mode kind) :: fs)
    (hn : s.next + margin < Sim.bound) (hP : Present s aTypeErrorProto) (hok : ObjPatOK F K W s S src ps)
    (hrest : ps = [] → rest ≠ none → RestOK F K W s S src ∧ Present s aObjectProto) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact objPatNext_sim hr hF src ps rest used env mode kind hf.1 hf.2.1 hf.2.2 (margin_bound hn (by decide)) hP hok hrest

/-- A property's value read for an object pattern: bind its sub-pattern. -/
theorem step_ret_objVal (h : RelB F FR W stk M ν K s S t C) {v src : Val} {k : PKey} {p : Pat}
    {ps : List (Key × Pat)} {rest : Option Pat} {used : List PKey} {env : Env} {mode : BindMode}
    {kind : DeclKind} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .b (.objVal src k p ps rest used env mode kind) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.b (.obj src ps rest used env mode kind))
    ⟨hf.1, hf.2.2.1, hf.2.2.2⟩).go (.bind p v env mode kind) ⟨hv, hf.2.2.2⟩⟩

/-- The iterator of a value collected by an array pattern: read its `next`. -/
theorem step_ret_collectIt (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {v : Val}
    {acc : List Val} {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .b (.collectIt acc) :: fs)
    (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  show MSim _ S C (Host.Ts.M.bind (dataOf F _ v kNext) _) (Host.Ts.M.bind (dataOf F _ (M.val v) kNext) _)
  refine read_step (dataOf_sim hr hF h.intr hv (k := kNext) trivial (LookupOK.of_noW rfl rfl (LookupNoW.congr (fun _ => rfl) hnw))) ?_
  rintro r r' ⟨rfl, hsupp⟩
  cases r with
  | none => exact MSim.fail _ _
  | some nx =>
    exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.b (.collect acc v nx)) ⟨hf, hv, hsupp nx rfl⟩).go
      (.call nx v []) ⟨hsupp nx rfl, hv, fun _ hx => nomatch hx⟩⟩


/-- An iterator result collected for an array pattern: done gives the array of the collected
values, else collect `value` and call `next()` again. `hz`: the map keeps bigints' zeroness. -/
theorem step_ret_collect (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    {v it nx : Val} {acc : List Val} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .b (.collect acc it nx) :: fs) (hn : s.next + margin < Sim.bound)
    (hpa : Present s aArrayProto) (hz : ∀ i, (M.big i == 0) = (i == 0)) (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  obtain ⟨hacc, hit, hnx⟩ := hf
  have hn0 := lt_of_margin hn
  show MSim _ S C (Host.Ts.M.bind (dataOf F _ v kDone) _) (Host.Ts.M.bind (dataOf F _ (M.val v) kDone) _)
  refine read_step (dataOf_sim hr hF h.intr hv (k := kDone) trivial (LookupOK.of_noW rfl rfl (LookupNoW.congr (fun _ => rfl) hnw))) ?_
  rintro d d' ⟨rfl, hd⟩
  have hdv : (d.map M.val).getD .undef = M.val (d.getD .undef) := by cases d <;> rfl
  show MSim _ S C (Host.Ts.M.bind (truthy (d.getD .undef)) _) (Host.Ts.M.bind (truthy ((d.map M.val).getD .undef)) _)
  rw [hdv]
  refine truthy_step hr hFR _ (fun i _ => hz i) (fun b M' S' C' hg hr' => ?_)
  have hA : Agree (Present s) S.tab.length M M' := hg.ext.agree
  have hle := hg.len
  cases b with
  | true =>
    have hrev : (M.vals acc).reverse = M'.vals acc.reverse := by
      rw [Map.vals_agree hA hacc]
      simp only [Map.vals, List.map_reverse]
    have hacc' : Supp.vals (Present s) S'.tab.length acc.reverse :=
      fun x hx => Supp.val_mono (fun _ hp => hp) hle (hacc x (List.mem_reverse.1 hx))
    obtain ⟨ea, h1⟩ := newArray_rel hr' acc.reverse hacc' hpa hn0
    show MSim _ S' C' (retS F (newArray { s with stack := fs } acc.reverse).2
        (.obj (newArray { s with stack := fs } acc.reverse).1))
      (retS F (newArray { t with stack := fs.map M.frame ++ stk } (M.vals acc).reverse).2
        (.obj (newArray { t with stack := fs.map M.frame ++ stk } (M.vals acc).reverse).1))
    rw [hrev, ea]
    exact MSim.pure ⟨Grow.refl hr'.srv, h1.ret (.obj _) (Present.alloc_next { s with stack := fs } _ (lt64 hr hn0))⟩
  | false =>
    have hv' := Supp.val_mono (fun _ hp => hp) hle hv
    have hd2 := dataOf_sim hr' hF hr'.intr hv' (k := kValue) trivial (LookupOK.of_noW rfl rfl (LookupNoW.congr (fun _ => rfl) hnw))
    rw [← Map.val_agree hA hv] at hd2
    show MSim _ S' C' (Host.Ts.M.bind (dataOf F _ v kValue) _) (Host.Ts.M.bind (dataOf F _ (M.val v) kValue) _)
    refine read_step hd2 ?_
    rintro r r' ⟨rfl, hsupp⟩
    cases r with
    | none => exact MSim.fail _ _
    | some x =>
      have hmono : ∀ {y : Val}, Supp.val (Present s) S.tab.length y → Supp.val (Present s) S'.tab.length y :=
        fun hy => Supp.val_mono (fun _ hp => hp) hle hy
      have hr2 := (hr'.push (.b (.collect (x :: acc) it nx)) ⟨fun y hy => by
          rcases List.mem_cons.1 hy with rfl | hy
          · exact hsupp _ rfl
          · exact hmono (hacc y hy), hmono hit, hmono hnx⟩).go (.call nx it [])
        ⟨hmono hnx, hmono hit, fun _ hx => nomatch hx⟩
      have ef : M'.frame (.b (.collect (x :: acc) it nx)) =
          .b (.collect (M'.val x :: M.vals acc) (M.val it) (M.val nx)) := by
        show Frame.b (.collect (M'.val x :: M'.vals acc) (M'.val it) (M'.val nx)) = _
        rw [← Map.vals_agree hA hacc, ← Map.val_agree hA hit, ← Map.val_agree hA hnx]
      have ec : M'.ctl (.call nx it []) = .call (M.val nx) (M.val it) [] := by
        show Ctl.call (M'.val nx) (M'.val it) (M'.vals []) = _
        rw [← Map.val_agree hA hit, ← Map.val_agree hA hnx]
        rfl
      rw [ef, ec] at hr2
      exact MSim.pure ⟨Grow.refl hr'.srv, hr2⟩


/-- Pattern frames let abrupt completions through. -/
theorem step_abr_bind (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {f : BindF} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .b f :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, _⟩ := abrTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩

end
end Host.Ts.Sim
