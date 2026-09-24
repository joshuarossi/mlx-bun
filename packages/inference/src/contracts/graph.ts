/** Describes an implementation's ABI, not a claim of oracle parity or speed. */
export interface GraphDescriptor {
  readonly id: string;
  readonly backend: string;
  readonly graphAbi: string;
  readonly stateAbi: string;
  readonly artifact: string;
}

export type LogitSelection =
  | { readonly type: "all" }
  | { readonly type: "last" }
  | { readonly type: "range"; readonly start: number; readonly end: number };

/** Backend-bound graph. Tensor/State/Inputs stay concrete within the binding.
 * Inputs and hidden are borrowed until the returned lazy work completes;
 * returned hidden/logits are owned by the caller. The graph appends to state.
 * Hidden is [batch, positions, hidden-width]; logits are [batch, selected
 * positions, vocabulary]. Selection precedes the vocabulary projection.
 * Dtypes and evaluation/fence semantics belong to the declared backend ABI.
 * Per-run masks, positions, media, taps, and adapters belong in Inputs or in
 * a bound graph context; they are not mutable session fields. */
export interface AutoregressiveGraph<Tensor, State, Inputs> {
  readonly descriptor: GraphDescriptor;
  forwardHidden(inputs: Inputs, state: State): Tensor | Promise<Tensor>;
  projectLogits(hidden: Tensor, selection: LogitSelection): Tensor;
}

/** A fused InferenceMethod can bypass this graph interface entirely. It need
 * only satisfy the method's output, cancellation, and ownership contracts. */
export interface GraphFactory<Artifact, Binding, Graph> {
  open(artifact: Artifact, binding: Binding): Promise<{ graph: Graph; close(): Promise<void> }>;
}
