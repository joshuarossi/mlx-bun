import host.sim.dispatch.DecideRetA
import host.sim.dispatch.DecideBuf
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Adapter: stores of renamed handles into 64-bit typed-array elements

`step_retA_put` (through `putV_sim`/`typedPut_sim`) asks `CellOK` of a bigint stored
into a `BigInt64Array`/`BigUint64Array`: the bigint and its wrapped value are fixed
by the map. A renamed native handle is not; it is stored as itself when its image is
in the element range. `PutOKX` asks `BigConvOK` (Buf.lean) instead and `PutRangeOK`
is the map fact for handles in the band (`toCellBig_map`). The proofs are those of
`typedPut_sim`, `putV_sim`, `rf_storeTarget` and `step_retA_put` (op `none`) with
`BufSim.toCell_sim`. -/

/-- `PutOK` with `BigConvOK` for typed-array stores. -/
def PutOKX (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (recv : Val) (k : PKey) (v : Val) : Prop :=
  ∀ a, recv = .obj a → K.fr a = none ∧ ∀ o, s.obj? a = some o →
    (∀ p, o.proto = .obj p → ChainOK F K s S k 16 p) ∧
    (∀ kk b off n, o.kind = .typed kk b off n → ∀ i, v = .big i → BufSim.BigConvOK K kk i)

/-- A bigint in the handle band stored into a typed array has an image in `[0, 2 ^ 63)`. -/
def PutRangeOK {S' : Type} (M : Map) (K : Ctx) (s : St S') (recv v : Val) : Prop :=
  ∀ a o kk b off n, recv = .obj a → s.obj? a = some o → o.kind = .typed kk b off n →
    ∀ i, v = .big i → (K.lo : Int) ≤ i → i < K.hi → 0 ≤ M.big i ∧ M.big i < 2 ^ 63

/-- `StoreTargetOK` with `PutOKX`. -/
def StoreTargetOKX (F : Ffi) (K : Ctx) (s : St F.S) (S : SSrv) (x : Target) (v : Val) : Prop :=
  match x with
  | .var _ _ => True
  | .prop o k => PutOKX F K s S o k v
  | .priv o _ _ => ∀ a, o = .obj a → K.fr a = none

theorem bigRange_of {k : EltK} {j : Int} (h : 0 ≤ j ∧ j < 2 ^ 63) : BufSim.BigRange k j := by
  unfold BufSim.BigRange
  refine ⟨h.1, ?_⟩
  cases k <;> simp only <;> omega

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

theorem typedPut_simX (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) (hI : M.Intr) (hn : s.next < Sim.bound)
    (hP : Present s aTypeErrorProto) {a : Nat} {o : Obj} {kk : EltK} {b off n i : Nat} {v : Val}
    (hv : Supp.val (Present s) S.tab.length v)
    (hb : ∀ j, v = .big j → BufSim.toCellBig kk (M.big j) = (BufSim.toCellBig kk j).map M.cell) :
    MSim (StepPost F FR M ν K S C) S C (typedPut F s a o kk b off n i v)
      (typedPut F t (M.a a) (M.obj o) kk (M.a b) off n i (M.val v)) := by
  unfold typedPut
  refine MSim.bind (BufSim.toCell_sim (A := Present s) h.srv kk v hv hb) ?_
  rintro M' S' C' r r' ⟨rfl, hg, hsupp⟩
  have h' := h.grow hFR hg
  have hI' := hI.ext hg.ext
  have hva : M'.val v = M.val v := (Map.val_agree hg.ext.agree hv).symm
  have hle : S.tab.length ≤ S'.tab.length := hg.len
  have hPid : ∀ x, Present s x → Present s x := fun _ hx => hx
  have hv' : Supp.val (Present s) S'.tab.length v := Supp.val_mono hPid hle hv
  cases r with
  | none => exact StepPost.after hg (typeErr_sim h' hI' hn hP _)
  | some c =>
    simp only [Option.map_some]
    refine MSim.cond _ ?_ (MSim.pure ⟨hg, by rw [← hva]; exact h'.ret v hv'⟩)
    cases hb : s.obj? b with
    | none => exact MSim.fail _ _
    | some bo =>
      have hso := h.obj?_supp hb
      obtain ⟨kd, pr, ps, pv, ex⟩ := bo
      cases kd with
      | buf bs =>
        have hfr : K.fr b = none := h.fr_none hb (fun es he => by cases he)
        have hb' := h'.obj? hb hfr
        rw [hg.ext.a] at hb'
        rw [hb']
        have hso' := Supp.obj_mono hPid hle hso
        have hnew := h'.setObj ⟨.buf (writeCell kk c bs (off + i * kk.size)), pr, ps, pv, ex⟩ hn
          (Present.of_get (obj?_iff.1 hb)) hfr
          ⟨writeCell_supp _ (hsupp c rfl) hso'.1, hso'.2.1, hso'.2.2.1, hso'.2.2.2⟩
        have hnew' := hnew.ret v (Supp.val_mono (h'.present_set hn (Present.of_get (obj?_iff.1 hb)) _) (Nat.le_refl _) hv')
        have e : M'.obj ⟨.buf (writeCell kk c bs (off + i * kk.size)), pr, ps, pv, ex⟩ =
            { M'.obj ⟨.buf bs, pr, ps, pv, ex⟩ with
              kind := .buf (writeCell kk (M'.cell c) (bs.map M'.byte) (off + i * kk.size)) } := by
          simp only [Map.obj, Map.kind, writeCell_map]
        rw [e, hg.ext.a, hva] at hnew'
        exact MSim.pure ⟨hg, hnew'⟩
      | _ => exact MSim.fail _ _

/-- `o[k] = v` (strict mode): own data, setter, array index or length, typed-array
element, or a new property. -/
theorem putV_simX (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hI : M.Intr) (hn : s.next < Sim.bound) (hP : Present s aTypeErrorProto) (hPR : Present s aRangeErrorProto)
    {recv : Val} {k : PKey} {v : Val} (hk : Supp.key (Present s) S.tab.length k)
    (hv : Supp.val (Present s) S.tab.length v) (hok : PutOKX F K s S recv k v)
    (hr : PutRangeOK M K s recv v) :
    MSim (StepPost F FR M ν K S C) S C (putV F s recv k v) (putV F t (M.val recv) (M.key k) (M.val v)) := by
  cases recv with
  | obj a =>
    obtain ⟨hfr, hok'⟩ := hok a rfl
    unfold putV
    simp only [Map.val]
    cases ho : s.obj? a with
    | none => exact MSim.fail _ _
    | some o =>
      obtain ⟨hch, hcell⟩ := hok' o ho
      have ord := putOrd_sim h hF hI hn hP ho hfr hk hv hch
      have ha : Present s a := Present.of_get (obj?_iff.1 ho)
      have hso := h.obj?_supp ho
      have hP' := h.present_set hn ha
      rw [h.obj? ho hfr]
      simp only
      rw [keyIndex_map, show (M.obj o).kind = M.kind o.kind from rfl]
      obtain ⟨kd, pr, ps, pv, ex⟩ := o
      cases kd with
      | array es =>
        rw [show M.kind (.array es) = .array (M.vals es) from rfl]
        cases hi : keyIndex k with
        | some i =>
          simp only
          refine MSim.cond _ ?_ (typeErr_sim h hI hn hP _)
          have := (h.setObj ⟨.array (setNth .undef es i v), pr, ps, pv, ex⟩ hn ha hfr
            ⟨setNth_supp (d := .undef) trivial hv hso.1, hso.2.1, hso.2.2.1, hso.2.2.2⟩).ret v
            (Supp.val_mono (hP' _) (Nat.le_refl _) hv)
          have e : M.obj ⟨.array (setNth .undef es i v), pr, ps, pv, ex⟩ =
              { M.obj ⟨.array es, pr, ps, pv, ex⟩ with kind := .array (setNth .undef (M.vals es) i (M.val v)) } := by
            simp only [Map.obj, Map.kind, Map.vals, setNth_map]
            rfl
          rw [e] at this
          exact MSim.pure ⟨Grow.refl h.srv, this⟩
        | none =>
          simp only
          have hkl : keyEq (M.key k) kLength = keyEq k kLength := keyEq_map_str h.inj hk _
          rw [hkl]
          refine MSim.cond _ ?_ ord
          cases v with
          | num x =>
            cases x with
            | lit x =>
              simp only [Map.nv]
              cases hx : F64.toIndex? x with
              | none => exact rangeErr_sim h hI hn hPR _
              | some n =>
                simp only
                refine MSim.cond _ ?_ (typeErr_sim h hI hn hP _)
                have := (h.setObj ⟨.array (resize es n), pr, ps, pv, ex⟩ hn ha hfr
                  ⟨resize_supp hso.1 n, hso.2.1, hso.2.2.1, hso.2.2.2⟩).ret (.num (.lit x)) trivial
                have e : M.obj ⟨.array (resize es n), pr, ps, pv, ex⟩ =
                    { M.obj ⟨.array es, pr, ps, pv, ex⟩ with kind := .array (resize (M.vals es) n) } := by
                  simp only [Map.obj, Map.kind, resize_map]
                rw [e] at this
                exact MSim.pure ⟨Grow.refl h.srv, this⟩
            | ref j => exact MSim.fail _ _
          | undef => exact MSim.fail _ _
          | null => exact MSim.fail _ _
          | bool _ => exact MSim.fail _ _
          | big _ => exact MSim.fail _ _
          | str _ => exact MSim.fail _ _
          | sym _ => exact MSim.fail _ _
          | obj _ => exact MSim.fail _ _
          | ptr _ _ => exact MSim.fail _ _
      | typed kk b off n =>
        rw [show M.kind (.typed kk b off n) = .typed kk (M.a b) off n from rfl]
        cases hi : keyIndex k with
        | some i => exact typedPut_simX h hFR hI hn hP hv (fun j hj => BufSim.toCellBig_map h
            (hcell kk b off n rfl j hj) (fun hlo hhi => bigRange_of (hr a _ kk b off n rfl ho rfl j hj hlo hhi)))
        | none => exact ord
      | ns ex => exact typeErr_sim h hI hn hP _
      | ordinary => exact ord
      | fn _ => exact ord
      | buf _ => exact ord
      | extBuf _ _ _ => exact ord
      | view _ _ _ => exact ord
      | map _ => exact ord
      | set _ => exact ord
      | promise _ => exact ord
      | gen _ _ _ => exact ord
      | box _ => exact ord
      | iter _ _ _ => exact ord
  | undef => exact typeErr_sim h hI hn hP _
  | null => exact typeErr_sim h hI hn hP _
  | bool _ => exact typeErr_sim h hI hn hP _
  | num _ => exact typeErr_sim h hI hn hP _
  | big _ => exact typeErr_sim h hI hn hP _
  | str _ => exact typeErr_sim h hI hn hP _
  | sym _ => exact typeErr_sim h hI hn hP _
  | ptr _ _ => exact typeErr_sim h hI hn hP _


theorem storeTarget_simX (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hn : s.next < Sim.bound)
    (hpT : Present s aTypeErrorProto) (hpRef : Present s aReferenceErrorProto) (hFR : FRLaws FR)
    (hpR : Present s aRangeErrorProto) {x : Target} {v : Val}
    (hx : Supp.target (Present s) S.tab.length x) (hv : Supp.val (Present s) S.tab.length v)
    (hok : StoreTargetOKX F K s S x v) (hr : ∀ o k, x = .prop o k → PutRangeOK M K s o v) :
    MSim (StepPost F FR M ν K S C) S C (storeTarget F s x v) (storeTarget F t (M.target x) (M.val v)) := by
  cases x with
  | var n env => exact rf_writeVar h hn hpRef hx hv
  | prop o k => exact putV_simX h hF hFR h.intr hn hpT hpR hx.2 hv hok (hr o k rfl)
  | priv o b nm => exact privPutV_sim h h.intr hn hpT hx.1 hx.2 hv hok

/-- The `put` frame of a plain assignment, with `StoreTargetOKX`. -/
theorem step_retA_putX (h : Rel F FR M ν K s S t C) (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hn : s.next < Sim.bound) {v : Val} {fs : List Frame} {x : Target} {old : Val} (hc : s.ctl = .ret v)
    (hs : s.stack = .a (.put none x old) :: fs) (hpT : Present s aTypeErrorProto)
    (hpR : Present s aRangeErrorProto) (hpRef : Present s aReferenceErrorProto)
    (hok : StoreTargetOKX F K s S x v) (hr : ∀ o k, x = .prop o k → PutRangeOK M K s o v) :
    MSim (StepPost F FR M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hr', hv, hf⟩ := h.rfRetFrame hc hs
  rw [e1, e2]
  obtain ⟨hx, _⟩ := hf
  exact storeTarget_simX hr' hF hn hpT hpRef hFR hpR hx hv hok hr

end

/-! ## Deciders -/

section
variable {F : Ffi} (P : JSP F)

/-- `PutOKX`, with the band condition of `PutRangeOK` (typed stores: `convB`). -/
def putXB (s : St F.S) (n : Nat) (recv : Val) (k : PKey) (v : Val) : Bool :=
  match recv with
  | .obj a => frB P a && (match s.obj? a with
    | some o => (match o.proto with
        | .obj p => plainKeyB k || chainB P s n k 16 p
        | _ => true) &&
      (match o.kind with
        | .typed kk _ _ _ => convB P s kk v
        | _ => true)
    | none => true)
  | _ => true

/-- `StoreTargetOKX`. -/
def storeTargetXB (s : St F.S) (n : Nat) (x : Target) (v : Val) : Bool :=
  match x with
  | .var _ _ => true
  | .prop o k => putXB P s n o k v
  | .priv o _ _ => match o with
    | .obj a => frB P a
    | _ => true

end

section
variable {F : Ffi} {P : JSP F} {K : Ctx}

theorem Kp.putX (hK : Kp P K) {s : St F.S} {S : SSrv} {recv : Val} {k : PKey} {v : Val}
    (h : putXB P s S.tab.length recv k v = true) : PutOKX F K s S recv k v := by
  rintro a rfl
  simp only [putXB, Bool.and_eq_true] at h
  refine ⟨hK.fr_none h.1, fun o ho => ?_⟩
  simp only [ho, Bool.and_eq_true] at h
  refine ⟨fun p hp => ?_, fun kk b off n hk => ?_⟩
  · have h1 := h.2.1
    simp only [hp, Bool.or_eq_true] at h1
    rcases h1 with h1 | h1
    · have := plainKeyB_sound h1
      exact ChainOK.of_plain this.1 this.2 16 p
    · exact hK.chain h1
  · have h2 := h.2.2
    simp only [hk] at h2
    exact hK.conv h2

theorem putXB_range {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {s t : St F.S}
    {S : SSrv} {C : CSrv} (hK : Kp P K) (hN : NativeFacts F FR P) (h : Rel F FR M ν K s S t C)
    {recv : Val} {k : PKey} {v : Val} (hb : putXB P s S.tab.length recv k v = true) : PutRangeOK M K s recv v := by
  rintro a o kk b off n rfl ho hk i rfl hlo hhi
  simp only [putXB, Bool.and_eq_true, ho, hk] at hb
  have hc := hb.2.2
  simp only [convB, Bool.or_eq_true, Bool.and_eq_true] at hc
  rcases hc with ⟨h1, _⟩ | ⟨_, h2⟩
  · exact absurd (hK.bf h1) (fun hf => not_band_of_fixed hf hlo hhi)
  · exact hN.range M _ _ _ h.ffi i h2

theorem Kp.storeTargetX (hK : Kp P K) {s : St F.S} {S : SSrv} {x : Target} {v : Val}
    (h : storeTargetXB P s S.tab.length x v = true) : StoreTargetOKX F K s S x v := by
  cases x with
  | var _ _ => trivial
  | prop o k => exact hK.putX h
  | priv o _ _ =>
    rintro a rfl
    exact hK.fr_none h

theorem storeTargetXB_range {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {s t : St F.S}
    {S : SSrv} {C : CSrv} (hK : Kp P K) (hN : NativeFacts F FR P) (h : Rel F FR M ν K s S t C)
    {x : Target} {v : Val} (hb : storeTargetXB P s S.tab.length x v = true) :
    ∀ o k, x = .prop o k → PutRangeOK M K s o v := by
  rintro o k rfl
  exact putXB_range hK hN h hb

end
end Host.Ts.Sim.Disp
