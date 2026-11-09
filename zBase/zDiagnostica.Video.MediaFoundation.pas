// ---------------------------------------------------------------------------
// Copyright (c) 2026 Luca Zebro - Tutti i diritti riservati.
// Uso, copia e distribuzione non autorizzati sono vietati.
//
// Ultima modifica: 2026-10-29
// ---------------------------------------------------------------------------

// ***************************************************************************
//
// zDiagnostica.Video.MediaFoundation
//
// Dichiarazioni minime di Media Foundation per scrivere un file MP4 H.264 con
// IMFSinkWriter. La RTL di Delphi non le contiene (c'e' solo Winapi.WMF9, il
// vecchio Windows Media Format), e servono solo queste.
//
// L'ORDINE DEI METODI DELLE INTERFACCE E' QUELLO DI mfobjects.h E
// mfreadwrite.h: e' la tabella dei metodi dell'oggetto COM, e un metodo
// saltato o spostato chiama la funzione sbagliata senza nessun errore di
// compilazione. Anche i metodi che non si usano vanno quindi dichiarati.
//
// Le funzioni sono importate con "delayed": l'eseguibile deve partire anche
// dove Media Foundation non c'e' (edizioni N di Windows senza Media Feature
// Pack, alcuni Windows Server). Prima di chiamarle si verifica la presenza
// delle DLL con MediaFoundationPresente.
//
// ***************************************************************************

unit zDiagnostica.Video.MediaFoundation;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX;

const
  MF_VERSION = $00020070; // MF_SDK_VERSION shl 16 or MF_API_VERSION
  MFSTARTUP_LITE = 1; // senza i socket: si scrive solo su file

  MFVideoInterlace_Progressive = 2;

  // Valori di CODECAPI_AVEncCommonRateControlMode (codecapi.h)
  eAVEncCommonRateControlMode_CBR = 0;
  eAVEncCommonRateControlMode_UnconstrainedVBR = 2;
  eAVEncCommonRateControlMode_Quality = 3;

  MFMediaType_Video: TGUID = '{73646976-0000-0010-8000-00AA00389B71}';
  MFVideoFormat_H264: TGUID = '{34363248-0000-0010-8000-00AA00389B71}';
  MFVideoFormat_RGB32: TGUID = '{00000016-0000-0010-8000-00AA00389B71}';

  MF_MT_MAJOR_TYPE: TGUID = '{48EBA18E-F8C9-4687-BF11-0A74C9F96A8F}';
  MF_MT_SUBTYPE: TGUID = '{F7E34C9A-42E8-4714-B74B-CB29D72C35E5}';
  MF_MT_AVG_BITRATE: TGUID = '{20332624-FB0D-4D9E-BD0D-CBF6786C102E}';
  MF_MT_INTERLACE_MODE: TGUID = '{E2724BB8-E676-4806-B4B2-A8D6EFB44CCD}';
  MF_MT_FRAME_SIZE: TGUID = '{1652C33D-D6B2-4012-B834-72030849A37D}';
  MF_MT_FRAME_RATE: TGUID = '{C459A2E8-3D2C-4E44-B132-FEE5156C7BB0}';
  MF_MT_PIXEL_ASPECT_RATIO: TGUID = '{C6376A1E-8D0A-4027-BE45-6D9A0AD39BB6}';
  MF_MT_DEFAULT_STRIDE: TGUID = '{644B4E48-1E02-4516-B0EB-C01CA9D49AC6}';

  MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS: TGUID = '{A634A91C-822B-41B9-A494-4DE4643612B0}';
  MF_SINK_WRITER_DISABLE_THROTTLING: TGUID = '{08B845D8-2B74-4AFE-9D53-BE16D2D5AE4F}';

  // Parametri del codificatore, passati a SetInputMediaType (codecapi.h)
  CODECAPI_AVEncCommonRateControlMode: TGUID = '{1C0608E9-370C-4710-8A58-CB6181C42423}';
  CODECAPI_AVEncCommonQuality: TGUID = '{FCBF57A3-7EA5-4B0C-9644-69B40C39C391}';
  CODECAPI_AVEncMPVGOPSize: TGUID = '{95F31B26-95A4-41AA-9303-246A7FC6EEF1}';

type
  IMFAttributes = interface(IUnknown)
    ['{2CD2D921-C447-44A7-A13C-4ADABFC247E3}']
    function GetItem(const [Ref] guidKey: TGUID; pValue: Pointer): HResult; stdcall;
    function GetItemType(const [Ref] guidKey: TGUID; out pType: Cardinal): HResult; stdcall;
    function CompareItem(const [Ref] guidKey: TGUID; Value: Pointer; out pbResult: BOOL): HResult; stdcall;
    function Compare(pTheirs: IMFAttributes; MatchType: Cardinal; out pbResult: BOOL): HResult; stdcall;
    function GetUINT32(const [Ref] guidKey: TGUID; out punValue: UINT32): HResult; stdcall;
    function GetUINT64(const [Ref] guidKey: TGUID; out punValue: UINT64): HResult; stdcall;
    function GetDouble(const [Ref] guidKey: TGUID; out pfValue: Double): HResult; stdcall;
    function GetGUID(const [Ref] guidKey: TGUID; out pguidValue: TGUID): HResult; stdcall;
    function GetStringLength(const [Ref] guidKey: TGUID; out pcchLength: UINT32): HResult; stdcall;
    function GetString(const [Ref] guidKey: TGUID; pwszValue: PWideChar; cchBufSize: UINT32;
      pcchLength: PCardinal): HResult; stdcall;
    function GetAllocatedString(const [Ref] guidKey: TGUID; out ppwszValue: PWideChar;
      out pcchLength: UINT32): HResult; stdcall;
    function GetBlobSize(const [Ref] guidKey: TGUID; out pcbBlobSize: UINT32): HResult; stdcall;
    function GetBlob(const [Ref] guidKey: TGUID; pBuf: PByte; cbBufSize: UINT32; pcbBlobSize: PCardinal): HResult; stdcall;
    function GetAllocatedBlob(const [Ref] guidKey: TGUID; out ppBuf: PByte; out pcbSize: UINT32): HResult; stdcall;
    function GetUnknown(const [Ref] guidKey: TGUID; const [Ref] riid: TGUID; out ppv): HResult; stdcall;
    function SetItem(const [Ref] guidKey: TGUID; Value: Pointer): HResult; stdcall;
    function DeleteItem(const [Ref] guidKey: TGUID): HResult; stdcall;
    function DeleteAllItems: HResult; stdcall;
    function SetUINT32(const [Ref] guidKey: TGUID; unValue: UINT32): HResult; stdcall;
    function SetUINT64(const [Ref] guidKey: TGUID; unValue: UINT64): HResult; stdcall;
    function SetDouble(const [Ref] guidKey: TGUID; fValue: Double): HResult; stdcall;
    function SetGUID(const [Ref] guidKey: TGUID; const [Ref] guidValue: TGUID): HResult; stdcall;
    function SetString(const [Ref] guidKey: TGUID; wszValue: PWideChar): HResult; stdcall;
    function SetBlob(const [Ref] guidKey: TGUID; pBuf: PByte; cbBufSize: UINT32): HResult; stdcall;
    function SetUnknown(const [Ref] guidKey: TGUID; pUnknown: IUnknown): HResult; stdcall;
    function LockStore: HResult; stdcall;
    function UnlockStore: HResult; stdcall;
    function GetCount(out pcItems: UINT32): HResult; stdcall;
    function GetItemByIndex(unIndex: UINT32; out pguidKey: TGUID; pValue: Pointer): HResult; stdcall;
    function CopyAllItems(pDest: IMFAttributes): HResult; stdcall;
  end;

  IMFMediaType = interface(IMFAttributes)
    ['{44AE0FA8-EA31-4109-8D2E-4CAE4997C555}']
    function GetMajorType(out pguidMajorType: TGUID): HResult; stdcall;
    function IsCompressedFormat(out pfCompressed: BOOL): HResult; stdcall;
    function IsEqual(pIMediaType: IMFMediaType; out pdwFlags: DWORD): HResult; stdcall;
    function GetRepresentation(guidRepresentation: TGUID; out ppvRepresentation: Pointer): HResult; stdcall;
    function FreeRepresentation(guidRepresentation: TGUID; pvRepresentation: Pointer): HResult; stdcall;
  end;

  IMFMediaBuffer = interface(IUnknown)
    ['{045FA593-8799-42B8-BC8D-8968C6453507}']
    function Lock(out ppbBuffer: PByte; pcbMaxLength: PDWORD; pcbCurrentLength: PDWORD): HResult; stdcall;
    function Unlock: HResult; stdcall;
    function GetCurrentLength(out pcbCurrentLength: DWORD): HResult; stdcall;
    function SetCurrentLength(cbCurrentLength: DWORD): HResult; stdcall;
    function GetMaxLength(out pcbMaxLength: DWORD): HResult; stdcall;
  end;

  IMFSample = interface(IMFAttributes)
    ['{C40A00F2-B93A-4D80-AE8C-5A1C634F58E4}']
    function GetSampleFlags(out pdwSampleFlags: DWORD): HResult; stdcall;
    function SetSampleFlags(dwSampleFlags: DWORD): HResult; stdcall;
    function GetSampleTime(out phnsSampleTime: Int64): HResult; stdcall;
    function SetSampleTime(hnsSampleTime: Int64): HResult; stdcall;
    function GetSampleDuration(out phnsSampleDuration: Int64): HResult; stdcall;
    function SetSampleDuration(hnsSampleDuration: Int64): HResult; stdcall;
    function GetBufferCount(out pdwBufferCount: DWORD): HResult; stdcall;
    function GetBufferByIndex(dwIndex: DWORD; out ppBuffer: IMFMediaBuffer): HResult; stdcall;
    function ConvertToContiguousBuffer(out ppBuffer: IMFMediaBuffer): HResult; stdcall;
    function AddBuffer(pBuffer: IMFMediaBuffer): HResult; stdcall;
    function RemoveBufferByIndex(dwIndex: DWORD): HResult; stdcall;
    function RemoveAllBuffers: HResult; stdcall;
    function GetTotalLength(out pcbTotalLength: DWORD): HResult; stdcall;
    function CopyToBuffer(pBuffer: IMFMediaBuffer): HResult; stdcall;
  end;

  IMFSinkWriter = interface(IUnknown)
    ['{3137F1CD-FE5E-4805-A5D8-FB477448CB3D}']
    function AddStream(pTargetMediaType: IMFMediaType; out pdwStreamIndex: DWORD): HResult; stdcall;
    function SetInputMediaType(dwStreamIndex: DWORD; pInputMediaType: IMFMediaType;
      pEncodingParameters: IMFAttributes): HResult; stdcall;
    function BeginWriting: HResult; stdcall;
    function WriteSample(dwStreamIndex: DWORD; pSample: IMFSample): HResult; stdcall;
    function SendStreamTick(dwStreamIndex: DWORD; llTimestamp: Int64): HResult; stdcall;
    function PlaceMarker(dwStreamIndex: DWORD; pvContext: Pointer): HResult; stdcall;
    function NotifyEndOfSegment(dwStreamIndex: DWORD): HResult; stdcall;
    function Flush(dwStreamIndex: DWORD): HResult; stdcall;
    function Finalize: HResult; stdcall;
    function GetServiceForStream(dwStreamIndex: DWORD; const [Ref] guidService: TGUID; const [Ref] riid: TGUID;
      out ppvObject): HResult; stdcall;
    function GetStatistics(dwStreamIndex: DWORD; pStats: Pointer): HResult; stdcall;
  end;

function MFStartup(Version: ULONG; dwFlags: DWORD): HResult; stdcall;
function MFShutdown: HResult; stdcall;
function MFCreateAttributes(out ppMFAttributes: IMFAttributes; cInitialSize: UINT32): HResult; stdcall;
function MFCreateMediaType(out ppMFType: IMFMediaType): HResult; stdcall;
function MFCreateSample(out ppIMFSample: IMFSample): HResult; stdcall;
function MFCreateMemoryBuffer(cbMaxLength: DWORD; out ppBuffer: IMFMediaBuffer): HResult; stdcall;
function MFCreateSinkWriterFromURL(pwszOutputURL: PWideChar; pByteStream: IUnknown; pAttributes: IMFAttributes;
  out ppSinkWriter: IMFSinkWriter): HResult; stdcall;

// True se le due DLL di Media Foundation si caricano. Non dice ancora se il
// codificatore H.264 c'e': lo si scopre creando lo scrittore.
function MediaFoundationPresente(out AMotivo: string): boolean;

// Dimensione del fotogramma e frequenza vanno passate come un solo UINT64
// con il primo valore nei 32 bit alti (MFSetAttributeSize e MFSetAttributeRatio
// di mfapi.h, che sono funzioni inline e non stanno in nessuna DLL).
function CoppiaUInt64(AAlto, ABasso: Cardinal): UINT64;

implementation

// "delayed" e' propria di Windows: l'avviso W1002 qui non dice niente.
{$WARN SYMBOL_PLATFORM OFF}

const
  mfplat = 'mfplat.dll';
  mfreadwrite = 'mfreadwrite.dll';

function MFStartup; external mfplat delayed;
function MFShutdown; external mfplat delayed;
function MFCreateAttributes; external mfplat delayed;
function MFCreateMediaType; external mfplat delayed;
function MFCreateSample; external mfplat delayed;
function MFCreateMemoryBuffer; external mfplat delayed;
function MFCreateSinkWriterFromURL; external mfreadwrite delayed;

function MediaFoundationPresente(out AMotivo: string): boolean;
var
  Libreria: HMODULE;
  Nome: string;
begin
  result := False;
  for Nome in [mfplat, mfreadwrite] do
  begin
    Libreria := LoadLibrary(PChar(Nome));
    if Libreria = 0 then
    begin
      AMotivo := Nome + ' non trovata: Media Foundation non e'' installato su questo computer';
      Exit;
    end;
    FreeLibrary(Libreria);
  end;
  AMotivo := '';
  result := True;
end;

function CoppiaUInt64(AAlto, ABasso: Cardinal): UINT64;
begin
  result := (UINT64(AAlto) shl 32) or ABasso;
end;

end.
