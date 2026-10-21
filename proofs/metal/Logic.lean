import metal.Run

namespace Metal
open Core Inference.Contracts.Mlx

/-! # Reasoning about runs

One-step lemmas for threads: each statement form, given the results of the
expressions it evaluates. A kernel proof chains them along a thread's code. -/

variable (C : M1Max.Contract)

section
variable {t : Thread} {sh sh' sh'' sh''' : Shared} {fs : List Frame} {rest : List CStmt} (n : Nat)

theorem runThread_stop (h : isRunning t.status = false) : (runThread C n t).run sh = some (t, sh) := by
  cases n <;> simp [runThread, h] <;> rfl

theorem runThread_step (h : isRunning t.status = true) :
    (runThread C (n + 1) t).run sh = ((step C t) >>= runThread C n).run sh := by
  simp [runThread, h]

theorem runThread_set {slot : Nat} {e : CExpr} {v : Val} (hr : isRunning t.status = true)
    (hf : t.frames = .block (.set slot e :: rest) :: fs) (he : (eval C t.ctx t.locals e).run sh = some (v, sh')) :
    (runThread C (n + 1) t).run sh = (runThread C n ({ t with frames := .block rest :: fs }.set slot v)).run sh' := by
  rw [runThread_step C n hr]
  simp only [step, hf, exec, StateT.run_bind] at *
  simp only [StateT.run] at he ⊢
  simp [he, bind, Option.bind]
  rfl

theorem runThread_pop (hr : isRunning t.status = true) (hf : t.frames = .block [] :: fs) :
    (runThread C (n + 1) t).run sh = (runThread C n { t with frames := fs }).run sh := by
  rw [runThread_step C n hr]; simp only [step, hf]; rfl

theorem runThread_done (hr : isRunning t.status = true) (hf : t.frames = []) :
    (runThread C (n + 1) t).run sh = (runThread C n { t with status := .done }).run sh := by
  rw [runThread_step C n hr]; simp only [step, hf]; rfl

theorem runThread_loop_enter {c : CExpr} {st body : List CStmt} {b : Bool} (hr : isRunning t.status = true)
    (hf : t.frames = .block (.loop c st body :: rest) :: fs)
    (hc : (eval C t.ctx t.locals c).run sh = some (.bool b, sh')) :
    (runThread C (n + 1) t).run sh = (runThread C n { t with frames := (if b then .block body :: .loop c st body :: .block rest :: fs else .block rest :: fs) }).run sh' := by
  rw [runThread_step C n hr]
  simp only [step, hf, exec, test]
  simp only [StateT.run] at hc ⊢
  cases b <;> simp [bind, StateT.bind, Option.bind, hc, lift, truth] <;> rfl

theorem runThread_loop_next {c : CExpr} {st body : List CStmt} (hr : isRunning t.status = true)
    (hf : t.frames = .loop c st body :: fs) :
    (runThread C (n + 1) t).run sh = (runThread C n { t with frames := .block st :: .next c st body :: fs }).run sh := by
  rw [runThread_step C n hr]; simp only [step, hf]; rfl

theorem runThread_loop_test {c : CExpr} {st body : List CStmt} {b : Bool} (hr : isRunning t.status = true)
    (hf : t.frames = .next c st body :: fs)
    (hc : (eval C t.ctx t.locals c).run sh = some (.bool b, sh')) :
    (runThread C (n + 1) t).run sh = (runThread C n { t with frames := (if b then .block body :: .loop c st body :: fs else fs) }).run sh' := by
  rw [runThread_step C n hr]
  simp only [step, hf, test]
  simp only [StateT.run] at hc ⊢
  cases b <;> simp [bind, StateT.bind, Option.bind, hc, lift, truth] <;> rfl

theorem runThread_ite {c : CExpr} {a b : List CStmt} {v : Bool} (hr : isRunning t.status = true)
    (hf : t.frames = .block (.ite c a b :: rest) :: fs)
    (hc : (eval C t.ctx t.locals c).run sh = some (.bool v, sh')) :
    (runThread C (n + 1) t).run sh = (runThread C n { t with frames := (.block (if v then a else b) :: .block rest :: fs) }).run sh' := by
  rw [runThread_step C n hr]
  simp only [step, hf, exec, test]
  simp only [StateT.run] at hc ⊢
  cases v <;> simp [bind, StateT.bind, Option.bind, hc, lift, truth] <;> rfl

theorem runThread_collective {site slot : Nat} {op : Collective} {s u : Scalar} {e d : CExpr} {v : Val} {k : Nat}
    (hr : isRunning t.status = true)
    (hf : t.frames = .block (.collective site slot op s e d :: rest) :: fs)
    (he : (eval C t.ctx t.locals e).run sh = some (v, sh'))
    (hd : (eval C t.ctx t.locals d).run sh' = some (.int u k, sh'')) (hu : u.isSigned = false) :
    (runThread C (n + 1) t).run sh = some ({ t with frames := (.block rest :: fs), status := (.collective site slot op s v k) }, sh'') := by
  rw [runThread_step C n hr]
  simp only [step, hf, exec]
  simp only [StateT.run] at he hd ⊢
  cases n <;> simp [bind, StateT.bind, Option.bind, he, hd, lift, natOf, Val.signed, hu, runThread, isRunning] <;> rfl

theorem runThread_store {ty : Ty} {p e : CExpr} {q : Ptr} {v : Val}
    (hr : isRunning t.status = true)
    (hf : t.frames = .block (.store ty p e :: rest) :: fs)
    (hp : (eval C t.ctx t.locals p).run sh = some (.ptr q, sh'))
    (he : (eval C t.ctx t.locals e).run sh' = some (v, sh''))
    (hs : (storeAt t.ctx ty q v).run sh'' = some ((), sh''')) :
    (runThread C (n + 1) t).run sh = (runThread C n { t with frames := .block rest :: fs }).run sh''' := by
  rw [runThread_step C n hr]
  simp only [step, hf, exec]
  simp only [StateT.run] at hp he hs ⊢
  simp [bind, StateT.bind, Option.bind, hp, he, hs]
  rfl

end

/-! ## Memory -/

/-- The log entry of an access by `ctx`'s thread in `sh`'s epochs. -/
def entry (ctx : Ctx) (sh : Shared) (region byte : Nat) (write : Bool) : Access :=
  ⟨ctx.thread, ctx.group, region, byte, write, sh.deviceEpoch, sh.groupEpoch⟩

theorem logAccess_run (ctx : Ctx) (region byte : Nat) (write : Bool) (r : Region) (hs : r.space ≠ .thread)
    (sh : Shared) (h : sh.regions region = some r) :
    (logAccess ctx region byte write).run sh = some ((), { sh with log := entry ctx sh region byte write :: sh.log }) := by
  simp [logAccess, StateT.run, modify, modifyGet, MonadStateOf.modifyGet, StateT.modifyGet, h, hs, entry]

theorem log_loop (ctx : Ctx) (region offset : Nat) (write : Bool) (r : Region) (hs : r.space ≠ .thread) :
    ∀ (xs : List Nat) (sh : Shared), sh.regions region = some r →
    (xs.foldlM (fun _ i => logAccess ctx region (offset + i) write) PUnit.unit).run sh =
      some (PUnit.unit, { sh with log := (xs.map fun i => entry ctx sh region (offset + i) write).reverse ++ sh.log }) := by
  intro xs
  induction xs with
  | nil => intro sh _; simp [StateT.run, pure, StateT.pure]
  | cons x xs ih =>
    intro sh h
    have ih' := ih { sh with log := entry ctx sh region (offset + x) write :: sh.log } h
    simp only [List.foldlM_cons, StateT.run_bind, logAccess_run ctx region (offset + x) write r hs sh h] at ih' ⊢
    show Option.bind (some _) _ = _
    rw [Option.bind_some]
    rw [ih']
    simp [entry]


/-- The byte offset a load of `t` reads in region `r` (`place`). -/
def loadOffset (t : Ty) (r : Region) (o : Nat) : Nat :=
  if r.space = .threadgroup ∧ t.bytes = 4 ∧ r.align % 4 = 0 then o - o % 4 else o

theorem loadAt_run (ctx : Ctx) (t : Ty) (p : Ptr) (r : Region) (sh : Shared) (v : Val)
    (hr : sh.regions p.region = some r) (hs : r.space ≠ .thread) (ho : 0 ≤ p.offset)
    (ha : r.align % alignment t = 0) (hoa : loadOffset t r p.offset.toNat % alignment t = 0)
    (hb : loadOffset t r p.offset.toNat + t.bytes ≤ r.size)
    (hd : decode t ((List.range t.bytes).map fun i => sh.bytes p.region (loadOffset t r p.offset.toNat + i)) = some v) :
    (loadAt ctx t p).run sh = some (v, { sh with log :=
      ((List.range t.bytes).map fun i => entry ctx sh p.region (loadOffset t r p.offset.toNat + i) false).reverse ++ sh.log }) := by
  have hl := log_loop ctx p.region (loadOffset t r p.offset.toNat) false r hs (List.range t.bytes) sh hr
  have hno : ¬ p.offset < 0 := by omega
  have hok : ¬ (r.align % alignment t ≠ 0 ∨ loadOffset t r p.offset.toNat % alignment t ≠ 0 ∨
      r.size < loadOffset t r p.offset.toNat + t.bytes) := by omega
  simp only [loadOffset] at hl hok hd ⊢
  simp [loadAt, place, StateT.run_bind, StateT.run_get, hr, lift, hno, hok, hl, hd, -ne_eq]
  done
theorem storeAt_run (ctx : Ctx) (t : Ty) (p : Ptr) (r : Region) (sh : Shared) (v : Val) (bytes : List (BitVec 8))
    (hr : sh.regions p.region = some r) (hs : r.space ≠ .thread) (hc : r.space ≠ .constant) (ho : 0 ≤ p.offset)
    (ha : r.align % alignment t = 0) (hoa : p.offset.toNat % alignment t = 0) (hb : p.offset.toNat + t.bytes ≤ r.size)
    (he : encode t v = some bytes) :
    (storeAt ctx t p v).run sh = some ((), { sh with
      log := ((List.range t.bytes).map fun i => entry ctx sh p.region (p.offset.toNat + i) true).reverse ++ sh.log,
      bytes := fun region => if region = p.region then writeBytes (sh.bytes region) p.offset.toNat bytes
        else sh.bytes region }) := by
  have hl := log_loop ctx p.region p.offset.toNat true r hs (List.range t.bytes) sh hr
  have hno : ¬ p.offset < 0 := by omega
  have hok : ¬ (r.align % alignment t ≠ 0 ∨ p.offset.toNat % alignment t ≠ 0 ∨ r.size < p.offset.toNat + t.bytes) := by
    omega
  simp [storeAt, place, StateT.run_bind, StateT.run_get, hr, lift, hno, hok, hl, he, hc, -ne_eq,
    StateT.run_modify]
/-! ## Expressions -/

theorem eval_lit (ctx : Ctx) (locals : Nat → Option Val) (v : Val) (sh : Shared) :
    (eval C ctx locals (.lit v)).run sh = some (v, sh) := rfl

theorem eval_coord (ctx : Ctx) (locals : Nat → Option Val) (c : Coord) (sh : Shared) :
    (eval C ctx locals (.coord c)).run sh = some (ctx.coord c, sh) := rfl

theorem eval_local (ctx : Ctx) (locals : Nat → Option Val) (i : Nat) (v : Val) (h : locals i = some v) (sh : Shared) :
    (eval C ctx locals (.local i)).run sh = some (v, sh) := by
  show (lift (locals i)).run sh = _; rw [h]; rfl

theorem eval_load (ctx : Ctx) (locals : Nat → Option Val) (t : Ty) (p : CExpr) (q : Ptr) (sh sh' : Shared)
    (hp : (eval C ctx locals p).run sh = some (.ptr q, sh')) :
    (eval C ctx locals (.load t p)).run sh = (loadAt ctx t q).run sh' := by
  simp only [StateT.run] at hp ⊢
  simp [eval, bind, StateT.bind, Option.bind, hp]
theorem ordered_lt_compare (a b : Int) : ordered .lt (some (compare a b)) = some (decide (a < b)) := by
  rcases lt_trichotomy a b with h | h | h
  · simp [ordered, compare_eq_iff_eq, (compare_lt_iff_lt).mpr h, h]
  · subst h; simp [ordered]
  · have : ¬ a < b := not_lt.mpr h.le
    simp [ordered, (compare_gt_iff_gt).mpr h, this]

theorem ordered_eq_compare (a b : Int) : ordered .eq (some (compare a b)) = some (decide (a = b)) := by
  rcases lt_trichotomy a b with h | h | h
  · simp [ordered, (compare_lt_iff_lt).mpr h, h.ne]
  · subst h; simp [ordered]
  · simp [ordered, (compare_gt_iff_gt).mpr h, h.ne']
/-! ## SIMD-groups -/

theorem lift_some {α : Type} (a : α) : (lift (some a) : M α) = pure a := rfl

theorem mapM_ofFn {α β : Type} : ∀ {n : Nat} (T : Fin n → α) (f : α → Option β) (g : Fin n → β),
    (∀ i, f (T i) = some (g i)) → (List.ofFn T).mapM f = some (List.ofFn g)
  | 0, _, _, _, _ => rfl
  | n + 1, T, f, g, h => by
    rw [List.ofFn_succ, List.ofFn_succ, List.mapM_cons, h 0,
      mapM_ofFn (fun i => T i.succ) f (fun i => g i.succ) (fun i => h i.succ)]
    rfl

theorem getD_ofFn {α : Type} {n : Nat} (x : Fin n → α) (d : α) (i : Fin n) : (List.ofFn x).getD i.val d = x i := by
  simp [List.getD_eq_getElem?_getD, List.getElem?_ofFn]

theorem zip_replicate {α β : Type} {n : Nat} (T : Fin n → α) (v : β) :
    (List.ofFn T).zip (List.replicate n v) = List.ofFn fun i => (T i, v) := by
  apply List.ext_getElem <;> simp

/-- Lanes that all stop done or at a barrier end the SIMD-group's run. -/
theorem runSimd_blocked (fuel r : Nat) (lanes ls' : List Thread) (sh sh' : Shared)
    (hrun : (lanes.mapM (runThread C fuel)).run sh = some (ls', sh'))
    (hb : ∀ t ∈ ls', blocked t.status = true) :
    (runSimd C fuel (r + 1) lanes).run sh = some (ls', sh') := by
  have hall : ls'.all (blocked ·.status) = true := List.all_eq_true.mpr hb
  simp only [runSimd, StateT.run_bind, hrun]
  show Option.bind (some (ls', sh')) _ = _
  simp only [Option.bind_some]
  rw [if_pos hall]
  rfl

/-- Lanes that all stop at the same f32 `simd_sum` resume with the sum of their values. -/
theorem runSimd_sum (fuel r : Nat) (lanes : List Thread) (T : Fin 32 → Thread) (sh sh' : Shared)
    (site slot d : Nat) (x : Fin 32 → Float32)
    (hrun : (lanes.mapM (runThread C fuel)).run sh = some (List.ofFn T, sh'))
    (hst : ∀ i, (T i).status = .collective site slot .sum .f32 (.f32 (x i)) d) :
    (runSimd C fuel (r + 1) lanes).run sh = (runSimd C fuel r ((List.ofFn T).map fun t =>
      { t with status := .running }.set slot (.f32 (C.simdSum x)))).run sh' := by
  have hb : ¬ ((List.ofFn T).all (blocked ·.status) = true) := by
    simp only [List.all_eq_true, List.mem_ofFn, not_forall]
    exact ⟨T 0, ⟨0, rfl⟩, by simp [hst, blocked]⟩
  have hc : (List.ofFn T).map (collectiveOf ·.status) = some (site, .sum, .f32, d) :: List.replicate 31 (some (site, .sum, .f32, d)) := by
    rw [List.map_ofFn]
    apply List.ext_getElem <;> simp [hst, collectiveOf]
  have hv := mapM_ofFn T (fun t => valueOf t.status) (fun i => .f32 (x i)) (fun i => by simp [hst, valueOf])
  have hsum : (C.simdSum fun i => (List.ofFn x).getD i.val (FloatMemory.decode 0)) = C.simdSum x := by
    congr 1; funext i; exact getD_ofFn x _ i
  simp only [runSimd, StateT.run_bind, hrun]
  show Option.bind (some (_, sh')) _ = _
  simp only [Option.bind_some]
  rw [if_neg hb, hc]
  simp only [List.all_replicate, decide_true, Bool.true_eq_false, ite_true, ite_self]
  rw [hv]
  have hr : resolve C .sum .f32 d (List.ofFn fun i => Val.f32 (x i)) = some (List.replicate 32 (.f32 (C.simdSum x))) := by
    simp only [resolve, List.length_ofFn, ne_eq, not_true_eq_false, ite_false]
    rw [mapM_ofFn (fun i => Val.f32 (x i)) _ x (fun i => rfl)]
    simp only [Option.bind_eq_bind, Option.bind_some, hsum]
  simp only [lift_some, pure_bind]
  rw [hr]
  simp only [lift_some, pure_bind]
  rw [zip_replicate, mapM_ofFn (fun i => (T i, Val.f32 (C.simdSum x))) _
    (fun i => { T i with status := .running }.set slot (.f32 (C.simdSum x))) ?_, List.map_ofFn]
  · simp only [lift_some, pure_bind]
    rfl
  · intro i
    simp [hst, slotOf]
/-- Running a list of lanes in order threads the shared state through them. -/
theorem mapM_ofFn_run {α β : Type} : ∀ {n : Nat} (T : Fin n → α) (f : α → M β) (U : Fin n → β) (S : Nat → Shared),
    (∀ i : Fin n, (f (T i)).run (S i) = some (U i, S (i + 1))) →
    ((List.ofFn T).mapM f).run (S 0) = some (List.ofFn U, S n)
  | 0, _, _, _, _, _ => rfl
  | n + 1, T, f, U, S, h => by
    have ih := mapM_ofFn_run (fun i : Fin n => T i.succ) f (fun i => U i.succ) (fun j => S (j + 1))
      (fun i => by simpa [Nat.add_assoc] using h i.succ)
    rw [List.ofFn_succ, List.ofFn_succ, List.mapM_cons]
    simp only [StateT.run_bind] at ih ⊢
    rw [show (f (T 0)).run (S 0) = some (U 0, S 1) from h 0]
    simp only [Option.bind_eq_bind, Option.bind_some]
    rw [show S 1 = S (0 + 1) from rfl, ih]
    rfl
/-- Running a list in order preserves an invariant indexed by position. -/
theorem mapM_ofFn_inv {α β : Type} : ∀ {n : Nat} (T : Fin n → α) (f : α → M β) (I : Nat → Shared → Prop)
    (Q : β → Prop), (∀ i : Fin n, ∀ sh, I i sh → ∃ u sh', (f (T i)).run sh = some (u, sh') ∧ I (i + 1) sh' ∧ Q u) →
    ∀ sh, I 0 sh → ∃ us sh', ((List.ofFn T).mapM f).run sh = some (us, sh') ∧ I n sh' ∧ ∀ u ∈ us, Q u
  | 0, _, _, _, _, _, sh, h0 => ⟨[], sh, rfl, h0, by simp⟩
  | n + 1, T, f, I, Q, h, sh, h0 => by
    obtain ⟨u, sh1, hr, h1, hq⟩ := h 0 sh h0
    obtain ⟨us, sh', hr', hn, hqs⟩ := mapM_ofFn_inv (fun i : Fin n => T i.succ) f (fun j => I (j + 1)) Q
      (fun i sh hi => by simpa [Nat.add_assoc] using h i.succ sh hi) sh1 h1
    refine ⟨u :: us, sh', ?_, hn, ?_⟩
    · rw [List.ofFn_succ, List.mapM_cons]
      simp only [StateT.run_bind] at hr' ⊢
      rw [hr]
      simp only [Option.bind_eq_bind, Option.bind_some]
      rw [hr']
      rfl
    · intro v hv
      rcases List.mem_cons.mp hv with rfl | hv
      · exact hq
      · exact hqs v hv

/-- `forM` over `xs` in order preserves an invariant indexed by position. -/
theorem forM_inv {α : Type} (f : α → M Unit) (I : Nat → Shared → Prop) :
    ∀ (xs : List α) (k : Nat), (∀ i (hi : i < xs.length), ∀ sh, I (k + i) sh →
      ∃ sh', (f xs[i]).run sh = some ((), sh') ∧ I (k + i + 1) sh') →
    ∀ sh, I k sh → ∃ sh', (xs.forM f).run sh = some ((), sh') ∧ I (k + xs.length) sh'
  | [], k, _, sh, h0 => ⟨sh, rfl, by simpa using h0⟩
  | x :: xs, k, h, sh, h0 => by
    obtain ⟨sh1, hr, h1⟩ := h 0 (by simp) sh (by simpa using h0)
    obtain ⟨sh', hr', hn⟩ := forM_inv f I xs (k + 1) (fun i hi sh hi' => by
      have := h (i + 1) (by simp; omega) sh (by simpa [Nat.add_assoc, Nat.add_comm 1] using hi')
      simpa [Nat.add_assoc, Nat.add_comm 1] using this) sh1 h1
    refine ⟨sh', ?_, by simpa [Nat.add_assoc, Nat.add_comm 1] using hn⟩
    have hr0 : (f x).run sh = some ((), sh1) := hr
    show (f x >>= fun _ => xs.forM f).run sh = _
    rw [StateT.run_bind, hr0]
    exact hr'
end Metal
