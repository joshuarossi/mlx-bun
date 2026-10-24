import host.sim.Support
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim

/-! # Support of images

The image under a map `σ` of data supported in `(A, n)` (present addresses `A`, number
references below `n`) is supported in `(A', n')` when `σ` sends `A` into `A'` and every
reference below `n` to a number supported below `n'`. The merge at a stage's return
(`host.sim.conv.Merge`) pushes the stage's return state into the caller's naming; its closedness
follows from the template's by these lemmas, with no check of the pushed entries. -/

set_option linter.unusedSectionVars false

section
variable {A A' : Nat → Prop} {n n' : Nat} {σ : Map}
variable (hA : ∀ a, A a → A' (σ.a a)) (hn : ∀ i, i < n → Supp.nv A' n' (σ.num i))
include hA hn

theorem Supp.nv_map {x : NumV} (hx : Supp.nv A n x) : Supp.nv A' n' (σ.nv x) := by
  cases x with
  | lit _ => trivial
  | ref i => exact hn i hx

theorem Supp.mem_map {m : Mem} (hx : Supp.mem A n m) : Supp.mem A' n' (σ.mem m) := by
  cases m with
  | js b => exact hA b hx
  | ext _ => trivial

theorem Supp.sym_map {i : Nat} (hx : Supp.sym A n i) : Supp.sym A' n' (σ.sym i) := by
  intro h16
  by_cases hi : i < 16
  · have e : σ.sym i = i := by simp [Map.sym, hi]
    rw [e] at h16; omega
  · have e : σ.sym i = σ.a (i - 16) + 16 := by simp [Map.sym, Nat.blt_eq, hi]
    rw [e, Nat.add_sub_cancel]
    exact hA _ (hx (by omega))

theorem Supp.env_map {e : Env} (hx : Supp.env A n e) : Supp.env A' n' (σ.env e) := by
  intro x hm
  obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hm
  exact hA _ (hx y hy)

theorem Supp.val_map {x : Val} (hx : Supp.val A n x) : Supp.val A' n' (σ.val x) := by
  cases x <;> simp_all [Supp.val, Map.val, Supp.nv_map hA hn, Supp.sym_map hA hn, Supp.mem_map hA hn]

theorem Supp.key_map {k : PKey} (hx : Supp.key A n k) : Supp.key A' n' (σ.key k) := by
  cases k <;> simp_all [Supp.key, Map.key, Supp.sym_map hA hn]

theorem Supp.okey_map {k : Option PKey} (hx : Supp.okey A n k) : Supp.okey A' n' (k.map σ.key) := by
  cases k <;> simp_all [Supp.okey, Supp.key_map hA hn]

theorem Supp.keys_map {ks : List PKey} (hx : Supp.keys A n ks) : Supp.keys A' n' (ks.map σ.key) := by
  intro k hm
  obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hm
  exact Supp.key_map hA hn (hx y hy)

theorem Supp.prop_map {p : PropV} (hx : Supp.prop A n p) : Supp.prop A' n' (σ.prop p) := by
  cases p <;> simp_all [Supp.prop, Map.prop, Supp.val_map hA hn]

theorem Supp.props_map {ps : Props} (hx : Supp.props A n ps) : Supp.props A' n' (σ.props ps) := by
  intro x hm
  obtain ⟨⟨k, p⟩, hy, rfl⟩ := List.mem_map.1 hm
  exact ⟨Supp.key_map hA hn (hx _ hy).1, Supp.prop_map hA hn (hx _ hy).2⟩

theorem Supp.vals_map {vs : List Val} (hx : Supp.vals A n vs) : Supp.vals A' n' (σ.vals vs) := by
  intro v hm
  obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hm
  exact Supp.val_map hA hn (hx y hy)

theorem Supp.cell_map {c : Cell} (hx : Supp.cell A n c) : Supp.cell A' n' (σ.cell c) := by
  cases c <;> simp_all [Supp.cell, Map.cell, Supp.nv_map hA hn]

theorem Supp.byte_map {b : Byte} (hx : Supp.byte A n b) : Supp.byte A' n' (σ.byte b) := by
  cases b <;> simp_all [Supp.byte, Map.byte, Supp.cell_map hA hn]

theorem Supp.bytes_map {bs : List Byte} (hx : Supp.bytes A n bs) : Supp.bytes A' n' (bs.map σ.byte) := by
  intro b hm
  obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hm
  exact Supp.byte_map hA hn (hx y hy)

theorem Supp.abr_map {a : Abrupt} (hx : Supp.abr A n a) : Supp.abr A' n' (σ.abr a) := by
  cases a <;> simp_all [Supp.abr, Map.abr, Supp.val_map hA hn]

theorem Supp.comp_map {c : Comp} (hx : Supp.comp A n c) : Supp.comp A' n' (σ.comp c) := by
  cases c <;> simp_all [Supp.comp, Map.comp, Supp.val_map hA hn, Supp.abr_map hA hn]

theorem Supp.inst_map {i : InstMember} (hx : Supp.inst A n i) : Supp.inst A' n' (σ.inst i) := by
  cases i <;> simp_all [Supp.inst, Map.inst, Supp.key_map hA hn, Supp.prop_map hA hn]

theorem Supp.insts_map {is : List InstMember} (hx : Supp.insts A n is) : Supp.insts A' n' (is.map σ.inst) := by
  intro i hm
  obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hm
  exact Supp.inst_map hA hn (hx y hy)

theorem Supp.bnd_map {b : Boundary} (hx : Supp.bnd A n b) : Supp.bnd A' n' (σ.bnd b) := by
  cases b <;> simp_all [Supp.bnd, Map.bnd, Supp.val_map hA hn]

theorem Supp.src_map {s : IterSrc} (hx : Supp.src A n s) : Supp.src A' n' (σ.src s) := by
  cases s <;> simp_all [Supp.src, Map.src, Supp.val_map hA hn]

theorem Supp.pairs_map {ps : List (Val × Val)} (hx : Supp.pairs A n ps) : Supp.pairs A' n' (σ.pairs ps) := by
  intro x hm
  obtain ⟨⟨u, v⟩, hy, rfl⟩ := List.mem_map.1 hm
  exact ⟨Supp.val_map hA hn (hx _ hy).1, Supp.val_map hA hn (hx _ hy).2⟩

theorem Supp.callF_map {f : CallF} (hx : Supp.callF A n f) : Supp.callF A' n' (σ.callF f) := by
  cases f <;> simp_all [Supp.callF, Map.callF, Supp.key_map hA hn, Supp.val_map hA hn, Supp.vals_map hA hn,
    Supp.env_map hA hn]

theorem Supp.exprF_map {f : ExprF} (hx : Supp.exprF A n f) : Supp.exprF A' n' (σ.exprF f) := by
  cases f <;> simp_all [Supp.exprF, Map.exprF, Supp.key_map hA hn, Supp.val_map hA hn, Supp.env_map hA hn]

theorem Supp.litF_map {f : LitF} (hx : Supp.litF A n f) : Supp.litF A' n' (σ.litF f) := by
  cases f <;> simp_all [Supp.litF, Map.litF, Supp.key_map hA hn, Supp.val_map hA hn, Supp.vals_map hA hn,
    Supp.env_map hA hn]

theorem Supp.target_map {t : Target} (hx : Supp.target A n t) : Supp.target A' n' (σ.target t) := by
  cases t <;> simp_all [Supp.target, Map.target, Supp.key_map hA hn, Supp.val_map hA hn, Supp.env_map hA hn]

theorem Supp.asgF_map {f : AsgF} (hx : Supp.asgF A n f) : Supp.asgF A' n' (σ.asgF f) := by
  cases f <;> simp_all [Supp.asgF, Map.asgF, Supp.okey_map hA hn, Supp.target_map hA hn,
    Supp.val_map hA hn, Supp.env_map hA hn]

theorem Supp.stmtF_map {f : StmtF} (hx : Supp.stmtF A n f) : Supp.stmtF A' n' (σ.stmtF f) := by
  cases f <;> simp_all [Supp.stmtF, Map.stmtF, Supp.pairs_map hA hn, Supp.comp_map hA hn,
    Supp.val_map hA hn, Supp.env_map hA hn]

theorem Supp.loopF_map {f : LoopF} (hx : Supp.loopF A n f) : Supp.loopF A' n' (σ.loopF f) := by
  cases f <;> simp_all [Supp.loopF, Map.loopF, Supp.src_map hA hn, Supp.comp_map hA hn,
    Supp.val_map hA hn, Supp.env_map hA hn]

theorem Supp.bindF_map {f : BindF} (hx : Supp.bindF A n f) : Supp.bindF A' n' (σ.bindF f) := by
  cases f <;> simp_all [Supp.bindF, Map.bindF, Supp.keys_map hA hn, Supp.key_map hA hn,
    Supp.val_map hA hn, Supp.vals_map hA hn, Supp.env_map hA hn]

theorem Supp.fnF_map {f : FnF} (hx : Supp.fnF A n f) : Supp.fnF A' n' (σ.fnF f) := by
  cases f
  case modules r =>
    intro x hm
    obtain ⟨⟨ss, e⟩, hy, rfl⟩ := List.mem_map.1 hm
    exact Supp.env_map hA hn (hx _ hy)
  all_goals simp_all [Supp.fnF, Map.fnF, Supp.insts_map hA hn, Supp.bnd_map hA hn, Supp.key_map hA hn,
    Supp.val_map hA hn, Supp.vals_map hA hn, Supp.env_map hA hn]

theorem Supp.frame_map {f : Frame} (hx : Supp.frame A n f) : Supp.frame A' n' (σ.frame f) := by
  cases f <;> simp_all [Supp.frame, Map.frame, Supp.exprF_map hA hn, Supp.callF_map hA hn,
    Supp.litF_map hA hn, Supp.asgF_map hA hn, Supp.stmtF_map hA hn, Supp.loopF_map hA hn,
    Supp.bindF_map hA hn, Supp.fnF_map hA hn]

theorem Supp.ctl_map {c : Ctl} (hx : Supp.ctl A n c) : Supp.ctl A' n' (σ.ctl c) := by
  cases c <;> simp_all [Supp.ctl, Map.ctl, Supp.abr_map hA hn, Supp.comp_map hA hn, Supp.val_map hA hn,
    Supp.vals_map hA hn, Supp.env_map hA hn]

theorem Supp.stores_map {ss : List (Nat × Val)} (hx : Supp.stores A n ss) :
    Supp.stores A' n' (σ.stores ss) := by
  intro x hm
  obtain ⟨⟨i, v⟩, hy, rfl⟩ := List.mem_map.1 hm
  exact ⟨hA _ (hx _ hy).1, Supp.val_map hA hn (hx _ hy).2⟩

theorem Supp.susp_map {u : Susp} (hx : Supp.susp A n u) : Supp.susp A' n' (σ.susp u) := by
  obtain ⟨hf, hs⟩ := hx
  refine ⟨fun f hm => ?_, Supp.stores_map hA hn hs⟩
  obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hm
  exact Supp.frame_map hA hn (hf y hy)

theorem Supp.gen_map {g : GenState} (hx : Supp.gen A n g) : Supp.gen A' n' (σ.gen g) := by
  cases g <;> simp_all [Supp.gen, Map.gen, Supp.susp_map hA hn, Supp.env_map hA hn]

theorem Supp.reaction_map {r : Reaction} (hx : Supp.reaction A n r) : Supp.reaction A' n' (σ.reaction r) := by
  cases r <;> simp_all [Supp.reaction, Map.reaction, Supp.susp_map hA hn, Supp.stores_map hA hn,
    Supp.val_map hA hn]

theorem Supp.pstate_map {p : PState} (hx : Supp.pstate A n p) : Supp.pstate A' n' (σ.pstate p) := by
  cases p
  case pending rs =>
    intro r hm
    obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hm
    exact Supp.reaction_map hA hn (hx y hy)
  all_goals simp_all [Supp.pstate, Map.pstate, Supp.val_map hA hn]

theorem Supp.code_map {c : Code} (hx : Supp.code A n c) : Supp.code A' n' (σ.code c) := by
  cases c <;> simp_all [Supp.code, Map.code, Supp.insts_map hA hn, Supp.val_map hA hn, Supp.vals_map hA hn,
    Supp.env_map hA hn]

theorem Supp.kind_map {k : Kind} (hx : Supp.kind A n k) : Supp.kind A' n' (σ.kind k) := by
  cases k
  case gen g a q =>
    obtain ⟨hg, hq⟩ := hx
    refine ⟨Supp.gen_map hA hn hg, fun x hm => ?_⟩
    obtain ⟨⟨p, c⟩, hy, rfl⟩ := List.mem_map.1 hm
    exact ⟨hA _ (hq _ hy).1, Supp.comp_map hA hn (hq _ hy).2⟩
  case ns ex =>
    intro x hm
    obtain ⟨⟨nm, c⟩, hy, rfl⟩ := List.mem_map.1 hm
    exact hA _ (hx _ hy)
  all_goals simp_all [Supp.kind, Map.kind, Supp.bytes_map hA hn, Supp.code_map hA hn,
    Supp.pairs_map hA hn, Supp.pstate_map hA hn, Supp.val_map hA hn, Supp.vals_map hA hn]

theorem Supp.obj_map {o : Obj} (hx : Supp.obj A n o) : Supp.obj A' n' (σ.obj o) := by
  obtain ⟨hk, hpr, hps, hpv⟩ := hx
  refine ⟨Supp.kind_map hA hn hk, Supp.val_map hA hn hpr, Supp.props_map hA hn hps, fun x hm => ?_⟩
  obtain ⟨⟨⟨b, nm⟩, p⟩, hy, rfl⟩ := List.mem_map.1 hm
  exact ⟨hA _ (hpv _ hy).1, Supp.prop_map hA hn (hpv _ hy).2⟩

theorem Supp.hobj_map {o : HObj} (hx : Supp.hobj A n o) : Supp.hobj A' n' (σ.hobj o) := by
  cases o with
  | cell v => cases v <;> simp_all [Supp.hobj, Map.hobj, Supp.val_map hA hn]
  | obj o => exact Supp.obj_map hA hn hx

theorem Supp.arg_map {a : Arg} (hx : Supp.arg A n a) : Supp.arg A' n' (σ.arg a) := by
  cases a <;> simp_all [Supp.arg, Map.arg, Supp.bytes_map hA hn, Supp.nv_map hA hn, Supp.val_map hA hn]

theorem Supp.args_map {as : List Arg} (hx : Supp.args A n as) : Supp.args A' n' (as.map σ.arg) := by
  intro a hm
  obtain ⟨y, hy, rfl⟩ := List.mem_map.1 hm
  exact Supp.arg_map hA hn (hx y hy)

theorem Supp.ret_map {r : Ret} (hx : Supp.ret A n r) : Supp.ret A' n' (σ.ret r) := by
  cases r <;> simp_all [Supp.ret, Map.ret, Supp.args_map hA hn, Supp.nv_map hA hn]

theorem Supp.event_map {e : Event} (hx : Supp.event A n e) : Supp.event A' n' (σ.event e) :=
  ⟨Supp.args_map hA hn hx.1, Supp.ret_map hA hn hx.2⟩

theorem Supp.job_map {j : Job} (hx : Supp.job A n j) : Supp.job A' n' (σ.job j) :=
  ⟨Supp.reaction_map hA hn hx.1, Supp.val_map hA hn hx.2⟩

end

end Host.Ts.Sim.Conv
