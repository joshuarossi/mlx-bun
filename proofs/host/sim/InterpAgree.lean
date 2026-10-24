import host.ts.Machine
namespace Host.Ts.Sim
open Host.Ts

/-! # The interpreter changes agree with the previous interpreter

Each change of the JavaScript interpreter for the prompt bridges replaces an interpreter
failure (`.fail`), replaces a `ReferenceError`, or reorders the job queue only once a macrotask
is queued. The previous definitions are copied here (`…Old`); on every other input the new
definition is the previous one:

* `relIdx` concretizes a number reference (`relIdx_eq_old`; previously `.fail`);
* `Number(ptr)` returns the pointer (`number_eq_old`; previously `.fail`);
* `Number.isSafeInteger` of a number reference asks the server (`safe_eq_old`; previously `.fail`);
* reading an undefined global `setImmediate` yields a fresh native function
  (`readVar_eq_old`; previously a `ReferenceError`);
* `stepJobs` runs the first microtask, a macrotask only when none is queued
  (`stepJobs_eq_old`: with no macrotask queued it runs the head, as before).

A run the previous interpreter completed takes no `.fail` branch; so it differs only if it
reads an undefined `setImmediate` (and catches the `ReferenceError`), or queues a macrotask,
which needs the native `setImmediate` (new, `CtlN.setImmediate`) or a symbol with id
`symMacro`, which no value holds (`Symbol()` allocates ids from 16). -/

section
variable (F : Ffi)

/-! ## `relIdx` -/

/-- `relIdx` before the change. -/
def relIdxOld (n : Nat) (v : Val) (dflt : Nat) : M Nat :=
  match v with
  | .undef => .pure dflt
  | .num (.lit x) => match F64.truncInt x with
    | some (.ofNat i) => .pure (bif Nat.ble i n then i else n)
    | some (.negSucc i) => .pure (n - (i + 1))
    | none => .pure (bif F64.lt x (F64.zero false) then 0 else bif F64.isNaN x then 0 else n)
  | _ => .fail "relative index from a non-literal"

theorem relIdx_eq_old (n : Nat) (v : Val) (d : Nat) (h : ∀ i, v ≠ .num (.ref i)) :
    relIdx n v d = relIdxOld n v d := by
  cases v with
  | num x =>
    cases x with
    | lit _ => rfl
    | ref i => exact absurd rfl (h i)
  | _ => rfl

theorem relIdxOld_ref (n i d : Nat) : relIdxOld n (.num (.ref i)) d = .fail "relative index from a non-literal" :=
  rfl

/-! ## `Number` -/

/-- `Number(v)` before the change. -/
def numberOld (s : St F.S) (args : List Val) : RS F :=
  match args with
  | [] => retS F s (.num zeroN)
  | v :: _ => match v with
    | .big i => retS F s (intV i)
    | .ptr _ _ => .fail "Number of a pointer"
    | v => .bind (toNum v) fun
      | some x => retS F s (.num x)
      | none => .fail "Number of an object"

theorem number_eq_old (s : St F.S) (this : Val) (args : List Val) (h : ∀ m o, args.head? ≠ some (.ptr m o)) :
    numN F s this args .number = numberOld F s args := by
  cases args with
  | nil => rfl
  | cons v vs =>
    cases v with
    | ptr m o => exact absurd rfl (h m o)
    | _ => rfl

/-! ## `Number.isSafeInteger` -/

/-- `Number.isSafeInteger` before the change (`litTest isSafeInt`). -/
def safeOld (s : St F.S) (args : List Val) : RS F :=
  match arg args 0 with
  | .num (.lit x) => retS F s (.bool (isSafeInt x))
  | .num _ => .fail "number predicate of a symbolic number"
  | _ => retS F s (.bool false)

theorem safe_eq_old (s : St F.S) (this : Val) (args : List Val) (h : ∀ i, arg args 0 ≠ .num (.ref i)) :
    numN F s this args .isSafeInteger = safeOld F s args := by
  simp only [numN, numN.safeTest, safeOld]
  cases ha : arg args 0 with
  | num x =>
    cases x with
    | lit _ => rfl
    | ref i => exact absurd ha (h i)
  | _ => rfl

/-! ## Reading a variable -/

/-- `readVar` before the change. -/
def readVarOld (s : MS F) (n : Name) (env : Env) : RS F :=
  match lookupEnv n env with
  | some c => match s.cell? c with
    | some (some v) => retS F s v
    | some none => refErr s (chars!"cannot access '" ++ n ++ chars!"' before initialization")
    | none => .fail "variable cell"
  | none => .bind (getChain F s (.str n) 16 aGlobal) fun
    | some p => .pure (readProp F s (.obj aGlobal) (some p))
    | none => refErr s (n ++ chars!" is not defined")

theorem readVar_eq_old (s : MS F) (n : Name) (env : Env) (hn : nameEq n (chars!"setImmediate") = false) :
    readVar F s n env = readVarOld F s n env := by
  simp only [readVar, readVarOld, hn, Bool.cond_false]
  rfl

/-! ## The job queue -/

/-- `stepJobs` before the change: the head of the queue. -/
def stepJobsOld (s : MS F) (v : Val) : RS F :=
  match s.jobs with
  | j :: js => runJob F (s.setJobs js) j
  | [] => .pure (s.go (.halt (.normal v)))

theorem nextJob_noMacro : ∀ js : List Job, (∀ j ∈ js, j.isMacro = false) →
    nextJob js = match js with
      | j :: r => some (j, r)
      | [] => none
  | [], _ => rfl
  | j :: js, h => by simp only [nextJob, takeMicro, h j (List.mem_cons_self ..), Bool.cond_false]

theorem stepJobs_eq_old (s : MS F) (v : Val) (h : ∀ j ∈ s.jobs, j.isMacro = false) :
    stepJobs F s v = stepJobsOld F s v := by
  unfold stepJobs stepJobsOld
  rw [nextJob_noMacro _ h]
  cases hj : s.jobs <;> rfl

end

end Host.Ts.Sim
