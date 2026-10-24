import host.sim.conv.Fresh
import host.sim.conv.NoRegCheck
import host.sim.RestartDrop
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim

/-! # Compaction after a site call

A site instance returns to the caller's state with the stage's actual allocations (`site_run`):
fresh objects, handles and nodes the stage class decides. **Compaction** relates the same target to
a canonical caller state `s0` the class does not decide: the caller's entries, the stage's
results at canonical places (fresh objects at the canonical addresses after the call's counter,
fresh handles and nodes likewise), the stage's garbage dropped. It is a pullback along the
compaction map `κ` from `s0` into the merged state `s1` that keeps every frame (`compact`:
`restartDrop` with all frames kept, `dropNext_keep`).

`κ` (`Map.compact`) fixes the caller's names, so its heap check covers only the stage's footprint
and results (`compact_heap`) once the caller's entries are known free of the stage's fresh bigints and
regions. That is **cut bookkeeping** (`Clean`): every piece checks, with `cleanListB`, the entries it
creates or changes against the native counter at its end (`Clean.step`), and the invariant stays
true as the counters grow (`Clean.mono`, from `NoBig`/`NoReg` monotonicity); at a template start
it gives the restart's `NoBigSt` (`Clean.noBigSt`). `band_of_call` gives the band's support within
the call's addresses from the caller's relation at the call. The stage's result numbers become
fresh table variables bound to the stage's entries (`compactθ`, `compact_num`,
`valuation_compactθ`). The full world's instance is `full_compact` (`host.sim.conv.CompactFull`). -/

/-! ## Monotonicity of bigint and region freedom -/

section
variable {I I' : Int → Prop} (hI : ∀ i, I' i → I i)
include hI

theorem NoBig.val_mono {v : Val} (h : NoBig.val I v) : NoBig.val I' v := by
  cases v <;> simp_all [NoBig.val]
  exact fun hi => h (hI _ hi)

theorem NoBig.prop_mono {p : PropV} (h : NoBig.prop I p) : NoBig.prop I' p := by
  cases p <;> simp_all [NoBig.prop, NoBig.val_mono hI]

theorem NoBig.props_mono {ps : Props} (h : NoBig.props I ps) : NoBig.props I' ps :=
  fun x hx => NoBig.prop_mono hI (h x hx)

theorem NoBig.vals_mono {vs : List Val} (h : NoBig.vals I vs) : NoBig.vals I' vs :=
  fun v hv => NoBig.val_mono hI (h v hv)

theorem NoBig.cell_mono {c : Cell} (h : NoBig.cell I c) : NoBig.cell I' c := by
  cases c <;> simp_all [NoBig.cell]
  exact fun hi => h (hI _ hi)

theorem NoBig.byte_mono {b : Byte} (h : NoBig.byte I b) : NoBig.byte I' b := by
  cases b <;> simp_all [NoBig.byte, NoBig.cell_mono hI]

theorem NoBig.bytes_mono {bs : List Byte} (h : NoBig.bytes I bs) : NoBig.bytes I' bs :=
  fun b hb => NoBig.byte_mono hI (h b hb)

theorem NoBig.abr_mono {a : Abrupt} (h : NoBig.abr I a) : NoBig.abr I' a := by
  cases a <;> simp_all [NoBig.abr, NoBig.val_mono hI]

theorem NoBig.comp_mono {c : Comp} (h : NoBig.comp I c) : NoBig.comp I' c := by
  cases c <;> simp_all [NoBig.comp, NoBig.val_mono hI, NoBig.abr_mono hI]

theorem NoBig.inst_mono {i : InstMember} (h : NoBig.inst I i) : NoBig.inst I' i := by
  cases i <;> simp_all [NoBig.inst, NoBig.prop_mono hI]

theorem NoBig.insts_mono {is : List InstMember} (h : NoBig.insts I is) : NoBig.insts I' is :=
  fun i hi => NoBig.inst_mono hI (h i hi)

theorem NoBig.bnd_mono {b : Boundary} (h : NoBig.bnd I b) : NoBig.bnd I' b := by
  cases b <;> simp_all [NoBig.bnd, NoBig.val_mono hI]

theorem NoBig.src_mono {s : IterSrc} (h : NoBig.src I s) : NoBig.src I' s := by
  cases s <;> simp_all [NoBig.src, NoBig.val_mono hI]

theorem NoBig.pairs_mono {ps : List (Val × Val)} (h : NoBig.pairs I ps) : NoBig.pairs I' ps :=
  fun x hx => ⟨NoBig.val_mono hI (h x hx).1, NoBig.val_mono hI (h x hx).2⟩

theorem NoBig.target_mono {t : Target} (h : NoBig.target I t) : NoBig.target I' t := by
  cases t <;> simp_all [NoBig.target, NoBig.val_mono hI]

theorem NoBig.callF_mono {f : CallF} (h : NoBig.callF I f) : NoBig.callF I' f := by
  cases f <;> simp_all [NoBig.callF, NoBig.val_mono hI, NoBig.vals_mono hI]

theorem NoBig.exprF_mono {f : ExprF} (h : NoBig.exprF I f) : NoBig.exprF I' f := by
  cases f <;> simp_all [NoBig.exprF, NoBig.val_mono hI]

theorem NoBig.litF_mono {f : LitF} (h : NoBig.litF I f) : NoBig.litF I' f := by
  cases f <;> simp_all [NoBig.litF, NoBig.val_mono hI, NoBig.vals_mono hI]

theorem NoBig.asgF_mono {f : AsgF} (h : NoBig.asgF I f) : NoBig.asgF I' f := by
  cases f <;> simp_all [NoBig.asgF, NoBig.val_mono hI, NoBig.target_mono hI]

theorem NoBig.stmtF_mono {f : StmtF} (h : NoBig.stmtF I f) : NoBig.stmtF I' f := by
  cases f <;> simp_all [NoBig.stmtF, NoBig.val_mono hI, NoBig.pairs_mono hI, NoBig.comp_mono hI]

theorem NoBig.loopF_mono {f : LoopF} (h : NoBig.loopF I f) : NoBig.loopF I' f := by
  cases f <;> simp_all [NoBig.loopF, NoBig.val_mono hI, NoBig.src_mono hI, NoBig.comp_mono hI]

theorem NoBig.bindF_mono {f : BindF} (h : NoBig.bindF I f) : NoBig.bindF I' f := by
  cases f <;> simp_all [NoBig.bindF, NoBig.val_mono hI, NoBig.vals_mono hI]

theorem NoBig.fnF_mono {f : FnF} (h : NoBig.fnF I f) : NoBig.fnF I' f := by
  cases f <;> simp_all [NoBig.fnF, NoBig.val_mono hI, NoBig.vals_mono hI, NoBig.insts_mono hI,
    NoBig.bnd_mono hI]

theorem NoBig.frame_mono {f : Frame} (h : NoBig.frame I f) : NoBig.frame I' f := by
  cases f <;> simp_all [NoBig.frame, NoBig.exprF_mono hI, NoBig.callF_mono hI, NoBig.litF_mono hI,
    NoBig.asgF_mono hI, NoBig.stmtF_mono hI, NoBig.loopF_mono hI, NoBig.bindF_mono hI, NoBig.fnF_mono hI]

theorem NoBig.stores_mono {ss : List (Nat × Val)} (h : NoBig.stores I ss) : NoBig.stores I' ss :=
  fun x hx => NoBig.val_mono hI (h x hx)

theorem NoBig.susp_mono {u : Susp} (h : NoBig.susp I u) : NoBig.susp I' u :=
  ⟨fun f hf => NoBig.frame_mono hI (h.1 f hf), NoBig.stores_mono hI h.2⟩

theorem NoBig.gen_mono {g : GenState} (h : NoBig.gen I g) : NoBig.gen I' g := by
  cases g <;> simp_all [NoBig.gen, NoBig.susp_mono hI]

theorem NoBig.reaction_mono {r : Reaction} (h : NoBig.reaction I r) : NoBig.reaction I' r := by
  cases r <;> simp_all [NoBig.reaction, NoBig.susp_mono hI, NoBig.val_mono hI, NoBig.stores_mono hI]

theorem NoBig.pstate_mono {p : PState} (h : NoBig.pstate I p) : NoBig.pstate I' p := by
  cases p
  case pending rs => exact fun r hr => NoBig.reaction_mono hI (h r hr)
  all_goals simp_all [NoBig.pstate, NoBig.val_mono hI]

theorem NoBig.code_mono {c : Code} (h : NoBig.code I c) : NoBig.code I' c := by
  cases c <;> simp_all [NoBig.code, NoBig.val_mono hI, NoBig.vals_mono hI, NoBig.insts_mono hI]

theorem NoBig.kind_mono {k : Kind} (h : NoBig.kind I k) : NoBig.kind I' k := by
  cases k
  case gen g a q => exact ⟨NoBig.gen_mono hI h.1, fun x hx => NoBig.comp_mono hI (h.2 x hx)⟩
  all_goals simp_all [NoBig.kind, NoBig.vals_mono hI, NoBig.code_mono hI, NoBig.bytes_mono hI,
    NoBig.pairs_mono hI, NoBig.pstate_mono hI, NoBig.val_mono hI]

theorem NoBig.obj_mono {o : Obj} (h : NoBig.obj I o) : NoBig.obj I' o :=
  ⟨NoBig.kind_mono hI h.1, NoBig.val_mono hI h.2.1, NoBig.props_mono hI h.2.2.1,
    fun x hx => NoBig.prop_mono hI (h.2.2.2 x hx)⟩

theorem NoBig.hobj_mono {o : HObj} (h : NoBig.hobj I o) : NoBig.hobj I' o := by
  match o, h with
  | .cell none, _ => trivial
  | .cell (some v), h => exact NoBig.val_mono hI h
  | .obj o, h => exact NoBig.obj_mono hI h

end

section
variable {R R' : Nat → Prop} (hR : ∀ r, R' r → R r)
include hR

theorem NoReg.mem_mono {m : Mem} (h : NoReg.mem R m) : NoReg.mem R' m := by
  cases m <;> simp_all [NoReg.mem]
  exact fun hr => h (hR _ hr)

theorem NoReg.val_mono {v : Val} (h : NoReg.val R v) : NoReg.val R' v := by
  cases v <;> simp_all [NoReg.val, NoReg.mem_mono hR]

theorem NoReg.prop_mono {p : PropV} (h : NoReg.prop R p) : NoReg.prop R' p := by
  cases p <;> simp_all [NoReg.prop, NoReg.val_mono hR]

theorem NoReg.props_mono {ps : Props} (h : NoReg.props R ps) : NoReg.props R' ps :=
  fun x hx => NoReg.prop_mono hR (h x hx)

theorem NoReg.vals_mono {vs : List Val} (h : NoReg.vals R vs) : NoReg.vals R' vs :=
  fun v hv => NoReg.val_mono hR (h v hv)

theorem NoReg.abr_mono {a : Abrupt} (h : NoReg.abr R a) : NoReg.abr R' a := by
  cases a <;> simp_all [NoReg.abr, NoReg.val_mono hR]

theorem NoReg.comp_mono {c : Comp} (h : NoReg.comp R c) : NoReg.comp R' c := by
  cases c <;> simp_all [NoReg.comp, NoReg.val_mono hR, NoReg.abr_mono hR]

theorem NoReg.inst_mono {i : InstMember} (h : NoReg.inst R i) : NoReg.inst R' i := by
  cases i <;> simp_all [NoReg.inst, NoReg.prop_mono hR]

theorem NoReg.insts_mono {is : List InstMember} (h : NoReg.insts R is) : NoReg.insts R' is :=
  fun i hi => NoReg.inst_mono hR (h i hi)

theorem NoReg.bnd_mono {b : Boundary} (h : NoReg.bnd R b) : NoReg.bnd R' b := by
  cases b <;> simp_all [NoReg.bnd, NoReg.val_mono hR]

theorem NoReg.src_mono {s : IterSrc} (h : NoReg.src R s) : NoReg.src R' s := by
  cases s <;> simp_all [NoReg.src, NoReg.val_mono hR]

theorem NoReg.pairs_mono {ps : List (Val × Val)} (h : NoReg.pairs R ps) : NoReg.pairs R' ps :=
  fun x hx => ⟨NoReg.val_mono hR (h x hx).1, NoReg.val_mono hR (h x hx).2⟩

theorem NoReg.target_mono {t : Target} (h : NoReg.target R t) : NoReg.target R' t := by
  cases t <;> simp_all [NoReg.target, NoReg.val_mono hR]

theorem NoReg.callF_mono {f : CallF} (h : NoReg.callF R f) : NoReg.callF R' f := by
  cases f <;> simp_all [NoReg.callF, NoReg.val_mono hR, NoReg.vals_mono hR]

theorem NoReg.exprF_mono {f : ExprF} (h : NoReg.exprF R f) : NoReg.exprF R' f := by
  cases f <;> simp_all [NoReg.exprF, NoReg.val_mono hR]

theorem NoReg.litF_mono {f : LitF} (h : NoReg.litF R f) : NoReg.litF R' f := by
  cases f <;> simp_all [NoReg.litF, NoReg.val_mono hR, NoReg.vals_mono hR]

theorem NoReg.asgF_mono {f : AsgF} (h : NoReg.asgF R f) : NoReg.asgF R' f := by
  cases f <;> simp_all [NoReg.asgF, NoReg.val_mono hR, NoReg.target_mono hR]

theorem NoReg.stmtF_mono {f : StmtF} (h : NoReg.stmtF R f) : NoReg.stmtF R' f := by
  cases f <;> simp_all [NoReg.stmtF, NoReg.val_mono hR, NoReg.pairs_mono hR, NoReg.comp_mono hR]

theorem NoReg.loopF_mono {f : LoopF} (h : NoReg.loopF R f) : NoReg.loopF R' f := by
  cases f <;> simp_all [NoReg.loopF, NoReg.val_mono hR, NoReg.src_mono hR, NoReg.comp_mono hR]

theorem NoReg.bindF_mono {f : BindF} (h : NoReg.bindF R f) : NoReg.bindF R' f := by
  cases f <;> simp_all [NoReg.bindF, NoReg.val_mono hR, NoReg.vals_mono hR]

theorem NoReg.fnF_mono {f : FnF} (h : NoReg.fnF R f) : NoReg.fnF R' f := by
  cases f <;> simp_all [NoReg.fnF, NoReg.val_mono hR, NoReg.vals_mono hR, NoReg.insts_mono hR,
    NoReg.bnd_mono hR]

theorem NoReg.frame_mono {f : Frame} (h : NoReg.frame R f) : NoReg.frame R' f := by
  cases f <;> simp_all [NoReg.frame, NoReg.exprF_mono hR, NoReg.callF_mono hR, NoReg.litF_mono hR,
    NoReg.asgF_mono hR, NoReg.stmtF_mono hR, NoReg.loopF_mono hR, NoReg.bindF_mono hR, NoReg.fnF_mono hR]

theorem NoReg.stores_mono {ss : List (Nat × Val)} (h : NoReg.stores R ss) : NoReg.stores R' ss :=
  fun x hx => NoReg.val_mono hR (h x hx)

theorem NoReg.susp_mono {u : Susp} (h : NoReg.susp R u) : NoReg.susp R' u :=
  ⟨fun f hf => NoReg.frame_mono hR (h.1 f hf), NoReg.stores_mono hR h.2⟩

theorem NoReg.gen_mono {g : GenState} (h : NoReg.gen R g) : NoReg.gen R' g := by
  cases g <;> simp_all [NoReg.gen, NoReg.susp_mono hR]

theorem NoReg.reaction_mono {r : Reaction} (h : NoReg.reaction R r) : NoReg.reaction R' r := by
  cases r <;> simp_all [NoReg.reaction, NoReg.susp_mono hR, NoReg.val_mono hR, NoReg.stores_mono hR]

theorem NoReg.pstate_mono {p : PState} (h : NoReg.pstate R p) : NoReg.pstate R' p := by
  cases p
  case pending rs => exact fun r hr => NoReg.reaction_mono hR (h r hr)
  all_goals simp_all [NoReg.pstate, NoReg.val_mono hR]

theorem NoReg.code_mono {c : Code} (h : NoReg.code R c) : NoReg.code R' c := by
  cases c <;> simp_all [NoReg.code, NoReg.val_mono hR, NoReg.vals_mono hR, NoReg.insts_mono hR]

theorem NoReg.kind_mono {k : Kind} (h : NoReg.kind R k) : NoReg.kind R' k := by
  cases k
  case gen g a q => exact ⟨NoReg.gen_mono hR h.1, fun x hx => NoReg.comp_mono hR (h.2 x hx)⟩
  case extBuf r o l => exact fun hr => h (hR _ hr)
  all_goals simp_all [NoReg.kind, NoReg.vals_mono hR, NoReg.code_mono hR,
    NoReg.pairs_mono hR, NoReg.pstate_mono hR, NoReg.val_mono hR]

theorem NoReg.obj_mono {o : Obj} (h : NoReg.obj R o) : NoReg.obj R' o :=
  ⟨NoReg.kind_mono hR h.1, NoReg.val_mono hR h.2.1, NoReg.props_mono hR h.2.2.1,
    fun x hx => NoReg.prop_mono hR (h.2.2.2 x hx)⟩

theorem NoReg.hobj_mono {o : HObj} (h : NoReg.hobj R o) : NoReg.hobj R' o := by
  match o, h with
  | .cell none, _ => trivial
  | .cell (some v), h => exact NoReg.val_mono hR h
  | .obj o, h => exact NoReg.obj_mono hR h

end

/-! ## The cut bookkeeping -/

section
variable {S : Type}

/-- **The cut bookkeeping**: no heap entry holds a bigint of `I` or a region of `R` (at a cut: `I`
the handle band from the native handle counter on, `R` those handles' regions and the callback
regions of the addresses from the address counter on). -/
def Clean (I : Int → Prop) (R : Nat → Prop) (s : St S) : Prop :=
  ∀ a o, s.heap.get a = some o → NoBig.hobj I o ∧ NoReg.hobj R o

/-- The bookkeeping survives the counters' growth (the bands shrink). -/
theorem Clean.mono {I I' : Int → Prop} {R R' : Nat → Prop} {s : St S} (h : Clean I R s)
    (hI : ∀ i, I' i → I i) (hR : ∀ r, R' r → R r) : Clean I' R' s := fun a o ho =>
  ⟨NoBig.hobj_mono hI (h a o ho).1, NoReg.hobj_mono hR (h a o ho).2⟩

/-- **A piece keeps the bookkeeping** when the entries it changes or creates (`l`) are checked. -/
theorem Clean.step {I : Int → Prop} {R : Nat → Prop} {s s' : St S} {l : List Nat} (h : Clean I R s)
    (hch : ∀ a, a ∉ l → s'.heap.get a = s.heap.get a)
    (hl : ∀ a ∈ l, ∀ o, s'.heap.get a = some o → NoBig.hobj I o ∧ NoReg.hobj R o) : Clean I R s' := by
  intro a o ho
  by_cases ha : a ∈ l
  · exact hl a ha o ho
  · rw [hch a ha] at ho; exact h a o ho

/-- The piece's kernel check (`cleanListB`) of its changed entries, for the band `[lo, hi)` and the
regions `rB`. -/
theorem Clean.stepB {lo hi : Int} {rB : Nat → Bool} {s s' : St S} {l : List Nat}
    (h : Clean (fun i => lo ≤ i ∧ i < hi) (fun r => rB r = true) s)
    (hch : ∀ a, a ∉ l → s'.heap.get a = s.heap.get a) (hc : cleanListB lo hi rB s' l = true) :
    Clean (fun i => lo ≤ i ∧ i < hi) (fun r => rB r = true) s' :=
  h.step hch (cleanListB_sound hc)

/-- **The restart's freedom from the bookkeeping** (`NoBigSt` at a template start, the trace base
the start's own trace): the heap from `Clean`, the roots checked. -/
theorem Clean.noBigSt {I : Int → Prop} {R : Nat → Prop} {s : St S} (h : Clean I R s)
    (hc : NoBig.ctl I s.ctl) (hs : ∀ f ∈ s.stack, NoBig.frame I f) (hj : ∀ j ∈ s.jobs, NoBig.job I j)
    (hst : NoBig.stores I s.stores) : NoBigSt I s.trace s where
  heap := fun a o ho => (h a o ho).1
  ctl := hc
  stack := hs
  jobs := hj
  stores := hst
  trace := fun e he => by simp [freshOf] at he

end

/-! ## The compaction map -/

theorem nth?_some_of_lt {α : Type} : ∀ {l : List α} {i : Nat}, i < l.length → ∃ x, nth? l i = some x
  | [], _, h => by cases h
  | y :: _, 0, _ => ⟨y, rfl⟩
  | _ :: l, i + 1, h => nth?_some_of_lt (l := l) (by simp at h; omega)

/-- **The compaction map** at a call with the addresses `< n0` and the table entries `< nS`: those
fixed, the canonical result places `n0 + j` sent to the stage's fresh result addresses `pl`, the
canonical fresh addresses after them to the merged state's (`n1 + k`), the canonical result numbers
`nS + j` to `nr`; bigints, regions and nodes by `big`, `region`, `node` (the native part). -/
def Map.compact (n0 n1 nS : Nat) (pl : List Nat) (nr : List NumV) (big : Int → Int) (region node : Nat → Nat) :
    Map :=
  ⟨fun x => if x < n0 then x else if x - n0 < pl.length then (nth? pl (x - n0)).getD 0
      else n1 + (x - n0 - pl.length),
    fun i => if i < nS then .ref i else (nth? nr (i - nS)).getD (.ref i), big, region, node⟩

section
variable {n0 n1 nS : Nat} {pl : List Nat} {nr : List NumV} {big : Int → Int} {region node : Nat → Nat}

theorem Map.compact_lt {x : Nat} (hx : x < n0) : (Map.compact n0 n1 nS pl nr big region node).a x = x := by
  show (if x < n0 then x else _) = x
  rw [if_pos hx]

theorem Map.compact_res {j p : Nat} (hj : nth? pl j = some p) :
    (Map.compact n0 n1 nS pl nr big region node).a (n0 + j) = p := by
  show (if n0 + j < n0 then n0 + j else if n0 + j - n0 < pl.length then (nth? pl (n0 + j - n0)).getD 0
    else _) = p
  rw [if_neg (by omega), Nat.add_sub_cancel_left, if_pos (nth?_lt _ _ _ hj), hj]
  rfl

theorem Map.compact_next (k : Nat) :
    (Map.compact n0 n1 nS pl nr big region node).a (n0 + pl.length + k) = n1 + k := by
  show (if n0 + pl.length + k < n0 then _ else if n0 + pl.length + k - n0 < pl.length then _
    else n1 + (n0 + pl.length + k - n0 - pl.length)) = n1 + k
  rw [if_neg (by omega), if_neg (by omega)]
  congr 1; omega

theorem Map.compact_num_lt {i : Nat} (hi : i < nS) :
    (Map.compact n0 n1 nS pl nr big region node).num i = .ref i := by
  show (if i < nS then NumV.ref i else _) = _
  rw [if_pos hi]

theorem Map.compact_num_res {j : Nat} {v : NumV} (hj : nth? nr j = some v) :
    (Map.compact n0 n1 nS pl nr big region node).num (nS + j) = v := by
  show (if nS + j < nS then NumV.ref (nS + j) else (nth? nr (nS + j - nS)).getD (.ref (nS + j))) = v
  rw [if_neg (by omega), Nat.add_sub_cancel_left, hj]
  rfl

/-- The map either fixes an address or sends it at or past `n0` (the stage's results fresh). -/
theorem Map.compact_cases (hpl : ∀ p ∈ pl, n0 ≤ p) (hn1 : n0 ≤ n1) (x : Nat) :
    (Map.compact n0 n1 nS pl nr big region node).a x = x ∨ n0 ≤ (Map.compact n0 n1 nS pl nr big region node).a x := by
  by_cases hx : x < n0
  · exact .inl (Map.compact_lt hx)
  · right
    show n0 ≤ (if x < n0 then x else if x - n0 < pl.length then (nth? pl (x - n0)).getD 0
      else n1 + (x - n0 - pl.length))
    rw [if_neg hx]
    split
    · rename_i hl
      obtain ⟨p, hp⟩ := nth?_some_of_lt hl
      rw [hp]; exact hpl p (nth?_mem_some hp)
    · omega

private theorem nth?_inj : ∀ {l : List Nat} {i j p : Nat}, l.Nodup → nth? l i = some p → nth? l j = some p → i = j := by
  intro l i j p hnd hi hj
  have e1 := idx?_nth hnd hi
  have e2 := idx?_nth hnd hj
  rw [e1] at e2; exact Option.some.inj e2

/-- **Injective on the canonical state** (`ShiftD.inj`), with distinct fresh result addresses. -/
theorem Map.compact_inj (hnd : pl.Nodup) (hpl : ∀ p ∈ pl, n0 ≤ p) {a b : Nat} (ha : a < n0 + pl.length)
    (hb : b < n0 + pl.length) (he : (Map.compact n0 n1 nS pl nr big region node).a a =
      (Map.compact n0 n1 nS pl nr big region node).a b) : a = b := by
  have hres : ∀ x, n0 ≤ x → x < n0 + pl.length → ∃ p, nth? pl (x - n0) = some p ∧
      (Map.compact n0 n1 nS pl nr big region node).a x = p := by
    intro x h1 h2
    obtain ⟨p, hp⟩ := nth?_some_of_lt (show x - n0 < pl.length by omega)
    refine ⟨p, hp, ?_⟩
    have hx : x = n0 + (x - n0) := by omega
    rw [hx]; exact Map.compact_res hp
  by_cases h1 : a < n0 <;> by_cases h2 : b < n0
  · rwa [Map.compact_lt h1, Map.compact_lt h2] at he
  · obtain ⟨p, hp, e⟩ := hres b (by omega) hb
    rw [Map.compact_lt h1, e] at he
    have := hpl p (nth?_mem_some hp); omega
  · obtain ⟨p, hp, e⟩ := hres a (by omega) ha
    rw [Map.compact_lt h2, e] at he
    have := hpl p (nth?_mem_some hp); omega
  · obtain ⟨p, hp, e⟩ := hres a (by omega) ha
    obtain ⟨q, hq, e'⟩ := hres b (by omega) hb
    rw [e, e'] at he; subst he
    have := nth?_inj hnd hp hq; omega

end

/-! ## The table: result variables -/

/-- The compaction's substitution: the result variables `ws` to the stage's result expressions `rs`,
every other variable to itself. -/
def compactθ (ws : List Nat) (rs : List SymE) (v : Nat) : SymE :=
  match idx? v ws with
  | some j => (nth? rs j).getD (.var v)
  | none => .var v

theorem SymE.subst_compactθ {ws : List Nat} {rs : List SymE} :
    ∀ e : SymE, (∀ w ∈ ws, e.noVar w = true) → e.subst (compactθ ws rs) = e
  | .lit _, _ => rfl
  | .var i, h => by
    have hi : i ∉ ws := fun hm => by have := h i hm; simp [SymE.noVar] at this
    show compactθ ws rs i = .var i
    simp only [compactθ, idx?_none hi]
  | .bin op a b, h => by
    show SymE.bin op (a.subst _) (b.subst _) = _
    rw [SymE.subst_compactθ a fun w hw => by have := h w hw; simp only [SymE.noVar, Bool.and_eq_true] at this; exact this.1,
      SymE.subst_compactθ b fun w hw => by have := h w hw; simp only [SymE.noVar, Bool.and_eq_true] at this; exact this.2]
  | .un op a, h => by
    show SymE.un op (a.subst _) = _
    rw [SymE.subst_compactθ a fun w hw => by have := h w hw; simpa [SymE.noVar] using this]

private theorem idx?_lt {v : Nat} : ∀ {l : List Nat} {k : Nat}, idx? v l = some k → k < l.length
  | [], _, h => by cases h
  | w :: l, k, h => by
    simp only [idx?] at h
    cases hb : Nat.beq w v
    · rw [hb] at h
      simp only [Bool.cond_false] at h
      cases e : idx? v l with
      | none => rw [e] at h; cases h
      | some k' =>
        rw [e] at h; cases h
        have := idx?_lt e; simp only [List.length_cons]; omega
    · rw [hb] at h; cases h; simp

/-- The compaction's valuation binds the result variables to the stage's results' values. -/
theorem valuation_compactθ {ws : List Nat} {rs : List SymE} (hl : rs.length = ws.length) (ν : Nat → F64) :
    Shift.valuation (compactθ ws rs) ν =
      resVal ν ws (fun j => ((nth? rs j).getD (.lit (F64.zero false))).eval ν) := by
  funext v
  show (compactθ ws rs v).eval ν = _
  unfold compactθ resVal
  cases e : idx? v ws with
  | none => rfl
  | some j =>
    obtain ⟨r, hr⟩ := nth?_some_of_lt (show j < rs.length by rw [hl]; exact idx?_lt e)
    simp only [hr, Option.getD_some]

/-- **The compaction's table check** (`ShiftD.num`): the canonical table is the call's `tab` and the
result variables `ws`; the merged table keeps `tab` and holds the results `rs` at the numbers `nr`. -/
theorem compact_num {tab : List SymE} {ws : List Nat} {rs : List SymE} {S1 : SSrv}
    {n0 n1 : Nat} {pl : List Nat} {nr : List NumV} {big : Int → Int} {region node : Nat → Nat}
    (hpre : ∀ i e, nth? tab i = some e → nth? S1.tab i = some e)
    (hfresh : ∀ e ∈ tab, ∀ w ∈ ws, e.noVar w = true) (hnd : ws.Nodup)
    (hl : nr.length = ws.length) (hrl : rs.length = ws.length)
    (hr : ∀ j v, nth? nr j = some v → S1.val v = nth? rs j) :
    ∀ i e, nth? (tab ++ resTab ws) i = some e →
      S1.val ((Map.compact n0 n1 tab.length pl nr big region node).num i) = some (e.subst (compactθ ws rs)) := by
  intro i e he
  by_cases hi : i < tab.length
  · rw [nth?_append_lt _ _ _ hi] at he
    rw [Map.compact_num_lt hi, SymE.subst_compactθ e (hfresh e (nth?_mem_some he))]
    exact hpre i e he
  · obtain ⟨j, rfl⟩ : ∃ j, i = tab.length + j := ⟨i - tab.length, by omega⟩
    have hdrop : ∀ (xs ys : List SymE) (k : Nat), nth? (xs ++ ys) (xs.length + k) = nth? ys k := by
      intro xs ys k; induction xs with
      | nil => simp
      | cons x xs ih => simpa [nth?, Nat.succ_add] using ih
    rw [hdrop] at he
    unfold resTab at he
    rw [nth?_map] at he
    cases hw : nth? ws j with
    | none => rw [hw] at he; cases he
    | some w =>
      rw [hw] at he; cases he
      obtain ⟨v, hv⟩ := nth?_some_of_lt (show j < nr.length by rw [hl]; exact nth?_lt _ _ _ hw)
      obtain ⟨r, hrj⟩ := nth?_some_of_lt (show j < rs.length by rw [hrl]; exact nth?_lt _ _ _ hw)
      rw [Map.compact_num_res hv, hr j v hv, hrj]
      show some r = some (compactθ ws rs w)
      simp only [compactθ, idx?_nth hnd hw, hrj, Option.getD_some]

/-! ## The caller's entries as a band -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
  {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- **The band's support from the call**: an entry of the caller's state at the call mentions only
the call's addresses and table references. -/
theorem band_of_call (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : HObj} (ho : s.heap.get a = some o) :
    Supp.hobj (· < s.next) S.tab.length o :=
  Supp.hobj_mono (fun x hx => h.presentBound x hx) (Nat.le_refl _) (h.heapSupp a o ho)

/-- **The compaction's heap check from the footprint** (`ShiftD.heap`): on the band `Stat` (the
caller's entries the stage leaves: the canonical and the merged state hold the call's entry) `κ`
fixes the entry (it fixes the call's addresses and table references, and every bigint and region
off the stage's fresh ones `I`, `R`, of which the bookkeeping `Clean` keeps the call's heap free);
the rest (the footprint and the results) is the kernel's check `hfoot`. -/
theorem compact_heap {κ : Map} {s0 s1 : St F.S} {I : Int → Prop} {R : Nat → Prop} (hcall : RelB F FR W stk M ν K s S t C)
    (hclean : Clean I R s) {Stat : Nat → Prop}
    (h0 : ∀ a, Stat a → s0.heap.get a = s.heap.get a) (h1 : ∀ a, Stat a → s1.heap.get a = s.heap.get a)
    (ha : ∀ x, x < s.next → κ.a x = x) (hn : ∀ i, i < S.tab.length → κ.num i = .ref i)
    (hb : ∀ i, ¬ I i → κ.big i = i) (hrg : ∀ r, ¬ R r → κ.region r = r)
    (hfoot : ∀ a o, s0.heap.get a = some o → ¬ Stat a → s1.heap.get (κ.a a) = some (κ.hobj o)) :
    ∀ a o, s0.heap.get a = some o → s1.heap.get (κ.a a) = some (κ.hobj o) := by
  intro a o ho
  by_cases hs : Stat a
  · rw [h0 a hs] at ho
    have hlt : a < s.next := hcall.presentBound a (Present.of_get ho)
    rw [ha a hlt, h1 a hs, ho,
      Map.hobj_fix ha hn hb hrg (band_of_call hcall ho) (hclean a o ho).1 (hclean a o ho).2]
  · exact hfoot a o ho hs

/-- **The compaction's frame check** (`ShiftD.unfr`): with every frame kept, an unframed canonical
entry's image is unframed when `κ` fixes it or sends it past the call's addresses. -/
theorem compact_unfr {κ : Map} (hcall : RelB F FR W stk M ν K s S t C)
    (hfix : ∀ a, κ.a a = a ∨ s.next ≤ κ.a a) {a : Nat} (hk : kpOf K W a = false) (hw : W a = none) :
    K.fr (κ.a a) = none := by
  rcases hfix a with e | hge
  · rw [e]
    simp only [kpOf, hw, Option.isNone_none, Bool.and_true, Option.isSome_eq_false_iff] at hk
    simpa using hk
  · cases hf : K.fr (κ.a a) with
    | none => rfl
    | some p =>
      have := hcall.presentBound _ (hcall.framedPresent _ p hf)
      omega

end

/-! ## Compaction -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {W : Nat → Option WFrame} {M κ : Map} {ν : Nat → F64} {θ : Nat → SymE} {K1 : Ctx}
  {s0 s1 t : St F.S} {S0 S1 : SSrv} {C : CSrv}

/-- **Compaction**: a target related to the merged state `s1` (frames `W`, context `K1`) is related
to the canonical state `s0` under `M.after κ`, every frame kept (the framed arrays rebased on their
template prefixes, `Shift.framedNext`), at the substituted valuation (`ShiftD` along the compaction
map with all frames kept: `restartDrop` at `kpOf K1 W` and `W`). -/
theorem compact (hFS : ∀ x y z, FS κ x y → FR M S1.tab.length y z → FR (M.after κ) S0.tab.length x z)
    (hr : RelF F FR W M ν K1 s1 S1 t C) (hs : ShiftD F FS κ θ (kpOf K1 W) W K1 s0 S0 s1 S1)
    (hg : Good (Shift.valuation θ ν) S0.oracle) (hroom : t.next - s0.next < Sim.bound) :
    RelF F FR W (M.after κ) (Shift.valuation θ ν)
      ⟨Shift.framedNext M K1 s1, s0.trace, t.trace, t.next - s0.next, K1.lo, K1.hi⟩ s0 S0 t C := by
  have h := restartDrop (kp := kpOf K1 W) (W0 := W) hFS hr hs (fun _ _ hw => hw) hg hroom
  rwa [dropNext_keep hr] at h

end

/-! ## The caller's framed and written entries

A stage may write caller entries (id counters, memo cells): they are the caller's, under the caller's
frames, at their own addresses (`κ` fixes them), not stage results. The canonical state holds their
merged values renamed back, so the compaction checks them with the results (`hfoot`, `cleanListB`),
and the restart's frame clauses take them by frame: an unframed one by the heap clause
(`compact_heapX`, which excludes only the kept arrays `X`, whose canonical entry is the template
prefix: `ShiftD.framed`), one under a frame of `W` by the wide clause (`compact_wide`, its frame's
names fixed: `WFix.of_fix`). -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
  {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- **The compaction's heap check from the footprint**, off a set `X` of entries the heap clause does
not cover (the kept arrays): `compact_heap` with `hfoot` asked only off `Stat` and `X`. The written
caller entries are among the checked ones (`¬ Stat`) at their own addresses. -/
theorem compact_heapX {κ : Map} {s0 s1 : St F.S} {I : Int → Prop} {R : Nat → Prop} {X : Nat → Prop}
    (hcall : RelB F FR W stk M ν K s S t C) (hclean : Clean I R s) {Stat : Nat → Prop}
    (h0 : ∀ a, Stat a → s0.heap.get a = s.heap.get a) (h1 : ∀ a, Stat a → s1.heap.get a = s.heap.get a)
    (ha : ∀ x, x < s.next → κ.a x = x) (hn : ∀ i, i < S.tab.length → κ.num i = .ref i)
    (hb : ∀ i, ¬ I i → κ.big i = i) (hrg : ∀ r, ¬ R r → κ.region r = r)
    (hfoot : ∀ a o, s0.heap.get a = some o → ¬ Stat a → ¬ X a → s1.heap.get (κ.a a) = some (κ.hobj o)) :
    ∀ a o, s0.heap.get a = some o → ¬ X a → s1.heap.get (κ.a a) = some (κ.hobj o) := by
  intro a o ho hx
  by_cases hs : Stat a
  · rw [h0 a hs] at ho
    have hlt : a < s.next := hcall.presentBound a (Present.of_get ho)
    rw [ha a hlt, h1 a hs, ho,
      Map.hobj_fix ha hn hb hrg (band_of_call hcall ho) (hclean a o ho).1 (hclean a o ho).2]
  · exact hfoot a o ho hs hx

end

/-- A frame's names fixed by one map and a set stay fixed by another fixing that set. -/
theorem WFix.of_fix {σ σ' : Map} {A A' : Nat → Prop} {w : WFrame} (h : WFix σ' A w)
    (hfix : ∀ b, A b → σ.a b = b) (hA : ∀ b, A b → A' b)
    (htyped : ∀ k b off n', w = .typed k b off n' → σ.a b = b) : WFix σ A' w := by
  cases w
  case typed k b off n' => exact htyped k b off n' rfl
  case fields ks ps => exact ⟨h.1, fun p hp => ⟨hfix _ (h.2 p hp).2, hA _ (h.2 p hp).2⟩⟩
  all_goals trivial

/-- **The compaction's wide clause** (`ShiftD.wide`) at a caller entry under a frame of `W`, written by
the stage or not: `κ` fixes its address, the canonical entry's image is the merged one (`hheap`, from
`compact_heapX`), its frame's names are fixed. -/
theorem compact_wide {κ : Map} {K1 : Ctx} {W : Nat → Option WFrame} {S' : Type} {s0 s1 : St S'} {n0 : Nat}
    (ha : ∀ x, x < n0 → κ.a x = x) {a : Nat} {w : WFrame} (hw : W a = some w) (hlt : a < n0)
    (hfr : K1.fr a ≠ none) (hP : Present s0 a)
    (hheap : ∀ h, s0.heap.get a = some h → s1.heap.get (κ.a a) = some (κ.hobj h))
    (hwf : WFix κ (Present s0) w) :
    kpOf K1 W a = false ∧ κ.a a = a ∧ K1.fr a ≠ none ∧ Present s0 a ∧
      (∀ h, s0.heap.get a = some h → s1.heap.get a = some (κ.hobj h)) ∧ WFix κ (Present s0) w := by
  refine ⟨by simp [kpOf, hw], ha a hlt, hfr, hP, fun h hg => ?_, hwf⟩
  have := hheap h hg
  rwa [ha a hlt] at this

end Host.Ts.Sim.Conv
