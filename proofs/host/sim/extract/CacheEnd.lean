import host.sim.extract.Struct
namespace Host.Ts.Sim.ExtractSim
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Extract

/-! # A cache binding under the map

At a cell the map fixes, the target's `cache` binding extracts to the images of the
source's caches (`cachesT_end`; with literal source offsets also by `Extract.cache`,
`caches_end`). The tensors' handles need only be bigints at the extracted caches'
slots (`cachesOkB`, a kernel check on the source), not everywhere (`BigHandles`). The
tensor nodes are the images under `M.node` (`cacheR_nodes`). -/

/-- `v`'s handle field is not a number. -/
def HandleBig (s : St LSt) (v : Val) : Prop := ∀ w, privateField s v chars!"handle" = some w → ∀ x, w ≠ .num x

def handleBigB (s : St LSt) (v : Val) : Bool :=
  match privateField s v chars!"handle" with
  | some (.num _) => false
  | _ => true

theorem handleBig_of {s : St LSt} {v : Val} (h : handleBigB s v = true) : HandleBig s v := by
  intro w hw x hx
  subst hx
  simp [handleBigB, hw] at h

/-- A cache slot's value (`conv`/`keys`, `recurrent`/`values`). -/
def slotVal (s : St LSt) (v : Val) (p o : List Char) : Option Val := (privateField s v p).orElse fun _ => own s v o

def slotOkB (s : St LSt) (v : Val) (p o : List Char) : Bool :=
  match slotVal s v p o with
  | some w => handleBigB s w
  | none => true

/-- Both slots of a cache object hold tensors with bigint handles (or no tensor). -/
def cacheOkB (s : St LSt) (v : Val) : Bool :=
  slotOkB s v chars!"conv" chars!"keys" && slotOkB s v chars!"recurrent" chars!"values"

theorem slotOk_of {s : St LSt} {v : Val} {p o : List Char} (h : slotOkB s v p o = true) :
    ∀ w, slotVal s v p o = some w → HandleBig s w := by
  intro w hw
  unfold slotOkB at h
  rw [hw] at h
  exact handleBig_of h

/-- The offset of a cache object is a literal index. -/
def offsetLitB (s : St LSt) (v : Val) : Bool :=
  match own s v chars!"offset" with
  | some (.num (.lit x)) => (F64.toIndex? x).isSome
  | _ => false

/-- The source's cache list (offsets dropped). -/
def cachesT (s : St LSt) (env : Env) : Option (List Cache) :=
  ((bindingOf s env chars!"cache").bind (elements s)).bind (List.mapM (cacheT s))

/-- The cache list `Extract` reads. -/
def caches (s : St LSt) (env : Env) : Option (List Cache) :=
  ((bindingOf s env chars!"cache").bind (elements s)).bind (List.mapM (cache s))

/-- The cache binding's elements pass `f`. -/
def cachesAllB (s : St LSt) (env : Env) (f : St LSt → Val → Bool) : Bool :=
  match (bindingOf s env chars!"cache").bind (elements s) with
  | some es => es.all (f s)
  | none => false

/-- Tensor nodes of a cache (`Host.Load.cacheNodePair`). -/
def nodePair (c : Cache) : Option Nat × Option Nat := (c.first.map Tensor.node, c.second.map Tensor.node)

theorem mapM_exists {α γ δ : Type} {R : γ → δ → Prop} {f : α → Option γ} {g : α → Option δ} :
    ∀ (l : List α) {bs : List γ}, (∀ a ∈ l, ∀ b, f a = some b → ∃ c, g a = some c ∧ R b c) →
      l.mapM f = some bs → ∃ cs, l.mapM g = some cs ∧ LRel R bs cs
  | [], bs, _, h1 => by
    simp only [List.mapM_nil, pure, Option.some.injEq] at h1
    subst h1; exact ⟨[], rfl, trivial⟩
  | a :: l, bs, hfg, h1 => by
    simp only [List.mapM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at h1
    obtain ⟨b, hb, bs', hbs, rfl⟩ := h1
    obtain ⟨c, hc, hr⟩ := hfg a (List.mem_cons_self ..) b hb
    obtain ⟨cs, hcs, hrs⟩ := mapM_exists l (fun a' ha' => hfg a' (List.mem_cons_of_mem _ ha')) hbs
    exact ⟨c :: cs, by simp [List.mapM_cons, hc, hcs], hr, hrs⟩

section
variable {P : LoadP} {r : List NumV} {FR : Map → Nat → LSt → LSt → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St LSt} {S : SSrv} {C : CSrv}

/-- A binding at a cell the map fixes reads the image of the source's. -/
theorem bindingOf_fix (h : Rel LF FR M ν K s S t C) {env : Env} {nm : Name} {c : Nat}
    (hc : lookupEnv nm env = some c) (hp : Present s c) (hfix : M.a c = c) :
    bindingOf t env nm = (bindingOf s env nm).map M.val := by
  unfold bindingOf
  rw [hc]
  simp only [Option.bind_some]
  cases hcs : s.cell? c with
  | none =>
    have := cell?_none h hp hcs
    rw [hfix] at this
    rw [this]; rfl
  | some w =>
    have := t_cell h hcs
    rw [hfix] at this
    rw [this]
    cases w <;> rfl

/-- `optionalTensor_rel` with the handle condition at the tensor only. -/
theorem optionalTensor_rel' (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v)
    (hb : HandleBig s v) {T : Option Tensor} (hT : optionalTensor s v = some T) :
    ∃ T', optionalTensor t (M.val v) = some T' ∧ ORel (TensorR P M) T T' := by
  by_cases hn : v = .null
  · subst hn; cases hT; exact ⟨none, rfl, trivial⟩
  · have e1 : optionalTensor s v = (tensor s v).map some := by
      cases v <;> first | rfl | exact absurd rfl hn
    have e2 : optionalTensor t (M.val v) = (tensor t (M.val v)).map some := by
      cases v <;> first | rfl | exact absurd rfl hn
    rw [e1] at hT
    rw [e2]
    cases ht : tensor s v with
    | none => rw [ht] at hT; cases hT
    | some T0 =>
      rw [ht] at hT
      cases hT
      obtain ⟨T', h1, h2⟩ := tensor_rel h hv hb ht
      exact ⟨some T', by rw [h1]; rfl, h2⟩

theorem slotVal_map (h : Rel LF FR M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) (p o : List Char) :
    slotVal t (M.val v) p o = (slotVal s v p o).map M.val := by
  unfold slotVal
  rw [privateField_map h hv, own_map h hv]
  cases privateField s v p <;> rfl

theorem slotVal_supp (h : Rel LF FR M ν K s S t C) {v w : Val} {p o : List Char} (hw : slotVal s v p o = some w) :
    SV s S.tab.length w := by
  unfold slotVal at hw
  cases hp : privateField s v p with
  | none => rw [hp] at hw; exact own_supp h hw
  | some x => rw [hp] at hw; cases hw; exact privateField_supp h hp

theorem slot_rel (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v) {p o : List Char}
    (hb : ∀ w, slotVal s v p o = some w → HandleBig s w) {T : Option Tensor}
    (hs : (slotVal s v p o).bind (optionalTensor s) = some T) :
    ∃ T', (slotVal t (M.val v) p o).bind (optionalTensor t) = some T' ∧ ORel (TensorR P M) T T' := by
  rw [slotVal_map h hv]
  cases hx : slotVal s v p o with
  | none => rw [hx] at hs; cases hs
  | some w =>
    rw [hx] at hs
    exact optionalTensor_rel' h (slotVal_supp h hx) (hb w hx) hs

/-- **A source cache's image extracts on the target** (offsets dropped). -/
theorem cacheT_exists (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v)
    (hok : cacheOkB s v = true) {c : Cache} (hs : cacheT s v = some c) :
    ∃ c', cacheT t (M.val v) = some c' ∧ CacheR P M c c' := by
  simp only [cacheOkB, Bool.and_eq_true] at hok
  unfold cacheT at hs ⊢
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff, pure, Option.some.injEq] at hs
  obtain ⟨cls, hcls, f, hf, sc, hsc, rfl⟩ := hs
  obtain ⟨f', hf', rf⟩ := slot_rel (p := chars!"conv") (o := chars!"keys") h hv (slotOk_of hok.1)
    (Option.bind_eq_some_iff.2 hf)
  obtain ⟨sc', hsc', rsc⟩ := slot_rel (p := chars!"recurrent") (o := chars!"values") h hv (slotOk_of hok.2)
    (Option.bind_eq_some_iff.2 hsc)
  refine ⟨⟨cls, 0, f', sc'⟩, ?_, rfl, rf, rsc⟩
  rw [className_map h hv, hcls]
  simp only [Option.bind_eq_bind, Option.bind_some]
  unfold slotVal at hf' hsc'
  rw [hf']
  simp only [Option.bind_some]
  rw [hsc']
  rfl

/-- `Extract.cache` is `cacheT` with the offset read. -/
theorem cache_eq_of_offset {s : St LSt} {v : Val} {k : Nat} (ho : (own s v chars!"offset").bind nat = some k) :
    cache s v = (cacheT s v).map fun c => { c with offset := k } := by
  unfold cache cacheT
  simp only [Option.bind_eq_bind, ho, Option.bind_some]
  cases className s v with
  | none => rfl
  | some cls =>
    simp only [Option.bind_some]
    cases ((privateField s v chars!"conv").orElse fun _ => own s v chars!"keys").bind (optionalTensor s) with
    | none => rfl
    | some f =>
      simp only [Option.bind_some]
      cases ((privateField s v chars!"recurrent").orElse fun _ => own s v chars!"values").bind (optionalTensor s) <;>
        rfl

/-- **With a literal source offset, `Extract.cache` extracts the image**, at the same offset. -/
theorem cache_exists (h : Rel LF (LR P r) M ν K s S t C) {v : Val} (hv : SV s S.tab.length v)
    (hok : cacheOkB s v = true) (hlit : offsetLitB s v = true) {c : Cache} (hs : cacheT s v = some c) :
    ∃ c', cache t (M.val v) = some c' ∧ CacheR P M c c' := by
  obtain ⟨c', hc', hr⟩ := cacheT_exists h hv hok hs
  unfold offsetLitB at hlit
  cases ho : own s v chars!"offset" with
  | none => simp [ho] at hlit
  | some w =>
    cases w with
    | num n =>
      cases n with
      | lit x =>
        cases hx : F64.toIndex? x with
        | none => simp [ho, hx] at hlit
        | some k =>
          have hot : (own t (M.val v) chars!"offset").bind nat = some k := by
            rw [own_map h hv, ho]; exact hx
          refine ⟨{ c' with offset := k }, ?_, hr⟩
          rw [cache_eq_of_offset hot, hc']
          rfl
      | ref _ => simp [ho] at hlit
    | _ => simp [ho] at hlit

theorem elements_bind_map (h : Rel LF FR M ν K s S t C) {env : Env} {c : Nat}
    (hc : lookupEnv chars!"cache" env = some c) (hp : Present s c) (hfix : M.a c = c)
    (hfr : ∀ a, bindingOf s env chars!"cache" = some (.obj a) → K.fr a = none) :
    (bindingOf t env chars!"cache").bind (elements t) =
      ((bindingOf s env chars!"cache").bind (elements s)).map M.vals := by
  rw [bindingOf_fix h hc hp hfix]
  cases hb : bindingOf s env chars!"cache" with
  | none => rfl
  | some w =>
    simp only [Option.map_some, Option.bind_some]
    exact elements_map h (bindingOf_supp h hb) fun a ha => hfr a (by rw [hb, ha])

theorem elements_bind_supp (h : Rel LF FR M ν K s S t C) {env : Env} {es : List Val}
    (he : (bindingOf s env chars!"cache").bind (elements s) = some es) : ∀ v ∈ es, SV s S.tab.length v := by
  cases hb : bindingOf s env chars!"cache" with
  | none => rw [hb] at he; cases he
  | some w =>
    rw [hb] at he
    exact elements_supp h he

/-- **The target's cache binding at a fixed cell extracts to the source caches' images**
(offsets dropped). -/
theorem cachesT_end (h : Rel LF (LR P r) M ν K s S t C) {env : Env} {c : Nat}
    (hc : lookupEnv chars!"cache" env = some c) (hp : Present s c) (hfix : M.a c = c)
    (hfr : ∀ a, bindingOf s env chars!"cache" = some (.obj a) → K.fr a = none)
    (hok : cachesAllB s env cacheOkB = true) {cs : List Cache} (hs : cachesT s env = some cs) :
    ∃ cs', cachesT t env = some cs' ∧ LRel (CacheR P M) cs cs' := by
  unfold cachesT at hs ⊢
  rw [elements_bind_map h hc hp hfix hfr]
  unfold cachesAllB at hok
  cases he : (bindingOf s env chars!"cache").bind (elements s) with
  | none => rw [he] at hs; cases hs
  | some es =>
    rw [he] at hs hok
    simp only [Option.map_some, Option.bind_some] at hs ⊢
    rw [show M.vals es = es.map M.val from rfl, mapM_map]
    have hsup := elements_bind_supp h he
    exact mapM_exists es (fun v hv c hcv => cacheT_exists h (hsup v hv) (List.all_eq_true.mp hok v hv) hcv) hs

/-- **The same by `Extract.cache`**, for literal source offsets. -/
theorem caches_end (h : Rel LF (LR P r) M ν K s S t C) {env : Env} {c : Nat}
    (hc : lookupEnv chars!"cache" env = some c) (hp : Present s c) (hfix : M.a c = c)
    (hfr : ∀ a, bindingOf s env chars!"cache" = some (.obj a) → K.fr a = none)
    (hok : cachesAllB s env cacheOkB = true) (hlit : cachesAllB s env offsetLitB = true)
    {cs : List Cache} (hs : cachesT s env = some cs) :
    ∃ cs', caches t env = some cs' ∧ LRel (CacheR P M) cs cs' := by
  unfold cachesT at hs
  unfold caches
  rw [elements_bind_map h hc hp hfix hfr]
  unfold cachesAllB at hok hlit
  cases he : (bindingOf s env chars!"cache").bind (elements s) with
  | none => rw [he] at hs; cases hs
  | some es =>
    rw [he] at hs hok hlit
    simp only [Option.map_some, Option.bind_some] at hs ⊢
    rw [show M.vals es = es.map M.val from rfl, mapM_map]
    have hsup := elements_bind_supp h he
    exact mapM_exists es (fun v hv c hcv => cache_exists h (hsup v hv) (List.all_eq_true.mp hok v hv)
      (List.all_eq_true.mp hlit v hv) hcv) hs

end

theorem oRel_node {P : LoadP} {M : Map} :
    ∀ {T : Option Tensor} {T' : Option Tensor}, ORel (TensorR P M) T T' → T'.map Tensor.node = (T.map Tensor.node).map M.node
  | none, none, _ => rfl
  | some _, some _, h => by simp only [Option.map_some]; rw [h.2.1]
  | none, some _, h => h.elim
  | some _, none, h => h.elim

/-- **Related caches' tensor nodes are the images.** -/
theorem cacheR_nodes {P : LoadP} {M : Map} :
    ∀ {cs cs' : List Cache}, LRel (CacheR P M) cs cs' →
      cs'.map nodePair = (cs.map nodePair).map fun p => (p.1.map M.node, p.2.map M.node)
  | [], [], _ => rfl
  | c :: cs, c' :: cs', ⟨hc, hr⟩ => by
    simp only [List.map_cons, nodePair]
    rw [oRel_node hc.2.1, oRel_node hc.2.2]
    exact congrArg _ (cacheR_nodes hr)
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim

section
variable {P : LoadP} {r : List NumV} {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St LSt} {S : SSrv} {C : CSrv}

/-- **`cachesT_end` with the source's tensor nodes `ps`**: the target's are their images. -/
theorem cachesT_end_nodes (h : Rel LF (LR P r) M ν K s S t C) {env : Env} {c : Nat}
    (hc : lookupEnv chars!"cache" env = some c) (hp : Present s c) (hfix : M.a c = c)
    (hfr : ∀ a, bindingOf s env chars!"cache" = some (.obj a) → K.fr a = none)
    (hok : cachesAllB s env cacheOkB = true) {cs : List Cache} (hs : cachesT s env = some cs)
    {ps : List (Option Nat × Option Nat)} (hn : cs.map nodePair = ps) :
    ∃ cs', cachesT t env = some cs' ∧ cs'.map nodePair = ps.map fun p => (p.1.map M.node, p.2.map M.node) := by
  obtain ⟨cs', h1, h2⟩ := cachesT_end h hc hp hfix hfr hok hs
  exact ⟨cs', h1, by rw [cacheR_nodes h2, hn]⟩

/-- **`caches_end` with the source's tensor nodes `ps`.** -/
theorem caches_end_nodes (h : Rel LF (LR P r) M ν K s S t C) {env : Env} {c : Nat}
    (hc : lookupEnv chars!"cache" env = some c) (hp : Present s c) (hfix : M.a c = c)
    (hfr : ∀ a, bindingOf s env chars!"cache" = some (.obj a) → K.fr a = none)
    (hok : cachesAllB s env cacheOkB = true) (hlit : cachesAllB s env offsetLitB = true)
    {cs : List Cache} (hs : cachesT s env = some cs)
    {ps : List (Option Nat × Option Nat)} (hn : cs.map nodePair = ps) :
    ∃ cs', caches t env = some cs' ∧ cs'.map nodePair = ps.map fun p => (p.1.map M.node, p.2.map M.node) := by
  obtain ⟨cs', h1, h2⟩ := caches_end h hc hp hfix hfr hok hlit hs
  exact ⟨cs', h1, by rw [cacheR_nodes h2, hn]⟩

end

end Host.Ts.Sim.ExtractSim
