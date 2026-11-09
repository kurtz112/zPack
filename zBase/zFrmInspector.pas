unit zFrmInspector;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  vcl.Graphics,
  vcl.Controls,
  vcl.Forms,
  vcl.Dialogs,
  OkCancel,
  Frame_ObjectInspector;

type
  TzFormInspector = class(TForm)
    OkCancel: TOkCancel;
    FrameObjectInspector: TFrameObjectInspector;
  private
  public
    procedure AddProps(Props: array of TPersistent);
  end;

// Ordinate = False mostra le proprieta' nell'ordine in cui l'inspector le
// aggiunge, cioe' l'ordine di dichiarazione delle published; True (il
// comportamento di sempre, e il default di cxOI) le ordina per nome.
function zEditProperties(Props: array of TPersistent; Ordinate: boolean = True): boolean;

implementation

{$R *.dfm}

function zEditProperties(Props: array of TPersistent; Ordinate: boolean = True): boolean;
var
  zFormInspector: TzFormInspector;
begin
  Result := False;

  zFormInspector := TzFormInspector.Create(Application);
  try
    // prima di AddProps: cambiare l'ordinamento a righe gia' costruite le
    // farebbe ricostruire per niente
    zFormInspector.FrameObjectInspector.SortProperties := Ordinate;
    zFormInspector.AddProps(Props);
    Result := zFormInspector.ShowModal = mrOk;
  finally
    FreeAndNil(zFormInspector);
  end;
end;

procedure TzFormInspector.AddProps(Props: array of TPersistent);
var
  i: integer;
begin
  FrameObjectInspector.Clear;

  for i := Low(Props) to High(Props) do
    FrameObjectInspector.Add(Props[i]);
end;

end.
