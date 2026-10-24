import host.sim.full.Rel

/-! # The Neural Engine bridge under the map

Once a surface is wrapped (`FfiAne.St.active`), the bridge records node ids: the aliases of surfaces
(wraps and their views), the readers and writers of surface memory (`touch`), the ones MLX has not
scheduled or not completed (`unscheduled`, `running`) and the effect log's evaluations (`.gpu`). The
target's bridge is the template's with those ids renamed by the map (`BridgeA`): the surfaces, the
programs and the create calls' handles are equal; the aliases and touches agree at the images of
the template's nodes, and both sides record them only below their node counters; the queues and the
log are the template's images. The template's nodes below its counter are all present (`dense`),
so the renaming is injective there and sends the template's fresh nodes to the target's fresh ones.

`BridgeX` is the full world's bridge relation: the inactive bridge (`BridgeI`) or the active one
under the map; `FullRX` is `FullRB BridgeX`. -/

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.FfiAne (Effect)

/-- The bridge state. -/
abbrev BSt := Host.Mlx.FfiAne.St

/-- An effect with node ids renamed. -/
def _root_.Host.Ts.Sim.Map.effect (M : Map) : Effect → Effect
  | .gpu ns => .gpu (ns.map M.node)
  | .start q => .start q
  | .join q => .join q

/-- **Bridge states under the map**: the template's `b` with node counter `nx`, the target's `b'` with
`ny` (see the module doc). -/
structure BRel (M : Map) (nx ny : Nat) (b b' : Host.Mlx.FfiAne.St) : Prop where
  surfaces : b'.surfaces = b.surfaces
  programs : b'.programs = b.programs
  handles : b'.handles = b.handles
  active : b'.active = b.active
  aliases : ∀ n, n < nx → b'.aliases.get (M.node n) = b.aliases.get n
  aliasX : ∀ n, (b.aliases.get n).isSome = true → n < nx
  aliasY : ∀ m, (b'.aliases.get m).isSome = true → m < ny
  touch : ∀ n, n < nx → b'.touch.get (M.node n) = b.touch.get n
  touchX : ∀ n, (b.touch.get n).isSome = true → n < nx
  touchY : ∀ m, (b'.touch.get m).isSome = true → m < ny
  unscheduled : b'.unscheduled = b.unscheduled.map M.node
  running : b'.running = b.running.map M.node
  queued : ∀ n ∈ b.unscheduled ++ b.running, n < nx
  log : b'.log = b.log.map M.effect

/-- **The active bridge under the map**: the bridge states related at the node counters, the
template's nodes below its counter present. -/
structure BridgeA (M : Map) (x y : FF.S) : Prop where
  rel : BRel M (mlxOf x).nnext (mlxOf y).nnext (bridgeOf x) (bridgeOf y)
  dense : ∀ i, i < (mlxOf x).nnext → PN (mlxOf x) i

/-- **The full world's bridge relation**: inactive and equal, or active under the map. -/
def BridgeX (M : Map) (x y : FF.S) : Prop := BridgeI M x y ∨ ((bridgeOf x).active = true ∧ BridgeA M x y)

/-- **The full world's native relation with the Neural Engine bridge.** -/
abbrev FullRX : LoadP → Nat → Map → Nat → FF.S → FF.S → Prop := FullRB BridgeX

theorem BRel.names {M M' : Map} {nx ny : Nat} {b b' : Host.Mlx.FfiAne.St} (h : BRel M nx ny b b') (hn : M'.node = M.node) :
    BRel M' nx ny b b' :=
  { h with
    aliases := fun n hn' => by rw [hn]; exact h.aliases n hn'
    touch := fun n hn' => by rw [hn]; exact h.touch n hn'
    unscheduled := by rw [h.unscheduled, hn]
    running := by rw [h.running, hn]
    log := by
      rw [h.log]
      congr 1
      funext e
      cases e <;> simp only [Map.effect, hn] }

theorem bridgeA_stable : BridgeStable BridgeA := fun _ _ _ _ h _ _ _ hn => ⟨h.rel.names hn, h.dense⟩

theorem bridgeX_stable : BridgeStable BridgeX := fun M M' x y h ha hb hr hn => by
  rcases h with h | ⟨ha', h⟩
  · exact .inl h
  · exact .inr ⟨ha', bridgeA_stable M M' x y h ha hb hr hn⟩

theorem fullRX_laws (P : LoadP) (NB : Nat) : FRLaws (F := FF) (FullRX P NB) := fullR_laws bridgeX_stable P NB

theorem any_congr_mem {α : Type} : ∀ {l : List α} {p q : α → Bool}, (∀ a ∈ l, p a = q a) → l.any p = l.any q
  | [], _, _, _ => rfl
  | a :: l, _, _, h => by
    simp only [List.any_cons]
    rw [h a List.mem_cons_self, any_congr_mem fun b hb => h b (List.mem_cons_of_mem _ hb)]

theorem all_congr_mem {α : Type} : ∀ {l : List α} {p q : α → Bool}, (∀ a ∈ l, p a = q a) → l.all p = l.all q
  | [], _, _, _ => rfl
  | a :: l, _, _, h => by
    simp only [List.all_cons]
    rw [h a List.mem_cons_self, all_congr_mem fun b hb => h b (List.mem_cons_of_mem _ hb)]


theorem Map.effect_names {M M' : Map} (hn : M'.node = M.node) : M'.effect = M.effect := by
  funext e; cases e <;> simp only [Map.effect, hn]

/-- **The target's bridge log is kept where the template's is**: between two cuts of a run (maps with
the same node names), a template log the run does not change leaves the target's unchanged. The
Neural Engine memory (`FfiAneEval.final init b`) reads only the log, so a decode link whose template
log is unchanged (a GPU forward: no reader or writer scheduled) keeps the target's memory. -/
theorem BridgeA.log_keep {M M' : Map} {x y x' y' : FF.S} (h : BridgeA M x y) (h' : BridgeA M' x' y')
    (hn : M'.node = M.node) (hx : (bridgeOf x').log = (bridgeOf x).log) : (bridgeOf y').log = (bridgeOf y).log := by
  rw [h'.rel.log, hx, Map.effect_names hn, ← h.rel.log]

/-- **`BridgeA.log_keep` with the bridge inactive**: the target's bridge is the template's at both cuts. -/
theorem BridgeI.log_keep {M M' : Map} {x y x' y' : FF.S} (h : BridgeI M x y) (h' : BridgeI M' x' y')
    (hx : (bridgeOf x').log = (bridgeOf x).log) : (bridgeOf y').log = (bridgeOf y).log := by
  rw [h'.1, h.1]; exact hx

/-- **`BridgeA.log_keep` for the bridge inactive or active** (the same at both cuts). -/
theorem BridgeX.log_keep {M M' : Map} {x y x' y' : FF.S} (h : BridgeX M x y) (h' : BridgeX M' x' y')
    (hn : M'.node = M.node) (ha : (bridgeOf x').active = (bridgeOf x).active)
    (hx : (bridgeOf x').log = (bridgeOf x).log) : (bridgeOf y').log = (bridgeOf y).log := by
  rcases h with h | ⟨ha0, h⟩
  · rcases h' with h' | ⟨ha1, -⟩
    · rw [h'.1, h.1]; exact hx
    · rw [ha, h.2] at ha1; cases ha1
  · rcases h' with h' | ⟨-, h'⟩
    · rw [h'.2] at ha; rw [← ha] at ha0; cases ha0
    · exact h.log_keep h' hn hx

/-! ## Changing the bridge relation -/

theorem FullRB.mapBridge {BR BR' : Map → FF.S → FF.S → Prop} {P : LoadP} {NB : Nat} {M : Map} {n : Nat}
    {x y : FF.S} (h : FullRB BR P NB M n x y) (hb : BR M x y → BR' M x y) : FullRB BR' P NB M n x y :=
  ⟨h.load, hb h.bridge, h.live, h.kern, h.pend⟩

theorem FullR.toX {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullR P NB M n x y) :
    FullRX P NB M n x y := h.mapBridge .inl

/-- With the template's bridge inactive, the relation is `FullR`'s. -/
theorem FullRX.toR {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : FF.S} (h : FullRX P NB M n x y)
    (ha : (bridgeOf x).active = false) : FullR P NB M n x y :=
  h.mapBridge fun hb => by
    rcases hb with hb | ⟨ha', -⟩
    · exact hb
    · rw [ha] at ha'; cases ha'

end Host.Ts.Sim.Full
