// Le finestre dell'editor in loco (ZzMetaInLocoService): il menu della scheda,
// la richiesta di un valore (etichetta, posizione) e l'editor completo dei
// metadati in una finestra sopra la pagina. Va messo una volta nella pagina che
// fornisce il servizio: <zz-meta-in-loco />.
import { ChangeDetectionStrategy, Component, inject, ViewEncapsulation } from '@angular/core';
import { DxButtonModule } from 'devextreme-angular/ui/button';
import { DxContextMenuModule, DxContextMenuTypes } from 'devextreme-angular/ui/context-menu';
import { DxNumberBoxModule } from 'devextreme-angular/ui/number-box';
import { DxPopupModule } from 'devextreme-angular/ui/popup';
import { DxTextBoxModule } from 'devextreme-angular/ui/text-box';

import { MetaEditorComponent } from './meta-editor.component';
import { DomandaInLoco, VoceInLoco, ZzMetaInLocoService } from './meta-in-loco.service';

@Component({
  // eslint-disable-next-line @angular-eslint/component-selector
  selector: 'zz-meta-in-loco',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  // gli stili valgono sulle finestre, che DevExtreme disegna fuori dal componente
  encapsulation: ViewEncapsulation.None,
  imports: [
    DxButtonModule,
    DxContextMenuModule,
    DxNumberBoxModule,
    DxPopupModule,
    DxTextBoxModule,
    MetaEditorComponent,
  ],
  template: `
    @if (inLoco.menuScheda(); as menu) {
      <dx-context-menu
        [items]="menu.voci"
        [visible]="true"
        [position]="posizione(menu.evento)"
        cssClass="zz-meta-in-loco__menu"
        (onItemClick)="scegli($event)"
        (onHidden)="inLoco.chiudiMenuScheda()"
      ></dx-context-menu>
    }

    @if (inLoco.domanda(); as domanda) {
      <dx-popup
        [visible]="true"
        [title]="domanda.titolo"
        [showTitle]="true"
        [width]="420"
        height="auto"
        [dragEnabled]="true"
        [hideOnOutsideClick]="false"
        (onHidden)="domanda.risolvi(undefined)"
      >
        <div *dxTemplate="let d of 'content'" class="zz-meta-in-loco__domanda">
          <div class="zz-meta-in-loco__etichetta">{{ domanda.etichetta }}</div>
          @if (domanda.tipo === 'numero') {
            <dx-number-box
              [value]="$any(domanda.valore)"
              [showSpinButtons]="true"
              (onValueChanged)="domanda.risposta = $event.value"
              (onEnterKey)="conferma(domanda)"
            ></dx-number-box>
          } @else {
            <dx-text-box
              [value]="$any(domanda.valore) ?? ''"
              valueChangeEvent="input"
              (onValueChanged)="domanda.risposta = $event.value"
              (onEnterKey)="conferma(domanda)"
            ></dx-text-box>
          }
          <div class="zz-meta-in-loco__pulsanti">
            <dx-button
              text="Annulla"
              stylingMode="outlined"
              (onClick)="domanda.risolvi(undefined)"
            ></dx-button>
            <dx-button text="Salva" type="default" (onClick)="conferma(domanda)"></dx-button>
          </div>
        </div>
      </dx-popup>
    }

    @if (inLoco.editor(); as editor) {
      <dx-popup
        [visible]="true"
        title="Editor metadati"
        [showTitle]="true"
        [showCloseButton]="true"
        width="95vw"
        height="92vh"
        [dragEnabled]="false"
        [hideOnOutsideClick]="false"
        (onHidden)="inLoco.chiudiEditor()"
      >
        <div *dxTemplate="let d of 'content'">
          <zz-meta-editor
            [datasetIniziale]="editor.dataset"
            [schedaIniziale]="editor.scheda"
            [campoIniziale]="editor.campo"
          />
        </div>
      </dx-popup>
    }
  `,
  styles: `
    /* il menu della scheda si apre sopra la finestra di modifica della griglia,
       che DevExtreme crea dopo e quindi con uno z-index piu' alto */
    .dx-overlay-wrapper.zz-meta-in-loco__menu,
    .dx-overlay-wrapper:has(.zz-meta-in-loco__menu) {
      z-index: 3000 !important;
    }
    .zz-meta-in-loco__domanda {
      display: flex;
      flex-direction: column;
      gap: 12px;
      padding: 16px;
    }
    .zz-meta-in-loco__etichetta {
      opacity: 0.75;
    }
    .zz-meta-in-loco__pulsanti {
      display: flex;
      justify-content: flex-end;
      gap: 8px;
    }
  `,
})
export class ZzMetaInLocoComponent {
  readonly inLoco = inject(ZzMetaInLocoService);

  // Il menu si apre dove si e' fatto clic: angolo della finestra piu' la posizione del mouse
  posizione(evento: MouseEvent) {
    return {
      my: 'left top' as const,
      at: 'left top' as const,
      of: window,
      offset: { x: evento.clientX, y: evento.clientY },
    };
  }

  conferma(domanda: DomandaInLoco) {
    const valore = domanda.risposta;
    if (domanda.tipo === 'numero')
      domanda.risolvi(
        typeof valore === 'number'
          ? valore
          : valore == null || valore === ''
            ? null
            : Number(valore),
      );
    else domanda.risolvi(valore == null ? '' : String(valore).trim());
  }

  scegli(e: DxContextMenuTypes.ItemClickEvent) {
    const voce = e.itemData as VoceInLoco | undefined;
    if (!voce?.azione) return;
    this.inLoco.chiudiMenuScheda();
    voce.azione();
  }
}
