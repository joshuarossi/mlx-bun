/** One request's exact-token speculative acceptance walk. The backend owns
 * logits and sampling; this state owns only the accepted prefix and stop facts.
 * A group advances each live walk independently, regardless of batch size. */
export class DraftAcceptance {
  position = 0;
  accepted = 0;
  correction: number | null = null;
  readonly emitted: number[] = [];
  sawEos = false;
  grammarDone = false;
  done = false;

  constructor(
    readonly drafts: readonly number[],
    readonly remaining: number,
    readonly eosTokenIds: readonly number[],
  ) {}

  /** Supply one target sample after its sampler has updated request history
   * and grammar. Once done, this request needs no further target samples. */
  accept(token: number, grammarDone = false): void {
    const matches = this.position < this.drafts.length && token === this.drafts[this.position];
    this.position++;
    if (matches) {
      this.accepted++;
      if (this.eosTokenIds.includes(token)) {
        this.sawEos = this.done = true;
        return;
      }
      this.emitted.push(token);
      this.grammarDone = grammarDone;
      this.done = grammarDone || this.emitted.length >= this.remaining;
      return;
    }
    this.correction = token;
    this.sawEos = this.eosTokenIds.includes(token);
    if (!this.sawEos) this.emitted.push(token);
    this.grammarDone = grammarDone;
    this.done = true;
  }
}
