import host.sim.dispatch.DecideBuf
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim Host.Ts.Sim.BufSim

/-! # Deciders for the side conditions of steps/FfiJs.lean

`MemReadOK`, `ArgBufOK` (with `BufOK`), `SymOK` (decided on the source
run of the argument decoding and of the native call; results that invoke a
`JSCallback` are rejected), and the host-region condition of `toArrayBuffer`. -/

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
  | .ptr (.js b) _ => bufOKB s n b
  | .obj a => match s.obj? a with
    | some o => match o.kind with
      | .typed _ b _ _ => bufOKB s n b
      | _ => true
    | none => true
  | _ => true

def retSuppB (n : Nat) : Ret → Bool
  | .num x => nvB n x
  | .callback _ _ => false
  | _ => true

/-- `ResOK`, without `JSCallback` invocations. -/
def resB (n : Nat) : Option (F.S × Ret × List (Nat × Nat × List Byte)) → Bool
  | none => true
  | some (_, ret, ws) => retSuppB n ret && allB (fun w => bytesB n w.2.2) ws

/-- `SymOK`, and the smallness decider on the decoded arguments. -/
def symOKB (s : St F.S) (S : SSrv) (name : Name) (tys args : List Val) : Bool :=
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
variable {F : Ffi} {P : JSP F} {K : Ctx}

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

theorem argBufB_sound {s : St F.S} {n : Nat} {v : Val} (h : argBufB s n v = true) : ArgBufOK F s n v := by
  rcases v with _ | _ | _ | _ | _ | _ | _ | a | ⟨b | r, o⟩ <;> simp only [ArgBufOK] <;> try trivial
  · intro o ho k b off len hk
    simp only [argBufB, ho, hk] at h
    exact bufOKB_sound h
  · exact bufOKB_sound h

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

theorem symOKB_sound {s : St F.S} {S : SSrv} {name : Name} {tys args : List Val}
    (h : symOKB P s S name tys args = true) : SymOK F K P.okCall s S name tys args := by
  intro as S1 hd
  simp only [symOKB, hd, Bool.and_eq_true] at h
  refine ⟨h.1.1, fun r S2 hc => ?_⟩
  have h2 := h.2
  simp only [hc] at h2
  exact resB_sound h2

theorem symOKB_small {s : St F.S} {S : SSrv} {name : Name} {tys args : List Val}
    (h : symOKB P s S name tys args = true) :
    ∀ as S1, interpS (decodeArgs F s tys args).run S = some (some as, S1) → P.smallB S1 s.ffi name as = true := by
  intro as S1 hd
  simp only [symOKB, hd, Bool.and_eq_true] at h
  exact h.1.2

theorem hostB_sound {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {s t : St F.S}
    {S : SSrv} {C : CSrv} (hN : NativeFacts F FR P) (h : Rel F FR M ν K s S t C) {args : List Val}
    (hb : hostB args = true) :
    ∀ x r o, arg args 0 = .num (.lit x) → hostAddr x = some (r, o) → M.region r = r := by
  intro x r o ha hx
  simp only [hostB, ha, hx, Bool.and_eq_true, Nat.blt_eq] at hb
  exact hN.host M _ _ _ h.ffi r (Nat.eq_of_beq_eq_true hb.1) hb.2

end
end Host.Ts.Sim.Disp
