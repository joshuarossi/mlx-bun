import host.sim.dispatch.DecideBuf
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

/-! # Deciders for the side conditions of steps/FfiJs.lean

`MemReadOK`, `ArgBufOK` (with `BufOK`), `SymOK` (decided on the source
run of the argument decoding and of the native call; a result that invokes a
`JSCallback` needs `CbOK` after the call's writes, `resCbB`), and the host-region
condition of `toArrayBuffer`. -/

section
variable {F : Ffi} (P : JSP F)

/-- `MemReadOK`. -/
def memReadB (s : St F.S) (n : Nat) (p : Val) (off : Nat) (k : EltK) : Bool :=
  match p with
  | .ptr (.js b) o => match bufBytes F s b with
    | some bs => readOKB P n k (bs.drop (o + off))
    | none => true
  | .ptr (.ext r) o => match F.read s.ffi r (o + off) k.size with
    | some bs => readOKB P n k bs
    | none => true
  | _ => true

/-- The read condition of `read.u64(p, off)` and friends. -/
def rdB (s : St F.S) (n : Nat) (args : List Val) (k : EltK) : Bool :=
  match offsetP (arg args 1) with
  | some off => memReadB P s n (arg args 0) off k
  | none => true

/-- `BufOK`. -/
def bufOKB (s : St F.S) (n b : Nat) : Bool :=
  match s.obj? b with
  | some o => match o.kind with
    | .extBuf r off len => match F.read s.ffi r off len with
      | some bs => bytesB n bs
      | none => false
    | _ => true
  | none => true

/-- `ArgBufOK`. -/
def argBufB (s : St F.S) (n : Nat) : Val → Bool
  | .ptr (.js b) _ => bufOKB s n b && nwoB P s b
  | .obj a => nwoB P s a && (match s.obj? a with
    | some o => match o.kind with
      | .typed _ b _ _ => bufOKB s n b && nwoB P s b
      | _ => true
    | none => true)
  | _ => true

def retSuppB (n : Nat) : Ret → Bool
  | .num x => nvB n x
  | .callback _ _ => false
  | _ => true

/-- `ResOK`, without `JSCallback` invocations. -/
def resB (n : Nat) : Option (F.S × Ret × List (Nat × Nat × List Byte)) → Bool
  | none => true
  | some (_, ret, ws) => retSuppB n ret && allB (fun w => bytesB n w.2.2) ws

/-- `Supp.arg` on the calling state (no `.other` argument). -/
def argSuppB (s : St F.S) (n : Nat) : Arg → Bool
  | .num x => nvB n x
  | .jsPtr b _ bs => presB s b && bytesB n bs
  | .other _ => false
  | _ => true

/-- `ArgValsOK`: a bigint passed to a parameter other than `u64`/`i64` is fixed by the map. -/
def argValsB : List Val → List Arg → Bool
  | .str ty :: ts, a :: as => (match a with
      | .big i => nameEq ty (chars!"u64") || nameEq ty (chars!"i64") || bfB P i
      | _ => true) && argValsB ts as
  | _, _ => true

/-- `CbOK`: the callback object and its `%args` array are unframed, `%args` is an array of
parameter types, and `ArgValsOK` holds. -/
def cbOKB (s : St F.S) (f : Nat) (cargs : List Arg) : Bool :=
  match s.obj? (f - cbBase) with
  | some o => frB P (f - cbBase) && match findProp kCbArgs o.props with
    | some (.data (.obj ta) _ _) => frB P ta && match s.obj? ta with
      | some oa => match oa.kind with
        | .array tys => argValsB P tys cargs
        | _ => false
      | none => false
    | some (.data _ _ _) => false
    | _ => true
  | none => true

/-- `ResOK` of a result that invokes a `JSCallback`: its arguments are closed on the calling state
`s` and `CbOK` holds after the call's writes. -/
def resCbB (s : St F.S) (n : Nat) : Option (F.S × Ret × List (Nat × Nat × List Byte)) → Bool
  | some (x, .callback f cargs, ws) => allB (argSuppB s n) cargs && allB (fun w => bytesB n w.2.2) ws &&
    match applyWrites F (s.setFfi x) ws with
    | some s2 => cbOKB P s2 f cargs
    | none => true
  | _ => false

/-- `SymOK`, and the smallness decider on the decoded arguments. -/
def symOKB (s : St F.S) (S : SSrv) (name : Name) (tys args : List Val) : Bool :=
  match interpS (decodeArgs F s tys args).run S with
  | some (some as, S1) => P.okCall s.ffi name as && P.smallB S1 s.ffi name as && (match interpS (F.call s.ffi name as).run S1 with
    | some (r, S2) => resB S2.tab.length r || resCbB P s S2.tab.length r
    | none => true)
  | _ => true

/-- `symOKB` before `JSCallback` results were accepted. -/
def symOKBOld (s : St F.S) (S : SSrv) (name : Name) (tys args : List Val) : Bool :=
  match interpS (decodeArgs F s tys args).run S with
  | some (some as, S1) => P.okCall s.ffi name as && P.smallB S1 s.ffi name as && (match interpS (F.call s.ffi name as).run S1 with
    | some (r, S2) => resB S2.tab.length r
    | none => true)
  | _ => true

/-- `toArrayBuffer` of a number names host memory only (a region `4 h + 3` below `cbBase`). -/
def hostB (args : List Val) : Bool :=
  match arg args 0 with
  | .num (.lit x) => match hostAddr x with
    | some (r, _) => Nat.beq (r % 4) 3 && Nat.blt r cbBase
    | none => true
  | _ => true

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx} {W : Nat → Option WFrame} {stk : List Frame}

theorem Kp.memRead (hK : Kp P K) {s : St F.S} {n : Nat} {p : Val} {off : Nat} {k : EltK}
    (h : memReadB P s n p off k = true) : MemReadOK F K s n p off k := by
  rcases p with _ | _ | _ | _ | _ | _ | _ | _ | ⟨b | r, o⟩ <;> simp only [MemReadOK] <;> try trivial
  · intro bs hb
    simp only [memReadB, hb] at h
    exact hK.readOK h
  · intro bs hb
    simp only [memReadB, hb] at h
    exact hK.readOK h

theorem Kp.rd (hK : Kp P K) {s : St F.S} {n : Nat} {args : List Val} {k : EltK} (h : rdB P s n args k = true) :
    ∀ off, offsetP (arg args 1) = some off → MemReadOK F K s n (arg args 0) off k := by
  intro off ho
  simp only [rdB, ho] at h
  exact hK.memRead h

theorem bufOKB_sound {s : St F.S} {n b : Nat} (h : bufOKB s n b = true) : BufOK F s n b := by
  intro o ho r off len hk
  simp only [bufOKB, ho, hk] at h
  cases hr : F.read s.ffi r off len with
  | none => simp [hr] at h
  | some bs =>
    simp only [hr] at h
    exact ⟨bs, rfl, bytesB_sound h⟩

theorem Kp.argBuf (hK : Kp P K) (hW : Wp P W) {s : St F.S} {n : Nat} {v : Val} (h : argBufB P s n v = true) :
    ArgBufOK F K W s n v := by
  rcases v with _ | _ | _ | _ | _ | _ | _ | a | ⟨b | r, o⟩ <;> simp only [ArgBufOK] <;> try trivial
  · simp only [argBufB, Bool.and_eq_true] at h
    refine ⟨hK.noW hW h.1, fun o ho k b off len hk => ?_⟩
    have h2 := h.2
    simp only [ho, hk, Bool.and_eq_true] at h2
    exact ⟨bufOKB_sound h2.1, hK.noW hW h2.2⟩
  · simp only [argBufB, Bool.and_eq_true] at h
    exact ⟨bufOKB_sound h.1, hK.noW hW h.2⟩

theorem resB_sound {s : St F.S} {n : Nat} {r : Option (F.S × Ret × List (Nat × Nat × List Byte))}
    (h : resB n r = true) : ResOK F K s n r := by
  rcases r with _ | ⟨x, ret, ws⟩
  · trivial
  · simp only [resB, Bool.and_eq_true] at h
    refine ⟨?_, fun w hw => bytesB_sound (allB_sound h.2 w hw), ?_⟩
    · cases ret <;> simp only [Supp.ret] <;> simp only [retSuppB] at h <;> first
        | trivial
        | exact nvB_sound h.1
        | simp at h
    · cases ret <;> simp only <;> first | trivial | simp [retSuppB] at h

theorem argSuppB_sound {s : St F.S} {n : Nat} {a : Arg} (h : argSuppB s n a = true) : Supp.arg (Present s) n a := by
  cases a with
  | num x => exact nvB_sound (A := Present s) h
  | jsPtr b o bs =>
    simp only [argSuppB, Bool.and_eq_true] at h
    exact ⟨presB_sound h.1, bytesB_sound h.2⟩
  | other v => simp [argSuppB] at h
  | _ => trivial

theorem Kp.argVals (hK : Kp P K) : ∀ {tys : List Val} {cargs : List Arg}, argValsB P tys cargs = true →
    ArgValsOK K tys cargs
  | [], _, _ => trivial
  | t0 :: ts, [], _ => by cases t0 <;> trivial
  | t0 :: ts, a :: as, h => by
    cases t0 with
    | str ty =>
      simp only [argValsB, Bool.and_eq_true] at h
      simp only [ArgValsOK]
      refine ⟨fun i hi hty => ?_, hK.argVals h.2⟩
      subst hi
      have h1 := h.1
      simp only [hty, Bool.false_or] at h1
      exact hK.bf h1
    | _ => trivial

theorem Kp.cbOK (hK : Kp P K) {s : St F.S} {f : Nat} {cargs : List Arg} (h : cbOKB P s f cargs = true) :
    CbOK F K s f cargs := by
  intro o ho
  simp only [cbOKB, ho, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun ats w e hp => ?_⟩
  have h2 := h.2
  rw [hp] at h2
  cases ats with
  | obj ta =>
    simp only [Bool.and_eq_true] at h2
    cases hta : s.obj? ta with
    | none => rw [hta] at h2; simp at h2
    | some oa =>
      rw [hta] at h2
      obtain ⟨kd, pr, ps, pv, e'⟩ := oa
      cases kd with
      | array tys => exact ⟨ta, _, tys, rfl, hta, rfl, hK.fr_none h2.1, hK.argVals h2.2⟩
      | _ => simp at h2
  | _ => simp at h2

theorem Kp.resCb (hK : Kp P K) {s : St F.S} {n : Nat} {r : Option (F.S × Ret × List (Nat × Nat × List Byte))}
    (h : resCbB P s n r = true) : ResOK F K s n r := by
  rcases r with _ | ⟨x, ret, ws⟩
  · trivial
  · cases ret with
    | callback f cargs =>
      simp only [resCbB, Bool.and_eq_true] at h
      obtain ⟨⟨h1, h2⟩, h3⟩ := h
      refine ⟨fun a ha => argSuppB_sound (allB_sound h1 a ha), fun w hw => bytesB_sound (allB_sound h2 w hw), ?_⟩
      intro s2 hw
      rw [hw] at h3
      exact hK.cbOK h3
    | _ => simp [resCbB] at h

theorem symOKB_sound (hK : Kp P K) {s : St F.S} {S : SSrv} {name : Name} {tys args : List Val}
    (h : symOKB P s S name tys args = true) : SymOK F K P.okCall s S name tys args := by
  intro as S1 hd
  simp only [symOKB, hd, Bool.and_eq_true] at h
  refine ⟨h.1.1, fun r S2 hc => ?_⟩
  have h2 := h.2
  simp only [hc, Bool.or_eq_true] at h2
  rcases h2 with h2 | h2
  · exact resB_sound h2
  · exact hK.resCb h2

/-- **Agreement**: every symbol call accepted before `JSCallback` results is accepted. -/
theorem symOKB_old {s : St F.S} {S : SSrv} {name : Name} {tys args : List Val}
    (h : symOKBOld P s S name tys args = true) : symOKB P s S name tys args = true := by
  unfold symOKBOld at h
  unfold symOKB
  split at h
  · rename_i as S1 _
    simp only [Bool.and_eq_true] at h ⊢
    refine ⟨h.1, ?_⟩
    split at h
    · simp_all
    · rfl
  · rfl

theorem symOKB_small {s : St F.S} {S : SSrv} {name : Name} {tys args : List Val}
    (h : symOKB P s S name tys args = true) :
    ∀ as S1, interpS (decodeArgs F s tys args).run S = some (some as, S1) → P.smallB S1 s.ffi name as = true := by
  intro as S1 hd
  simp only [symOKB, hd, Bool.and_eq_true] at h
  exact h.1.2

theorem hostB_sound {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {s t : St F.S}
    {S : SSrv} {C : CSrv} (hN : NativeFacts F FR P) (h : RelB F FR W stk M ν K s S t C) {args : List Val}
    (hb : hostB args = true) :
    ∀ x r o, arg args 0 = .num (.lit x) → hostAddr x = some (r, o) → M.region r = r := by
  intro x r o ha hx
  simp only [hostB, ha, hx, Bool.and_eq_true, Nat.blt_eq] at hb
  exact hN.host M _ _ _ h.ffi r (Nat.eq_of_beq_eq_true hb.1) hb.2

end
end Host.Ts.Sim.Disp
