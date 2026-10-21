import host.sim.steps.Buf
import host.sim.FfiCall
namespace Host.Ts.Sim

/-! # The JavaScript side of `bun:ffi`

`ptr`, `read.u64`/`read.u32`, `toArrayBuffer` and calls of `dlopen` symbols
(`ffiN .symbol`: argument decoding, `F.call`, buffer writes, the trace event and
the return value). Helpers are in `BufSim` (see `Buf.lean`).

A native call's arguments and results are computed by the source run, so the side
conditions about them (`okCall`, closedness of results) are stated about the source
run (`interpS … .run`); `MSim.withRun` brings the run into the simulation, which
needs the native calls to be `Lawful` (`FfiLawful`). -/

namespace BufSim

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool}
  {okBack : F.S → Arg → Bool}

/-! ## `ptr` -/

theorem isEmpty_map {α β : Type} (f : α → β) (l : List α) : (l.map f).isEmpty = l.isEmpty := by
  cases l <;> rfl

/-- `ptr(view, extra)`: a pointer into the view's buffer (JS or native memory). -/
theorem _root_.Host.Ts.Sim.step_ffi_ptr (h : Rel F FR M ν K s S t C) {a : Nat} {this : Val}
    {args : List Val} {o : Obj} {data : List Val} (hc : s.ctl = .call (.obj a) this args)
    (ho : s.obj? a = some o) (hk : o.kind = .fn (.native (.ffi .ptr) data)) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  show MSim _ S C (ffiN F s this args data .ptr) (ffiN F t (M.val this) (M.vals args) (M.vals data) .ptr)
  simp only [ffiN, arg_vals]
  have hs0 := arg_supp (call_supp h hc).2 0
  cases harg : arg args 0 with
  | obj p =>
    rw [harg] at hs0
    refine offsetArg_msim M _ fun extra _ => ?_
    rcases obj?_cases h hs0 with ⟨hs, ht⟩ | ⟨o1, hs, ht⟩ | ⟨o1, o1', es, es', hs, ht, hk1, hk1'⟩
    · simp only [hs, ht]
      exact typeErr_sim h _ hn hI hpT
    · have hso := h.obj?_supp hs
      obtain ⟨kd, pr, ps, pv, e⟩ := o1
      cases kd with
      | typed k b off n =>
        simp only [Map.val, hs, ht, Map.obj, Map.kind]
        cases hz : Nat.beq n 0
        · simp only [Bool.cond_false]
          have hpb : Present s b := hso.1
          rcases obj?_cases h hpb with ⟨hb, hbt⟩ | ⟨ob, hb, hbt⟩ | ⟨ob, ob', es, es', hb, hbt, hkb, hkb'⟩
          · simp only [hb, hbt]
            exact sim_ret h (.ptr (.js b) (off + extra)) hpb
          · obtain ⟨kb, prb, psb, pvb, eb⟩ := ob
            cases kb with
            | extBuf r o0 l =>
              simp only [hb, hbt, Map.obj, Map.kind]
              exact sim_ret h (.ptr (.ext r) (o0 + off + extra)) trivial
            | _ =>
              simp only [hb, hbt, Map.obj, Map.kind]
              exact sim_ret h (.ptr (.js b) (off + extra)) hpb
          · obtain ⟨kb, prb, psb, pvb, eb⟩ := ob
            obtain ⟨kb', prb', psb', pvb', eb'⟩ := ob'
            simp only at hkb hkb'
            subst hkb hkb'
            simp only [hb, hbt]
            exact sim_ret h (.ptr (.js b) (off + extra)) hpb
        · simp only [Bool.cond_true]
          exact typeErr_sim h _ hn hI hpT
      | buf bs =>
        simp only [Map.val, hs, ht, Map.obj, Map.kind, isEmpty_map]
        cases bs.isEmpty
        · exact sim_ret h (.ptr (.js p) extra) hs0
        · exact typeErr_sim h _ hn hI hpT
      | extBuf r o0 l =>
        simp only [Map.val, hs, ht, Map.obj, Map.kind]
        exact sim_ret h (.ptr (.ext r) (o0 + extra)) trivial
      | _ =>
        simp only [Map.val, hs, ht, Map.obj, Map.kind]
        exact typeErr_sim h _ hn hI hpT
    · obtain ⟨kd, pr, ps, pv, e⟩ := o1
      obtain ⟨kd', pr', ps', pv', e'⟩ := o1'
      simp only at hk1 hk1'
      subst hk1 hk1'
      simp only [hs, ht]
      exact typeErr_sim h _ hn hI hpT
  | _ =>
    simp only [Map.val]
    exact typeErr_sim h _ hn hI hpT

/-! ## Memory reads -/

def readMemP (F : Ffi) (s : St F.S) (p : Val) (off : Nat) (k : EltK) : Option Cell :=
  match p with
  | .ptr (.js b) o => (bufBytes F s b).bind fun bs => readCell k (bs.drop (o + off))
  | .ptr (.ext r) o => (F.read s.ffi r (o + off) k.size).bind (readCell k)
  | _ => none

theorem readMem_eq (F : Ffi) (s : St F.S) (p : Val) (off : Nat) (k : EltK) :
    readMem F s p off k = Host.Ts.M.pure (readMemP F s p off k) := by
  cases p with
  | ptr m o => cases m <;> rfl
  | _ => rfl

/-- Side condition of a memory read: the element read is `ReadOK`. -/
def MemReadOK (F : Ffi) (K : Ctx) (s : St F.S) (n : Nat) (p : Val) (off : Nat) (k : EltK) : Prop :=
  match p with
  | .ptr (.js b) o => ∀ bs, bufBytes F s b = some bs → ReadOK K.lo K.hi n k (bs.drop (o + off))
  | .ptr (.ext r) o => ∀ bs, F.read s.ffi r (o + off) k.size = some bs → ReadOK K.lo K.hi n k bs
  | _ => True

theorem readMemP_rel (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {p : Val}
    {off : Nat} {k : EltK} {c : Cell} (hok : MemReadOK F K s S.tab.length p off k)
    (hr : readMemP F s p off k = some c) :
    readMemP F t (M.val p) off k = some (M.cell c) ∧ Supp.cell (fun _ => True) S.tab.length c := by
  cases p with
  | ptr m o =>
    cases m with
    | js b =>
      simp only [readMemP] at hr
      cases hbs : bufBytes F s b with
      | none => rw [hbs] at hr; cases hr
      | some bs =>
        rw [hbs] at hr
        simp only [Option.bind_some] at hr
        have hok' := hok bs hbs
        refine ⟨?_, (hok' c hr).1⟩
        show (bufBytes F t (M.a b)).bind (fun bs => readCell k (bs.drop (o + off))) = _
        rw [bufBytes_rel h hF hbs, Option.bind_some, ← List.map_drop]
        exact readCell_map h.bigFixed hok' hr
    | ext r =>
      simp only [readMemP] at hr
      cases hbs : F.read s.ffi r (o + off) k.size with
      | none => rw [hbs] at hr; cases hr
      | some bs =>
        rw [hbs] at hr
        simp only [Option.bind_some] at hr
        have hok' := hok bs hbs
        refine ⟨?_, (hok' c hr).1⟩
        show (F.read t.ffi (M.region r) (o + off) k.size).bind (readCell k) = _
        rw [hF.read M S.tab.length s.ffi t.ffi r (o + off) k.size bs h.ffi hbs, Option.bind_some]
        exact readCell_map h.bigFixed hok' hr
  | _ => cases hr

/-- `read.X(ptr, off)` for element kind `k`. -/
theorem rd_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (k : EltK)
    {args : List Val}
    (hrd : ∀ off, offsetP (arg args 1) = some off → MemReadOK F K s S.tab.length (arg args 0) off k) :
    MSim (StepPost F FR M ν K S C) S C (ffiN.rd F s args k) (ffiN.rd F t (M.vals args) k) := by
  unfold ffiN.rd
  simp only [arg_vals]
  refine offsetArg_msim M _ fun off hoff => ?_
  rw [readMem_eq, readMem_eq]
  cases hr : readMemP F s (arg args 0) off k with
  | none => exact MSim.fail _ _
  | some c =>
    obtain ⟨hr', hsc⟩ := readMemP_rel h hF (hrd off hoff) hr
    rw [hr']
    have := sim_ret h (cellVal c) (cellVal_supp hsc)
    rw [cellVal_map] at this
    exact this

theorem _root_.Host.Ts.Sim.step_ffi_readU64 (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ffi .readU64) data))
    (hrd : ∀ off, offsetP (arg args 1) = some off → MemReadOK F K s S.tab.length (arg args 0) off .u64) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact rd_sim h hF .u64 hrd

theorem _root_.Host.Ts.Sim.step_ffi_readU32 (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ffi .readU32) data))
    (hrd : ∀ off, offsetP (arg args 1) = some off → MemReadOK F K s S.tab.length (arg args 0) off .u32) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact rd_sim h hF .u32 hrd

theorem _root_.Host.Ts.Sim.step_ffi_readI32 (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ffi .readI32) data))
    (hrd : ∀ off, offsetP (arg args 1) = some off → MemReadOK F K s S.tab.length (arg args 0) off .i32) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact rd_sim h hF .i32 hrd

theorem _root_.Host.Ts.Sim.step_ffi_readF32 (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ffi .readF32) data))
    (hrd : ∀ off, offsetP (arg args 1) = some off → MemReadOK F K s S.tab.length (arg args 0) off .f32) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  exact rd_sim h hF .f32 hrd

/-! ## `toArrayBuffer` -/

/-- `toArrayBuffer(ptr, off, len)`: an `ArrayBuffer` over native memory. A number operand
naming host memory (`hostAddr`) needs the map to fix that region (`hhost`; vacuous when no
such operand occurs). -/
theorem _root_.Host.Ts.Sim.step_ffi_toArrayBuffer (h : Rel F FR M ν K s S t C) {a : Nat} {this : Val}
    {args : List Val} {o : Obj} {data : List Val} (hc : s.ctl = .call (.obj a) this args)
    (ho : s.obj? a = some o) (hk : o.kind = .fn (.native (.ffi .toArrayBuffer) data))
    (hn : s.next < Sim.bound) (hp14 : Present s aArrayBufferProto)
    (hhost : ∀ x r o, arg args 0 = .num (.lit x) → hostAddr x = some (r, o) → M.region r = r) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  have hI := h.intr
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  show MSim _ S C (ffiN F s this args data .toArrayBuffer)
    (ffiN F t (M.val this) (M.vals args) (M.vals data) .toArrayBuffer)
  simp only [ffiN, arg_vals]
  cases harg : arg args 0 with
  | ptr m o0 =>
    cases m with
    | ext r =>
      simp only [Map.val, Map.mem]
      refine offsetArg_msim M _ fun off _ => offsetArg_msim M _ fun n _ => ?_
      exact allocObj_ret_sim h (.extBuf r (o0 + off) n) aArrayBufferProto hn (hI _ (by decide)) hp14
        trivial
    | js _ => exact MSim.fail _ _
  | num x =>
    cases x with
    | lit x =>
      simp only [Map.val, Map.nv]
      cases hx : hostAddr x with
      | none => exact MSim.fail _ _
      | some p =>
        obtain ⟨r, o0⟩ := p
        have hr := hhost x r o0 harg hx
        refine offsetArg_msim M _ fun off _ => offsetArg_msim M _ fun n _ => ?_
        have := allocObj_ret_sim h (.extBuf r (o0 + off) n) aArrayBufferProto hn (hI _ (by decide)) hp14
          trivial
        rw [show M.kind (.extBuf r (o0 + off) n) = .extBuf r (o0 + off) n by
          show Kind.extBuf (M.region r) _ _ = _; rw [hr]] at this
        exact this
    | ref _ => exact MSim.fail _ _
  | _ => exact MSim.fail _ _


/-! ## Argument decoding -/

theorem truthy_lawful (v : Val) : Lawful (truthy v) := by
  cases v <;> first | exact Lawful.pure _ | exact numTest_lawful _ _ _

theorem decodeArg_lawful (F : Ffi) (s : St F.S) (ty : List Char) (v : Val) :
    Lawful (decodeArg F s ty v) := by
  unfold decodeArg
  refine Lawful.cond _ ?_ (Lawful.cond _ ?_ (Lawful.cond _ ?_ (Lawful.cond _ ?_ (Lawful.cond _ ?_ ?_))))
  all_goals first
    | exact Lawful.bind (truthy_lawful v) fun _ => Lawful.pure _
    | (split <;> (try split) <;> first | exact Lawful.pure _ |
        exact Lawful.bind (numUn_lawful _ _) fun _ => Lawful.pure _)

theorem decodeArgs_lawful (F : Ffi) (s : St F.S) : ∀ (ts vs : List Val), Lawful (decodeArgs F s ts vs)
  | [], [] => Lawful.pure _
  | [], _ :: _ => Lawful.pure _
  | t :: ts, vs => by
    cases t
    case str ty =>
      cases vs with
      | nil =>
        unfold decodeArgs
        refine Lawful.bind (decodeArg_lawful F s ty .undef) fun r => ?_
        cases r with
        | some a => exact Lawful.bind (decodeArgs_lawful F s ts []) fun _ => Lawful.pure _
        | none => exact Lawful.pure _
      | cons v vs =>
        unfold decodeArgs
        refine Lawful.bind (decodeArg_lawful F s ty v) fun r => ?_
        cases r with
        | some a => exact Lawful.bind (decodeArgs_lawful F s ts vs) fun _ => Lawful.pure _
        | none => exact Lawful.pure _
    all_goals exact Lawful.pure _

theorem MSim.condH {α β : Type} {P : Map → SSrv → CSrv → α → β → Prop} {S : SSrv} {C : CSrv}
    (b : Bool) {m1 m2 : Host.Ts.M α} {m1' m2' : Host.Ts.M β} (h1 : b = true → MSim P S C m1 m1')
    (h2 : b = false → MSim P S C m2 m2') :
    MSim P S C (bif b then m1 else m2) (bif b then m1' else m2') := by
  cases b
  · exact h2 rfl
  · exact h1 rfl

/-- Side condition on an argument passed by pointer: its buffer is `BufOK`. -/
def ArgBufOK (F : Ffi) (s : St F.S) (n : Nat) : Val → Prop
  | .ptr (.js b) _ => BufOK F s n b
  | .obj a => ∀ o, s.obj? a = some o → ∀ k b off len, o.kind = .typed k b off len → BufOK F s n b
  | _ => True

/-- A bigint passed as a `bool` parameter keeps its value. -/
def BoolOK (K : Ctx) (ty : List Char) (v : Val) : Prop :=
  nameEq ty (chars!"bool") = true → ∀ i, v = .big i → BigFixed K.lo K.hi i

/-- The postcondition of `decodeArg`. -/
def ArgP (A : Nat → Prop) (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option Arg → Option Arg → Prop :=
  fun M' S' C' r r' => r' = r.map M'.arg ∧ Grow M ν S C M' S' C' ∧
    ∀ a, r = some a → Supp.arg A S'.tab.length a

theorem jsPtr_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) {b : Nat} (o : Nat)
    (hp : Present s b) (hok : BufOK F s S.tab.length b) :
    MSim (ArgP (Present s) M ν S C) S C
      (Host.Ts.M.pure ((bufBytes F s b).map fun bs => Arg.jsPtr b o (bs.drop o)))
      (Host.Ts.M.pure ((bufBytes F t (M.a b)).map fun bs => Arg.jsPtr (M.a b) o (bs.drop o))) := by
  obtain ⟨he, hsupp⟩ := bufBytes_exact h hF hp hok
  rw [he]
  refine MSim.pure ⟨?_, Grow.refl h.srv, fun a ha => ?_⟩
  · cases bufBytes F s b <;> simp [Map.arg, List.map_drop]
  · cases hb : bufBytes F s b with
    | none => rw [hb] at ha; cases ha
    | some bs =>
      rw [hb] at ha
      cases ha
      exact ⟨hp, bytes_drop (hsupp bs hb) o⟩

theorem numUn_arg {A : Nat → Prop} (hs : Srv M ν S C) (op : NUn) (x : NumV) :
    MSim (ArgP A M ν S C) S C
      (Host.Ts.M.bind (numUn op x) fun y => Host.Ts.M.pure (some (Arg.num y)))
      (Host.Ts.M.bind (numUn op (M.nv x)) fun y => Host.Ts.M.pure (some (Arg.num y))) :=
  MSim.bind (numUn_simS (A := A) hs op x) fun M' S' C' y y' ⟨h1, h2, h3⟩ =>
    MSim.pure ⟨by rw [h1]; rfl, h2, fun a ha => by cases ha; exact h3⟩

theorem decodeArg_sim (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (ty : List Char)
    (v : Val) (hv : Supp.val (Present s) S.tab.length v) (hbuf : ArgBufOK F s S.tab.length v)
    (hbool : BoolOK K ty v) :
    MSim (ArgP (Present s) M ν S C) S C (decodeArg F s ty v) (decodeArg F t ty (M.val v)) := by
  have hs := h.srv
  have pure_none : MSim (ArgP (Present s) M ν S C) S C (Host.Ts.M.pure none) (Host.Ts.M.pure none) :=
    MSim.pure ⟨rfl, Grow.refl hs, fun _ h => nomatch h⟩
  unfold decodeArg
  refine MSim.condH _ (fun _ => ?_) fun _ => MSim.condH _ (fun _ => ?_) fun _ => MSim.condH _ (fun _ => ?_)
    fun _ => MSim.condH _ (fun _ => ?_) fun _ => MSim.condH _ (fun hb => ?_) fun _ => ?_
  · cases v with
    | ptr m o =>
      cases m with
      | js b => exact jsPtr_sim h hF o hv hbuf
      | ext r => exact MSim.pure ⟨rfl, Grow.refl hs, fun a ha => by cases ha; trivial⟩
    | null => exact MSim.pure ⟨rfl, Grow.refl hs, fun a ha => by cases ha; trivial⟩
    | undef => exact MSim.pure ⟨rfl, Grow.refl hs, fun a ha => by cases ha; trivial⟩
    | num x => exact MSim.pure ⟨rfl, Grow.refl hs, fun a ha => by cases ha; exact hv⟩
    | big i => exact MSim.pure ⟨rfl, Grow.refl hs, fun a ha => by cases ha; trivial⟩
    | obj a =>
      show MSim _ S C _ (match t.obj? (M.a a) with
        | some ⟨.typed _ b off _, _, _, _, _⟩ =>
          Host.Ts.M.pure ((bufBytes F t b).map fun bs => Arg.jsPtr b off (bs.drop off))
        | _ => Host.Ts.M.pure none)
      rcases obj?_cases h hv with ⟨ho, ht⟩ | ⟨o, ho, ht⟩ | ⟨o, o', es, es', ho, ht, hk, hk'⟩
      · simp only [ho, ht]; exact pure_none
      · have hso := h.obj?_supp ho
        obtain ⟨kd, pr, ps, pv, e⟩ := o
        cases kd with
        | typed k b off len =>
          simp only [ho, ht, Map.obj, Map.kind]
          exact jsPtr_sim h hF off hso.1 (hbuf _ ho k b off len rfl)
        | _ => simp only [ho, ht, Map.obj, Map.kind]; exact pure_none
      · obtain ⟨kd, pr, ps, pv, e⟩ := o
        obtain ⟨kd', pr', ps', pv', e'⟩ := o'
        simp only at hk hk'
        subst hk hk'
        simp only [ho, ht]
        exact pure_none
    | _ => exact pure_none
  · cases v with
    | big i => exact MSim.pure ⟨rfl, Grow.refl hs, fun a ha => by cases ha; trivial⟩
    | num x => exact MSim.pure ⟨rfl, Grow.refl hs, fun a ha => by cases ha; exact hv⟩
    | _ => exact pure_none
  · cases v with
    | num x => exact numUn_arg hs .f32 x
    | _ => exact pure_none
  · cases v with
    | num x => exact MSim.pure ⟨rfl, Grow.refl hs, fun a ha => by cases ha; exact hv⟩
    | _ => exact pure_none
  · refine MSim.bind (truthy_sim hs v fun i hi => h.bigFixed i (hbool hb i hi)) ?_
    rintro M' S' C' r r' ⟨rfl, g⟩
    exact MSim.pure ⟨rfl, g, fun a ha => by cases ha; trivial⟩
  · cases v with
    | num x => exact numUn_arg hs .int32 x
    | bool b => cases b <;> exact MSim.pure ⟨rfl, Grow.refl hs, fun a ha => by cases ha; trivial⟩
    | _ => exact pure_none


theorem BufOK.mono {n n' : Nat} {b : Nat} (h : BufOK F s n b) (hn : n ≤ n') : BufOK F s n' b :=
  fun o ho r off len hk => by
    obtain ⟨bs, hr, hbs⟩ := h o ho r off len hk
    exact ⟨bs, hr, bytes_mono hbs hn⟩

theorem ArgBufOK.mono {n n' : Nat} {v : Val} (h : ArgBufOK F s n v) (hn : n ≤ n') : ArgBufOK F s n' v := by
  cases v with
  | ptr m o => cases m with
    | js b => exact BufOK.mono (F := F) h hn
    | ext _ => trivial
  | obj a => exact fun o ho k b off len hk => BufOK.mono (h o ho k b off len hk) hn
  | _ => trivial

/-- The postcondition of `decodeArgs`. -/
def ArgsP (A : Nat → Prop) (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) :
    Map → SSrv → CSrv → Option (List Arg) → Option (List Arg) → Prop :=
  fun M' S' C' r r' => r' = r.map (List.map M'.arg) ∧ Grow M ν S C M' S' C' ∧
    ∀ as, r = some as → ∀ a ∈ as, Supp.arg A S'.tab.length a

theorem decodeArgs_sim (hFR : FRLaws FR) (hF : FfiSim F FR okCall okBack) :
    ∀ (ts vs : List Val) {M : Map} {S : SSrv} {C : CSrv}, Rel F FR M ν K s S t C →
    Supp.vals (Present s) S.tab.length ts → Supp.vals (Present s) S.tab.length vs →
    (∀ v ∈ vs, ArgBufOK F s S.tab.length v) → (∀ ty v, Val.str ty ∈ ts → v ∈ vs → BoolOK K ty v) →
    MSim (ArgsP (Present s) M ν S C) S C (decodeArgs F s ts vs) (decodeArgs F t (M.vals ts) (M.vals vs))
  | [], [], M, S, C, h, _, _, _, _ => MSim.pure ⟨rfl, Grow.refl h.srv, fun as has a ha => by
      cases has; exact nomatch ha⟩
  | [], _ :: _, M, S, C, h, _, _, _, _ => MSim.pure ⟨rfl, Grow.refl h.srv, fun _ h => nomatch h⟩
  | t0 :: ts, vs, M, S, C, h, hts, hvs, hbuf, hbool => by
    have tail : ∀ (v : Val) (vs' : List Val), Supp.val (Present s) S.tab.length v →
        ArgBufOK F s S.tab.length v → BoolOK K (match t0 with | .str ty => ty | _ => []) v →
        Supp.vals (Present s) S.tab.length vs' → (∀ v ∈ vs', ArgBufOK F s S.tab.length v) →
        (∀ ty v, Val.str ty ∈ ts → v ∈ vs' → BoolOK K ty v) →
        ∀ ty, t0 = .str ty →
        MSim (ArgsP (Present s) M ν S C) S C
          (Host.Ts.M.bind (decodeArg F s ty v) fun
            | some a => Host.Ts.M.bind (decodeArgs F s ts vs') fun r => Host.Ts.M.pure (r.map (a :: ·))
            | none => Host.Ts.M.pure none)
          (Host.Ts.M.bind (decodeArg F t ty (M.val v)) fun
            | some a => Host.Ts.M.bind (decodeArgs F t (M.vals ts) (M.vals vs')) fun r =>
                Host.Ts.M.pure (r.map (a :: ·))
            | none => Host.Ts.M.pure none) := by
      intro v vs' hv hb hbo hvs' hbuf' hbool' ty hty
      subst hty
      refine MSim.bind (decodeArg_sim h hF ty v hv hb hbo) ?_
      rintro M1 S1 C1 r r' ⟨rfl, g1, hs1⟩
      cases r with
      | none => exact MSim.pure ⟨rfl, g1, fun _ h => nomatch h⟩
      | some a =>
        have hts' : Supp.vals (Present s) S.tab.length ts := fun w hw => hts w (List.mem_cons_of_mem _ hw)
        rw [Map.vals_agree (g1.ext.agree (A := Present s)) hts',
          Map.vals_agree (g1.ext.agree (A := Present s)) hvs']
        refine MSim.bind (decodeArgs_sim hFR hF ts vs' (h.grow hFR g1) (Supp.vals_mono (fun _ h => h) g1.len hts')
          (Supp.vals_mono (fun _ h => h) g1.len hvs') (fun w hw => ArgBufOK.mono (hbuf' w hw) g1.len)
          hbool') ?_
        rintro M2 S2 C2 r2 r2' ⟨rfl, g2, hs2⟩
        have ha : Supp.arg (Present s) S1.tab.length a := hs1 a rfl
        have hma : M1.arg a = M2.arg a := Map.arg_agree (g2.ext.agree (A := Present s)) ha
        refine MSim.pure ⟨?_, g1.trans g2, fun as has x hx => ?_⟩
        · cases r2 <;> simp [hma]
        · cases r2 with
          | none => cases has
          | some as2 =>
            simp only [Option.map_some, Option.some.injEq] at has
            subst has
            rcases List.mem_cons.1 hx with rfl | hx
            · exact Supp.arg_mono (fun _ h => h) g2.len ha
            · exact hs2 as2 rfl x hx
    cases t0 with
    | str ty =>
      have hbool0 : ∀ v ∈ vs, BoolOK K ty v := fun v hv => hbool ty v (List.mem_cons_self ..) hv
      have hbool1 : ∀ ty' v, Val.str ty' ∈ ts → v ∈ vs → BoolOK K ty' v :=
        fun ty' v hm hv => hbool ty' v (List.mem_cons_of_mem _ hm) hv
      cases vs with
      | nil =>
        exact tail .undef [] trivial trivial (fun _ _ hi => nomatch hi) (fun _ h => nomatch h)
          (fun _ h => nomatch h) (fun _ _ _ h => nomatch h) ty rfl
      | cons v vs =>
        exact tail v vs (hvs v (List.mem_cons_self ..)) (hbuf v (List.mem_cons_self ..))
          (hbool0 v (List.mem_cons_self ..)) (fun w hw => hvs w (List.mem_cons_of_mem _ hw))
          (fun w hw => hbuf w (List.mem_cons_of_mem _ hw))
          (fun ty' w hm hw => hbool1 ty' w hm (List.mem_cons_of_mem _ hw)) ty rfl
    | _ => exact MSim.pure ⟨rfl, Grow.refl h.srv, fun _ h => nomatch h⟩


/-! ## Native results -/

/-- Writes into a present JS buffer object keep presence. -/
theorem present_setObj (hn : s.next < Sim.bound) (presentBound : ∀ a, Present s a → a < s.next)
    {b : Nat} (hb : Present s b) (o : Obj) (a : Nat) : Present (s.setObj b o) a ↔ Present s a := by
  have hb64 : b < 2 ^ 64 := by
    have := presentBound b hb
    have hbd : Sim.bound = 2 ^ 61 := rfl
    omega
  constructor
  · intro hp
    rcases Present.of_set hb64 hp with rfl | hp
    · exact hb
    · exact hp
  · exact Present.set (.obj o) hb64

/-- Applying native writes into JS buffers: the target applies the image writes. -/
theorem applyWrites_rel : ∀ (ws : List (Nat × Nat × List Byte)) {s1 t1 s2 : St F.S},
    Rel F FR M ν K s1 S t1 C → s1.next < Sim.bound →
    (∀ w ∈ ws, Supp.bytes (fun _ => True) S.tab.length w.2.2) → applyWrites F s1 ws = some s2 →
    ∃ t2, applyWrites F t1 (ws.map M.write) = some t2 ∧ Rel F FR M ν K s2 S t2 C ∧
      s2.next = s1.next ∧ ∀ a, Present s2 a ↔ Present s1 a
  | [], s1, t1, s2, h, _, _, hw => by
    cases hw
    exact ⟨t1, rfl, h, rfl, fun _ => Iff.rfl⟩
  | (b, off, bytes) :: ws, s1, t1, s2, h, hn, hsupp, hw => by
    simp only [applyWrites] at hw
    cases ho : s1.obj? b with
    | none => rw [ho] at hw; cases hw
    | some o =>
      rw [ho] at hw
      obtain ⟨kd, pr, ps, pv, e⟩ := o
      cases kd with
      | buf bs =>
        simp only at hw
        have hso := h.obj?_supp ho
        have hbytes : Supp.bytes (Present s1) S.tab.length bytes :=
          bytesA (hsupp (b, off, bytes) (List.mem_cons_self ..))
        obtain ⟨ht, hr⟩ := Rel.setBuf h hn ho (bs.take off ++ bytes ++ bs.drop (off + len bytes))
          (bytes_append (bytes_append (bytes_take hso.1 _) hbytes) (bytes_drop hso.1 _))
        have hp : ∀ a, Present (s1.setObj b ⟨.buf (bs.take off ++ bytes ++ bs.drop (off + len bytes)), pr, ps,
            pv, e⟩) a ↔ Present s1 a :=
          present_setObj hn h.presentBound (Present.of_get (obj?_iff.1 ho)) _
        obtain ⟨t2, ht2, hr2, hn2, hp2⟩ := applyWrites_rel ws hr (by exact hn)
          (fun w hw => hsupp w (List.mem_cons_of_mem _ hw)) hw
        refine ⟨t2, ?_, hr2, hn2, fun a => (hp2 a).trans (hp a)⟩
        simp only [List.map_cons, Map.write, applyWrites, ht, len_map]
        simp only [List.map_append, List.map_take, List.map_drop] at ht2
        exact ht2
      | _ => cases hw

/-! ## `JSCallback` invocations -/

/-- Bigint callback arguments to parameters other than `u64`/`i64` become numbers: their
value must be fixed by the map. -/
def ArgValsOK (K : Ctx) : List Val → List Arg → Prop
  | .str ty :: ts, a :: as =>
    (∀ i, a = .big i → (nameEq ty (chars!"u64") || nameEq ty (chars!"i64")) = false →
      BigFixed K.lo K.hi i) ∧ ArgValsOK K ts as
  | _, _ => True

theorem argVal_map {M : Map} {lo hi : Nat} (hfix : ∀ i, BigFixed lo hi i → M.big i = i) (ty : List Char)
    (a : Arg) (ha : ∀ i, a = .big i → (nameEq ty (chars!"u64") || nameEq ty (chars!"i64")) = false →
      BigFixed lo hi i) :
    argVal ty (M.arg a) = M.val (argVal ty a) := by
  cases a with
  | big i =>
    show (bif nameEq ty (chars!"u64") || nameEq ty (chars!"i64") then Val.big (M.big i)
      else .num (.lit (F64.ofInt (M.big i)))) = M.val (bif nameEq ty (chars!"u64") || nameEq ty (chars!"i64")
        then Val.big i else .num (.lit (F64.ofInt i)))
    cases hc : (nameEq ty (chars!"u64") || nameEq ty (chars!"i64"))
    · rw [hfix i (ha i rfl hc)]; rfl
    · rfl
  | _ => rfl

theorem argVals_map {M : Map} {K : Ctx} (hfix : ∀ i, BigFixed K.lo K.hi i → M.big i = i) :
    ∀ (tys : List Val) (cargs : List Arg), ArgValsOK K tys cargs →
      argVals (M.vals tys) (cargs.map M.arg) = M.vals (argVals tys cargs)
  | [], _, _ => rfl
  | t0 :: ts, [], _ => by cases t0 <;> rfl
  | t0 :: ts, a :: as, h => by
    cases t0 with
    | str ty =>
      obtain ⟨ha, hrest⟩ := h
      show argVal ty (M.arg a) :: argVals (M.vals ts) (as.map M.arg) =
        M.val (argVal ty a) :: M.vals (argVals ts as)
      rw [argVal_map hfix ty a ha, argVals_map hfix ts as hrest]
    | _ => rfl

theorem argVals_supp {A : Nat → Prop} {n : Nat} : ∀ (tys : List Val) {cargs : List Arg},
    Supp.args A n cargs → Supp.vals A n (argVals tys cargs)
  | [], _, _ => fun _ h => nomatch h
  | t0 :: ts, [], _ => by cases t0 <;> exact fun _ h => nomatch h
  | t0 :: ts, a :: as, h => by
    cases t0 with
    | str ty =>
      intro v hv
      rcases List.mem_cons.1 hv with rfl | hv
      · have ha := h a (List.mem_cons_self ..)
        cases a with
        | big i => show Supp.val A n (bif _ then _ else _); cases (nameEq ty (chars!"u64") || nameEq ty (chars!"i64")) <;> trivial
        | jsPtr b off bs => exact ha.1
        | _ => exact ha
      · exact argVals_supp ts (fun x hx => h x (List.mem_cons_of_mem _ hx)) v hv
    | _ => exact fun _ h => nomatch h

/-- Side condition of a `JSCallback` invocation on the state that invokes it: the callback's
`%args` is an unframed array of parameter types for which `ArgValsOK` holds. -/
def CbOK (F : Ffi) (K : Ctx) (s : St F.S) (f : Nat) (cargs : List Arg) : Prop :=
  ∀ o, s.obj? (f - cbBase) = some o → ∀ ats w e, findProp kCbArgs o.props = some (.data ats w e) →
    ∃ ta oa tys, ats = .obj ta ∧ s.obj? ta = some oa ∧ oa.kind = .array tys ∧ K.fr ta = none ∧
      ArgValsOK K tys cargs

/-- An invocation of `JSCallback` region `f`. The map must send the callback's region to the
region of the callback object's image (`hcbr`, a fact about native regions). -/
theorem ffiCallback_sim (h : Rel F FR M ν K s S t C) {name : Name} {f : Nat} {cargs : List Arg}
    (hcargs : Supp.args (Present s) S.tab.length cargs)
    (hcbr : cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase))
    (hcb : CbOK F K s f cargs) :
    MSim (StepPost F FR M ν K S C) S C (ffiCallback F s name f cargs)
      (ffiCallback F t name (M.region f) (cargs.map M.arg)) := by
  unfold ffiCallback
  cases hlt : Nat.blt f cbBase
  · have hge : cbBase ≤ f := by
      have : ¬ (Nat.blt f cbBase = true) := by rw [hlt]; exact Bool.false_ne_true
      rw [Nat.blt_eq] at this
      omega
    simp only [Bool.cond_false]
    cases ho : s.obj? (f - cbBase) with
    | none => exact MSim.fail _ _
    | some o =>
      have hp : Present s (f - cbBase) := Present.of_get (obj?_iff.1 ho)
      rw [hcbr hge hp]
      have hlt' : Nat.blt (cbBase + M.a (f - cbBase)) cbBase = false := by
        rw [Bool.eq_false_iff, ne_eq, Nat.blt_eq]; omega
      rw [hlt', Nat.add_sub_cancel_left]
      simp only [Bool.cond_false]
      obtain ⟨o', ho', -, hprops, -, -⟩ := h.obj?_some ho
      simp only [ho', hprops]
      have hps := (h.obj?_supp ho).2.2.1
      have hfp : ∀ k : List Char, findProp (.str k) (M.props o.props) = (findProp (.str k) o.props).map M.prop :=
        fun k => findProp_map (k := .str k) h.inj trivial hps
      simp only [kCbFn, kCbArgs, kCbRet, hfp]
      cases h1 : findProp (.str chars!"%fn") o.props with
      | none => exact MSim.fail _ _
      | some p1 =>
        cases p1 with
        | acc _ _ _ => exact MSim.fail _ _
        | data fn w1 e1 =>
          cases h2 : findProp (.str chars!"%args") o.props with
          | none => exact MSim.fail _ _
          | some p2 =>
            cases p2 with
            | acc _ _ _ => exact MSim.fail _ _
            | data ats w2 e2 =>
              cases h3 : findProp (.str chars!"%returns") o.props with
              | none => exact MSim.fail _ _
              | some p3 =>
                cases p3 with
                | acc _ _ _ => exact MSim.fail _ _
                | data rt w3 e3 =>
                  simp only [Option.map_some, Map.prop]
                  obtain ⟨ta, oa, tys, rfl, hta, htk, hfr, hav⟩ := hcb o ho ats w2 e2 h2
                  have htt := h.obj? hta hfr
                  obtain ⟨kd, pr, ps, pv, e⟩ := oa
                  simp only at htk
                  subst htk
                  have hso := h.obj?_supp hta
                  have hfn : Supp.val (Present s) S.tab.length fn := findProp_supp hps h1
                  have hrt : Supp.val (Present s) S.tab.length rt := findProp_supp hps h3
                  simp only [elemsOf, Map.val, hta, htt, Map.obj, Map.kind]
                  show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure ((t.push (.k (.native (.ffi .callbackRet)
                    [.str name, M.val rt]))).go (.call (M.val fn) .undef (argVals (M.vals tys) (cargs.map M.arg)))))
                  rw [argVals_map h.bigFixed tys cargs hav]
                  exact sim_rel ((h.push (.k (.native (.ffi .callbackRet) [.str name, rt]))
                    (fun v hv => by
                      rcases List.mem_cons.1 hv with rfl | hv
                      · trivial
                      · rcases List.mem_cons.1 hv with rfl | hv
                        · exact hrt
                        · exact nomatch hv)).go (.call fn .undef (argVals tys cargs))
                    ⟨hfn, trivial, argVals_supp tys hcargs⟩)
  · exact MSim.fail _ _

/-- Closedness and shape of a native call's result (a side condition on the source run): the
result is closed and a `JSCallback` invocation satisfies `CbOK` after the writes. -/
def ResOK (F : Ffi) (K : Ctx) (s : St F.S) (n : Nat) :
    Option (F.S × Ret × List (Nat × Nat × List Byte)) → Prop
  | none => True
  | some (x, ret, ws) => Supp.ret (Present s) n ret ∧ (∀ w ∈ ws, Supp.bytes (fun _ => True) n w.2.2) ∧
      match ret with
      | .callback f cargs => ∀ s2, applyWrites F (s.setFfi x) ws = some s2 → CbOK F K s2 f cargs
      | _ => True

theorem retVal_supp {A : Nat → Prop} {n : Nat} {ret : Ret} (h : Supp.ret A n ret) :
    Supp.val A n (retVal ret) := by
  cases ret <;> first | trivial | exact h

/-- A native call's completion: buffer writes, the trace event, then the return value or the
`JSCallback` invocation the call waits for. -/
theorem ffiDone_sim (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) {name : Name} {as : List Arg}
    (has : ∀ a ∈ as, Supp.arg (Present s) S.tab.length a)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase))
    {r r' : Option (F.S × Ret × List (Nat × Nat × List Byte))} (hr : CallR FR M S.tab.length r r')
    (hres : ResOK F K s S.tab.length r) :
    MSim (StepPost F FR M ν K S C) S C (ffiDone F s name as r) (ffiDone F t name (as.map M.arg) r') := by
  cases r with
  | none => exact MSim.fail _ _
  | some p =>
    obtain ⟨x, ret, ws⟩ := p
    cases r' with
    | none => exact hr.elim
    | some p' =>
      obtain ⟨y, ret', ws'⟩ := p'
      obtain ⟨hxy, rfl, rfl⟩ := hr
      obtain ⟨hret, hws, hcb⟩ := hres
      have h1 := h.setFfi x y hxy
      simp only [ffiDone]
      cases hw : applyWrites F (s.setFfi x) ws with
      | none => exact MSim.fail _ _
      | some s2 =>
        obtain ⟨t2, ht2, hr2, _, hp2⟩ := applyWrites_rel ws h1 hn hws hw
        rw [ht2]
        have hP : ∀ a, Present s a → Present s2 a := fun a ha => (hp2 a).2 ha
        have he : Supp.event (Present s2) S.tab.length ⟨name, as, ret⟩ :=
          ⟨fun a ha => Supp.arg_mono hP (Nat.le_refl _) (has a ha), Supp.ret_mono hP (Nat.le_refl _) hret⟩
        have h3 := hr2.event ⟨name, as, ret⟩ he
        cases ret with
        | callback f cargs =>
          exact ffiCallback_sim h3 (Supp.ret_mono hP (Nat.le_refl _) hret)
            (fun hge hp => hcbr f hge ((hp2 _).1 hp)) (hcb s2 hw)
        | _ =>
          exact sim_ret h3 _ (retVal_supp (Supp.ret_mono hP (Nat.le_refl _) hret))

end

/-- Native calls are proper machine computations: they run their continuation on their
result (needed to state side conditions about the source call's arguments and results). -/
structure FfiLawful (F : Ffi) : Prop where
  call : ∀ x name as, Lawful (F.call x name as)
  back : ∀ x a, Lawful (F.back x a)

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool}
  {okBack : F.S → Arg → Bool}

/-- The side condition of a symbol call, about the source run: the decoded arguments are
accepted by `okCall`, and the call's result is closed and invokes no `JSCallback`. -/
def SymOK (F : Ffi) (K : Ctx) (okCall : F.S → Name → List Arg → Bool) (s : St F.S) (S : SSrv) (name : Name)
    (tys args : List Val) : Prop :=
  ∀ as S1, interpS (decodeArgs F s tys args).run S = some (some as, S1) →
    okCall s.ffi name as = true ∧
    ∀ r S2, interpS (F.call s.ffi name as).run S1 = some (r, S2) → ResOK F K s S2.tab.length r

/-- A call of a `dlopen` symbol whose signature is the array `tys` at `ta`. -/
theorem _root_.Host.Ts.Sim.step_ffi_symbol (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall okBack) (hL : FfiLawful F) {a : Nat} {this : Val} {args : List Val}
    {o : Obj} {name rt : Name} {ta : Nat} {oa : Obj} {tys : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]))
    (hta : s.obj? ta = some oa) (htk : oa.kind = .array tys) (hn : s.next < Sim.bound)
    (hfr : K.fr ta = none) (hbuf : ∀ v ∈ args, ArgBufOK F s S.tab.length v)
    (hbool : ∀ ty v, Val.str ty ∈ tys → v ∈ args → BoolOK K ty v)
    (hok : SymOK F K okCall s S name tys args)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  have htt : t.obj? (M.a ta) = some (M.obj oa) := h.obj? hta hfr
  have hso : Supp.vals (Present s) S.tab.length tys := by
    have := (h.obj?_supp hta).1
    rw [htk] at this
    exact this
  obtain ⟨kd, pr, ps, pv, e⟩ := oa
  simp only at htk
  subst htk
  show MSim _ S C (ffiN F s this args [.str name, .obj ta, .str rt] .symbol)
    (ffiN F t (M.val this) (M.vals args) (M.vals [.str name, .obj ta, .str rt]) .symbol)
  simp only [ffiN, Map.vals, List.map, Map.val, elemsOf, hta, htt, Map.obj, Map.kind]
  show MSim _ S C (Host.Ts.M.bind (decodeArgs F s tys args) _)
    (Host.Ts.M.bind (decodeArgs F t (M.vals tys) (M.vals args)) _)
  refine MSim.bind (MSim.withRun (decodeArgs_sim hFR hF tys args h hso (call_supp h hc).2 hbuf hbool)
    (decodeArgs_lawful _ _ _ _) (decodeArgs_lawful _ _ _ _)) ?_
  rintro M1 S1 C1 r r' ⟨⟨rfl, g1, hs1⟩, hrun⟩
  cases r with
  | none => exact MSim.fail _ _
  | some as =>
    obtain ⟨hokc, hres⟩ := hok as S1 hrun
    have h1 := h.grow hFR g1
    have hcall := hF.call M1 ν S1 C1 s.ffi t.ffi name as h1.srv h1.ffi hokc
      (fun x hx => Supp.arg_mono (fun _ _ => trivial) (Nat.le_refl _) (hs1 as rfl x hx))
    simp only [Option.map_some]
    refine MSim.bind (MSim.withRun hcall (hL.call _ _ _) (hL.call _ _ _)) ?_
    rintro M2 S2 C2 cr cr' ⟨⟨g2, hcr⟩, hrun2⟩
    have h2 := h1.grow hFR g2
    have has2 : ∀ x ∈ as, Supp.arg (Present s) S2.tab.length x :=
      fun x hx => Supp.arg_mono (fun _ h => h) g2.len (hs1 as rfl x hx)
    have hmap : as.map M1.arg = as.map M2.arg :=
      List.map_congr_left fun x hx => Map.arg_agree (g2.ext.agree (A := Present s)) (hs1 as rfl x hx)
    rw [hmap]
    have g := g1.trans g2
    exact StepPost.after g (ffiDone_sim h2 hn has2 (by rw [g.ext.region, g.ext.a]; exact hcbr) hcr
      (hres cr S2 hrun2))


/-- `step_ffi_symbol` for native calls that need a numeric premise (`FfiCallSim`): `small`
holds of the source call (decoded arguments `as`, server `S1` after decoding), stated on
the source run like `SymOK`. `hF` is used for native memory reads only. -/
theorem _root_.Host.Ts.Sim.step_ffi_symbol_small
    {small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop}
    (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall okBack) (hC : FfiCallSim F FR okCall small) (hL : FfiLawful F)
    {a : Nat} {this : Val} {args : List Val}
    {o : Obj} {name rt : Name} {ta : Nat} {oa : Obj} {tys : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]))
    (hta : s.obj? ta = some oa) (htk : oa.kind = .array tys) (hn : s.next < Sim.bound)
    (hfr : K.fr ta = none) (hbuf : ∀ v ∈ args, ArgBufOK F s S.tab.length v)
    (hbool : ∀ ty v, Val.str ty ∈ tys → v ∈ args → BoolOK K ty v)
    (hok : SymOK F K okCall s S name tys args)
    (hsmall : ∀ as S1, interpS (decodeArgs F s tys args).run S = some (some as, S1) →
      small ν S1 s.ffi name as)
    (hcbr : ∀ f, cbBase ≤ f → Present s (f - cbBase) → M.region f = cbBase + M.a (f - cbBase)) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  rw [step_call_native hc ho hk, step_call_native_t h hc ho hk]
  have htt : t.obj? (M.a ta) = some (M.obj oa) := h.obj? hta hfr
  have hso : Supp.vals (Present s) S.tab.length tys := by
    have := (h.obj?_supp hta).1
    rw [htk] at this
    exact this
  obtain ⟨kd, pr, ps, pv, e⟩ := oa
  simp only at htk
  subst htk
  show MSim _ S C (ffiN F s this args [.str name, .obj ta, .str rt] .symbol)
    (ffiN F t (M.val this) (M.vals args) (M.vals [.str name, .obj ta, .str rt]) .symbol)
  simp only [ffiN, Map.vals, List.map, Map.val, elemsOf, hta, htt, Map.obj, Map.kind]
  show MSim _ S C (Host.Ts.M.bind (decodeArgs F s tys args) _)
    (Host.Ts.M.bind (decodeArgs F t (M.vals tys) (M.vals args)) _)
  refine MSim.bind (MSim.withRun (decodeArgs_sim hFR hF tys args h hso (call_supp h hc).2 hbuf hbool)
    (decodeArgs_lawful _ _ _ _) (decodeArgs_lawful _ _ _ _)) ?_
  rintro M1 S1 C1 r r' ⟨⟨rfl, g1, hs1⟩, hrun⟩
  cases r with
  | none => exact MSim.fail _ _
  | some as =>
    obtain ⟨hokc, hres⟩ := hok as S1 hrun
    have h1 := h.grow hFR g1
    have hcall := hC.call M1 ν S1 C1 s.ffi t.ffi name as h1.srv h1.ffi hokc
      (fun x hx => Supp.arg_mono (fun _ _ => trivial) (Nat.le_refl _) (hs1 as rfl x hx)) (hsmall as S1 hrun)
    simp only [Option.map_some]
    refine MSim.bind (MSim.withRun hcall (hL.call _ _ _) (hL.call _ _ _)) ?_
    rintro M2 S2 C2 cr cr' ⟨⟨g2, hcr⟩, hrun2⟩
    have h2 := h1.grow hFR g2
    have has2 : ∀ x ∈ as, Supp.arg (Present s) S2.tab.length x :=
      fun x hx => Supp.arg_mono (fun _ h => h) g2.len (hs1 as rfl x hx)
    have hmap : as.map M1.arg = as.map M2.arg :=
      List.map_congr_left fun x hx => Map.arg_agree (g2.ext.agree (A := Present s)) (hs1 as rfl x hx)
    rw [hmap]
    have g := g1.trans g2
    exact StepPost.after g (ffiDone_sim h2 hn has2 (by rw [g.ext.region, g.ext.a]; exact hcbr) hcr
      (hres cr S2 hrun2))

end

end BufSim
end Host.Ts.Sim
