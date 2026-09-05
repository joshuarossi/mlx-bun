/** A complete transaction over every participating target state layer.
 * A failed begin/resolve invalidates the run; its state must be discarded. */
export interface SpeculativeTransaction {
  canBegin(drafts: number): boolean;
  begin(drafts: number): void;
  resolve(accepted: number): void;
}
