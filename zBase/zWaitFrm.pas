unit zWaitFrm;

// Le procedure storiche StartWait, StopWait e UpdateWait, sopra la finestra di
// attesa di DevExpress (TSmartWaitForm di zz.SplashWait). La vecchia form
// TWaitForm non veniva piu' creata da tempo (il suo codice stava dopo un
// exit) ed e' stata tolta, insieme al suo .dfm.

interface

// NoTimer resta per compatibilita' con le chiamate esistenti: non ha piu'
// effetto.
procedure StartWait(const Msg: string = ''; const NoTimer: Boolean = false);
procedure StopWait;
procedure UpdateWait(const Msg: string);

implementation

uses
  SysUtils,
  vcl.Controls,
  vcl.Forms,
  zz.SplashWait;

procedure StartWait(const Msg: string = ''; const NoTimer: Boolean = false);
begin
  // Il messaggio va passato: senza, la finestra mostrava sempre il testo
  // predefinito e ogni StartWait('...') scritto nel codice restava invisibile.
  // Con il messaggio vuoto, alla prima attesa si passa 'Attendere...':
  // TSmartWaitForm ignora i testi vuoti e lascerebbe a video quello
  // dell'attesa precedente, ormai chiusa. In un'attesa annidata invece il
  // vuoto va passato cosi' com'e', perche' tenga il messaggio di quella
  // esterna.
  if Trim(Msg) <> '' then
    TSmartWaitForm.Show(Msg)
  else if TSmartWaitForm.IsShowing then
    TSmartWaitForm.Show('')
  else
    TSmartWaitForm.Show('Attendere...');
end;

procedure StopWait;
begin
  TSmartWaitForm.Hide;
  Screen.Cursor := crDefault;
end;

procedure UpdateWait(const Msg: string);
begin
  TSmartWaitForm.Update(Msg);
end;

end.
