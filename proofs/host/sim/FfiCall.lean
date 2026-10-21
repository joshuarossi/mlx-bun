import host.sim.Ffi
namespace Host.Ts.Sim

/-! # Native calls with numeric premises

Native shape computations do exact integer arithmetic on literal dimensions and
server arithmetic on symbolic ones. A symbolic source dimension and its literal
target image agree only when the values involved are small integers at the
target iteration's valuation. `FfiCallSim` is `FfiSim.call` with that premise:
`small ν S x name args` is a fact about the source call (its number references,
including those its native inputs carry) at the valuation, which the checked
run establishes from bounds on the template variables. -/

structure FfiCallSim (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (okCall : F.S → Name → List Arg → Bool)
    (small : (Nat → F64) → SSrv → F.S → Name → List Arg → Prop) : Prop where
  call : ∀ M ν S C x y name args, Srv M ν S C → FR M S.tab.length x y → okCall x name args = true →
    (∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) → small ν S x name args →
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR FR M' S'.tab.length r r') S C
      (F.call x name args) (F.call y name (args.map M.arg))

/-- Every `FfiSim` gives an `FfiCallSim` with the trivial premise. -/
theorem FfiSim.callSim {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {okCall : F.S → Name → List Arg → Bool}
    {okBack : F.S → Arg → Bool} (h : FfiSim F FR okCall okBack) :
    FfiCallSim F FR okCall (fun _ _ _ _ _ => True) :=
  ⟨fun M ν S C x y name args hs hr hok hsupp _ => h.call M ν S C x y name args hs hr hok hsupp⟩

end Host.Ts.Sim
