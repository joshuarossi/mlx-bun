import host.sim.Support
import host.sim.Free
namespace Host.Ts.Sim

/-! # The native interface under the map

The interpreter's step lemmas are generic in the FFI `F`; what they need of
it is `FfiSim`: native calls (and callback continuations) on related native
states with mapped arguments give related results, and native memory reads
commute with the map. `okCall` restricts the obligation to the calls the
checked run accepts. -/

/-- Results of a native call correspond. A call the source model rejects needs nothing. -/
def CallR {F : Ffi} (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (n : Nat) :
    Option (F.S × Ret × List (Nat × Nat × List Byte)) → Option (F.S × Ret × List (Nat × Nat × List Byte)) → Prop
  | none, _ => True
  | some (x, r, ws), some (y, r', ws') => FR M n x y ∧ r' = M.ret r ∧ ws' = ws.map M.write
  | some _, none => False

structure FfiSim (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (okCall : F.S → Name → List Arg → Bool)
    (okBack : F.S → Arg → Bool) : Prop where
  call : ∀ M ν S C x y name args, Srv M ν S C → FR M S.tab.length x y → okCall x name args = true →
    (∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) →
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR FR M' S'.tab.length r r') S C
      (F.call x name args) (F.call y name (args.map M.arg))
  back : ∀ M ν S C x y a, Srv M ν S C → FR M S.tab.length x y → okBack x a = true →
    Supp.arg (fun _ => True) S.tab.length a →
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ CallR FR M' S'.tab.length r r') S C
      (F.back x a) (F.back y (M.arg a))
  read : ∀ M n x y r off k bs, FR M n x y → F.read x r off k = some bs →
    F.read y (M.region r) off k = some (bs.map M.byte)

end Host.Ts.Sim
