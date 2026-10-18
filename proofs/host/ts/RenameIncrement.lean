import host.ts.RenameBounded
namespace Host.Ts

/-- Actual interpreter addition of a referenced counter and a literal increment
specializes to literal arithmetic, including the different number-allocation paths. -/
theorem step_numAdd_ref_lit_materialize (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C E : CSrv) (i : Nat) (fs : List Frame) (x y : F64)
    (hc : s.ctl = .ret (.num (.lit y)))
    (hf : s.stack = .e (.binR .add (.num (.ref i))) :: fs)
    (hx : C.val (.ref i) = some x) (closed : NumericClosedWith ffiMap C s) :
    let D : CSrv := ⟨C.tab ++ [F64.bin .add x y]⟩
    let t := { s with ctl := .ret (.num (.ref C.tab.length)), stack := fs }
    interpC (step F s).run C = some (t, D) ∧
      interpC (step F (materializeStateWith ffiMap C s)).run E =
        some (materializeStateWith ffiMap D t, E) ∧ NumericClosedWith ffiMap D t := by
  dsimp only
  let D : CSrv := ⟨C.tab ++ [F64.bin .add x y]⟩
  have hm := materialize_num C (.ref i) x hx
  have hcs : (materializeStateWith ffiMap C s).ctl = .ret (.num (.lit y)) := by
    change (materializer C).ctl s.ctl = _
    rw [hc]
  have hfs : (materializeStateWith ffiMap C s).stack =
      .e (.binR .add (.num (.lit x))) :: fs.map (materializer C).frame := by
    change s.stack.map (materializer C).frame = _
    rw [hf]
    change Frame.e (.binR .add (.num ((materializer C).num (.ref i)))) :: _ = _
    rw [hm]
  have hnew : D.val (.ref C.tab.length) = some (F64.bin .add x y) :=
    nth?_append_length C.tab _
  have ht := materialize_number_return ffiMap C D s closed (TableExtends.append C _)
    (.ref C.tab.length) (F64.bin .add x y) hnew (.e (.binR .add (.num (.ref i)))) fs hf
  constructor
  · have hx' : nth? C.tab i = some x := hx
    simp only [step, hc, stepRet, hf, retStep, retE, binOp, addOp, arith, toNum, numOp?, M.bind, M.pure,
      numBin, M.bin, M.run, retS, St.ret, interpC_bin, CSrv.val, hx', interpC_pure]
  constructor
  · change interpC (step F (materializeStateWith ffiMap C s)).run E =
      some (materializeStateWith ffiMap D { s with ctl := .ret (.num (.ref C.tab.length)), stack := fs }, E)
    rw [ht]
    simp only [step, hcs, stepRet, hfs, retStep, retE, binOp, addOp, arith, toNum, numOp?, M.bind, M.pure,
      numBin, M.run, retS, St.ret, interpC_pure]
  · exact (closed.mono (TableExtends.append C _)).ret_number (.ref C.tab.length)
      (F64.bin .add x y) hnew (.e (.binR .add (.num (.ref i)))) fs hf

/-- The actual postfix update of a source variable writes the incremented value
to its heap cell. Materialization preserves the whole post-update machine state,
including the waiting frame that returns the old postfix value. -/
theorem step_postinc_var_materialize (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C E : CSrv) (i : Nat) (fs : List Frame) (x : F64)
    (name : Name) (env : Env) (address : Nat)
    (hc : s.ctl = .ret (.num (.ref i)))
    (hf : s.stack = .a (.updOld true false (.var name env)) :: fs)
    (he : lookupEnv name env = some address)
    (hcell : s.cell? address = some (some (.num (.ref i))))
    (hx : C.val (.ref i) = some x) (closed : NumericClosedWith ffiMap C s) :
    let result := F64.bin .add x (F64.ofNat 1)
    let D : CSrv := ⟨C.tab ++ [result]⟩
    let t := { s.setCell address (.num (.ref C.tab.length)) with
      ctl := .ret (.num (.ref C.tab.length))
      stack := .e (.const (.num (.ref i))) :: fs }
    interpC (step F s).run C = some (t, D) ∧
      interpC (step F (materializeStateWith ffiMap C s)).run E =
        some (materializeStateWith ffiMap D t, E) := by
  dsimp only
  let result := F64.bin .add x (F64.ofNat 1)
  let D : CSrv := ⟨C.tab ++ [result]⟩
  have hm := materialize_num C (.ref i) x hx
  have hcs : (materializeStateWith ffiMap C s).ctl = .ret (.num (.lit x)) := by
    change (materializer C).ctl s.ctl = _
    rw [hc]
    change Ctl.ret (.num ((materializer C).num (.ref i))) = _
    rw [hm]
  have hfs : (materializeStateWith ffiMap C s).stack =
      .a (.updOld true false (.var name env)) :: fs.map (materializer C).frame := by
    change s.stack.map (materializer C).frame = _
    rw [hf]
    change Frame.a (.updOld true false (.var name ((materializer C).env env))) :: _ = _
    rw [materializer_env]
  have hcell' : (materializeStateWith ffiMap C s).cell? address = some (some (.num (.lit x))) := by
    rw [materializeStateWith_cell, hcell]
    change some (some (Val.num ((materializer C).num (.ref i)))) = _
    rw [hm]
  have hx' : nth? C.tab i = some x := hx
  have hn : D.val (.ref C.tab.length) = some result := nth?_append_length C.tab _
  have hold := materialize_num D (.ref i) x ((TableExtends.append C [result]).val hx)
  have hnew := materialize_num D (.ref C.tab.length) result hn
  have hs := closed D (TableExtends.append C _)
  have htail : fs.map (materializer D).frame = fs.map (materializer C).frame := by
    have hh := congrArg (fun u : St F.S => u.stack) hs
    change s.stack.map (materializer D).frame = s.stack.map (materializer C).frame at hh
    rw [hf] at hh
    exact (List.cons.inj hh).2
  have ht : materializeStateWith ffiMap D
      { s.setCell address (.num (.ref C.tab.length)) with
        ctl := .ret (.num (.ref C.tab.length))
        stack := .e (.const (.num (.ref i))) :: fs } =
      { (materializeStateWith ffiMap C s).setCell address (.num (.lit result)) with
        ctl := .ret (.num (.lit result))
        stack := .e (.const (.num (.lit x))) :: fs.map (materializer C).frame } := by
    rw [materializeStateWith_control, materializeStateWith_setCell, hs]
    change { (materializeStateWith ffiMap C s).setCell address (.num ((materializer D).num (.ref C.tab.length))) with
      ctl := .ret (.num ((materializer D).num (.ref C.tab.length)))
      stack := .e (.const (.num ((materializer D).num (.ref i)))) :: fs.map (materializer D).frame } = _
    rw [hnew, hold, htail]
  constructor
  · simp only [step, hc, stepRet, hf, retStep, retA, toNum, numBin, M.bind, M.pure, M.bin,
      M.run, interpC_bin, CSrv.val, hx', interpC_pure, Bool.cond_true, Bool.cond_false,
      storeTarget, writeVar, he, cell?_control, hcell, retS, St.push, St.ret, St.setCell, one]
    rfl
  · change interpC (step F (materializeStateWith ffiMap C s)).run E =
      some (materializeStateWith ffiMap D
        { s.setCell address (.num (.ref C.tab.length)) with
          ctl := .ret (.num (.ref C.tab.length))
          stack := .e (.const (.num (.ref i))) :: fs }, E)
    rw [ht]
    simp only [step, hcs, stepRet, hfs, retStep, retA, toNum, numBin, M.bind, M.pure,
      M.run, interpC_pure, Bool.cond_true, Bool.cond_false, storeTarget, writeVar, he, hcell',
      retS, St.push, St.ret, St.setCell, one, cell?_control]
    rfl

theorem postinc_numericClosed (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C : CSrv) (i : Nat) (fs : List Frame) (x : F64)
    (name : Name) (env : Env) (address : Nat)
    (hf : s.stack = .a (.updOld true false (.var name env)) :: fs)
    (hx : C.val (.ref i) = some x) (closed : NumericClosedWith ffiMap C s) :
    let result := F64.bin .add x (F64.ofNat 1)
    let D : CSrv := ⟨C.tab ++ [result]⟩
    NumericClosedWith ffiMap D { s.setCell address (.num (.ref C.tab.length)) with
      ctl := .ret (.num (.ref C.tab.length))
      stack := .e (.const (.num (.ref i))) :: fs } := by
  dsimp only
  have hext := TableExtends.append C [F64.bin .add x (F64.ofNat 1)]
  have hn := nth?_append_length C.tab (F64.bin .add x (F64.ofNat 1))
  exact ((closed.mono hext).set_number address (.ref C.tab.length) _ hn).ret_number_postfix
    (.ref C.tab.length) (.ref i) _ x hn (hext.val hx) (.a (.updOld true false (.var name env))) fs hf

/-- For every supported counter value, source `generated++` stores its exact
successor and preserves the full-state numeric specialization invariant. -/
theorem step_postinc_var_bounded (F : Ffi) (ffiMap : CSrv → F.S → F.S)
    (s : St F.S) (C E : CSrv) (i n : Nat) (fs : List Frame)
    (name : Name) (env : Env) (address : Nat)
    (hc : s.ctl = .ret (.num (.ref i)))
    (hf : s.stack = .a (.updOld true false (.var name env)) :: fs)
    (he : lookupEnv name env = some address)
    (hcell : s.cell? address = some (some (.num (.ref i))))
    (hx : C.val (.ref i) = some (F64.ofNat n)) (hn : n + 1 < 2 ^ 31)
    (closed : NumericClosedWith ffiMap C s) :
    let D : CSrv := ⟨C.tab ++ [F64.ofNat (n + 1)]⟩
    let t := { s.setCell address (.num (.ref C.tab.length)) with
      ctl := .ret (.num (.ref C.tab.length))
      stack := .e (.const (.num (.ref i))) :: fs }
    interpC (step F s).run C = some (t, D) ∧
      interpC (step F (materializeStateWith ffiMap C s)).run E =
        some (materializeStateWith ffiMap D t, E) ∧ NumericClosedWith ffiMap D t := by
  have h := step_postinc_var_materialize F ffiMap s C E i fs _ name env address hc hf he hcell hx closed
  have hclosed := postinc_numericClosed F ffiMap s C i fs _ name env address hf hx closed
  have hh := And.intro h.1 (And.intro h.2 hclosed)
  simpa only [F64.bin, F64.add_ofNat32 n 1 hn] using hh

end Host.Ts
