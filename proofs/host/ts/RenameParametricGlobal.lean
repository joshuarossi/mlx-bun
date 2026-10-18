import host.ts.RenameParametricProps
import host.ts.RenameParametricViews

set_option Elab.async false

namespace Host.Ts.Owned.Parametric

theorem step_global_eq (F : Ffi) (s : St F.S) (name : Name) (env : Env) (o : Obj)
    (v : Val) (w e : Bool) (hc : s.ctl = .ev (.id name) env) (he : lookupEnv name env = none)
    (ho : s.heap.get aGlobal = some (.obj o)) (hk : o.kind = .ordinary)
    (hp : findProp (.str name) o.props = some (.data v w e)) :
    step F s = M.pure (s.ret v) := by
  funext β k
  simp only [step,hc,evStep,readVar,he,getChain,St.obj?,ho,ownGet,hk,hp,M.bind,M.pure,readProp]

/-- Global identifier lookup derives the target descriptor from the live realm
object. The fixed global address is an explicit intrinsic invariant. -/
theorem step_global_from_source (F : Ffi) (NR : NumV → NumV → Prop)
    (FR : Ren → F.S → F.S → Prop) (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : StateR NR FR R live framed before after old old' s₀ s)
    (name : Name) (env : Env) (o₀ : Obj) (v₀ : Val) (w e : Bool)
    (hc₀ : s₀.ctl = .ev (.id name) env) (he₀ : lookupEnv name env = none)
    (ho₀ : s₀.heap.get aGlobal = some (.obj o₀)) (hk₀ : o₀.kind = .ordinary)
    (hp₀ : findProp (.str name) o₀.props = some (.data v₀ w e))
    (hg : live aGlobal) (hgf : R.a aGlobal = aGlobal) :
    ∃ v, interpC (step F s₀).run C₀ = some (s₀.ret v₀,C₀) ∧
      interpC (step F s).run C = some (s.ret v,C) ∧
      StateR NR FR R live framed before after old old' (s₀.ret v₀) (s.ret v) ∧ ValueR NR R v₀ v := by
  have hc := (h.control_view hc₀).ev_view
  have he : lookupEnv name (R.env env) = none := by rw [lookupEnv_map,he₀]; rfl
  obtain ⟨o,ho,hor,hos⟩ := h.heap.readOrdinary aGlobal o₀ hg ho₀ hk₀
  rw [hgf] at ho
  obtain ⟨v,hp,hvr⟩ := hor.properties.find_data name v₀ w e hp₀
  have hvl := (PropsR.support_find hos.2.2.1 name hp₀).1
  refine ⟨v,?_,?_,h.go (.node _ (.cons (.value hvr) .nil)) ⟨hvl,True.intro⟩,hvr⟩
  · rw [step_global_eq F s₀ name env o₀ v₀ w e hc₀ he₀ ho₀ hk₀ hp₀]; rfl
  · rw [step_global_eq F s name (R.env env) o v w e hc he ho (hor.ordinary hk₀) hp]; rfl

end Host.Ts.Owned.Parametric
