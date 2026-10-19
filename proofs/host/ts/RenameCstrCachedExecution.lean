import host.ts.ast.mlx.Ops
import host.ts.RenameParametricStringMapMethod
import host.ts.RenameRouteComposition

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated
open Parametric

noncomputable def cstrFunction : Func := Sources.Mlx.Ops.ast_n7
noncomputable def cstrStatements : List Stmt :=
  [Sources.Mlx.Ops.ast_n1,Sources.Mlx.Ops.ast_n5,Sources.Mlx.Ops.ast_n6]

theorem cstr_function_source : cstrFunction = .mk (some chars!"cstr") [.id chars!"s"] none
    (.block cstrStatements) false false [] := rfl

noncomputable def cstrBodyState {S : Type} (source : St S) (env : Env) (caller : List Frame) : St S :=
  {source with
    ctl := .ret .undef,
    stack := .s (.block cstrStatements env)::.s (.scope [])::.k (.fn .call)::caller}

def cstrBodyResult {S : Type} (source : St S) (cell buffer : Nat) (caller : List Frame) : St S :=
  {(source.setCell cell (.obj buffer)) with ctl := .ret (.obj buffer),stack := caller}

/-- The cached branch executes the original pinned function body, including
its Map prototype lookup and negated guard, for any source heap and caller. -/
theorem run_cstr_cached_body (F : Ffi) (source : St F.S) (C : CSrv) (env : Env)
    (caller : List Frame) (cacheCell parameter localCell owner prototype callee buffer : Nat)
    (object parent function : Obj) (entries : List (Val × Val)) (data : List Val)
    (key : Name) (w e : Bool)
    (cacheLookup : lookupEnv chars!"cstrCache" env = some cacheCell)
    (parameterLookup : lookupEnv chars!"s" env = some parameter)
    (localLookup : lookupEnv chars!"b" env = some localCell)
    (cacheRead : source.heap.get cacheCell = some (.cell (some (.obj owner))))
    (parameterRead : source.heap.get parameter = some (.cell (some (.str key))))
    (objectRead : source.heap.get owner = some (.obj object)) (objectKind : object.kind = .map entries)
    (ownAbsent : findProp (.str chars!"get") object.props = none)
    (proto : object.proto = .obj prototype)
    (parentRead : source.heap.get prototype = some (.obj parent)) (parentKind : parent.kind = .ordinary)
    (getMethod : findProp (.str chars!"get") parent.props = some (.data (.obj callee) w e))
    (functionRead : source.heap.get callee = some (.obj function))
    (functionKind : function.kind = .fn (.native (.map .get) data))
    (cached : StringIndex.firstValue (pack key) entries = some (.obj buffer))
    (localBound : localCell < 2^64) :
    runC F 25 (cstrBodyState source env caller) C = some (cstrBodyResult source localCell buffer caller,C) := by
  have notSize : keyEq (.str chars!"get") (.str chars!"size") = false := by decide +kernel
  simp only [runC,runWith_succ,runWith_zero,cstrBodyState,cstrBodyResult,cstrStatements,
    Sources.Mlx.Ops.ast_n1,Sources.Mlx.Ops.ast_n5,Sources.Mlx.Ops.ast_n6,
    brec,Bool.cond_false,Bool.cond_true,Bool.not_true,Bool.false_and,List.nil_append,List.append_nil,
    List.reverse_cons,List.reverse_nil,Host.Ts.arg,nthD,
    St.push,St.go,St.ret,St.setCell,St.rebuild_eq,isHalt,step,stepRet,stepAbr,
    evStep,exStep,retStep,retSt,retE,retC,abrStep,abrSt,abrK,boundaryAbr,
    declNext,declarationValue,isUsing,bindStep,localLookup,cacheLookup,parameterLookup,
    readVar,St.cell?,cacheRead,parameterRead,St.obj?,objectRead,objectKind,
    getV,lookup,getChain,ownGet,ownAbsent,notSize,proto,parentRead,parentKind,getMethod,readProp,
    evCall,argsNext,isNullish,callStep,functionRead,functionKind,callNative,mapN,mapN.withMap,mapOf,
    mapEntryValue_string,cached,Option.getD_some,unaryOp,truthy,
    PTrie.get_set_u64 _ _ _ localBound,ite_true,retS,M.run,M.bind,M.pure,interpC_pure]

end Host.Ts.Owned.Annotated
