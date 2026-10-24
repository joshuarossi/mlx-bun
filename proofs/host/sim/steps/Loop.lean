import host.sim.steps.Stmt
namespace Host.Ts.Sim

/-! # Loops: `for`, `for…of`, `while`, `do…while`, labels, optional-chain unwinding

`for (let …)` copies the iteration's cells into fresh ones (`nextIter`, one cell
per name: the count is a side condition). `for…of` over arrays, typed arrays and
strings reads elements by index (`elemAt`: an iterated array must be unframed, and
typed-array elements need `CellRead`); other iterables run the iterator protocol
through `getV`/`dataOf`. -/

namespace StmtSim
section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-! ## Cells of the next iteration -/

/-- A present address reads as a cell (or not) on both sides alike. -/
theorem cell_img (h : RelB F FR W stk M ν K s S t C) {a : Nat} (ha : Present s a) (hn : NoW K W s a) :
    t.cell? (M.a a) = (s.cell? a).map (Option.map M.val) := by
  obtain ⟨o, hg⟩ := ha.get
  cases o with
  | cell v => rw [h.cell? (cell?_iff.2 hg) hn, cell?_iff.2 hg]; rfl
  | obj o =>
    have hs : s.cell? a = none := by unfold St.cell?; rw [hg]
    rw [hs]
    obtain ⟨o', ht⟩ := h.obj_target hg
    unfold St.cell?
    rw [ht]
    rfl

/-- A cell binding of an unframed fresh cell keeps `CellNoW`. -/
theorem CellNoW.cons {m n : Name} {c : Nat} {env : Env} (hc : W c = none ∨ K.fr c = none)
    (h : CellNoW K W env n) : CellNoW K W ((m, c) :: env) n := by
  intro c' hl
  change brec (Nat.beq (pack n) (pack m)) (some c) (lookupEnv n env) = some c' at hl
  cases hb : Nat.beq (pack n) (pack m)
  · rw [hb] at hl; exact h c' hl
  · rw [hb] at hl
    have hl' : some c = some c' := hl
    cases hl'
    exact hc

theorem cellVal_img (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env}
    (he : Supp.env (Present s) S.tab.length env) (hcn : CellNoW K W env n) :
    cellVal? F t n (M.env env) = (cellVal? F s n env).map M.val := by
  unfold cellVal?
  rw [lookupEnv_map]
  cases hl : lookupEnv n env with
  | none => rfl
  | some c =>
    show (t.cell? (M.a c)).bind id = ((s.cell? c).bind id).map M.val
    rw [cell_img h (env_lookup_supp he hl) (.of_or (hcn c hl))]
    cases s.cell? c with
    | none => rfl
    | some w => cases w <;> rfl

theorem cellVal_supp' (h : RelB F FR W stk M ν K s S t C) {n : Name} {env : Env} {v : Val}
    (hv : cellVal? F s n env = some v) : Supp.val (Present s) S.tab.length v := by
  unfold cellVal? at hv
  cases hl : lookupEnv n env with
  | none => rw [hl] at hv; cases hv
  | some c =>
    rw [hl] at hv
    change (s.cell? c).bind id = some v at hv
    cases hc : s.cell? c with
    | none => rw [hc] at hv; cases hv
    | some x =>
      rw [hc] at hv
      cases x with
      | none => cases hv
      | some w =>
        cases hv
        exact h.cell?_supp hc

theorem copy_cons (s : St F.S) (n : Name) (ns : List Name) (env : Env) :
    copyIter F s (n :: ns) env =
      copyIter F (s.alloc (.cell (cellVal? F s n env))).2 ns ((n, s.next) :: env) := by
  cases hv : cellVal? F s n env <;> simp only [copyIter, hv] <;> rfl

/-- Copying the iteration's cells on both sides. -/
theorem copy_rel : ∀ (ns : List Name) {s t : St F.S} (_h : RelB F FR W stk M ν K s S t C) (env : Env),
    s.next + ns.length < Sim.bound → Supp.env (Present s) S.tab.length env → (∀ n ∈ ns, CellNoW K W env n) →
    (copyIter F t ns (M.env env)).1 = M.env (copyIter F s ns env).1 ∧
    RelB F FR W stk M ν K (copyIter F s ns env).2 S (copyIter F t ns (M.env env)).2 C ∧
    Supp.env (Present (copyIter F s ns env).2) S.tab.length (copyIter F s ns env).1 ∧
    (∀ a, Present s a → Present (copyIter F s ns env).2 a)
  | [], _, _, h, _, _, he, _ => ⟨rfl, h, he, fun _ hp => hp⟩
  | n :: ns, s, t, h, env, hn, he, hcn => by
    have hn0 : s.next < Sim.bound := by
      simp only [List.length_cons] at hn
      omega
    have h64 := lt64 h hn0
    have hP : ∀ a, Present s a → Present (s.alloc (.cell (cellVal? F s n env))).2 a :=
      fun _ hp => Present.alloc _ h64 hp
    have hcv : Supp.hobj (Present (s.alloc (.cell (cellVal? F s n env))).2) S.tab.length
        (.cell (cellVal? F s n env)) := by
      cases hv : cellVal? F s n env with
      | none => trivial
      | some v => exact Supp.val_mono (fun _ hp => Present.alloc _ h64 hp) (Nat.le_refl _) (cellVal_supp' h hv)
    obtain ⟨ha, h1⟩ := h.alloc (.cell (cellVal? F s n env)) hn0 hcv
    have hat : M.a s.next = t.next := by simpa using h.next 0
    have he1 : Supp.env (Present (s.alloc (.cell (cellVal? F s n env))).2) S.tab.length
        ((n, s.next) :: env) := by
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact Present.alloc_next s _ h64
      · exact hP _ (he x hx)
    have hn1 : (s.alloc (.cell (cellVal? F s n env))).2.next + ns.length < Sim.bound := by
      show s.next + 1 + ns.length < Sim.bound
      simp only [List.length_cons] at hn
      omega
    have hfr0 : K.fr s.next = none := by
      cases hf : K.fr s.next with
      | none => rfl
      | some p => exact absurd (h.presentBound _ (h.framedPresent _ _ hf)) (Nat.lt_irrefl _)
    obtain ⟨e, h2, he2, hP2⟩ := copy_rel ns h1 _ hn1 he1
      (fun n' hn' => CellNoW.cons (.inr hfr0) (hcn n' (List.mem_cons_of_mem _ hn')))
    have key : copyIter F t (n :: ns) (M.env env) =
        copyIter F (t.alloc (M.hobj (.cell (cellVal? F s n env)))).2 ns (M.env ((n, s.next) :: env)) := by
      rw [copy_cons, cellVal_img h he (hcn n (List.mem_cons_self ..))]
      show copyIter F (t.alloc (.cell ((cellVal? F s n env).map M.val))).2 ns ((n, t.next) :: M.env env) =
        copyIter F (t.alloc (.cell ((cellVal? F s n env).map M.val))).2 ns ((n, M.a s.next) :: M.env env)
      rw [hat]
    rw [key, copy_cons]
    exact ⟨e, h2, he2, fun a hp => hP2 a (hP a hp)⟩

theorem env_take_drop (M : Map) (l : Env) (i j : Nat) :
    M.env (l.take i ++ l.drop j) = (M.env l).take i ++ (M.env l).drop j := by
  simp only [Map.env, List.map_append, List.map_take, List.map_drop]

/-- The next iteration's environment of a `for (let …)` loop on both sides. -/
theorem next_rel (h : RelB F FR W stk M ν K s S t C) (names : List Name) (env : Env)
    (hn : s.next + names.length < Sim.bound) (he : Supp.env (Present s) S.tab.length env)
    (hcn : ∀ n ∈ names, CellNoW K W env n) :
    (nextIter F t names (M.env env)).1 = M.env (nextIter F s names env).1 ∧
    RelB F FR W stk M ν K (nextIter F s names env).2 S (nextIter F t names (M.env env)).2 C ∧
    Supp.env (Present (nextIter F s names env).2) S.tab.length (nextIter F s names env).1 ∧
    (∀ a, Present s a → Present (nextIter F s names env).2 a) := by
  obtain ⟨e, h1, he1, hP1⟩ := copy_rel names h env hn he hcn
  have es : nextIter F s names env = ((copyIter F s names env).1.take names.length ++
      (copyIter F s names env).1.drop (2 * names.length), (copyIter F s names env).2) := rfl
  have et : nextIter F t names (M.env env) = ((copyIter F t names (M.env env)).1.take names.length ++
      (copyIter F t names (M.env env)).1.drop (2 * names.length), (copyIter F t names (M.env env)).2) := rfl
  rw [es, et, e]
  refine ⟨(env_take_drop M _ _ _).symm, h1, ?_, hP1⟩
  intro x hx
  rcases List.mem_append.1 hx with hx | hx
  · exact he1 x (List.mem_of_mem_take hx)
  · exact he1 x (List.mem_of_mem_drop hx)

/-! ## Loop entry -/

theorem labels_rel : ∀ (labels : List Name) {s t : St F.S}, RelB F FR W stk M ν K s S t C →
    RelB F FR W stk M ν K (labels.foldl (fun s l => s.push (.s (.label l))) s) S
      (labels.foldl (fun s l => s.push (.s (.label l))) t) C ∧
      ∀ a, Present s a → Present (labels.foldl (fun s l => s.push (.s (.label l))) s) a
  | [], _, _, h => ⟨h, fun _ hp => hp⟩
  | l :: ls, _, _, h => labels_rel ls (h.push (.s (.label l)) trivial)

theorem forStart_sim (h : RelB F FR W stk M ν K s S t C) (init : Option ForHead) (test update : Option Expr)
    (body : Stmt) (env : Env) (labels : List Name) (he : Supp.env (Present s) S.tab.length env)
    (hn : s.next + margin < Sim.bound)
    (hsz : ∀ k ds, init = some (.decl k ds) → (declsNames ds).length ≤ 2 ^ 20) :
    MSim (StepPostB F FR W stk M ν K S C) S C (forStart F s init test update body env labels)
      (forStart F t init test update body (M.env env) labels) := by
  cases init with
  | none =>
    exact MSim.pure ⟨Grow.refl h.srv,
      (h.push (.lp (.forTest false test update body env [] labels)) he).ret .undef trivial⟩
  | some hd =>
    cases hd with
    | expr e =>
      exact MSim.pure ⟨Grow.refl h.srv,
        (h.push (.lp (.forTest false test update body env [] labels)) he).go (.ev e env) he⟩
    | decl kind ds =>
      have hn' := margin_bound hn (hsz kind ds rfl)
      obtain ⟨e, h1, he1, _⟩ := cells_rel (declsNames ds) h env hn' he
      cases kind
      case let_ =>
        have es : forStart F s (some (.decl .let_ ds)) test update body env labels =
            declNext F ((allocCells s (declsNames ds) env).2.push (.lp (.forTest true test update body
              (allocCells s (declsNames ds) env).1 (declsNames ds) labels))) .let_ ds
              (allocCells s (declsNames ds) env).1 := rfl
        have et : forStart F t (some (.decl .let_ ds)) test update body (M.env env) labels =
            declNext F ((allocCells t (declsNames ds) (M.env env)).2.push (.lp (.forTest true test update body
              (allocCells t (declsNames ds) (M.env env)).1 (declsNames ds) labels))) .let_ ds
              (allocCells t (declsNames ds) (M.env env)).1 := rfl
        rw [es, et, e]
        exact declNext_sim (h1.push (.lp (.forTest true test update body _ (declsNames ds) labels)) he1)
          .let_ ds _ he1
      case const =>
        have es : forStart F s (some (.decl .const ds)) test update body env labels =
            declNext F ((allocCells s (declsNames ds) env).2.push (.lp (.forTest true test update body
              (allocCells s (declsNames ds) env).1 (declsNames ds) labels))) .const ds
              (allocCells s (declsNames ds) env).1 := rfl
        have et : forStart F t (some (.decl .const ds)) test update body (M.env env) labels =
            declNext F ((allocCells t (declsNames ds) (M.env env)).2.push (.lp (.forTest true test update body
              (allocCells t (declsNames ds) (M.env env)).1 (declsNames ds) labels))) .const ds
              (allocCells t (declsNames ds) (M.env env)).1 := rfl
        rw [es, et, e]
        exact declNext_sim (h1.push (.lp (.forTest true test update body _ (declsNames ds) labels)) he1)
          .const ds _ he1
      all_goals exact MSim.fail _ _

/-- The cells a loop statement's `for (let …)` head allocates (through labels). -/
def loopDecls : Nat → Stmt → List Name
  | 0, _ => []
  | f + 1, st => match st with
    | .for_ (some (.decl _ ds)) _ _ _ => declsNames ds
    | .labeled _ st => loopDecls f st
    | _ => []

theorem exLoopF_sim : ∀ (fuel : Nat) (st : Stmt) (labels : List Name) {s t : St F.S}
    (_h : RelB F FR W stk M ν K s S t C) (env : Env),
    Supp.env (Present s) S.tab.length env → s.next + margin < Sim.bound → (loopDecls fuel st).length ≤ 2 ^ 20 →
    MSim (StepPostB F FR W stk M ν K S C) S C (exLoopF F s fuel st env labels) (exLoopF F t fuel st (M.env env) labels)
  | 0, _, _, _, _, _, _, _, _, _ => MSim.fail _ _
  | f + 1, st, labels, s, t, h, env, he, hn, hsz => by
    cases st
    case for_ init test update body =>
      exact forStart_sim h init test update body env labels he hn (fun k ds hk => by subst hk; exact hsz)
    case forOf aw kind p e body =>
      exact MSim.pure ⟨Grow.refl h.srv,
        (h.push (.lp (.forOfSrc aw kind p body env labels)) he).go (.ev e env) he⟩
    case while_ c body =>
      exact MSim.pure ⟨Grow.refl h.srv, (h.push (.lp (.whileTest c body env labels)) he).go (.ev c env) he⟩
    case doWhile body c =>
      exact MSim.pure ⟨Grow.refl h.srv, (h.push (.lp (.doBody body c env labels)) he).go (.ex body env) he⟩
    case labeled l st => exact exLoopF_sim f st (l :: labels) h env he hn hsz
    all_goals
      obtain ⟨h1, hP1⟩ := labels_rel labels h
      exact MSim.pure ⟨Grow.refl h.srv, h1.go (.ex _ env) (Supp.env_mono hP1 (Nat.le_refl _) he)⟩

/-! ## Iteration -/

theorem forTestStep_sim (h : RelB F FR W stk M ν K s S t C) (test update : Option Expr) (body : Stmt) (env : Env)
    (names labels : List Name) (he : Supp.env (Present s) S.tab.length env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (forTestStep F s test update body env names labels)
      (forTestStep F t test update body (M.env env) names labels) := by
  cases test with
  | some e =>
    exact MSim.pure ⟨Grow.refl h.srv,
      (h.push (.lp (.forBody (some e) update body env names labels)) he).go (.ev e env) he⟩
  | none =>
    exact MSim.pure ⟨Grow.refl h.srv,
      (h.push (.lp (.forUpd none update body env names labels)) he).go (.ex body env) he⟩

theorem forTest_sim (h : RelB F FR W stk M ν K s S t C) (copy : Bool) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) (v : Val) (he : Supp.env (Present s) S.tab.length env)
    (hn : s.next + margin < Sim.bound) (hsz : names.length ≤ 2 ^ 20) (hcn : ∀ n ∈ names, CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (retLp F s (.forTest copy test update body env names labels) v)
      (retLp F t (.forTest copy test update body (M.env env) names labels) (M.val v)) := by
  cases copy with
  | false => exact forTestStep_sim h test update body env names labels he
  | true =>
    obtain ⟨e, h1, he1, _⟩ := next_rel h names env (margin_bound hn hsz) he hcn
    have es : retLp F s (.forTest true test update body env names labels) v =
        forTestStep F (nextIter F s names env).2 test update body (nextIter F s names env).1 names labels := rfl
    have et : retLp F t (.forTest true test update body (M.env env) names labels) (M.val v) =
        forTestStep F (nextIter F t names (M.env env)).2 test update body (nextIter F t names (M.env env)).1
          names labels := rfl
    rw [es, et, e]
    exact forTestStep_sim h1 test update body _ names labels he1

theorem forUpd_sim (h : RelB F FR W stk M ν K s S t C) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) (v : Val) (he : Supp.env (Present s) S.tab.length env)
    (hn : s.next + margin < Sim.bound) (hsz : names.length ≤ 2 ^ 20) (hcn : ∀ n ∈ names, CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (retLp F s (.forUpd test update body env names labels) v)
      (retLp F t (.forUpd test update body (M.env env) names labels) (M.val v)) := by
  obtain ⟨e, h1, he1, _⟩ := next_rel h names env (margin_bound hn hsz) he hcn
  cases update with
  | none =>
    have es : retLp F s (.forUpd test none body env names labels) v =
        forTestStep F (nextIter F s names env).2 test none body (nextIter F s names env).1 names labels := rfl
    have et : retLp F t (.forUpd test none body (M.env env) names labels) (M.val v) =
        forTestStep F (nextIter F t names (M.env env)).2 test none body (nextIter F t names (M.env env)).1
          names labels := rfl
    rw [es, et, e]
    exact forTestStep_sim h1 test none body _ names labels he1
  | some u =>
    have es : retLp F s (.forUpd test (some u) body env names labels) v =
        Host.Ts.M.pure (((nextIter F s names env).2.push (.lp (.forTest false test (some u) body
          (nextIter F s names env).1 names labels))).go (.ev u (nextIter F s names env).1)) := rfl
    have et : retLp F t (.forUpd test (some u) body (M.env env) names labels) (M.val v) =
        Host.Ts.M.pure (((nextIter F t names (M.env env)).2.push (.lp (.forTest false test (some u) body
          (nextIter F t names (M.env env)).1 names labels))).go (.ev u (nextIter F t names (M.env env)).1)) := rfl
    rw [es, et, e]
    exact MSim.pure ⟨Grow.refl h.srv,
      (h1.push (.lp (.forTest false test (some u) body _ names labels)) he1).go (.ev u _) he1⟩

/-! ## `for…of` -/

/-- Index reads of `for…of`: an iterated array is unframed; typed-array elements are `CellRead`. -/
def IdxOK (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (v : Val) (i : Nat) : Prop :=
  ∀ a, v = .obj a → K.fr a = none ∧ ∀ o, s.obj? a = some o → ∀ k b off n, o.kind = .typed k b off n →
    i < n → ∀ bs, bufBytes F s b = some bs → CellRead K (Present s) S.tab.length k (bs.drop (off + i * k.size))

theorem elemAt_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (v : Val) (i : Nat)
    (hv : Supp.val (Present s) S.tab.length v) (hok : IdxOK F K s S v i) :
    MSim (ReadPost M S C (ValR M (Present s) S.tab.length)) S C (elemAt F s v i) (elemAt F t (M.val v) i) := by
  cases v with
  | obj a =>
    obtain ⟨hfr, hty⟩ := hok a rfl
    show MSim _ S C (elemAt F s (.obj a) i) (elemAt F t (.obj (M.a a)) i)
    simp only [elemAt]
    cases ho : s.obj? a with
    | none =>
      rw [h.obj?_none hv ho]
      exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
    | some o =>
      rw [h.obj? ho hfr]
      have hso := h.obj?_supp ho
      obtain ⟨k, pr, ps, pv, ex⟩ := o
      cases k
      case array es =>
        exact ReadPost.pure ⟨(nth?_map M.val es i), fun x hx => hso.1 x (nth?_mem hx)⟩
      case typed kk b off n =>
        refine read_bind (typedGet_sim h hF (hty _ ho kk b off n rfl)) ?_
        rintro r r' ⟨rfl, hsupp⟩
        rcases r with _ | ⟨x, w, e⟩ | ⟨g, st, e⟩
        · exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
        · exact ReadPost.pure ⟨rfl, fun _ hx => by cases hx; exact hsupp⟩
        · exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
      all_goals exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
  | str cs =>
    refine ReadPost.pure ⟨?_, fun x hx => ?_⟩
    · cases nth? cs i <;> rfl
    · obtain ⟨c, _, rfl⟩ := Option.map_eq_some_iff.1 hx
      trivial
  | undef => exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
  | null => exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
  | bool b => exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
  | num x => exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
  | big i => exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
  | sym i => exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩
  | ptr m off => exact ReadPost.pure ⟨rfl, fun _ hx => nomatch hx⟩

def idxKind : Kind → Bool
  | .array _ => true
  | .typed _ _ _ _ => true
  | _ => false

theorem isIndexable_obj (s : St F.S) (a : Nat) :
    isIndexable F s (.obj a) = ((s.obj? a).map fun o => idxKind o.kind).getD false := by
  simp only [isIndexable]
  cases s.obj? a with
  | none => rfl
  | some o =>
    obtain ⟨k, pr, ps, pv, ex⟩ := o
    cases k <;> rfl

/-- Whether a value is iterated by index is the same on both sides (framed objects are arrays). -/
theorem idx_img (h : RelB F FR W stk M ν K s S t C) {v : Val} (hv : Supp.val (Present s) S.tab.length v)
    (hnw : ∀ a o, v = .obj a → s.obj? a = some o → W a = none ∨ K.fr a = none) :
    isIndexable F t (M.val v) = isIndexable F s v := by
  cases v
  case obj a =>
    show isIndexable F t (.obj (M.a a)) = _
    rw [isIndexable_obj, isIndexable_obj]
    cases ho : s.obj? a with
    | none => rw [h.obj?_none hv ho]
    | some o =>
      cases hfr : K.fr a with
      | none =>
        rw [h.obj? ho hfr]
        obtain ⟨k, pr, ps, pv, ex⟩ := o
        cases k <;> rfl
      | some p =>
        obtain ⟨pre, pre'⟩ := p
        obtain ⟨o', ht, xs, hk, rfl⟩ := h.obj?_framed ho hfr (h.w_none (.of_or (hnw a o rfl ho)) hfr)
        rw [ht]
        show idxKind (Kind.array (pre' ++ M.vals xs)) = idxKind o.kind
        rw [hk]
        rfl
  all_goals rfl

theorem forOfBind_alloc (h : RelB F FR W stk M ν K s S t C) (aw : Bool) (k : DeclKind) (p : Pat) (body : Stmt)
    (env : Env) (labels : List Name) (src : IterSrc) (x : Val) (he : Supp.env (Present s) S.tab.length env)
    (hsrc : Supp.src (Present s) S.tab.length src) (hx : Supp.val (Present s) S.tab.length x)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20)
    (es : ∀ (y : St F.S) (e : Env) (sr : IterSrc) (w : Val),
      forOfStep.forOfBind F aw (some k) p body e labels y sr w =
        Host.Ts.M.pure ((((allocCells y (patNames p) e).2.push (.lp (.forOfBody sr aw (some k) p body e labels))).push
          (.s (.block [body] (allocCells y (patNames p) e).1))).go (.bind p w (allocCells y (patNames p) e).1 .init k))) :
    MSim (StepPostB F FR W stk M ν K S C) S C (forOfStep.forOfBind F aw (some k) p body env labels s src x)
      (forOfStep.forOfBind F aw (some k) p body (M.env env) labels t (M.src src) (M.val x)) := by
  rw [es, es]
  obtain ⟨e, h1, he1, hP1⟩ := cells_rel (patNames p) h env (margin_bound hn hsz) he
  rw [e]
  have hle := Nat.le_refl S.tab.length
  exact MSim.pure ⟨Grow.refl h.srv, ((h1.push (.lp (.forOfBody src aw (some k) p body env labels))
    ⟨Supp.src_mono hP1 hle hsrc, Supp.env_mono hP1 hle he⟩).push (.s (.block [body] _)) he1).go
    (.bind p x _ .init k) ⟨Supp.val_mono hP1 hle hx, he1⟩⟩

theorem forOfBind_sim (h : RelB F FR W stk M ν K s S t C) (aw : Bool) (kind : Option DeclKind) (p : Pat) (body : Stmt)
    (env : Env) (labels : List Name) (src : IterSrc) (x : Val) (he : Supp.env (Present s) S.tab.length env)
    (hsrc : Supp.src (Present s) S.tab.length src) (hx : Supp.val (Present s) S.tab.length x)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20) :
    MSim (StepPostB F FR W stk M ν K S C) S C (forOfStep.forOfBind F aw kind p body env labels s src x)
      (forOfStep.forOfBind F aw kind p body (M.env env) labels t (M.src src) (M.val x)) := by
  cases kind with
  | none =>
    exact MSim.pure ⟨Grow.refl h.srv, ((h.push (.lp (.forOfBody src aw none p body env labels)) ⟨hsrc, he⟩).push
      (.s (.block [body] env)) he).go (.bind p x env .assign .let_) ⟨hx, he⟩⟩
  | some k =>
    cases k
    case «using» => exact MSim.fail _ _
    all_goals exact forOfBind_alloc h aw _ p body env labels src x he hsrc hx hn hsz (fun _ _ _ _ => rfl)

theorem forOfStep_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (src : IterSrc) (aw : Bool)
    (kind : Option DeclKind) (p : Pat) (body : Stmt) (env : Env) (labels : List Name)
    (he : Supp.env (Present s) S.tab.length env) (hsrc : Supp.src (Present s) S.tab.length src)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20)
    (hok : ∀ v i, src = .index v i → IdxOK F K s S v i) :
    MSim (StepPostB F FR W stk M ν K S C) S C (forOfStep F s src aw kind p body env labels)
      (forOfStep F t (M.src src) aw kind p body (M.env env) labels) := by
  cases src with
  | index v i =>
    show MSim _ S C (Host.Ts.M.bind (elemAt F s v i) _) (Host.Ts.M.bind (elemAt F t (M.val v) i) _)
    refine read_step (elemAt_sim h hF v i hsrc (hok v i rfl)) ?_
    rintro r r' ⟨rfl, hsupp⟩
    cases r with
    | none => exact MSim.pure ⟨Grow.refl h.srv, h.ret .undef trivial⟩
    | some x => exact forOfBind_sim h aw kind p body env labels (.index v (i + 1)) x he hsrc (hsupp x rfl) hn hsz
  | proto it nx =>
    cases aw
    · exact MSim.pure ⟨Grow.refl h.srv, (h.push (.lp (.forOfNext it nx false kind p body env labels))
        ⟨hsrc.1, hsrc.2, he⟩).go (.call nx it []) ⟨hsrc.2, hsrc.1, fun _ hx => nomatch hx⟩⟩
    · exact MSim.pure ⟨Grow.refl h.srv, ((h.push (.lp (.forOfNext it nx true kind p body env labels))
        ⟨hsrc.1, hsrc.2, he⟩).push (.k .await) trivial).go (.call nx it []) ⟨hsrc.2, hsrc.1, fun _ hx => nomatch hx⟩⟩

theorem keyEq_sym_str (i : Nat) (cs : List Char) : keyEq (.sym i) (.str cs) = false := by
  unfold keyEq PKey.code
  cases hb : Nat.beq (Nat.succ (Nat.mul 2 i)) (Nat.mul 2 (pack cs))
  · rfl
  · have e : Nat.succ (2 * i) = 2 * pack cs := Nat.eq_of_beq_eq_true hb
    omega

theorem symKey (M : Map) {i : Nat} (hi : i < 16) : M.key (.sym i) = .sym i := by
  show PKey.sym (M.sym i) = _
  rw [Map.sym_lt M hi]

/-- `v[Symbol.iterator]()` / `v[Symbol.asyncIterator]()` on an object, after pushing `f`. -/
theorem iterGet_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (f : Frame) (a : Nat)
    (i : Nat) (hi : i < 16) (hf : Supp.frame (Present s) S.tab.length f) (ha : Present s a)
    (hn : s.next < Sim.bound) (hP : Present s aTypeErrorProto) (hnw : ChainNoW K W s 16 a) :
    MSim (StepPostB F FR W stk M ν K S C) S C
      (getV F ((s.push f).push (.c (.method (.obj a) [] [] false))) (.obj a) (.sym i))
      (getV F ((t.push (M.frame f)).push (.c (.method (.obj (M.a a)) [] [] false))) (.obj (M.a a)) (.sym i)) := by
  have := getV_sim ((h.push f hf).push (.c (.method (.obj a) [] [] false)) ⟨ha, fun _ hx => nomatch hx⟩) hF
    h.intr hn hP (recv := .obj a) (k := .sym i) ha (fun h16 => absurd h16 (by omega))
    (LookupOK.of_noW rfl (keyEq_sym_str i _) (recv := .obj a) (ChainNoW.congr (fun _ => rfl) 16 a hnw))
  rw [symKey M hi] at this
  exact this

theorem forOfSrc_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (aw : Bool)
    (kind : Option DeclKind) (p : Pat) (body : Stmt) (env : Env) (labels : List Name) (v : Val)
    (he : Supp.env (Present s) S.tab.length env) (hv : Supp.val (Present s) S.tab.length v)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20)
    (hP : Present s aTypeErrorProto) (hidx : isIndexable F s v = true → IdxOK F K s S v 0)
    (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (retLp F s (.forOfSrc aw kind p body env labels) v)
      (retLp F t (.forOfSrc aw kind p body (M.env env) labels) (M.val v)) := by
  have hn0 := lt_of_margin hn
  cases aw with
  | true =>
    cases v
    case obj a => exact iterGet_sim h hF (.lp (.forOfIt true kind p body env labels)) a 1 (by decide) he hv hn0 hP hnw
    all_goals exact typeErr_sim h h.intr hn0 hP _
  | false =>
    show MSim _ S C (bif isIndexable F s v then _ else _) (bif isIndexable F t (M.val v) then _ else _)
    rw [idx_img h hv (fun a o he ho => by subst he; exact (hnw o ho).1)]
    cases hi : isIndexable F s v with
    | true =>
      exact forOfStep_sim h hF (.index v 0) false kind p body env labels he hv hn hsz
        (fun v' i' heq => by cases heq; exact hidx hi)
    | false =>
      cases v
      case obj a => exact iterGet_sim h hF (.lp (.forOfIt false kind p body env labels)) a 0 (by decide) he hv hn0 hP hnw
      all_goals exact typeErr_sim h h.intr hn0 hP _

theorem forOfIt_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (aw : Bool)
    (kind : Option DeclKind) (p : Pat) (body : Stmt) (env : Env) (labels : List Name) (v : Val)
    (he : Supp.env (Present s) S.tab.length env) (hv : Supp.val (Present s) S.tab.length v)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20) (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (retLp F s (.forOfIt aw kind p body env labels) v)
      (retLp F t (.forOfIt aw kind p body (M.env env) labels) (M.val v)) := by
  show MSim _ S C (Host.Ts.M.bind (dataOf F s v kNext) _) (Host.Ts.M.bind (dataOf F t (M.val v) kNext) _)
  refine read_step (dataOf_sim h hF h.intr hv (k := kNext) trivial (LookupOK.of_noW rfl rfl hnw)) ?_
  rintro r r' ⟨rfl, hsupp⟩
  cases r with
  | none => exact MSim.fail _ _
  | some nx =>
    exact forOfStep_sim h hF (.proto v nx) aw kind p body env labels he ⟨hv, hsupp nx rfl⟩ hn hsz
      (fun _ _ he => nomatch he)

/-- The iterator's `next()` result: `done` (its truthiness; bigints keep zeroness under the
map, `hz`), then `value`. -/
theorem forOfNext_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (it nx : Val) (aw : Bool) (kind : Option DeclKind) (p : Pat) (body : Stmt) (env : Env)
    (labels : List Name) (v : Val) (he : Supp.env (Present s) S.tab.length env)
    (hit : Supp.val (Present s) S.tab.length it) (hnx : Supp.val (Present s) S.tab.length nx)
    (hv : Supp.val (Present s) S.tab.length v) (hn : s.next + margin < Sim.bound)
    (hsz : (patNames p).length ≤ 2 ^ 20) (hz : ∀ i, (M.big i == 0) = (i == 0)) (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (retLp F s (.forOfNext it nx aw kind p body env labels) v)
      (retLp F t (.forOfNext (M.val it) (M.val nx) aw kind p body (M.env env) labels) (M.val v)) := by
  show MSim _ S C (Host.Ts.M.bind (dataOf F s v kDone) _) (Host.Ts.M.bind (dataOf F t (M.val v) kDone) _)
  refine read_step (dataOf_sim h hF h.intr hv (k := kDone) trivial (LookupOK.of_noW rfl rfl hnw)) ?_
  rintro d d' ⟨rfl, hd⟩
  have hdv : (d.map M.val).getD .undef = M.val (d.getD .undef) := by cases d <;> rfl
  show MSim _ S C (Host.Ts.M.bind (truthy (d.getD .undef)) _) (Host.Ts.M.bind (truthy ((d.map M.val).getD .undef)) _)
  rw [hdv]
  refine truthy_step h hFR _ (fun i _ => hz i) (fun b M' S' C' hg hr' => ?_)
  have hA : Agree (Present s) S.tab.length M M' := hg.ext.agree
  have hle := hg.len
  cases b with
  | true => exact MSim.pure ⟨Grow.refl hr'.srv, hr'.ret .undef trivial⟩
  | false =>
    have hv' := Supp.val_mono (fun _ hp => hp) hle hv
    have hd2 := dataOf_sim hr' hF hr'.intr hv' (k := kValue) trivial (LookupOK.of_noW rfl rfl hnw)
    rw [← Map.val_agree hA hv] at hd2
    show MSim _ S' C' (Host.Ts.M.bind (dataOf F s v kValue) _) (Host.Ts.M.bind (dataOf F t (M.val v) kValue) _)
    refine read_step hd2 ?_
    rintro r r' ⟨rfl, hsupp⟩
    cases r with
    | none => exact MSim.fail _ _
    | some x =>
      have hsrc : Supp.src (Present s) S.tab.length (.proto it nx) := ⟨hit, hnx⟩
      have := forOfBind_sim hr' aw kind p body env labels (.proto it nx) x he
        (Supp.src_mono (fun _ hp => hp) hle hsrc) (hsupp x rfl) hn hsz
      rw [← Map.env_agree hA he, ← Map.src_agree hA hsrc] at this
      exact this

/-- `IteratorClose`: call `return()` if the iterator has one. -/
theorem closeIter_sim (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (src : IterSrc) (aw : Bool)
    (c : Comp) (hsrc : Supp.src (Present s) S.tab.length src) (hc : Supp.comp (Present s) S.tab.length c)
    (hnw : ∀ it nx, src = .proto it nx → LookupNoW F K W s it) :
    MSim (StepPostB F FR W stk M ν K S C) S C (closeIter F s src aw c) (closeIter F t (M.src src) aw (M.comp c)) := by
  cases src with
  | index v i => exact MSim.pure ⟨Grow.refl h.srv, resume_rel h c hc⟩
  | proto it nx =>
    show MSim _ S C (Host.Ts.M.bind (dataOf F s it kReturn) _) (Host.Ts.M.bind (dataOf F t (M.val it) kReturn) _)
    refine read_step (dataOf_sim h hF h.intr hsrc.1 (k := kReturn) trivial (LookupOK.of_noW rfl rfl (hnw it nx rfl))) ?_
    rintro r r' ⟨rfl, hsupp⟩
    rcases r with _ | ⟨_ | _ | _ | _ | _ | _ | _ | a | _⟩
    case obj =>
      have hm : Supp.val (Present s) S.tab.length (.obj a) := hsupp _ rfl
      cases aw
      · exact MSim.pure ⟨Grow.refl h.srv, (h.push (.lp (.close c)) hc).go (.call (.obj a) it [])
          ⟨hm, hsrc.1, fun _ hx => nomatch hx⟩⟩
      · exact MSim.pure ⟨Grow.refl h.srv, ((h.push (.lp (.close c)) hc).push (.k .await) trivial).go
          (.call (.obj a) it []) ⟨hm, hsrc.1, fun _ hx => nomatch hx⟩⟩
    all_goals exact MSim.pure ⟨Grow.refl h.srv, resume_rel h c hc⟩

end
end StmtSim

open StmtSim

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-! ## Loop statements -/

theorem step_ex_for (h : RelB F FR W stk M ν K s S t C) {init : Option ForHead} {test update : Option Expr}
    {body : Stmt} {env : Env} (hc : s.ctl = .ex (.for_ init test update body) env)
    (hn : s.next + margin < Sim.bound)
    (hsz : ∀ k ds, init = some (.decl k ds) → (declsNames ds).length ≤ 2 ^ 20) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  exact forStart_sim h init test update body env [] he hn hsz

theorem step_ex_forOf (h : RelB F FR W stk M ν K s S t C) {aw : Bool} {kind : Option DeclKind} {p : Pat} {e : Expr}
    {body : Stmt} {env : Env} (hc : s.ctl = .ex (.forOf aw kind p e body) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, (h.push (.lp (.forOfSrc aw kind p body env [])) he).go (.ev e env) he⟩

theorem step_ex_while (h : RelB F FR W stk M ν K s S t C) {c : Expr} {body : Stmt} {env : Env}
    (hc : s.ctl = .ex (.while_ c body) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, (h.push (.lp (.whileTest c body env [])) he).go (.ev c env) he⟩

theorem step_ex_doWhile (h : RelB F FR W stk M ν K s S t C) {c : Expr} {body : Stmt} {env : Env}
    (hc : s.ctl = .ex (.doWhile body c) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, (h.push (.lp (.doBody body c env [])) he).go (.ex body env) he⟩

theorem step_ex_labeled (h : RelB F FR W stk M ν K s S t C) {l : Name} {st : Stmt} {env : Env}
    (hc : s.ctl = .ex (.labeled l st) env) (hn : s.next + margin < Sim.bound)
    (hsz : (loopDecls 8 st).length ≤ 2 ^ 20) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, he⟩ := exTop h hc
  rw [e1, e2]
  exact exLoopF_sim 8 st [l] h env he hn hsz

theorem step_ex_forIn (h : RelB F FR W stk M ν K s S t C) {kind : Option DeclKind} {p : Pat} {e : Expr} {body : Stmt}
    {env : Env} (hc : s.ctl = .ex (.forIn kind p e body) env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, _⟩ := exTop h hc
  rw [e1, e2]
  exact MSim.fail _ _

/-! ## Values returning to loop frames -/

theorem step_ret_forTest (h : RelB F FR W stk M ν K s S t C) {v : Val} {copy : Bool} {test update : Option Expr}
    {body : Stmt} {env : Env} {names labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.forTest copy test update body env names labels) :: fs)
    (hn : s.next + margin < Sim.bound) (hsz : names.length ≤ 2 ^ 20) (hcn : ∀ n ∈ names, CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact forTest_sim hr copy test update body env names labels v hf hn hsz hcn

theorem step_ret_forBody (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {v : Val} {test update : Option Expr}
    {body : Stmt} {env : Env} {names labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.forBody test update body env names labels) :: fs)
    (hb : ∀ i, v = .big i → BigFixed K.lo K.hi i) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  refine truthy_step hr hFR v (fixed_zero h hb) (fun b M' S' C' hg hr' => ?_)
  cases b with
  | true => exact MSim.pure ⟨Grow.refl hr'.srv, go' (push' hr' hg.ext hg.len
      (.lp (.forUpd test update body env names labels)) hf) hg.ext hg.len (.ex body env) hf⟩
  | false => exact MSim.pure ⟨Grow.refl hr'.srv, hr'.ret .undef trivial⟩

theorem step_ret_forUpd (h : RelB F FR W stk M ν K s S t C) {v : Val} {test update : Option Expr}
    {body : Stmt} {env : Env} {names labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.forUpd test update body env names labels) :: fs)
    (hn : s.next + margin < Sim.bound) (hsz : names.length ≤ 2 ^ 20) (hcn : ∀ n ∈ names, CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact forUpd_sim hr test update body env names labels v hf hn hsz hcn

theorem step_ret_whileTest (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR) {v : Val} {c : Expr} {body : Stmt}
    {env : Env} {labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.whileTest c body env labels) :: fs)
    (hb : ∀ i, v = .big i → BigFixed K.lo K.hi i) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  refine truthy_step hr hFR v (fixed_zero h hb) (fun b M' S' C' hg hr' => ?_)
  cases b with
  | true => exact MSim.pure ⟨Grow.refl hr'.srv, go' (push' hr' hg.ext hg.len
      (.lp (.whileBody c body env labels)) hf) hg.ext hg.len (.ex body env) hf⟩
  | false => exact MSim.pure ⟨Grow.refl hr'.srv, hr'.ret .undef trivial⟩

theorem step_ret_whileBody (h : RelB F FR W stk M ν K s S t C) {v : Val} {c : Expr} {body : Stmt}
    {env : Env} {labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.whileBody c body env labels) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.lp (.whileTest c body env labels)) hf).go (.ev c env) hf⟩

theorem step_ret_doBody (h : RelB F FR W stk M ν K s S t C) {v : Val} {c : Expr} {body : Stmt}
    {env : Env} {labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.doBody body c env labels) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.lp (.whileTest c body env labels)) hf).go (.ev c env) hf⟩

theorem step_ret_close (h : RelB F FR W stk M ν K s S t C) {v : Val} {c : Comp} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .lp (.close c) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, resume_rel hr c hf⟩

/-- The next element of a `for…of`: by index (arrays unframed, typed-array cells
readable: `hok`), or the iterator's `next()`. -/
theorem step_ret_forOfBody (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {v : Val}
    {src : IterSrc} {aw : Bool} {kind : Option DeclKind} {p : Pat} {body : Stmt} {env : Env}
    {labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.forOfBody src aw kind p body env labels) :: fs)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20)
    (hok : ∀ x i, src = .index x i → IdxOK F K s S x i) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, _, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact forOfStep_sim hr hF src aw kind p body env labels hf.2 hf.1 hn hsz hok

/-- The iterated value of a `for…of`: arrays, typed arrays and strings by index, other
objects through `[Symbol.iterator]()` (`[Symbol.asyncIterator]()` for `for await`). -/
theorem step_ret_forOfSrc (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {v : Val}
    {aw : Bool} {kind : Option DeclKind} {p : Pat} {body : Stmt} {env : Env}
    {labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.forOfSrc aw kind p body env labels) :: fs)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20)
    (hP : Present s aTypeErrorProto) (hidx : isIndexable F s v = true → IdxOK F K s S v 0)
    (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact forOfSrc_sim hr hF aw kind p body env labels v hf hv hn hsz hP hidx (LookupNoW.congr (fun _ => rfl) hnw)

theorem step_ret_forOfIt (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {v : Val}
    {aw : Bool} {kind : Option DeclKind} {p : Pat} {body : Stmt} {env : Env}
    {labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.forOfIt aw kind p body env labels) :: fs)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20) (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact forOfIt_sim hr hF aw kind p body env labels v hf hv hn hsz (LookupNoW.congr (fun _ => rfl) hnw)

/-- An iterator result. `hz`: the map keeps bigints' zeroness (the `done` value's truthiness). -/
theorem step_ret_forOfNext (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    {v it nx : Val} {aw : Bool} {kind : Option DeclKind} {p : Pat} {body : Stmt} {env : Env}
    {labels : List Name} {fs : List Frame} (hc : s.ctl = .ret v)
    (hs : s.stack = .lp (.forOfNext it nx aw kind p body env labels) :: fs)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20)
    (hz : ∀ i, (M.big i == 0) = (i == 0)) (hnw : LookupNoW F K W s v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, hv, hf⟩ := retTop h hc hs
  rw [e1, e2]
  exact forOfNext_sim hr hF hFR it nx aw kind p body env labels v hf.2.2 hf.1 hf.2.1 hv hn hsz hz
    (LookupNoW.congr (fun _ => rfl) hnw)

/-! ## Abrupt completions reaching loop frames -/

theorem step_abr_forUpd (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {test update : Option Expr}
    {body : Stmt} {env : Env} {names labels : List Name} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .lp (.forUpd test update body env names labels) :: fs)
    (hn : s.next + margin < Sim.bound) (hsz : names.length ≤ 2 ^ 20) (hcn : ∀ n ∈ names, CellNoW K W env n) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, hf⟩ := abrTop h hc hs
  rw [e1, e2]
  cases a with
  | cont l =>
    show MSim _ S C (bif matchLabel l labels then _ else _) (bif matchLabel l labels then _ else _)
    cases matchLabel l labels
    · exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.cont l)) trivial⟩
    · exact forUpd_sim hr test update body env names labels .undef hf hn hsz hcn
  | brk l =>
    show MSim _ S C (bif matchLabel l labels then _ else _) (bif matchLabel l labels then _ else _)
    cases matchLabel l labels
    · exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.brk l)) trivial⟩
    · exact MSim.pure ⟨Grow.refl h.srv, hr.ret .undef trivial⟩
  | throw e => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.throw e)) ha⟩
  | ret v => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.ret v)) ha⟩

theorem step_abr_whileBody (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {c : Expr} {body : Stmt}
    {env : Env} {labels : List Name} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .lp (.whileBody c body env labels) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, hf⟩ := abrTop h hc hs
  rw [e1, e2]
  cases a with
  | cont l =>
    show MSim _ S C (bif matchLabel l labels then _ else _) (bif matchLabel l labels then _ else _)
    cases matchLabel l labels
    · exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.cont l)) trivial⟩
    · exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.lp (.whileTest c body env labels)) hf).go (.ev c env) hf⟩
  | brk l =>
    show MSim _ S C (bif matchLabel l labels then _ else _) (bif matchLabel l labels then _ else _)
    cases matchLabel l labels
    · exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.brk l)) trivial⟩
    · exact MSim.pure ⟨Grow.refl h.srv, hr.ret .undef trivial⟩
  | throw e => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.throw e)) ha⟩
  | ret v => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.ret v)) ha⟩

theorem step_abr_doBody (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {c : Expr} {body : Stmt}
    {env : Env} {labels : List Name} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .lp (.doBody body c env labels) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, hf⟩ := abrTop h hc hs
  rw [e1, e2]
  cases a with
  | cont l =>
    show MSim _ S C (bif matchLabel l labels then _ else _) (bif matchLabel l labels then _ else _)
    cases matchLabel l labels
    · exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.cont l)) trivial⟩
    · exact MSim.pure ⟨Grow.refl h.srv, (hr.push (.lp (.whileTest c body env labels)) hf).go (.ev c env) hf⟩
  | brk l =>
    show MSim _ S C (bif matchLabel l labels then _ else _) (bif matchLabel l labels then _ else _)
    cases matchLabel l labels
    · exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.brk l)) trivial⟩
    · exact MSim.pure ⟨Grow.refl h.srv, hr.ret .undef trivial⟩
  | throw e => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.throw e)) ha⟩
  | ret v => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.ret v)) ha⟩

/-- Leaving a `for…of` body abruptly: `continue` moves on, anything else closes the iterator. -/
theorem step_abr_forOfBody (h : RelB F FR W stk M ν K s S t C) (hF : FfiSim F FR okCall okBack) {a : Abrupt}
    {src : IterSrc} {aw : Bool} {kind : Option DeclKind} {p : Pat} {body : Stmt} {env : Env}
    {labels : List Name} {fs : List Frame} (hc : s.ctl = .abr a)
    (hs : s.stack = .lp (.forOfBody src aw kind p body env labels) :: fs)
    (hn : s.next + margin < Sim.bound) (hsz : (patNames p).length ≤ 2 ^ 20)
    (hok : ∀ x i, src = .index x i → IdxOK F K s S x i)
    (hnw : ∀ it nx, src = .proto it nx → LookupNoW F K W s it) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, hf⟩ := abrTop h hc hs
  rw [e1, e2]
  have hnw' := fun it nx he => LookupNoW.congr (s' := { s with stack := fs }) (fun _ => rfl) (hnw it nx he)
  cases a with
  | cont l =>
    show MSim _ S C (bif matchLabel l labels then _ else _) (bif matchLabel l labels then _ else _)
    cases matchLabel l labels
    · exact closeIter_sim hr hF src aw (.abrupt (.cont l)) hf.1 trivial hnw'
    · exact forOfStep_sim hr hF src aw kind p body env labels hf.2 hf.1 hn hsz hok
  | brk l =>
    show MSim _ S C (bif matchLabel l labels then _ else _) (bif matchLabel l labels then _ else _)
    cases matchLabel l labels
    · exact closeIter_sim hr hF src aw (.abrupt (.brk l)) hf.1 trivial hnw'
    · exact closeIter_sim hr hF src aw (.normal .undef) hf.1 trivial hnw'
  | throw e => exact closeIter_sim hr hF src aw (.abrupt (.throw e)) hf.1 ha hnw'
  | ret v => exact closeIter_sim hr hF src aw (.abrupt (.ret v)) hf.1 ha hnw'

/-- An abrupt completion of `return()` during a close: a saved throw wins. -/
theorem step_abr_close (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {c : Comp} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .lp (.close c) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, hf⟩ := abrTop h hc hs
  rw [e1, e2]
  cases c with
  | normal w => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩
  | abrupt b =>
    cases b with
    | throw e => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr (.throw e)) hf⟩
    | ret w => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩
    | brk l => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩
    | cont l => exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩

/-- Loop frames that let abrupt completions through (`forTest`, `forBody`, `whileTest`,
`forOfSrc`, `forOfIt`, `forOfNext`). -/
def lpPass : LoopF → Bool
  | .forTest .. | .forBody .. | .whileTest .. | .forOfSrc .. | .forOfIt .. | .forOfNext .. => true
  | _ => false

theorem step_abr_lp_pass (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {f : LoopF} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .lp f :: fs) (hf : lpPass f = true) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr, ha, _⟩ := abrTop h hc hs
  rw [e1, e2]
  cases f <;> first
    | exact MSim.pure ⟨Grow.refl h.srv, hr.go (.abr a) ha⟩
    | cases hf
/-! ## Optional-chain unwinding -/

theorem step_short (h : RelB F FR W stk M ν K s S t C) (hc : s.ctl = .short) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  have htc : t.ctl = .short := by rw [h.ctl, hc]; rfl
  have e1 : step F s = shortStep F s := by simp only [step, hc]
  have e2 : step F t = shortStep F t := by simp only [step, htc]
  rw [e1, e2]
  unfold shortStep
  rw [h.stack]
  cases hs : s.stack with
  | nil => exact MSim.fail _ _
  | cons f fs =>
    obtain ⟨-, hr⟩ := h.pop hs
    cases f
    case e g =>
      cases g
      case chain => exact MSim.pure ⟨Grow.refl h.srv, hr.ret .undef trivial⟩
      all_goals exact MSim.pure ⟨Grow.refl h.srv, hr.go .short trivial⟩
    all_goals exact MSim.pure ⟨Grow.refl h.srv, hr.go .short trivial⟩

end

end Host.Ts.Sim
