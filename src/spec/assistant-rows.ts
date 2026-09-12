import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import { materializeCopy } from "../mlx/materialize";
import { disposeResources, applyStateChanges } from "../engine/resources";
import type { PreparedStateChange } from "../contracts/resources";
import type { AssistantRowsTarget, DraftPrefillGroup, DraftRowGroup, DraftRowCheckpoint, GroupedDraftProvider } from "./source";
import type { GemmaAssistantDrafter } from "./drafter";

/** The assistant owns only its last true target hidden and coverage. Donor
 * attention stays with target storage; checkpoints contain no duplicate KV. */
class AssistantRows implements DraftPrefillGroup, DraftRowGroup {
  readonly prefillMode = "tail-split" as const;
  readonly tapLayers: readonly number[] = [];
  #hidden: MlxArray | null = null;
  #processed: number[] = [];
  constructor(readonly target: AssistantRowsTarget, readonly drafter: GemmaAssistantDrafter,
    readonly namespace: string, checkpoints: readonly (DraftRowCheckpoint | null)[]) { this.append(checkpoints); }
  get rowCount(): number { return this.#processed.length; }
  append(checkpoints: readonly (DraftRowCheckpoint | null)[]): void {
    if (checkpoints.length) applyStateChanges([() => this.prepareAppend(checkpoints)]);
  }
  prepareAppend(checkpoints: readonly (DraftRowCheckpoint | null)[]): PreparedStateChange {
    const processed = [...this.#processed, ...checkpoints.map(checkpoint => checkpoint?.processedTokens ?? 0)];
    const example = this.#hidden ?? checkpoints.find(checkpoint => checkpoint !== null)?.attachment.tensors[0];
    const held: MlxArray[] = []; let hidden: MlxArray | null = null;
    try {
      for (const checkpoint of checkpoints) if (checkpoint && (checkpoint.attachment.schema !== "gemma-assistant-v1" ||
        checkpoint.attachment.metadata.processedTokens !== checkpoint.processedTokens))
        throw new Error("invalid assistant checkpoint alignment");
      if (example) {
        const zero = (rows: number) => { const value = ops.zeros([rows,1,this.target.hiddenSize],example.dtype); held.push(value); return value; };
        hidden = ops.concatAxis([...(this.rowCount ? [this.#hidden ?? zero(this.rowCount)] : []),
          ...checkpoints.map(checkpoint => checkpoint?.attachment.tensors[0] ?? zero(1))],0);
      }
    } finally { disposeResources(held); }
    return { commit: () => { const old = this.#hidden; this.#hidden=hidden; hidden=old; this.#processed=processed; },
      dispose: () => { hidden?.dispose(); hidden=null; } };
  }
  filterRows(keep: readonly number[]): void {
    if (!keep.length) { this.dispose(); return; }
    using indices = ops.fromInt32([...keep],[keep.length]);
    const next = this.#hidden && keep.length ? ops.takeAxis(this.#hidden,indices,0) : null;
    this.#hidden?.dispose(); this.#hidden=next; this.#processed=keep.map(row=>this.#processed[row]!);
  }
  prefill(tokens: MlxArray, context?: MlxArray): void {
    const [B,N] = tokens.shape as [number,number];
    using tail = context!.slice([0,N-1,0],[B,N,context!.shape[2]!]);
    const hidden = materializeCopy(tail);
    this.#hidden?.dispose(); this.#hidden=hidden; this.#processed=this.#processed.map(count=>count+N);
  }
  materialize(): void { this.#hidden?.eval(); }
  capture(row: number): DraftRowCheckpoint {
    const processedTokens=this.#processed[row]!;
    const hidden=this.#hidden!.slice([row,0,0],[row+1,1,this.target.hiddenSize]);
    return { processedTokens, attachment: { schema:"gemma-assistant-v1",metadata:{processedTokens},tensors:[hidden] } };
  }
  draft(pending: readonly number[], depth: number, _steps: readonly number[]): number[][] {
    if (!depth) return pending.map(()=>[]);
    const B=pending.length, owned: MlxArray[]=[];
    const donors=this.target.readDonors();
    let ids=ops.fromInt32([...pending],[B,1]), hidden=this.#hidden!;
    const tokens: MlxArray[]=[];
    try {
      for(let step=0;step<depth;step++) {
        using emb=this.target.embed(ids);
        const positions=donors.positions.map(position=>position+step);
        const common=positions.every(position=>position===positions[0]);
        using offsets=common ? null : ops.fromInt32(positions,[B]);
        const next=this.drafter.forwardRows(emb,hidden,donors,offsets ?? positions[0]!);
        owned.push(next.nextHidden); tokens.push(next.tokens); hidden=next.nextHidden;
        ids.dispose(); ids=ops.reshape(next.tokens,[B,1]);
      }
      using packed=ops.concatAxis(tokens,0);
      const values=packed.toIntTokens();
      return pending.map((_,row)=>Array.from({length:depth},(_,step)=>values[step*B+row]!));
    } finally { ids.dispose(); donors.dispose(); disposeResources([...owned,...tokens]); }
  }
  commit(accepted: readonly number[], context: MlxArray): void {
    using indices=ops.fromInt32([...accepted],[accepted.length,1,1]);
    const hidden=ops.takeAlongAxis(context,indices,1);
    this.#hidden?.dispose(); this.#hidden=hidden;
    this.#processed=this.#processed.map((count,row)=>count+accepted[row]!+1);
  }
  dispose(): void { this.#hidden?.dispose(); this.#hidden=null; this.#processed=[]; }
}

export function assistantGroups(drafter: GemmaAssistantDrafter, namespace: string): GroupedDraftProvider {
  return {
    checkpointNamespace: () => namespace,
    openPrefill: ({target,checkpoints}) => new AssistantRows(target.assistantRows!,drafter,namespace,checkpoints),
    open: ({target,checkpoints}) => new AssistantRows(target.assistantRows!,drafter,namespace,checkpoints),
  };
}
