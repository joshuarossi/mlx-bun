import host.mlx.NativeSymbol
import host.ts.RenameRetainedInventory

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Owned
open Host.Ts

theorem call_array_new (s : Host.Mlx.Ffi.St) :
    Host.Mlx.Ffi.call s chars!"mlx_array_new" [] = Host.Mlx.Ffi.ok s (.big 0) := by
  have symbol : Host.Mlx.Ffi.symOf chars!"mlx_array_new" = some .arrayNew := by decide +kernel
  unfold Host.Mlx.Ffi.call
  rw [symbol]

theorem load_array_new (s : LSt) :
    Host.Load.call s chars!"mlx_array_new" [] = M.pure (some (s,.big 0,[])) := by
  have mlx : Host.Load.isMlx chars!"mlx_array_new" = true := by decide +kernel
  funext β k
  simp only [Host.Load.call,mlx,Bool.cond_true,call_array_new,Host.Mlx.Ffi.ok,M.bind,M.pure]

end Host.Load.Owned

namespace Host.Ts.Owned.Annotated
open Parametric

/-- The original empty-array constructor returns ordinary integer zero and
leaves every native resource and retained heap annotation unchanged. -/
theorem RetainedInventory.nullArray_step {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren}
    (FR : Ren → Host.Load.LSt → Host.Load.LSt → Prop)
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {s₀ s : St Host.Load.LSt}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (fn types : Nat) (function signatureObject : Obj) (returns : Name) (receiver : Val)
    (control : s₀.ctl = .call (.obj fn) receiver [])
    (read : s₀.heap.get fn = some (.obj function))
    (kind : function.kind = .fn (.native (.ffi .symbol) [.str chars!"mlx_array_new",.obj types,.str returns]))
    (signatureRead : s₀.heap.get types = some (.obj signatureObject))
    (signatureKind : signatureObject.kind = .array []) (signatureFrame : ¬ framed types) :
    let sourcePost := finishBig s₀ s₀.ffi chars!"mlx_array_new" [] 0
    let targetPost := finishBig s s.ffi chars!"mlx_array_new" [] 0
    interpC (step Host.Load.ffi s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.ordinaryBig 0),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live sourcePost targetPost := by
  dsimp only
  have calleeLive : live fn := by have alive := h.controlLive; rw [control] at alive; exact alive.1
  obtain ⟨_,_,_,functionLive⟩ := h.heap.readObject fn function calleeLive
    (h.heap.function_notFramed fn function _ calleeLive read kind) read
  have signatureLive : live types := by
    have alive := functionLive.1
    rw [kind] at alive
    exact alive.1.2.1.2.1
  obtain ⟨targetFunction,data,this,args,targetControl,targetRead,targetKind,dataRoles,_,argRoles⟩ :=
    h.native_call_view fn function (.ffi .symbol) _ receiver [] control read kind
  cases dataRoles with | cons symbol dataRoles =>
    cases dataRoles with | cons signature dataRoles =>
      cases dataRoles with | cons result dataRoles =>
        cases dataRoles
        cases symbol; cases signature; cases result
        cases argRoles
        obtain ⟨targetSignature,targetSignatureRead,signatureRelation,_⟩ := h.heap.readObject types signatureObject
          signatureLive signatureFrame signatureRead
        have targetSignatureKind := signatureRelation.kind
        rw [signatureKind] at targetSignatureKind
        obtain ⟨values,targetSignatureKind,valueRoles⟩ := kind_array targetSignatureKind
        cases valueRoles
        have eventRole : Parametric.TreeR (NumberRoles ν₀ ν C₀ C) R
            (event ⟨chars!"mlx_array_new",[],.big 0⟩) (event ⟨chars!"mlx_array_new",[],.big 0⟩) :=
          .node _ (.cons (.atom _ _) (.cons (.node _ .nil)
            (.cons (.node _ (.cons (.value (.ordinaryBig 0)) .nil)) .nil)))
        have post := h.finishBig s₀.ffi s.ffi h.native chars!"mlx_array_new" [] [] 0 0 eventRole (.ordinaryBig 0)
        have sourceCall : Host.Load.ffi.call s₀.ffi chars!"mlx_array_new" [] = M.pure (some (s₀.ffi,.big 0,[])) := by
          simpa only [Host.Load.ffi] using Host.Load.Owned.load_array_new s₀.ffi
        have targetCall : Host.Load.ffi.call s.ffi chars!"mlx_array_new" [] = M.pure (some (s.ffi,.big 0,[])) := by
          simpa only [Host.Load.ffi] using Host.Load.Owned.load_array_new s.ffi
        have sourceRun : interpC (step Host.Load.ffi s₀).run C₀ =
            some (finishBig s₀ s₀.ffi chars!"mlx_array_new" [] 0,C₀) := by
          rw [step_ffi_noargs Host.Load.ffi s₀ fn types chars!"mlx_array_new" returns function signatureObject
            s₀.ffi (.big 0) [] control (by simp only [St.obj?,read]) kind
            (by simp only [St.obj?,signatureRead]) signatureKind sourceCall]
          rfl
        have targetRun : interpC (step Host.Load.ffi s).run C =
            some (finishBig s s.ffi chars!"mlx_array_new" [] 0,C) := by
          rw [step_ffi_noargs Host.Load.ffi s (R.a fn) (R.a types) chars!"mlx_array_new" returns targetFunction targetSignature
            s.ffi (.big 0) [] targetControl (by simp only [St.obj?,targetRead]) targetKind
            (by simp only [St.obj?,targetSignatureRead]) targetSignatureKind targetCall]
          rfl
        refine ⟨sourceRun,targetRun,post,?_,?_,?_,?_,?_,?_⟩
        · exact ⟨inventory.runtime.keyLive,
            ⟨returnNote_holds (.ordinaryBig 0),inventory.runtime.source.stack,inventory.runtime.source.cells⟩,
            ⟨returnNote_holds (.ordinaryBig 0),inventory.runtime.target.stack,inventory.runtime.target.cells⟩⟩
        · exact inventory.privates.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
        · exact inventory.captures.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
        · exact inventory.arrays.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
        · exact inventory.publicFields.frame (fun _ alive => alive) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
        · exact inventory.buffers.frame (fun _ alive => alive) (fun _ _ _ => rfl) (fun _ _ _ => rfl)

end Host.Ts.Owned.Annotated
