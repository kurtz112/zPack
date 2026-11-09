import { AfterViewInit, Directive, ElementRef, Input, OnDestroy, inject } from '@angular/core';
import { DxNumberBoxComponent } from 'devextreme-angular/ui/number-box';
import { FORMATO_INTERO, agganciaCampoIntero } from '../helper/campo-intero';

/**
 * Campo intero: `<dx-number-box zzInteri [(value)]="chilometri" />`.
 * Non accetta virgola ne' punto (si bloccano mentre si digita), arrotonda quello che
 * si incolla e mostra il valore senza decimali. Da usare per ogni casella che alimenta
 * una colonna INTERO; per le schede e le griglie dai metadati ci pensa il motore zz-*.
 */
@Directive({
  selector: 'dx-number-box[zzInteri]',
  standalone: true
})
export class ZzInteriDirective implements AfterViewInit, OnDestroy {
  private readonly casella = inject(DxNumberBoxComponent, { self: true });
  private readonly elemento = inject<ElementRef<HTMLElement>>(ElementRef);
  private togli?: () => void;

  /**
   * `zzInteri` da solo vale vero; `[zzInteri]="espressione"` lo applica solo se vera
   * (per le caselle che servono sia contatori interi sia con decimali). Si legge una
   * volta, quando la casella compare.
   */
  @Input() zzInteri: boolean | '' = true;

  ngAfterViewInit(): void {
    const istanza = this.casella.instance;
    if (!istanza || this.zzInteri === false) return;
    if (!istanza.option('format')) istanza.option('format', FORMATO_INTERO);
    this.togli = agganciaCampoIntero(this.elemento.nativeElement, istanza);
  }

  ngOnDestroy(): void {
    this.togli?.();
  }
}
