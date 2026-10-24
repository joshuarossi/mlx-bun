import host.sim.world.World
import host.sim.full.Restart
namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers

/-! # The full world as a world

`fullWorld NB`: the full FFI world `Layers.full` (after loadDone) with the native relation
`FLR P NB r` (`FullR` with the bridge inactive, pre-load band `NB`), the mlx model's state `mlxOf`,
the look-ahead token appended to the mlx tokens (`FullR.addToken`; the observers and the bridge do not
read tokens), the native shift `FullShift`, the start facts `fullStart` and the restart
`full_restart_drop`, which ends in the world's restart map. -/

/-- The look-ahead token reference `n` appended to the source's mlx tokens. -/
def fullPush (x : FF.S) (n : Nat) : FF.S :=
  ((⟨{ x.1.1.base with mlx := { x.1.1.base.mlx with tokens := x.1.1.base.mlx.tokens ++ [.ref n] } }, x.1.1.bridge⟩,
    x.1.2), x.2)

/-- The observer relations read only the template's objects. -/
theorem LiveR.ofObjs {M : Map} {x x' y : NSt} {ex ey : Option (PTrie Unit)} (h : LiveR M x y ex ey)
    (ho : x'.objs = x.objs) : LiveR M x' y ex ey := fun fx e => by
  obtain ⟨fy, e', hf⟩ := h fx e
  exact ⟨fy, e', ⟨fun k hk => by rw [ho]; exact hf.obj k hk, fun k hk => hf.img k (by rw [← ho]; exact hk), hf.lt⟩⟩

theorem KernR.ofObjs {M : Map} {n : Nat} {x x' y : NSt} {ex ey : Option KRec} (h : KernR M n x y ex ey)
    (ho : x'.objs = x.objs) : KernR M n x' y ex ey := fun kx e => by
  obtain ⟨ky, e', hk⟩ := h kx e
  exact ⟨ky, e', { hk with
    flagsObj := fun k hk' => by rw [ho]; exact hk.flagsObj k hk'
    targsObj := fun k hk' => by rw [ho]; exact hk.targsObj k hk'
    flags := fun k hk' => hk.flags k (by rw [← ho]; exact hk')
    targs := fun k hk' => hk.targs k (by rw [← ho]; exact hk') }⟩

/-- The bridge relation is kept when a token reference joins the template's queue under `M.setNum`. -/
def BridgePush (BR : Map → FF.S → FF.S → Prop) : Prop :=
  ∀ M x y n w, BR M x y → BR (M.setNum n w) (fullPush x n) y

theorem bridgeI_push : BridgePush BridgeI := fun _ _ _ _ _ h => h

/-- **A second token over the bridge relation `BR`** (`G.LoadR.addToken`). -/
theorem FullRB.addToken {BR : Map → FF.S → FF.S → Prop} (hp : BridgePush BR) {P : LoadP} {NB : Nat} {w : NumV}
    {r : List NumV} {M : Map} {n : Nat} {x y : FF.S} (hr : FullRB BR { P with rest := w :: r } NB M n x y) :
    FullRB BR { P with rest := r } NB (M.setNum n w) (n + 1) (fullPush x n) y :=
  ⟨G.LoadR.addToken hr.load, hp M x y n w hr.bridge, (hr.live.agree (M' := M.setNum n w) rfl).ofObjs rfl,
    ((hr.kern.agree (Map.setNum_ext M n w)).mono (Nat.le_succ n)).ofObjs rfl, (hr.pend.names (M' := M.setNum n w) rfl rfl).congr rfl rfl⟩

/-- **A second token** (`G.LoadR.addToken`). -/
theorem FullR.addToken {P : LoadP} {NB : Nat} {w : NumV} {r : List NumV} {M : Map} {n : Nat} {x y : FF.S}
    (hr : FLR P NB (w :: r) M n x y) : FLR P NB r (M.setNum n w) (n + 1) (fullPush x n) y :=
  FullRB.addToken bridgeI_push hr

/-- **The full world over the bridge relation `BR`**, its template shifts `NS` (with the bridge part `BS`). -/
def fullWorldB (BR NSb : Map → FF.S → FF.S → Prop) (NS : LoadP → Nat → Map → FF.S → FF.S → Prop)
    (hn : BridgeNames BR) (hc : ShiftComp NSb BR) (hns : ∀ P n0 σ x y, NS P n0 σ x y → FullShiftB NSb P n0 σ x y)
    (hp : BridgePush BR) (NB : Nat) : World where
  F := FF
  Par := LoadP
  lo P := P.lo
  E P := P.E
  NE P := P.NE
  R P r := FullRB BR { P with rest := r } NB
  toMlx := mlxOf
  laws _ _ := fullR_laws hn.stable _ NB
  pushTok := fullPush
  addToken h := FullRB.addToken hp h
  NSh P n0 σ x y := NS P n0 σ x y
  Start := fullStart
  -- the 25 implicit arguments are bound positionally
  restart := fun k w _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ hst h hr0 hrc hext h1 hKD hKlo hKhi htab hor
      hshift hW hσ hk hband hx hE hD hroomH hroomN =>
    full_restart_dropB hn hc NB k w hst h hr0 hrc hext h1 hKD hKlo hKhi htab hor
      { hshift with ffi := ⟨hshift.ffi.1, hns _ _ _ _ _ hshift.ffi.2⟩ } hW hσ hk hband hx hE hD hroomH hroomN

/-- **The full world's end laws over the bridge relation**: the restart from the end relation alone
(`full_restart_dropEB`) and the fresh counters of the load-world part. -/
theorem fullWorldB_end {BR NSb : Map → FF.S → FF.S → Prop} {NS : LoadP → Nat → Map → FF.S → FF.S → Prop}
    (hn : BridgeNames BR) (hc : ShiftComp NSb BR) (hns : ∀ P n0 σ x y, NS P n0 σ x y → FullShiftB NSb P n0 σ x y)
    (hp : BridgePush BR) (NB : Nat) : (fullWorldB BR NSb NS hn hc hns hp NB).EndLaws where
  restartE k w _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ hst hr0 h1 htab hor hshift hW hσ hk hband hx hroom hroomH hroomN :=
    full_restart_dropEB hn hc NB k w hst hr0 h1 htab hor
      { hshift with ffi := ⟨hshift.ffi.1, hns _ _ _ _ _ hshift.ffi.2⟩ } hW hσ hk hband hx hroom hroomH hroomN
  bigFresh h k hk := h.load.mlx.hfreshB k hk
  nodeFresh h k := h.load.mlx.nfresh k

/-- **The full world** with the bridge inactive. -/
def fullWorld (NB : Nat) : World :=
  fullWorldB BridgeI BSI FullShift bridgeI_names shiftComp_I (fun _ _ _ _ _ h => h.toB) bridgeI_push NB

/-- **The full world's end laws**: the restart from the end relation alone (`full_restart_dropE`)
and the fresh counters of the load-world part. -/
theorem fullWorld_end (NB : Nat) : (fullWorld NB).EndLaws :=
  fullWorldB_end bridgeI_names shiftComp_I (fun _ _ _ _ _ h => h.toB) bridgeI_push NB

end Host.Ts.Sim.Full
