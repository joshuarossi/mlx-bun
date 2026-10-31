import host.sim.world.Route
namespace Host.Ts.Sim
open Host.Ts Host.Ts.Sim.Prefill

/-- The saved binding is fixed; its unframed array may be mapped to another address. -/
theorem RelB.emittedMappedW {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St F.S} {S : SSrv} {C : CSrv}
    (h : RelB F FR W stk M ν K s S t C)
    {env : Env} {nm : Name} {cell array : Nat} {o : Obj} {xs : List Val}
    (hl : lookupEnv nm env = some cell)
    (hc : s.cell? cell = some (some (.obj array)))
    (hcell : M.a cell = cell) (ho : s.obj? array = some o)
    (hkind : o.kind = .array xs) (hframe : K.fr array = none) (hwide : W cell = none) :
    (bindingOf t env nm).bind (elementsW t) = some (M.vals xs) := by
  have ht := h.cell? hc (.inl hwide)
  rw [hcell] at ht
  have ho' := h.obj? ho hframe
  unfold bindingOf
  rw [hl, Option.bind_some, ht]
  change elementsW t (.obj (M.a array)) = _
  simp only [elementsW, objectW, ho']
  show (match M.kind o.kind with | .array es => some es | _ => none) = _
  rw [hkind]
  rfl

/-- Number-server correspondence evaluates the mapped emitted array at the same witness. -/
theorem RelB.emittedMappedValsW {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop}
    {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s t : St F.S} {S : SSrv} {C : CSrv}
    (h : RelB F FR W stk M ν K s S t C)
    {env : Env} {nm : Name} {cell array : Nat} {o : Obj} {xs : List Val} {vs : List F64}
    (hl : lookupEnv nm env = some cell)
    (hc : s.cell? cell = some (some (.obj array)))
    (hcell : M.a cell = cell) (ho : s.obj? array = some o)
    (hkind : o.kind = .array xs) (hframe : K.fr array = none) (hwide : W cell = none)
    (hv : xs.mapM (symValW S ν) = some vs) :
    emittedValsW t env nm C = some vs := by
  apply emittedValsW_of (h.emittedMappedW hl hc hcell ho hkind hframe hwide)
  exact mapM_vals (numVal_of_sym h.srv.num) xs vs hv

end Host.Ts.Sim
