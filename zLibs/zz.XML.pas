unit zz.XML;

interface

uses
  System.SysUtils,
  System.Classes,
  XML.xmldom,
  XML.XMLIntf,
  XML.XMLDoc,
  XML.Win.msxmldom;

type
  TXMLDocumentHelper = class helper for TXMLDocument
  public
    procedure ClearNameSpaces;
    procedure ClearNameSpace(const NameSpace: String);

    
  end;

implementation

uses
  System.Generics.Collections;

procedure TXMLDocumentHelper.ClearNameSpaces;
var
  i: integer;
  Prefix: string;
  PrefixList: TList<string>;
  node: IXMLNode;
  tmpXML: string;
begin

  PrefixList := TList<string>.Create;
  try
    for i := 0 to ChildNodes.Nodes[1].AttributeNodes.Count - 1 do
    begin
      node := ChildNodes.Nodes[1].AttributeNodes[i];

      // Prefix := node.Xml;
      // Prefix := node.Prefix;
      // Prefix := node.NamespaceURI;
      // Prefix := node.Text;
      Prefix := node.LocalName;

      if not Prefix.IsEmpty then
        if not PrefixList.Contains(Prefix) then
          PrefixList.Add(Prefix);
    end;

    /// /////////////////////

    tmpXML := XML.Text;
    for Prefix in PrefixList do
    begin
      tmpXML := tmpXML.Replace('<' + Prefix + ':', '<', [rfReplaceAll]);
      tmpXML := tmpXML.Replace('</' + Prefix + ':', '</', [rfReplaceAll]);
    end;

    XML.Text := tmpXML;
    Active := true;
  finally
    FreeAndNil(PrefixList);
  end;
end;

procedure TXMLDocumentHelper.ClearNameSpace(const NameSpace: String);
var
  tmpXML: string;
begin
  tmpXML := XML.Text;
  tmpXML := tmpXML.Replace('' + NameSpace, '', [rfReplaceAll, rfIgnoreCase]);
  XML.Text := tmpXML;
  Active := true;
end;

end.
