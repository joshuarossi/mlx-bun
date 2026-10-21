import host.sim.native.Rel
import host.simgraph.Domain
namespace Host.Mlx.SimGraph
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval
open Host.Mlx.Ffi (Prim Node)

/-! # The native relation as a template embedding

The decode-route native relation `MR P M n x y` (`host.sim.native.Rel`)
corresponds the nodes in its full bands (`Full P`: below `P.NL`, from `P.N0`)
exactly as `nodeI M.node (loadImg M)`, with the order `Embeds` needs, and
keeps every kernel object. So a template domain inside the full bands gives
`NativeImage`, and `embeds_of_run` applies with the map's own images. -/

/-- The iteration map's image of native data. -/
def loadImg (M : Map) : SynImg := numImg M.nv M.big M.arg M.handle

theorem byteI_map (M : Map) (b : Byte) : byteI M.nv M.big b = M.byte b := by
  cases b with
  | lit _ => rfl
  | part k c i => cases c <;> rfl

theorem dimI_map (M : Map) (d : Ffi.Dim) : dimI M.nv d = M.dim d := by
  cases d <;> rfl

theorem primI_map (M : Map) (p : Prim) : primI (loadImg M) p = M.prim p := by
  have hb : (loadImg M).byte = M.byte := funext (byteI_map M)
  have hd : (loadImg M).dim = M.dim := funext (dimI_map M)
  have hds : ∀ l : List Ffi.Dim, l.map (loadImg M).dim = M.dims l := fun l => by rw [hd]; rfl
  induction p with
  | data bs => simp only [primI, Map.prim, hb]
  | kernel k c o =>
    obtain ⟨outs, grid, group, ints, dts, init⟩ := c
    simp only [primI, Map.prim, cfgI, Map.cfg, hds]
    rfl
  | replayed c p ih => simp only [primI, Map.prim, ih]; rfl
  | _ => rfl

theorem nodeI_map (M : Map) (nd : Node) :
    nodeI M.node (loadImg M) nd = ⟨M.prim nd.prim, nd.ins.map M.node, M.dims nd.shape, nd.dtype⟩ := by
  simp only [nodeI, primI_map]
  congr 1

/-- **The native relation gives the template embedding's native image** on any
domain inside its full bands. -/
theorem nativeImage_of_MR {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y) (D : Nat → Bool)
    (hD : ∀ i, D i = true → Full P i) : NativeImage M.node (loadImg M) D x y where
  nodes := by
    intro i nd hi hn
    obtain ⟨nd', h1, hs, hd, _, hf⟩ := hr.nodes i nd hn
    obtain ⟨hp, hins⟩ := hf (hD i hi)
    rw [h1, nodeI_map]
    obtain ⟨p', ins', sh', dt'⟩ := nd'
    simp only at hp hins hs hd
    subst hp hins hs hd
    rfl
  order := by
    intro i j hi hp hj
    exact hr.norder i hp (hD i hi) j hj

/-- The native relation keeps every route kernel object. -/
theorem kernels_of_MR {P : LoadP} {M : Map} {n : Nat} {x y : NSt} (hr : MR P M n x y) (Ks : KernelSources) :
    ∀ k name, kernelName? Ks x k = some name → kernelName? Ks y (M.handle k) = some name := by
  intro k name hk
  unfold kernelName? at hk ⊢
  cases ho : x.objs.get k with
  | none => simp [Ffi.St.obj?, ho] at hk
  | some o =>
    have hpres : PH x k := .inr (by simp [ho])
    have hy := hr.objs k hpres
    rw [ho] at hy
    simp only [Ffi.St.obj?, ho] at hk
    cases o with
    | kernel nm src hdr a b =>
      simp only [Ffi.St.obj?, hy, Option.map_some, Map.nobj]
      exact hk
    | _ => simp at hk

/-- Literal numbers keep their image. -/
theorem nv_lit (M : Map) (f : F64) : M.nv (.lit f) = .lit f := rfl

/-- The map keeps rope arguments it fixes as bigints. -/
theorem arg_fixed (M : Map) (fixed : List Int) (hfix : ∀ i ∈ fixed, M.big i = i) :
    ∀ a v, okArg fixed a = true → Ffi.argNat a = some v → Ffi.argNat (M.arg a) = some v :=
  okArg_kept fixed M.arg (fun i hi => by simp [Map.arg, hfix i hi]) (fun f => rfl)

end Host.Mlx.SimGraph
