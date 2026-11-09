object zControlsController: TzControlsController
  OldCreateOrder = False
  Height = 77
  Width = 152
  object ReadTrans: TzFbTransaction
    TRParams.Strings = (
      'read'
      'nowait'
      'rec_version'
      'read_committed')
    TPBMode = tpbDefault
    Left = 28
    Top = 22
  end
  object WriteTrans: TzFbTransaction
    TRParams.Strings = (
      'write'
      'nowait'
      'rec_version'
      'read_committed')
    TPBMode = tpbDefault
    Left = 92
    Top = 22
  end
end
