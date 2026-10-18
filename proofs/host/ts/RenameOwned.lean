import host.ts.RenameFresh
import host.ts.RenameLoadReadback
namespace Host.Ts.Owned

inductive ListR {α β : Type} (rel : α → β → Prop) : List α → List β → Prop where
  | nil : ListR rel [] []
  | cons {a : α} {b : β} {as : List α} {bs : List β} :
      rel a b → ListR rel as bs → ListR rel (a :: as) (b :: bs)

/-- Roles belong to occurrences. Equal integer values in an arithmetic argument
and in a native-handle field can therefore have different target values. -/
inductive ValueR (R : Ren) : Val → Val → Prop where
  | undef : ValueR R .undef .undef
  | null : ValueR R .null .null
  | bool (b : Bool) : ValueR R (.bool b) (.bool b)
  | str (n : Name) : ValueR R (.str n) (.str n)
  | num (n : NumV) : ValueR R (.num n) (.num (R.num n))
  | ordinaryBig (i : Int) : ValueR R (.big i) (.big i)
  | handle (h : Nat) : ValueR R (.big (Int.ofNat h)) (.big (Int.ofNat (R.handle h)))
  | pointerInteger (m : Mem) (off : Nat) :
      ValueR R (.big (ptrInt m off)) (.big (ptrInt (R.mem m) off))
  | obj (a : Nat) : ValueR R (.obj a) (.obj (R.a a))
  | sym (a : Nat) : ValueR R (.sym a) (.sym (R.sym a))
  | ptr (m : Mem) (off : Nat) : ValueR R (.ptr m off) (.ptr (R.mem m) off)

inductive CellR (R : Ren) : Cell → Cell → Prop where
  | num (n : NumV) : CellR R (.num n) (.num (R.num n))
  | ordinaryBig (i : Int) : CellR R (.big i) (.big i)
  | handle (h : Nat) : CellR R (.big (Int.ofNat h)) (.big (Int.ofNat (R.handle h)))
  | pointerInteger (m : Mem) (off : Nat) :
      CellR R (.big (ptrInt m off)) (.big (ptrInt (R.mem m) off))

inductive ByteR (R : Ren) : Byte → Byte → Prop where
  | lit (n : Nat) : ByteR R (.lit n) (.lit n)
  | part {c c' : Cell} (k : EltK) (i : Nat) : CellR R c c' → ByteR R (.part k c i) (.part k c' i)

inductive ArgR (R : Ren) : Arg → Arg → Prop where
  | num (n : NumV) : ArgR R (.num n) (.num (R.num n))
  | bool (b : Bool) : ArgR R (.bool b) (.bool b)
  | ordinaryBig (i : Int) : ArgR R (.big i) (.big i)
  | handle (h : Nat) : ArgR R (.big (Int.ofNat h)) (.big (Int.ofNat (R.handle h)))
  | pointerInteger (m : Mem) (off : Nat) :
      ArgR R (.big (ptrInt m off)) (.big (ptrInt (R.mem m) off))
  | jsPtr {bs bs' : List Byte} (b off : Nat) : ListR (ByteR R) bs bs' →
      ArgR R (.jsPtr b off bs) (.jsPtr (R.a b) off bs')
  | extPtr (r off : Nat) : ArgR R (.extPtr r off) (.extPtr (R.region r) off)
  | other {v v' : Val} : ValueR R v v' → ArgR R (.other v) (.other v')
  | null : ArgR R .null .null

theorem cellParts_related {R : Ren} {c c' : Cell} (hc : CellR R c c') (k : EltK) :
    ∀ n i, ListR (ByteR R) (cellParts k c n i) (cellParts k c' n i)
  | 0, _ => .nil
  | n + 1, i => .cons (.part k i hc) (cellParts_related hc k n (i + 1))

/-- The actual scalar bigint shift used by optional-integer packing. Ordinary
operands and its possibly large result retain their values, independently of
the map used for native handles. -/
theorem step_bigShl (F : Ffi) (R : Ren) (s s' : St F.S) (a : Int) (b : Nat)
    (fs fs' : List Frame)
    (hc : s.ctl = .ret (.big (Int.ofNat b))) (hc' : s'.ctl = .ret (.big (Int.ofNat b)))
    (hf : s.stack = .e (.binR .shl (.big a)) :: fs)
    (hf' : s'.stack = .e (.binR .shl (.big a)) :: fs') :
    let value := Val.big (a * (2 ^ b : Nat))
    step F s = M.pure ({ s with stack := fs }.ret value) ∧
      step F s' = M.pure ({ s' with stack := fs' }.ret value) ∧ ValueR R value value := by
  dsimp only
  refine ⟨?_, ?_, .ordinaryBig _⟩
  · simp only [step, hc, stepRet, hf, retStep, retE, binOp, arith, bigOp, retS]
  · simp only [step, hc', stepRet, hf', retStep, retE, binOp, arith, bigOp, retS]

inductive ScalarBitOp where
  | band | bor | bxor

def ScalarBitOp.op : ScalarBitOp → BinOp
  | .band => .band | .bor => .bor | .bxor => .bxor

def ScalarBitOp.eval : ScalarBitOp → Nat → Nat → Nat
  | .band => Nat.land | .bor => Nat.lor | .bxor => Nat.xor

/-- Actual scalar bitwise steps preserve ordinary bigint roles. In particular,
packing a has-value bit does not accidentally create a renamed native handle. -/
theorem step_bigBitwise (F : Ffi) (R : Ren) (op : ScalarBitOp) (s s' : St F.S) (a b : Nat)
    (fs fs' : List Frame)
    (hc : s.ctl = .ret (.big (Int.ofNat b))) (hc' : s'.ctl = .ret (.big (Int.ofNat b)))
    (hf : s.stack = .e (.binR op.op (.big (Int.ofNat a))) :: fs)
    (hf' : s'.stack = .e (.binR op.op (.big (Int.ofNat a))) :: fs') :
    let value := Val.big (Int.ofNat (op.eval a b))
    step F s = M.pure ({ s with stack := fs }.ret value) ∧
      step F s' = M.pure ({ s' with stack := fs' }.ret value) ∧ ValueR R value value := by
  dsimp only
  refine ⟨?_, ?_, .ordinaryBig _⟩
  · cases op <;> simp only [step, hc, stepRet, hf, retStep, retE, binOp, arith, bigOp,
      bigNat2, ScalarBitOp.op, ScalarBitOp.eval, retS, Int.ofNat_eq_natCast]
  · cases op <;> simp only [step, hc', stepRet, hf', retStep, retE, binOp, arith, bigOp,
      bigNat2, ScalarBitOp.op, ScalarBitOp.eval, retS, Int.ofNat_eq_natCast]

/-- Actual native `BigInt(number)` conversion produces an ordinary bigint. The
number is concrete on this path, as required by the interpreter's implementation. -/
theorem step_bigint_number (F : Ffi) (R : Ren) (s s' : St F.S) (fn fn' : Nat) (fo fo' : Obj)
    (x : F64) (i : Int)
    (hc : s.ctl = .call (.obj fn) .undef [.num (.lit x)])
    (hc' : s'.ctl = .call (.obj fn') .undef [.num (.lit x)])
    (ho : s.obj? fn = some fo) (ho' : s'.obj? fn' = some fo')
    (hk : fo.kind = .fn (.native (.num .bigint) []))
    (hk' : fo'.kind = .fn (.native (.num .bigint) []))
    (hx : F64.toInt? x = some i) :
    step F s = M.pure (s.ret (.big i)) ∧ step F s' = M.pure (s'.ret (.big i)) ∧
      ValueR R (.big i) (.big i) := by
  refine ⟨?_, ?_, .ordinaryBig _⟩
  · simp only [step, hc, callStep, ho, hk, callNative, numN, arg, nthD, hx, retS]
  · simp only [step, hc', callStep, ho', hk', callNative, numN, arg, nthD, hx, retS]

theorem step_bigint_pointer (F : Ffi) (R : Ren) (s s' : St F.S) (fn fn' : Nat) (fo fo' : Obj)
    (m : Mem) (off : Nat)
    (hc : s.ctl = .call (.obj fn) .undef [.ptr m off])
    (hc' : s'.ctl = .call (.obj fn') .undef [.ptr (R.mem m) off])
    (ho : s.obj? fn = some fo) (ho' : s'.obj? fn' = some fo')
    (hk : fo.kind = .fn (.native (.num .bigint) []))
    (hk' : fo'.kind = .fn (.native (.num .bigint) [])) :
    step F s = M.pure (s.ret (.big (ptrInt m off))) ∧
      step F s' = M.pure (s'.ret (.big (ptrInt (R.mem m) off))) ∧
      ValueR R (.big (ptrInt m off)) (.big (ptrInt (R.mem m) off)) := by
  refine ⟨?_, ?_, .pointerInteger m off⟩
  · simp only [step, hc, callStep, ho, hk, callNative, numN, arg, nthD, retS]
  · simp only [step, hc', callStep, ho', hk', callNative, numN, arg, nthD, retS]

theorem step_bigint_big (F : Ffi) (R : Ren) (s s' : St F.S) (fn fn' : Nat) (fo fo' : Obj)
    (i i' : Int) (hv : ValueR R (.big i) (.big i'))
    (hc : s.ctl = .call (.obj fn) .undef [.big i])
    (hc' : s'.ctl = .call (.obj fn') .undef [.big i'])
    (ho : s.obj? fn = some fo) (ho' : s'.obj? fn' = some fo')
    (hk : fo.kind = .fn (.native (.num .bigint) []))
    (hk' : fo'.kind = .fn (.native (.num .bigint) [])) :
    step F s = M.pure (s.ret (.big i)) ∧ step F s' = M.pure (s'.ret (.big i')) ∧
      ValueR R (.big i) (.big i') := by
  refine ⟨?_, ?_, hv⟩
  · simp only [step, hc, callStep, ho, hk, callNative, numN, arg, nthD, retS]
  · simp only [step, hc', callStep, ho', hk', callNative, numN, arg, nthD, retS]

private theorem readU32_pure (s : Host.Load.LSt) (b off : Nat) (bs : List Byte)
    (handle node : Nat) (n : Host.Mlx.Ffi.Node) (token : NumV) (tail : List NumV)
    (hid : s.mlx.nodeId? handle = some node) (hn : s.mlx.node? handle = some n)
    (hd : Nat.beq n.dtype Host.Mlx.Ffi.dtUint32 = true) (hm : s.mlx.items.get node = none)
    (ht : s.mlx.tokens = token :: tail) :
    Host.Load.call s chars!"mlx_array_item_uint32" [.jsPtr b off bs, .big (Int.ofNat handle)] =
      M.pure (some ({ s with mlx := { s.mlx with tokens := tail, items := s.mlx.items.set node token } },
        Host.Mlx.Ffi.status0, [(b, off, cellParts .u32 (.num token) 4 0)])) := by
  have h := Host.Mlx.Ffi.itemU32_first_pure s.mlx b off bs handle node n token tail hid hn hd hm ht
  have hmlx : Host.Load.isMlx chars!"mlx_array_item_uint32" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call, hmlx, Bool.cond_true, h, M.bind, M.pure]

/-- Symbol-specific roles for the actual load-world uint32 read: its second
argument is an owned handle, while the read value and written cell are numbers.
No map of ordinary bigints is required by this invocation. -/
theorem call_readU32_roles (R : Ren) (s s' : Host.Load.LSt) (b off handle node : Nat)
    (bs bs' : List Byte) (n n' : Host.Mlx.Ffi.Node) (token : NumV) (tail tail' : List NumV)
    (hb : ListR (ByteR R) bs bs')
    (hid : s.mlx.nodeId? handle = some node) (hn : s.mlx.node? handle = some n)
    (hd : Nat.beq n.dtype Host.Mlx.Ffi.dtUint32 = true) (hm : s.mlx.items.get node = none)
    (ht : s.mlx.tokens = token :: tail)
    (hid' : s'.mlx.nodeId? (R.handle handle) = some (R.node node))
    (hn' : s'.mlx.node? (R.handle handle) = some n')
    (hd' : Nat.beq n'.dtype Host.Mlx.Ffi.dtUint32 = true) (hm' : s'.mlx.items.get (R.node node) = none)
    (ht' : s'.mlx.tokens = R.num token :: tail') :
    Host.Load.call s chars!"mlx_array_item_uint32" [.jsPtr b off bs, .big (Int.ofNat handle)] =
        M.pure (some ({ s with mlx := { s.mlx with tokens := tail, items := s.mlx.items.set node token } },
          Host.Mlx.Ffi.status0, [(b, off, cellParts .u32 (.num token) 4 0)])) ∧
      Host.Load.call s' chars!"mlx_array_item_uint32"
        [.jsPtr (R.a b) off bs', .big (Int.ofNat (R.handle handle))] =
        M.pure (some ({ s' with mlx := { s'.mlx with tokens := tail', items := s'.mlx.items.set (R.node node) (R.num token) } },
          Host.Mlx.Ffi.status0, [(R.a b, off, cellParts .u32 (.num (R.num token)) 4 0)])) ∧
      ListR (ArgR R) [.jsPtr b off bs, .big (Int.ofNat handle)]
        [.jsPtr (R.a b) off bs', .big (Int.ofNat (R.handle handle))] ∧
      ListR (ByteR R) (cellParts .u32 (.num token) 4 0) (cellParts .u32 (.num (R.num token)) 4 0) := by
  refine ⟨readU32_pure s b off bs handle node n token tail hid hn hd hm ht,
    readU32_pure s' (R.a b) off bs' (R.handle handle) (R.node node) n' (R.num token) tail' hid' hn' hd' hm' ht',
    .cons (.jsPtr b off hb) (.cons (.handle handle) .nil), ?_⟩
  exact cellParts_related (.num token) .u32 4 0

end Host.Ts.Owned
