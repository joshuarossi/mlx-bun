import host.sim.steps.Props
namespace Host.Ts.Sim

/-! # Expression frames receiving a value

Shared helpers of the value-receiving frames (`rf_*`, also used by `RetC`,
`RetL`, `RetA`) and the steps of `ret v` with an expression frame on top. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-! ## Helpers -/

/-- A value returning to the top frame, on both sides. -/
theorem Rel.rfRetFrame (h : Rel F FR M ν K s S t C) {v : Val} {f : Frame} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = f :: fs) :
    step F s = retStep F { s with stack := fs } f v ∧
    step F t = retStep F { t with stack := fs.map M.frame } (M.frame f) (M.val v) ∧
    Rel F FR M ν K { s with stack := fs } S { t with stack := fs.map M.frame } C ∧
    Supp.val (Present s) S.tab.length v ∧ Supp.frame (Present s) S.tab.length f := by
  obtain ⟨hts, hr⟩ := h.pop hs
  have htc : t.ctl = .ret (M.val v) := by rw [h.ctl, hc]; rfl
  refine ⟨by simp only [step, hc, stepRet, hs], by simp only [step, htc, stepRet, hts], hr, ?_,
    h.stackSupp f (by rw [hs]; exact List.mem_cons_self ..)⟩
  have := h.ctlSupp
  rw [hc] at this
  exact this

theorem rf_rel {s' t' : St F.S} (h : Rel F FR M ν K s' S t' C) :
    MSim (StepPost F FR M ν K S C) S C (Host.Ts.M.pure s') (Host.Ts.M.pure t') :=
  MSim.pure ⟨Grow.refl h.srv, h⟩

theorem rf_ret (h : Rel F FR M ν K s S t C) (v : Val) (hv : Supp.val (Present s) S.tab.length v) :
    MSim (StepPost F FR M ν K S C) S C (retS F s v) (retS F t (M.val v)) :=
  rf_rel (h.ret v hv)

/-- Sequencing a value computation with a step. -/
theorem rf_bind {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {m : Host.Ts.M α}
    {m' : Host.Ts.M β} {f : α → RS F} {f' : β → RS F}
    (hm : MSim (fun M' S' C' a b => P M' S' C' a b ∧ Grow M ν S C M' S' C') S C m m')
    (hf : ∀ M' S' C' a b, P M' S' C' a b → Grow M ν S C M' S' C' →
      MSim (StepPost F FR M' ν K S' C') S' C' (f a) (f' b)) :
    MSim (StepPost F FR M ν K S C) S C (Host.Ts.M.bind m f) (Host.Ts.M.bind m' f') :=
  MSim.bind hm fun M' S' C' a b hab =>
    MSim.mono (hf M' S' C' a b hab.1 hab.2) fun _ _ _ _ _ hp => ⟨hab.2.trans hp.1, hp.2⟩

/-- The map images of supported data agree along growth. -/
theorem Grow.rfVal {M' : Map} {S' : SSrv} {C' : CSrv} {A : Nat → Prop} (g : Grow M ν S C M' S' C')
    {v : Val} (hv : Supp.val A S.tab.length v) : M.val v = M'.val v :=
  Map.val_agree g.ext.agree hv

theorem Grow.rfEnv {M' : Map} {S' : SSrv} {C' : CSrv} {A : Nat → Prop} (g : Grow M ν S C M' S' C')
    {e : Env} (he : Supp.env A S.tab.length e) : M.env e = M'.env e :=
  Map.env_agree g.ext.agree he

theorem Grow.rfFrame {M' : Map} {S' : SSrv} {C' : CSrv} {A : Nat → Prop} (g : Grow M ν S C M' S' C')
    {f : Frame} (hf : Supp.frame A S.tab.length f) : M.frame f = M'.frame f :=
  Map.frame_agree g.ext.agree hf

theorem Grow.rfKey {M' : Map} {S' : SSrv} {C' : CSrv} {A : Nat → Prop} (g : Grow M ν S C M' S' C')
    {k : PKey} (hk : Supp.key A S.tab.length k) : M.key k = M'.key k :=
  Map.key_agree g.ext.agree hk

theorem Grow.rfVals {M' : Map} {S' : SSrv} {C' : CSrv} {A : Nat → Prop} (g : Grow M ν S C M' S' C')
    {vs : List Val} (hv : Supp.vals A S.tab.length vs) : M.vals vs = M'.vals vs :=
  Map.vals_agree g.ext.agree hv

theorem Grow.rfTarget {M' : Map} {S' : SSrv} {C' : CSrv} {A : Nat → Prop} (g : Grow M ν S C M' S' C')
    {x : Target} (hx : Supp.target A S.tab.length x) : M.target x = M'.target x :=
  Map.target_agree g.ext.agree hx

/-- Support only weakens as the table grows. -/
theorem rf_vmono {A : Nat → Prop} {n n' : Nat} (hn : n ≤ n') {v : Val} (hv : Supp.val A n v) :
    Supp.val A n' v :=
  Supp.val_mono (fun _ h => h) hn hv

theorem rf_s64 (hn : s.next < Sim.bound) : s.next < 2 ^ 64 := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  rw [hb] at hn
  omega

end


/-! ## Numbers with the support of the result -/

section
variable {ν : Nat → F64}

private theorem rf_srv_push {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    Srv (M.setNum S.tab.length x) ν { S with tab := S.tab ++ [e] } C1 := by
  refine ⟨?_, hs.good⟩
  intro i e' he
  rcases nth?_append_eq S.tab e i e' he with ⟨hi, hi'⟩ | ⟨rfl, rfl⟩
  · rw [(M.setNum_ext S.tab.length x).num i hi]
    exact hle.val (hs.num i e' hi')
  · rw [M.setNum_self]
    exact hx

private theorem rf_push_val (C : CSrv) (x : F64) :
    (⟨C.tab ++ [x]⟩ : CSrv).val (.ref C.tab.length) = some x :=
  nth?_length_append C.tab x

private theorem rf_grow_push {M : Map} {S : SSrv} {C C1 : CSrv} (hs : Srv M ν S C) (hle : CSrv.Le C C1)
    (e : SymE) (x : NumV) (hx : C1.val x = some (e.eval ν)) :
    Grow M ν S C (M.setNum S.tab.length x) { S with tab := S.tab ++ [e] } C1 :=
  ⟨M.setNum_ext _ _, rf_srv_push hs hle e x hx, by simp⟩

private theorem rf_supp_push {A : Nat → Prop} (S : SSrv) (e : SymE) :
    Supp.nv A ({ S with tab := S.tab ++ [e] } : SSrv).tab.length (.ref S.tab.length) := by
  show S.tab.length < (S.tab ++ [e]).length
  simp

private theorem rf_numBin_req {δ : Type} (op : NBin) (x y : NumV) (k' : NumV → Free δ)
    (h : ∀ u v, x = .lit u → y = .lit v → False) :
    (numBin op x y) δ k' = .bin op x y fun j => k' (.ref j) := by
  cases x with
  | lit u =>
    cases y with
    | lit v => exact (h u v rfl rfl).elim
    | ref _ => rfl
  | ref _ => cases y <;> rfl

/-- `numBin_sim`, also giving the support of the result. -/
theorem rf_numBin {A : Nat → Prop} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NBin)
    (a b : NumV) :
    MSim (fun M' S' C' r r' => (r' = M'.nv r ∧ Supp.nv A S'.tab.length r) ∧ Grow M ν S C M' S' C') S C
      (numBin op a b) (numBin op (M.nv a) (M.nv b)) := by
  intro γ δ Q k k' hk
  have req : ∀ (K : Nat → Free γ), (∀ i, K i = k (.ref i)) →
      FSim Q S C (.bin op a b K) ((numBin op (M.nv a) (M.nv b)) δ k') := by
    intro K hK r S' hu
    rw [interpS_bin] at hu
    cases hva : S.val a with
    | none => rw [hva] at hu; cases hu
    | some ea =>
      cases hvb : S.val b with
      | none => rw [hva, hvb] at hu; cases hu
      | some eb =>
        rw [hva, hvb] at hu
        simp only at hu
        rw [hK] at hu
        have ca := hs.num.val hva
        have cb := hs.num.val hvb
        by_cases lits : ∃ u v, M.nv a = .lit u ∧ M.nv b = .lit v
        · obtain ⟨u, v, hu', hv'⟩ := lits
          rw [hu'] at ca; rw [hv'] at cb
          simp only [CSrv.val, Option.some.injEq] at ca cb
          subst ca cb
          have hg := rf_grow_push hs (CSrv.Le.refl C) (.bin op ea eb)
            (.lit (F64.bin op (ea.eval ν) (eb.eval ν))) rfl
          obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length)
            (.lit (F64.bin op (ea.eval ν) (eb.eval ν)))
            ⟨⟨(M.setNum_self _ _).symm, rf_supp_push S _⟩, hg⟩ r S' hu
          refine ⟨M', b', C', ?_, hq⟩
          rw [hu', hv']
          exact hv
        · have hnot : ∀ u v, M.nv a = .lit u → M.nv b = .lit v → False :=
            fun u v h1 h2 => lits ⟨u, v, h1, h2⟩
          have hg := rf_grow_push hs (C1 := ⟨C.tab ++ [F64.bin op (ea.eval ν) (eb.eval ν)]⟩) ⟨_, rfl⟩
            (.bin op ea eb) (.ref C.tab.length) (rf_push_val C _)
          obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.ref C.tab.length)
            ⟨⟨(M.setNum_self _ _).symm, rf_supp_push S _⟩, hg⟩ r S' hu
          refine ⟨M', b', C', ?_, hq⟩
          rw [rf_numBin_req op _ _ k' hnot, interpC_bin, ca, cb]
          exact hv
  cases a with
  | lit x =>
    cases b with
    | lit y => exact hk M S C _ _ ⟨⟨rfl, trivial⟩, Grow.refl hs⟩
    | ref j => exact req _ (fun _ => rfl)
  | ref i =>
    cases b with
    | lit y => exact req _ (fun _ => rfl)
    | ref j => exact req _ (fun _ => rfl)

private theorem rf_numUn_req {δ : Type} (op : NUn) (x : NumV) (k' : NumV → Free δ)
    (h : ∀ u, x = .lit u → False) :
    (numUn op x) δ k' = .un op x fun j => k' (.ref j) := by
  cases x with
  | lit u => exact (h u rfl).elim
  | ref _ => rfl

/-- `numUn_sim`, also giving the support of the result. -/
theorem rf_numUn {A : Nat → Prop} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (op : NUn)
    (a : NumV) :
    MSim (fun M' S' C' r r' => (r' = M'.nv r ∧ Supp.nv A S'.tab.length r) ∧ Grow M ν S C M' S' C') S C
      (numUn op a) (numUn op (M.nv a)) := by
  intro γ δ Q k k' hk
  have req : ∀ (K : Nat → Free γ), (∀ i, K i = k (.ref i)) →
      FSim Q S C (.un op a K) ((numUn op (M.nv a)) δ k') := by
    intro K hK r S' hu
    rw [interpS_un] at hu
    cases hva : S.val a with
    | none => rw [hva] at hu; cases hu
    | some ea =>
      rw [hva] at hu
      simp only at hu
      rw [hK] at hu
      have ca := hs.num.val hva
      by_cases lit : ∃ u, M.nv a = .lit u
      · obtain ⟨u, hu'⟩ := lit
        rw [hu'] at ca
        simp only [CSrv.val, Option.some.injEq] at ca
        subst ca
        have hg := rf_grow_push hs (CSrv.Le.refl C) (.un op ea) (.lit (F64.un op (ea.eval ν))) rfl
        obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.lit (F64.un op (ea.eval ν)))
          ⟨⟨(M.setNum_self _ _).symm, rf_supp_push S _⟩, hg⟩ r S' hu
        refine ⟨M', b', C', ?_, hq⟩
        rw [hu']
        exact hv
      · have hnot : ∀ u, M.nv a = .lit u → False := fun u h1 => lit ⟨u, h1⟩
        have hg := rf_grow_push hs (C1 := ⟨C.tab ++ [F64.un op (ea.eval ν)]⟩) ⟨_, rfl⟩
          (.un op ea) (.ref C.tab.length) (rf_push_val C _)
        obtain ⟨M', b', C', hv, hq⟩ := hk _ _ _ (.ref S.tab.length) (.ref C.tab.length)
          ⟨⟨(M.setNum_self _ _).symm, rf_supp_push S _⟩, hg⟩ r S' hu
        refine ⟨M', b', C', ?_, hq⟩
        rw [rf_numUn_req op _ k' hnot, interpC_un, ca]
        exact hv
  cases a with
  | lit x => exact hk M S C _ _ ⟨⟨rfl, trivial⟩, Grow.refl hs⟩
  | ref i => exact req _ (fun _ => rfl)

end

/-! ## Side conditions on bigints -/

instance rfDecBigFixed (lo hi : Nat) (i : Int) : Decidable (BigFixed lo hi i) :=
  inferInstanceAs (Decidable (_ ∨ _ ∨ _))

/-- A bigint value is one the map fixes (other values: no condition). -/
def BigFixedV (K : Ctx) : Val → Prop
  | .big i => BigFixed K.lo K.hi i
  | _ => True

instance rfDecBigFixedV (K : Ctx) (v : Val) : Decidable (BigFixedV K v) := by
  cases v <;> simp only [BigFixedV] <;> infer_instance

theorem Rel.rfFixBig {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St F.S} {S : SSrv} {C : CSrv} (h : Rel F FR M ν K s S t C) {v : Val} (hb : BigFixedV K v) :
    ∀ i, v = .big i → M.big i = i := by
  intro i hv
  subst hv
  exact h.bigFixed i hb

/-! ## Values through the map -/

section
variable {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv}

theorem rf_bind_pure {α β : Type} (a : α) (f : α → Host.Ts.M β) :
    Host.Ts.M.bind (Host.Ts.M.pure a) f = f a := rfl

theorem rf_isNullish (v : Val) : isNullish (M.val v) = isNullish v := by
  cases v <;> rfl

theorem Grow.rfBig {M' : Map} {S' : SSrv} {C' : CSrv} (g : Grow M ν S C M' S' C') : M'.big = M.big :=
  g.ext.big

theorem rf_truthy (hs : Srv M ν S C) (v : Val) (hb : ∀ i, v = .big i → M.big i = i) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (truthy v) (truthy (M.val v)) := by
  cases v with
  | num x => exact numTest_sim hs .truthy x zeroN
  | big i =>
    show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure (!(M.big i == 0)))
    rw [hb i rfl]
    exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | _ => exact MSim.pure ⟨rfl, Grow.refl hs⟩

theorem rf_primStr (hs : Srv M ν S C) (v : Val) (hb : ∀ i, v = .big i → M.big i = i) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (primStr v) (primStr (M.val v)) := by
  cases v with
  | num x =>
    show MSim _ S C (Host.Ts.M.bind (numConc x) _) (Host.Ts.M.bind (numConc (M.nv x)) _)
    refine MSim.bind (numConc_sim hs x) fun M' S' C' f f' hf => ?_
    obtain ⟨rfl, g⟩ := hf
    cases hstr : F64.toStr f' with
    | some cs => exact MSim.pure ⟨rfl, g⟩
    | none => exact MSim.fail _ _
  | big i =>
    show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure (some (bigStr (M.big i))))
    rw [hb i rfl]
    exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | _ => exact MSim.pure ⟨rfl, Grow.refl hs⟩

theorem rf_toKey {A : Nat → Prop} (hs : Srv M ν S C) (v : Val) (hb : ∀ i, v = .big i → M.big i = i)
    (hv : Supp.val A S.tab.length v) :
    MSim (fun M' S' C' r r' => (r' = r.map M'.key ∧ Supp.okey A S'.tab.length r) ∧ Grow M ν S C M' S' C')
      S C (toKey v) (toKey (M.val v)) := by
  cases v with
  | sym i => exact MSim.pure ⟨⟨rfl, hv⟩, Grow.refl hs⟩
  | _ =>
    show MSim _ S C (Host.Ts.M.bind (primStr _) _) (Host.Ts.M.bind (primStr _) _)
    refine MSim.bind (rf_primStr hs _ hb) fun M' S' C' o o' ho => ?_
    obtain ⟨rfl, g⟩ := ho
    cases o' <;> exact MSim.pure ⟨⟨rfl, trivial⟩, g⟩

/-- `toNum` is pure. -/
def toNumPure : Val → Option NumV
  | .num x => some x
  | .bool b => some (bif b then one else zeroN)
  | .undef => some (.lit .nan)
  | .null => some zeroN
  | .str cs => some (.lit (F64.ofString cs))
  | _ => none

theorem rf_toNum (v : Val) : toNum v = Host.Ts.M.pure (toNumPure v) := by
  cases v <;> rfl

theorem rf_toNumP (v : Val) : toNumPure (M.val v) = (toNumPure v).map M.nv := by
  cases v with
  | bool b => cases b <;> rfl
  | _ => rfl

theorem rf_toNumP_supp {A : Nat → Prop} {n : Nat} {v : Val} {x : NumV} (hv : Supp.val A n v)
    (hx : toNumPure v = some x) : Supp.nv A n x := by
  cases v with
  | num y => cases hx; exact hv
  | bool b => cases hx; cases b <;> trivial
  | undef => cases hx; trivial
  | null => cases hx; trivial
  | str cs => cases hx; trivial
  | _ => cases hx

end

/-! ## Steps through the value helpers -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A numeric result returned. -/
theorem rf_numRet (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) {m m' : Host.Ts.M NumV}
    (hm : MSim (fun M' S' C' r r' => (r' = M'.nv r ∧ Supp.nv (Present s) S'.tab.length r) ∧
      Grow M ν S C M' S' C') S C m m') :
    MSim (StepPost F FR M ν K S C) S C (Host.Ts.M.bind m fun r => retS F s (.num r))
      (Host.Ts.M.bind m' fun r => retS F t (.num r)) :=
  rf_bind hm fun _ _ _ r _ hr g => by
    obtain ⟨rfl, hsupp⟩ := hr
    exact rf_ret (h.grow hFR g) (.num r) hsupp

theorem rf_retBig (h : Rel F FR M ν K s S t C) (r : Int) (hr : M.big r = r) :
    MSim (StepPost F FR M ν K S C) S C (retS F s (.big r)) (retS F t (.big r)) := by
  have := rf_ret h (.big r) trivial
  rwa [show M.val (.big r) = .big r from by show Val.big (M.big r) = _; rw [hr]] at this

theorem rf_typeofStr (h : Rel F FR M ν K s S t C) {v : Val} (hv : Supp.val (Present s) S.tab.length v) :
    typeofStr t (M.val v) = typeofStr s v := by
  cases v with
  | obj a =>
    show typeofStr t (.obj (M.a a)) = typeofStr s (.obj a)
    obtain ⟨o, hg⟩ := Present.get hv
    cases o with
    | cell c =>
      have hfr := h.fr_cell hg
      have ht := h.get hg hfr
      simp only [typeofStr, St.obj?, hg, ht, Map.hobj]
    | obj o =>
      cases hfr : K.fr a with
      | none =>
        have ht := h.get hg hfr
        simp only [typeofStr, St.obj?, hg, ht, Map.hobj, Map.obj]
        cases o.kind <;> rfl
      | some p =>
        obtain ⟨pre, pre'⟩ := p
        obtain ⟨o', ht, xs, hk, rfl⟩ := h.obj?_framed (obj?_iff.2 hg) hfr
        rw [obj?_iff] at ht
        simp only [typeofStr, St.obj?, hg, ht, hk]
        rfl
  | _ => rfl

end

/-! ## Operators -/

/-- The bigint result of `bigOp`, when it returns one. -/
def bigOpRes (op : BinOp) (a b : Int) : Option Int :=
  match op with
  | .add => some (a + b)
  | .sub => some (a - b)
  | .mul => some (a * b)
  | .div => bif decide (b = 0) then none else some (a.tdiv b)
  | .mod => bif decide (b = 0) then none else some (a.tmod b)
  | .exp => match b with
    | .ofNat k => some (a ^ k)
    | _ => none
  | .band => match a, b with
    | .ofNat x, .ofNat y => some ((Nat.land x y : Nat) : Int)
    | _, _ => none
  | .bor => match a, b with
    | .ofNat x, .ofNat y => some ((Nat.lor x y : Nat) : Int)
    | _, _ => none
  | .bxor => match a, b with
    | .ofNat x, .ofNat y => some ((Nat.xor x y : Nat) : Int)
    | _, _ => none
  | .shl => match b with
    | .ofNat k => some (a * ((2 ^ k : Nat) : Int))
    | _ => none
  | .shr => match b with
    | .ofNat k => some (a / ((2 ^ k : Nat) : Int))
    | _ => none
  | _ => none

def BigFixedO (K : Ctx) : Option Int → Prop
  | some r => BigFixed K.lo K.hi r
  | none => True

instance rfDecBigFixedO (K : Ctx) (o : Option Int) : Decidable (BigFixedO K o) := by
  cases o <;> simp only [BigFixedO] <;> infer_instance

def BigResOK (K : Ctx) (op : BinOp) : Val → Val → Prop
  | .big x, .big y => BigFixedO K (bigOpRes op x y)
  | _, _ => True

instance rfDecBigResOK (K : Ctx) (op : BinOp) (a b : Val) : Decidable (BigResOK K op a b) := by
  cases a <;> cases b <;> simp only [BigResOK] <;> infer_instance

/-- Bigint side condition of a binary operator: bigint operands are fixed by the
map, and so is a bigint result. -/
def BinBigOK (K : Ctx) (op : BinOp) (a b : Val) : Prop :=
  BigFixedV K a ∧ BigFixedV K b ∧ BigResOK K op a b

instance rfDecBinBigOK (K : Ctx) (op : BinOp) (a b : Val) : Decidable (BinBigOK K op a b) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _))

/-- Bigint side condition of a unary operator. -/
def UnBigOK (K : Ctx) : UnOp → Val → Prop
  | .neg, .big i => BigFixed K.lo K.hi i ∧ BigFixed K.lo K.hi (-i)
  | .bnot, .big i => BigFixed K.lo K.hi i ∧ BigFixed K.lo K.hi (-(i + 1))
  | .not, v => BigFixedV K v
  | _, _ => True

instance rfDecUnBigOK (K : Ctx) (op : UnOp) (v : Val) : Decidable (UnBigOK K op v) := by
  cases op <;> cases v <;> simp only [UnBigOK, BigFixedV] <;> infer_instance

theorem rf_val_big {M : Map} {v : Val} (hv : ∀ i, v ≠ .big i) : ∀ i, M.val v ≠ .big i := by
  intro i he
  cases v <;> simp only [Map.val, reduceCtorEq] at he
  exact hv _ rfl

theorem rf_val_str {M : Map} {v : Val} (hv : ∀ x, v ≠ .str x) : ∀ x, M.val v ≠ .str x := by
  intro x he
  cases v <;> simp only [Map.val, reduceCtorEq] at he
  exact hv _ rfl

section
variable {F : Ffi}

/-- `arith` once both operands are numbers. -/
def rfArithN (s : St F.S) (op : BinOp) (x y : NumV) : RS F :=
  match op with
  | .exp => match x, y with
    | .lit p, .lit q => match F64.pow p q with
      | some r => retS F s (.num (.lit r))
      | none => .fail "** with an inexact result"
    | _, _ => .fail "** of a symbolic number"
  | op => match numOp? op with
    | some o => .bind (numBin o x y) fun r => retS F s (.num r)
    | none => .fail "numeric operator"

/-- `arith` when an operand is not a number. -/
def rfArithFb (s : St F.S) (a b : Val) : RS F :=
  match a, b with
  | .sym _, _ => typeErr s (chars!"cannot convert a Symbol to a number")
  | _, .sym _ => typeErr s (chars!"cannot convert a Symbol to a number")
  | _, _ => .fail "ToPrimitive of an object"

theorem rf_arith_eq (s : St F.S) (op : BinOp) (a b : Val) (ha : ∀ i, a ≠ .big i) (hb : ∀ i, b ≠ .big i) :
    arith F s op a b = (match toNumPure a, toNumPure b with
      | some x, some y => rfArithN s op x y
      | _, _ => rfArithFb s a b) := by
  cases a <;> cases b <;> first | rfl | exact absurd rfl (ha _) | exact absurd rfl (hb _)

def rfCmpN (s : St F.S) (le : Bool) (x y : Option NumV) : RS F :=
  match x, y with
  | some x, some y => .bind (numTest (bif le then .le else .lt) x y) fun r => retS F s (.bool r)
  | _, _ => .fail "comparison of objects"

theorem rf_compare_eq (s : St F.S) (a b : Val) (le : Bool) (ha : ∀ i, a ≠ .big i) (hb : ∀ i, b ≠ .big i)
    (hs : ∀ x, a ≠ .str x) : compare F s a b le = rfCmpN s le (toNumPure a) (toNumPure b) := by
  cases a <;> cases b <;> first | rfl | exact absurd rfl (ha _) | exact absurd rfl (hb _) |
    exact absurd rfl (hs _)

theorem rf_compare_eq' (s : St F.S) (a b : Val) (le : Bool) (ha : ∀ i, a ≠ .big i) (hb : ∀ i, b ≠ .big i)
    (hs : ∀ x, b ≠ .str x) : compare F s a b le = rfCmpN s le (toNumPure a) (toNumPure b) := by
  cases a <;> cases b <;> first | rfl | exact absurd rfl (ha _) | exact absurd rfl (hb _) |
    exact absurd rfl (hs _)

/-- `addOp` with a string on the left, once the right operand is converted. -/
def rfAddL (s : St F.S) (x : List Char) (b : Val) : Option (List Char) → RS F
  | some y => retS F s (.str (x ++ y))
  | none => match b with
    | .sym _ => typeErr s (chars!"cannot convert a Symbol to a string")
    | _ => .fail "string concatenation with an object"

def rfAddR (s : St F.S) (y : List Char) (a : Val) : Option (List Char) → RS F
  | some x => retS F s (.str (x ++ y))
  | none => match a with
    | .sym _ => typeErr s (chars!"cannot convert a Symbol to a string")
    | _ => .fail "string concatenation with an object"

theorem rf_addOp_strL (s : St F.S) (x : List Char) (b : Val) (hb : ∀ y, b ≠ .str y) :
    addOp F s (.str x) b = Host.Ts.M.bind (primStr b) (rfAddL s x b) := by
  cases b <;> first | rfl | exact absurd rfl (hb _)

theorem rf_addOp_strR (s : St F.S) (a : Val) (y : List Char) (ha : ∀ x, a ≠ .str x) :
    addOp F s a (.str y) = Host.Ts.M.bind (primStr a) (rfAddR s y a) := by
  cases a <;> first | rfl | exact absurd rfl (ha _)

theorem rf_addOp_arith (s : St F.S) (a b : Val) (ha : ∀ x, a ≠ .str x) (hb : ∀ y, b ≠ .str y) :
    addOp F s a b = arith F s .add a b := by
  cases a <;> cases b <;> first | rfl | exact absurd rfl (ha _) | exact absurd rfl (hb _)

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

section
variable (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
  (hn : s.next < Sim.bound)
include h hn

theorem rf_bigOp (hpT : Present s aTypeErrorProto) (hpR : Present s aRangeErrorProto) (op : BinOp)
    (x y : Int) (hr : BigFixedO K (bigOpRes op x y)) :
    MSim (StepPost F FR M ν K S C) S C (bigOp F s op x y) (bigOp F t op x y) := by
  cases op
  case add | sub | mul =>
    simp only [bigOp]
    exact rf_retBig h _ (h.bigFixed _ hr)
  case div | mod =>
    simp only [bigOp, bigOpRes] at hr ⊢
    cases hz : decide (y = 0) <;> simp only [hz, Bool.cond_true, Bool.cond_false] at hr ⊢
    · exact rf_retBig h _ (h.bigFixed _ hr)
    · exact rangeErr_sim h h.intr hn hpR _
  case exp =>
    simp only [bigOp, bigOpRes] at hr ⊢
    cases y with
    | ofNat k => exact rf_retBig h _ (h.bigFixed _ hr)
    | negSucc k => exact rangeErr_sim h h.intr hn hpR _
  case band | bor | bxor =>
    simp only [bigOp, bigNat2, bigOpRes] at hr ⊢
    cases x <;> cases y
    case ofNat.ofNat => exact rf_retBig h _ (h.bigFixed _ hr)
    all_goals exact MSim.fail _ _
  case shl | shr =>
    simp only [bigOp, bigOpRes] at hr ⊢
    cases y with
    | ofNat k => exact rf_retBig h _ (h.bigFixed _ hr)
    | negSucc k => exact MSim.fail _ _
  all_goals exact typeErr_sim h h.intr hn hpT _

omit hn in
include hFR in
theorem rf_arithN (op : BinOp) (x y : NumV) (hx : Supp.nv (Present s) S.tab.length x)
    (hy : Supp.nv (Present s) S.tab.length y) :
    MSim (StepPost F FR M ν K S C) S C (rfArithN s op x y) (rfArithN t op (M.nv x) (M.nv y)) := by
  cases op
  case exp =>
    cases x with
    | lit p =>
      cases y with
      | lit q =>
        simp only [rfArithN, Map.nv]
        cases F64.pow p q with
        | some r => exact rf_ret h (.num (.lit r)) trivial
        | none => exact MSim.fail _ _
      | ref _ => exact MSim.fail _ _
    | ref _ => exact MSim.fail _ _
  all_goals first
    | exact rf_numRet h hFR (rf_numBin h.srv _ x y)
    | exact MSim.fail _ _

theorem rf_arithFb (hpT : Present s aTypeErrorProto) (a b : Val) :
    MSim (StepPost F FR M ν K S C) S C (rfArithFb s a b) (rfArithFb t (M.val a) (M.val b)) := by
  cases a <;> cases b <;> first | exact MSim.fail _ _ | exact typeErr_sim h h.intr hn hpT _

include hFR in
theorem rf_arith (hpT : Present s aTypeErrorProto) (hpR : Present s aRangeErrorProto) (op : BinOp)
    {a b : Val} (ha : Supp.val (Present s) S.tab.length a) (hb : Supp.val (Present s) S.tab.length b)
    (hok : BinBigOK K op a b) :
    MSim (StepPost F FR M ν K S C) S C (arith F s op a b) (arith F t op (M.val a) (M.val b)) := by
  by_cases hbig : ∃ x y, a = .big x ∧ b = .big y
  · obtain ⟨x, y, rfl, rfl⟩ := hbig
    show MSim _ S C (bigOp F s op x y) (bigOp F t op (M.big x) (M.big y))
    rw [h.bigFixed x hok.1, h.bigFixed y hok.2.1]
    exact rf_bigOp h hn hpT hpR op x y hok.2.2
  by_cases hba : ∃ x, a = .big x
  · obtain ⟨x, rfl⟩ := hba
    cases b <;> first | exact typeErr_sim h h.intr hn hpT _ | exact absurd ⟨_, _, rfl, rfl⟩ hbig
  by_cases hbb : ∃ y, b = .big y
  · obtain ⟨y, rfl⟩ := hbb
    cases a <;> first | exact typeErr_sim h h.intr hn hpT _ | exact absurd ⟨_, _, rfl, rfl⟩ hbig
  have ha' : ∀ i, a ≠ .big i := fun i he => hba ⟨i, he⟩
  have hb' : ∀ i, b ≠ .big i := fun i he => hbb ⟨i, he⟩
  rw [rf_arith_eq s op a b ha' hb', rf_arith_eq t op _ _ (rf_val_big ha') (rf_val_big hb'), rf_toNumP,
    rf_toNumP]
  cases hx : toNumPure a with
  | none => exact rf_arithFb h hn hpT a b
  | some x =>
    cases hy : toNumPure b with
    | none => exact rf_arithFb h hn hpT a b
    | some y => exact rf_arithN h hFR op x y (rf_toNumP_supp ha hx) (rf_toNumP_supp hb hy)

omit hn in
include hFR in
theorem rf_compare {a b : Val} (ha : Supp.val (Present s) S.tab.length a)
    (hb : Supp.val (Present s) S.tab.length b) (le : Bool) (hok : BigFixedV K a ∧ BigFixedV K b) :
    MSim (StepPost F FR M ν K S C) S C (compare F s a b le) (compare F t (M.val a) (M.val b) le) := by
  by_cases hstr : ∃ x y, a = .str x ∧ b = .str y
  · obtain ⟨x, y, rfl, rfl⟩ := hstr
    exact rf_ret h (.bool _) trivial
  by_cases hbig : ∃ x y, a = .big x ∧ b = .big y
  · obtain ⟨x, y, rfl, rfl⟩ := hbig
    show MSim _ S C (retS F s _) (retS F t (.bool (bif le then decide (M.big x ≤ M.big y)
      else decide (M.big x < M.big y))))
    rw [h.bigFixed x hok.1, h.bigFixed y hok.2]
    exact rf_ret h (.bool _) trivial
  by_cases hba : ∃ x, a = .big x
  · obtain ⟨x, rfl⟩ := hba
    cases b <;> first | exact MSim.fail _ _ | exact absurd ⟨_, _, rfl, rfl⟩ hbig
  by_cases hbb : ∃ y, b = .big y
  · obtain ⟨y, rfl⟩ := hbb
    cases a <;> first | exact MSim.fail _ _ | exact absurd ⟨_, _, rfl, rfl⟩ hbig
  have ha' : ∀ i, a ≠ .big i := fun i he => hba ⟨i, he⟩
  have hb' : ∀ i, b ≠ .big i := fun i he => hbb ⟨i, he⟩
  have key : ∀ x y, toNumPure a = x → toNumPure b = y →
      MSim (StepPost F FR M ν K S C) S C (rfCmpN s le x y) (rfCmpN t le (x.map M.nv) (y.map M.nv)) := by
    intro x y hx hy
    cases x with
    | none => exact MSim.fail _ _
    | some x =>
      cases y with
      | none => exact MSim.fail _ _
      | some y =>
        show MSim _ S C (Host.Ts.M.bind (numTest _ x y) _) (Host.Ts.M.bind (numTest _ (M.nv x) (M.nv y)) _)
        refine rf_bind (numTest_sim h.srv _ x y) fun M' S' C' r r' hr g => ?_
        cases le <;> (subst hr; exact rf_ret (h.grow hFR g) (.bool _) trivial)
  by_cases hsa : ∃ x, a = .str x
  · obtain ⟨x, rfl⟩ := hsa
    have hsb : ∀ y, b ≠ .str y := fun y he => hstr ⟨x, y, rfl, he⟩
    rw [rf_compare_eq' s _ b le ha' hb' hsb, rf_compare_eq' t _ _ le (rf_val_big ha') (rf_val_big hb')
      (rf_val_str hsb), rf_toNumP, rf_toNumP]
    exact key _ _ rfl rfl
  · have hsa' : ∀ x, a ≠ .str x := fun x he => hsa ⟨x, he⟩
    rw [rf_compare_eq s a b le ha' hb' hsa', rf_compare_eq t _ _ le (rf_val_big ha') (rf_val_big hb')
      (rf_val_str hsa'), rf_toNumP, rf_toNumP]
    exact key _ _ rfl rfl

include hFR in
theorem rf_addOp (hpT : Present s aTypeErrorProto) (hpR : Present s aRangeErrorProto) {a b : Val}
    (ha : Supp.val (Present s) S.tab.length a) (hb : Supp.val (Present s) S.tab.length b)
    (hok : BinBigOK K .add a b) :
    MSim (StepPost F FR M ν K S C) S C (addOp F s a b) (addOp F t (M.val a) (M.val b)) := by
  by_cases hstr : ∃ x y, a = .str x ∧ b = .str y
  · obtain ⟨x, y, rfl, rfl⟩ := hstr
    exact rf_ret h (.str _) trivial
  by_cases hsa : ∃ x, a = .str x
  · obtain ⟨x, rfl⟩ := hsa
    have hsb : ∀ y, b ≠ .str y := fun y he => hstr ⟨x, y, rfl, he⟩
    rw [show M.val (.str x) = .str x from rfl, rf_addOp_strL s x b hsb, rf_addOp_strL t x _ (rf_val_str hsb)]
    refine rf_bind (rf_primStr h.srv b (h.rfFixBig hok.2.1)) fun M' S' C' r r' hr g => ?_
    subst hr
    have h' := h.grow hFR g
    cases r' with
    | some y => exact rf_ret h' (.str _) trivial
    | none =>
      cases b <;> first | exact MSim.fail _ _ | exact typeErr_sim h' h'.intr hn hpT _
  by_cases hsb : ∃ y, b = .str y
  · obtain ⟨y, rfl⟩ := hsb
    have hsa' : ∀ x, a ≠ .str x := fun x he => hsa ⟨x, he⟩
    rw [show M.val (.str y) = .str y from rfl, rf_addOp_strR s a y hsa', rf_addOp_strR t _ y (rf_val_str hsa')]
    refine rf_bind (rf_primStr h.srv a (h.rfFixBig hok.1)) fun M' S' C' r r' hr g => ?_
    subst hr
    have h' := h.grow hFR g
    cases r' with
    | some x => exact rf_ret h' (.str _) trivial
    | none =>
      cases a <;> first | exact MSim.fail _ _ | exact typeErr_sim h' h'.intr hn hpT _
  have hsa' : ∀ x, a ≠ .str x := fun x he => hsa ⟨x, he⟩
  have hsb' : ∀ y, b ≠ .str y := fun y he => hsb ⟨y, he⟩
  rw [rf_addOp_arith s a b hsa' hsb', rf_addOp_arith t _ _ (rf_val_str hsa') (rf_val_str hsb')]
  exact rf_arith h hFR hn hpT hpR .add ha hb hok

include hFR in
theorem rf_unaryOp (hpT : Present s aTypeErrorProto) (op : UnOp) {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) (hok : UnBigOK K op v) :
    MSim (StepPost F FR M ν K S C) S C (unaryOp F s op v) (unaryOp F t op (M.val v)) := by
  cases op
  case neg =>
    rcases v with _ | _ | ⟨_ | _⟩ | x | i | cs | i | a | ⟨m, off⟩
    case big =>
      show MSim _ S C (retS F s _) (retS F t (.big (-(M.big i))))
      rw [h.bigFixed i hok.1]
      exact rf_retBig h _ (h.bigFixed _ hok.2)
    all_goals simp only [unaryOp, Map.val, toNum, rf_bind_pure]
    all_goals first
      | exact MSim.fail _ _
      | exact rf_numRet h hFR (rf_numUn h.srv .neg _)
  case pos =>
    rcases v with _ | _ | ⟨_ | _⟩ | x | i | cs | i | a | ⟨m, off⟩
    case big => exact typeErr_sim h h.intr hn hpT _
    all_goals simp only [unaryOp, Map.val, toNum, rf_bind_pure]
    all_goals first
      | exact MSim.fail _ _
      | exact rf_ret h (.num _) trivial
      | exact rf_ret h (.num _) hv
  case not =>
    show MSim _ S C (Host.Ts.M.bind (truthy v) _) (Host.Ts.M.bind (truthy (M.val v)) _)
    refine rf_bind (rf_truthy h.srv v (h.rfFixBig hok)) fun M' S' C' r r' hr g => ?_
    subst hr
    exact rf_ret (h.grow hFR g) (.bool _) trivial
  case bnot =>
    rcases v with _ | _ | ⟨_ | _⟩ | x | i | cs | i | a | ⟨m, off⟩
    case big =>
      show MSim _ S C (retS F s _) (retS F t (.big (-(M.big i + 1))))
      rw [h.bigFixed i hok.1]
      exact rf_retBig h _ (h.bigFixed _ hok.2)
    all_goals simp only [unaryOp, Map.val, toNum, rf_bind_pure]
    all_goals first
      | exact MSim.fail _ _
      | exact rf_numRet h hFR (rf_numBin h.srv .bxor _ (.lit _))
  case typeof =>
    show MSim _ S C (retS F s _) (retS F t (.str (typeofStr t (M.val v))))
    rw [rf_typeofStr h hv]
    exact rf_ret h (.str _) trivial
  case void => exact rf_ret h .undef trivial
  case delete => exact MSim.fail _ _

end
end

/-! ## Element access -/

/-- A number that is a literal (the image of a symbolic number may be a literal, so
code matching `.num (.lit x)` directly needs the source to be literal). -/
def NumLitV : Val → Prop
  | .num (.ref _) => False
  | _ => True

instance rfDecNumLitV (v : Val) : Decidable (NumLitV v) := by
  rcases v with _ | _ | _ | ⟨_ | _⟩ | _ | _ | _ | _ | _ <;> simp only [NumLitV] <;> infer_instance

theorem rf_numIndex {M : Map} {v : Val} (hv : NumLitV v) : numIndex (M.val v) = numIndex v := by
  rcases v with _ | _ | _ | ⟨_ | _⟩ | _ | _ | _ | _ | _
  case num.ref => exact hv.elim
  all_goals rfl

/-- The key `toKey` produces for a value without symbolic numbers. -/
def keyOfVal : Val → Option PKey
  | .sym i => some (.sym i)
  | .str cs => some (.str cs)
  | .num x => match x with
    | .lit y => (F64.toStr y).map PKey.str
    | .ref _ => none
  | .big i => some (.str (bigStr i))
  | .bool b => some (.str (bif b then chars!"true" else chars!"false"))
  | .undef => some (.str chars!"undefined")
  | .null => some (.str chars!"null")
  | _ => none

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-- `toKey` of a value without symbolic numbers asks no server. -/
theorem rf_toKeyLit (h : Rel F FR M ν K s S t C) {v : Val} (hv : Supp.val (Present s) S.tab.length v)
    (hl : NumLitV v) (hb : BigFixedV K v) :
    MSim (ReadPost M S C (fun r r' => r' = r.map M.key ∧ Supp.okey (Present s) S.tab.length r ∧
      r = keyOfVal v)) S C (toKey v) (toKey (M.val v)) := by
  rcases v with _ | _ | ⟨_ | _⟩ | ⟨x | i⟩ | i | cs | i | a | ⟨m, off⟩
  case num.ref => exact hl.elim
  case num.lit =>
    have e : toKey (.num (.lit x)) = Host.Ts.M.bind (match F64.toStr x with
        | some cs => Host.Ts.M.pure (some cs)
        | none => Host.Ts.M.fail "Number::toString of a non-integer")
        (fun o => Host.Ts.M.pure (o.map PKey.str)) := rfl
    show MSim _ S C (toKey (.num (.lit x))) (toKey (.num (.lit x)))
    rw [e]
    cases hs : F64.toStr x with
    | none => exact MSim.fail _ _
    | some cs =>
      refine ReadPost.pure ⟨rfl, trivial, ?_⟩
      simp only [keyOfVal, hs, Option.map_some]
  case big =>
    show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure (some (PKey.str (bigStr (M.big i)))))
    rw [h.bigFixed i hb]
    exact ReadPost.pure ⟨rfl, trivial, rfl⟩
  case sym => exact ReadPost.pure ⟨rfl, hv, rfl⟩
  all_goals exact ReadPost.pure ⟨rfl, trivial, rfl⟩

/-- Element reads of `elemAt`: arrays read are unframed; typed-array cells are `CellRead`. -/
def ElemAtOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (o : Val) (i : Nat) : Prop :=
  ∀ a, o = .obj a → ∀ ob, s.obj? a = some ob →
    (∀ es, ob.kind = .array es → K.fr a = none) ∧
    ∀ kk b off n, ob.kind = .typed kk b off n → i < n → ∀ bs, bufBytes F s b = some bs →
      CellRead K (Present s) S.tab.length kk (bs.drop (off + i * kk.size))

theorem rf_elemAt (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {o : Val}
    (ho : Supp.val (Present s) S.tab.length o) (i : Nat) (hok : ElemAtOK F K s S o i) :
    MSim (ReadPost M S C (ValR M (Present s) S.tab.length)) S C (elemAt F s o i) (elemAt F t (M.val o) i) := by
  cases o with
  | obj a =>
    show MSim _ S C (elemAt F s (.obj a) i) (elemAt F t (.obj (M.a a)) i)
    cases hob : s.obj? a with
    | none =>
      simp only [elemAt, hob, h.obj?_none ho hob]
      exact ReadPost.pure ⟨rfl, fun _ hv => nomatch hv⟩
    | some ob =>
      obtain ⟨harr, hty⟩ := hok a rfl ob hob
      have hso := h.obj?_supp hob
      have hfr : K.fr a = none := by
        cases hk : ob.kind with
        | array es => exact harr es hk
        | _ => exact h.fr_none hob fun es he => by rw [hk] at he; cases he
      have ht := h.obj? hob hfr
      obtain ⟨kd, pr, ps, pv, ex⟩ := ob
      simp only [elemAt, hob, ht, Map.obj, Map.kind]
      cases kd with
      | array es =>
        refine ReadPost.pure ⟨?_, fun v hv => hso.1 v (nth?_mem hv)⟩
        rw [Map.vals, nth?_map]
      | typed kk b off n =>
        refine MSim.bind (typedGet_sim h hF fun hlt bs hb => hty kk b off n rfl hlt bs hb) ?_
        rintro M' S' C' r r' ⟨rfl, rfl, rfl, rfl, hsupp⟩
        rcases r with _ | ⟨x, w, e⟩ | ⟨g, st, e⟩
        · exact ReadPost.pure ⟨rfl, fun _ hv => nomatch hv⟩
        · exact ReadPost.pure ⟨rfl, fun v hv => by cases hv; exact hsupp⟩
        · exact ReadPost.pure ⟨rfl, fun _ hv => nomatch hv⟩
      | _ => exact ReadPost.pure ⟨rfl, fun _ hv => nomatch hv⟩
  | str cs =>
    refine ReadPost.pure ⟨?_, fun v hv => ?_⟩
    · show (nth? cs i).map (fun c => Val.str [c]) = ((nth? cs i).map fun c => Val.str [c]).map M.val
      cases nth? cs i <;> rfl
    · cases hn : nth? cs i <;> rw [hn] at hv <;> cases hv; trivial
  | _ => exact ReadPost.pure ⟨rfl, fun _ hv => nomatch hv⟩

theorem rf_isIndexable (h : Rel F FR M ν K s S t C) {o : Val} (ho : Supp.val (Present s) S.tab.length o) :
    isIndexable F t (M.val o) = isIndexable F s o := by
  cases o with
  | obj a =>
    show isIndexable F t (.obj (M.a a)) = isIndexable F s (.obj a)
    cases hob : s.obj? a with
    | none => simp only [isIndexable, hob, h.obj?_none ho hob]
    | some ob =>
      cases hfr : K.fr a with
      | none =>
        obtain ⟨kd, pr, ps, pv, ex⟩ := ob
        simp only [isIndexable, hob, h.obj? hob hfr, Map.obj]
        cases kd <;> rfl
      | some p =>
        obtain ⟨pre, pre'⟩ := p
        obtain ⟨o', ht, xs, hk, rfl⟩ := h.obj?_framed hob hfr
        obtain ⟨kd, pr, ps, pv, ex⟩ := ob
        simp only at hk
        subst hk
        simp only [isIndexable, hob, ht]
  | _ => rfl

/-- Side condition of `getIndex o k`. -/
def GetIndexOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (o k : Val) : Prop :=
  NumLitV k ∧ BigFixedV K k ∧
    match numIndex k with
    | some i => ElemAtOK F K s S o i ∧ LookupOK F K s S o (.str (F64.natStr i))
    | none => ∀ key, keyOfVal k = some key → LookupOK F K s S o key

theorem rf_getIndex (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) (hP : Present s aTypeErrorProto) {o k : Val}
    (ho : Supp.val (Present s) S.tab.length o) (hk : Supp.val (Present s) S.tab.length k)
    (hok : GetIndexOK F K s S o k) :
    MSim (StepPost F FR M ν K S C) S C (getIndex F s o k) (getIndex F t (M.val o) (M.val k)) := by
  obtain ⟨hl, hb, hrest⟩ := hok
  unfold getIndex
  rw [rf_numIndex hl]
  cases hi : numIndex k with
  | some i =>
    rw [hi] at hrest
    obtain ⟨hel, hlk⟩ := hrest
    simp only
    rw [rf_isIndexable h ho]
    refine MSim.cond _ ?_ (getV_sim h hF h.intr hn hP ho trivial hlk)
    refine MSim.bind (rf_elemAt h hF ho i hel) ?_
    rintro M' S' C' r r' ⟨rfl, rfl, rfl, rfl, hsupp⟩
    cases r with
    | some v => exact rf_ret h v (hsupp v rfl)
    | none => exact getV_sim h hF h.intr hn hP ho trivial hlk
  | none =>
    rw [hi] at hrest
    simp only
    refine MSim.bind (rf_toKeyLit h hk hl hb) ?_
    rintro M' S' C' r r' ⟨rfl, rfl, rfl, rfl, hsupp, hkey⟩
    cases r with
    | some key => exact getV_sim h hF h.intr hn hP ho hsupp (hrest key hkey.symm)
    | none => exact MSim.fail _ _

end

/-! ## Binary operators -/

/-- Side condition of `binOp op a b`: bigint operands of arithmetic, comparisons and
string conversion are fixed by the map (and so are bigint results), `instanceof` and
`in` look up under `LookupOK`, and an `in` key is not a symbolic number. Equality
needs `BinMapOK` instead. -/
def BinOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (op : BinOp) (a b : Val) : Prop :=
  match op with
  | .seq | .sne | .eq | .ne => True
  | .inst => LookupOK F K s S b kPrototype
  | .in_ => NumLitV a ∧ BigFixedV K a ∧ ∀ key, keyOfVal a = some key → LookupOK F K s S b key
  | _ => BinBigOK K op a b

/-- What equality needs of the map (a fact about native handles and regions, which only
the native relation knows): it separates the operands' bigints and native regions. -/
def EqMapOK (M : Map) (a b : Val) : Prop :=
  (∀ i j, a = .big i → b = .big j → M.big i = M.big j → i = j) ∧
  (∀ r o r' o', a = .ptr (.ext r) o → b = .ptr (.ext r') o' → M.region r = M.region r' → r = r')

/-- The map hypothesis of `binOp op a b`: only equality needs one. -/
def BinMapOK (M : Map) (op : BinOp) (a b : Val) : Prop :=
  match op with
  | .seq | .sne | .eq | .ne => EqMapOK M a b
  | _ => True

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-- Fixed or equal bigints, and equal regions, need nothing of the map. -/
theorem EqMapOK.of_strict (h : Rel F FR M ν K s S t C) {a b : Val} (hok : StrictOK K a b) :
    EqMapOK M a b := by
  refine ⟨fun i j hi hj he => ?_, fun r o r' o' hr hr' _ => hok.2 r o r' o' hr hr'⟩
  rcases hok.1 i j hi hj with ⟨hfi, hfj⟩ | rfl
  · rwa [h.bigFixed i hfi, h.bigFixed j hfj] at he
  · rfl

theorem rf_strictEq (h : Rel F FR M ν K s S t C) {a b : Val} (ha : Supp.val (Present s) S.tab.length a)
    (hb : Supp.val (Present s) S.tab.length b) (hEq : EqMapOK M a b) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C
      (strictEq F s a b) (strictEq F t (M.val a) (M.val b)) :=
  strictEq_sim_of h ha hb (fun i j hi hj => decide_eq_decide.2 ⟨hEq.1 i j hi hj, fun e => e ▸ rfl⟩)
    (fun r o r' o' hr hr' => by
      rw [Bool.eq_iff_iff, beq_iff, beq_iff]
      exact ⟨hEq.2 r o r' o' hr hr', fun e => e ▸ rfl⟩)

theorem rf_someTail {S : SSrv} {C : CSrv} {m m' : Host.Ts.M Bool}
    (hm : MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C m m') :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C
      (Host.Ts.M.bind m fun r => Host.Ts.M.pure (some r)) (Host.Ts.M.bind m' fun r => Host.Ts.M.pure (some r)) :=
  MSim.bind hm fun _ _ _ _ _ hr => by
    obtain ⟨rfl, g⟩ := hr
    exact MSim.pure ⟨rfl, g⟩

theorem rf_looseEq (h : Rel F FR M ν K s S t C) {a b : Val} (ha : Supp.val (Present s) S.tab.length a)
    (hb : Supp.val (Present s) S.tab.length b) (hEq : EqMapOK M a b) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (looseEq F s a b)
      (looseEq F t (M.val a) (M.val b)) := by
  have st := rf_someTail (rf_strictEq h ha hb hEq)
  rcases a with _ | _ | ⟨_ | _⟩ | x | i | cs | i | a | ⟨m, off⟩ <;>
  rcases b with _ | _ | ⟨_ | _⟩ | y | j | ds | j | b | ⟨m', off'⟩
  all_goals first
    | exact MSim.pure ⟨rfl, Grow.refl h.srv⟩
    | exact st
    | (have key := rf_someTail (numTest_sim h.srv .eq (M := M) (S := S) (C := C) (a := x) (b := .lit (F64.ofString ds)))
       exact key)
    | (have key := rf_someTail (numTest_sim h.srv .eq (M := M) (S := S) (C := C) (a := .lit (F64.ofString cs)) (b := y))
       exact key)
    | (have key := rf_someTail (numTest_sim h.srv .eq (M := M) (S := S) (C := C) (a := one) (b := y))
       exact key)
    | (have key := rf_someTail (numTest_sim h.srv .eq (M := M) (S := S) (C := C) (a := zeroN) (b := y))
       exact key)
    | (have key := rf_someTail (numTest_sim h.srv .eq (M := M) (S := S) (C := C) (a := x) (b := one))
       exact key)
    | (have key := rf_someTail (numTest_sim h.srv .eq (M := M) (S := S) (C := C) (a := x) (b := zeroN))
       exact key)

theorem rf_protoChainHas (h : Rel F FR M ν K s S t C) {p : Nat} (hp : Present s p) :
    ∀ (f : Nat) (v : Val), Supp.val (Present s) S.tab.length v →
      protoChainHas F t (M.a p) f (M.val v) = protoChainHas F s p f v
  | 0, _, _ => rfl
  | f + 1, .obj a, ha => by
    show protoChainHas F t (M.a p) (f + 1) (.obj (M.a a)) = protoChainHas F s p (f + 1) (.obj a)
    cases ho : s.obj? a with
    | none => simp only [protoChainHas, ho, h.obj?_none ha ho]
    | some o =>
      have hso := h.obj?_supp ho
      obtain ⟨o', ho', hpr, -⟩ := h.obj?_some ho
      simp only [protoChainHas, ho, ho', hpr]
      have hsp : Supp.val (Present s) S.tab.length o.proto := hso.2.1
      cases hq : o.proto with
      | obj q =>
        rw [hq] at hsp
        show (Nat.beq (M.a q) (M.a p) || protoChainHas F t (M.a p) f (M.val (.obj q))) = _
        rw [beq_map h.inj hsp hp, rf_protoChainHas h hp f (.obj q) hsp]
      | _ => rfl
  | _ + 1, .undef, _ => rfl
  | _ + 1, .null, _ => rfl
  | _ + 1, .bool _, _ => rfl
  | _ + 1, .num _, _ => rfl
  | _ + 1, .big _, _ => rfl
  | _ + 1, .str _, _ => rfl
  | _ + 1, .sym _, _ => rfl
  | _ + 1, .ptr _ _, _ => rfl

theorem rf_binOp (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hn : s.next < Sim.bound) (hpT : Present s aTypeErrorProto)
    (hpR : Present s aRangeErrorProto) (op : BinOp) {a b : Val}
    (ha : Supp.val (Present s) S.tab.length a) (hb : Supp.val (Present s) S.tab.length b)
    (hok : BinOK F K s S op a b) (hM : BinMapOK M op a b) :
    MSim (StepPost F FR M ν K S C) S C (binOp F s op a b) (binOp F t op (M.val a) (M.val b)) := by
  cases op
  case add => exact rf_addOp h hFR hn hpT hpR ha hb hok
  case lt => exact rf_compare h hFR ha hb false ⟨hok.1, hok.2.1⟩
  case gt => exact rf_compare h hFR hb ha false ⟨hok.2.1, hok.1⟩
  case le => exact rf_compare h hFR ha hb true ⟨hok.1, hok.2.1⟩
  case ge => exact rf_compare h hFR hb ha true ⟨hok.2.1, hok.1⟩
  case seq | sne =>
    show MSim _ S C (Host.Ts.M.bind (strictEq F s a b) _) (Host.Ts.M.bind (strictEq F t (M.val a) (M.val b)) _)
    refine rf_bind (rf_strictEq h ha hb hM) fun M' S' C' r r' hr g => ?_
    subst hr
    exact rf_ret (h.grow hFR g) (.bool _) trivial
  case eq | ne =>
    show MSim _ S C (Host.Ts.M.bind (looseEq F s a b) _) (Host.Ts.M.bind (looseEq F t (M.val a) (M.val b)) _)
    refine rf_bind (rf_looseEq h ha hb hM) fun M' S' C' r r' hr g => ?_
    subst hr
    cases r' with
    | some r => exact rf_ret (h.grow hFR g) (.bool _) trivial
    | none => exact MSim.fail _ _
  case inst =>
    cases b
    case obj c =>
      show MSim _ S C (Host.Ts.M.bind (dataOf F s (.obj c) kPrototype) _)
        (Host.Ts.M.bind (dataOf F t (M.val (.obj c)) (M.key kPrototype)) _)
      refine MSim.bind (dataOf_sim h hF h.intr hb trivial hok) ?_
      rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp⟩
      rw [hS, hC]
      rcases r with _ | ⟨_ | _ | _ | _ | _ | _ | _ | q | _⟩
      case some.obj =>
        have hq : Present s q := hsupp _ rfl
        show MSim _ S C (retS F s (.bool (protoChainHas F s q 64 a)))
          (retS F t (.bool (protoChainHas F t (M.a q) 64 (M.val a))))
        rw [rf_protoChainHas h hq 64 a ha]
        exact rf_ret h (.bool _) trivial
      all_goals exact typeErr_sim h h.intr hn hpT _
    all_goals exact typeErr_sim h h.intr hn hpT _
  case in_ =>
    obtain ⟨hl, hbf, hlk⟩ := hok
    cases b
    case obj c =>
      show MSim _ S C (Host.Ts.M.bind (toKey a) _) (Host.Ts.M.bind (toKey (M.val a)) _)
      refine MSim.bind (rf_toKeyLit h ha hl hbf) ?_
      rintro M' S' C' r r' ⟨-, hS, hC, rfl, hsupp, hkey⟩
      rw [hS, hC]
      cases r with
      | none => exact MSim.fail _ _
      | some k =>
        show MSim _ S C (Host.Ts.M.bind (lookup F s (.obj c) k) _)
          (Host.Ts.M.bind (lookup F t (M.val (.obj c)) (M.key k)) _)
        refine MSim.bind (lookup_sim h hF h.intr hb hsupp (hlk k hkey.symm)) ?_
        rintro M'' S'' C'' r r' ⟨-, hS', hC', rfl, -⟩
        rw [hS', hC']
        rw [show (r.map M.prop).isSome = r.isSome by cases r <;> rfl]
        exact rf_ret h (.bool _) trivial
    all_goals exact typeErr_sim h h.intr hn hpT _
  all_goals exact rf_arith h hFR hn hpT hpR _ ha hb hok

end

/-! ## Steps -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
  {v : Val} {fs : List Frame}

theorem step_retE_binL (h : Rel F FR M ν K s S t C) {op : BinOp} {b : Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .e (.binL op b env) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  exact rf_rel ((hr.push (.e (.binR op v)) hv).go (.ev b env) hf)

theorem step_retE_const (h : Rel F FR M ν K s S t C) {c : Val}
    (hc : s.ctl = .ret v) (hs : s.stack = .e (.const c) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  exact rf_ret hr c hf

theorem step_retE_chain (h : Rel F FR M ν K s S t C)
    (hc : s.ctl = .ret v) (hs : s.stack = .e .chain :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, _⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  exact rf_ret hr v hv

theorem step_retE_seq (h : Rel F FR M ν K s S t C) {b : Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .e (.seq b env) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  exact rf_rel (hr.go (.ev b env) hf)

theorem step_retE_typeof (h : Rel F FR M ν K s S t C)
    (hc : s.ctl = .ret v) (hs : s.stack = .e .typeof :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, _⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  show MSim _ S C (retS F _ (.str (typeofStr _ v))) (retS F _ (.str (typeofStr _ (M.val v))))
  rw [rf_typeofStr hr hv]
  exact rf_ret hr (.str _) trivial

theorem step_retE_logL (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) {op : LogOp} {b : Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .e (.logL op b env) :: fs) (hb : BigFixedV K v) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have he : Supp.env (Present s) S.tab.length env := hf
  cases op with
  | and =>
    show MSim _ S C (Host.Ts.M.bind (truthy v) _) (Host.Ts.M.bind (truthy (M.val v)) _)
    refine rf_bind (rf_truthy h.srv v (h.rfFixBig hb)) fun M' S' C' r r' hrr g => ?_
    subst hrr
    have h' := hr.grow hFR g
    rw [g.rfEnv he, g.rfVal hv]
    cases r'
    · exact rf_ret h' v (rf_vmono g.len hv)
    · exact rf_rel (h'.go (.ev b env) (Supp.env_mono (fun _ h => h) g.len he))
  | or =>
    show MSim _ S C (Host.Ts.M.bind (truthy v) _) (Host.Ts.M.bind (truthy (M.val v)) _)
    refine rf_bind (rf_truthy h.srv v (h.rfFixBig hb)) fun M' S' C' r r' hrr g => ?_
    subst hrr
    have h' := hr.grow hFR g
    rw [g.rfEnv he, g.rfVal hv]
    cases r'
    · exact rf_rel (h'.go (.ev b env) (Supp.env_mono (fun _ h => h) g.len he))
    · exact rf_ret h' v (rf_vmono g.len hv)
  | nullish =>
    show MSim _ S C (bif isNullish v then _ else _) (bif isNullish (M.val v) then _ else _)
    rw [rf_isNullish]
    exact MSim.cond _ (rf_rel (hr.go (.ev b env) he)) (rf_ret hr v hv)

theorem step_retE_cond (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) {a b : Expr} {env : Env}
    (hc : s.ctl = .ret v) (hs : s.stack = .e (.cond a b env) :: fs) (hb : BigFixedV K v) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have he : Supp.env (Present s) S.tab.length env := hf
  show MSim _ S C (Host.Ts.M.bind (truthy v) _) (Host.Ts.M.bind (truthy (M.val v)) _)
  refine rf_bind (rf_truthy h.srv v (h.rfFixBig hb)) fun M' S' C' r r' hrr g => ?_
  subst hrr
  have h' := hr.grow hFR g
  rw [g.rfEnv he]
  cases r' <;> exact rf_rel (h'.go (.ev _ env) (Supp.env_mono (fun _ h => h) g.len he))

theorem step_retE_unary (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
    (hn : s.next < Sim.bound) {op : UnOp} (hc : s.ctl = .ret v) (hs : s.stack = .e (.unary op) :: fs)
    (hpT : Present s aTypeErrorProto) (hok : UnBigOK K op v) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, _⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  exact rf_unaryOp hr hFR hn hpT op hv hok

theorem step_retE_indexL (h : Rel F FR M ν K s S t C) {k : Expr} {env : Env} {opt : Bool}
    (hc : s.ctl = .ret v) (hs : s.stack = .e (.indexL k env opt) :: fs) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have he : Supp.env (Present s) S.tab.length env := hf
  show MSim _ S C (bif opt && isNullish v then _ else _) (bif opt && isNullish (M.val v) then _ else _)
  rw [rf_isNullish]
  exact MSim.cond _ (rf_rel (hr.go .short trivial)) (rf_rel ((hr.push (.e (.indexR v)) hv).go (.ev k env) he))

theorem step_retE_indexR (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {o : Val} (hc : s.ctl = .ret v) (hs : s.stack = .e (.indexR o) :: fs)
    (hpT : Present s aTypeErrorProto) (hok : GetIndexOK F K s S o v) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have ho : Supp.val (Present s) S.tab.length o := hf
  cases o <;> first
    | exact typeErr_sim hr hr.intr hn hpT _
    | exact rf_getIndex hr hF hn hpT ho hv hok

theorem step_retE_member (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    (hn : s.next < Sim.bound) {k : PKey} {opt : Bool} (hc : s.ctl = .ret v)
    (hs : s.stack = .e (.member k opt) :: fs) (hpT : Present s aTypeErrorProto) (hok : LookupOK F K s S v k) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have hk : Supp.key (Present s) S.tab.length k := hf
  show MSim _ S C (bif opt && isNullish v then _ else _) (bif opt && isNullish (M.val v) then _ else _)
  rw [rf_isNullish]
  exact MSim.cond _ (rf_rel (hr.go .short trivial)) (getV_sim hr hF hr.intr hn hpT hv hk hok)

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
  {v : Val} {fs : List Frame}

theorem step_retE_binR (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hn : s.next < Sim.bound) {op : BinOp} {a : Val} (hc : s.ctl = .ret v)
    (hs : s.stack = .e (.binR op a) :: fs) (hpT : Present s aTypeErrorProto)
    (hpR : Present s aRangeErrorProto) (hok : BinOK F K s S op a v) (hM : BinMapOK M op a v) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  exact rf_binOp hr hF hFR hn hpT hpR op hf hv hok hM

theorem step_retE_priv (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound)
    {b : Nat} {nm : Name} {opt : Bool} (hc : s.ctl = .ret v) (hs : s.stack = .e (.priv b nm opt) :: fs)
    (hpT : Present s aTypeErrorProto) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  have hb : Present s b := hf
  show MSim _ S C (bif opt && isNullish v then _ else _) (bif opt && isNullish (M.val v) then _ else _)
  rw [rf_isNullish]
  exact MSim.cond _ (rf_rel (hr.go .short trivial)) (privGetV_sim hr hr.intr hn hpT hv hb)

end
end Host.Ts.Sim
