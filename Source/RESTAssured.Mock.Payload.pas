unit RESTAssured.Mock.Payload;

interface

uses
  System.JSON,
  System.IOUtils,
  System.SysUtils,
  RESTAssured.Utils,
  RESTAssured.Utils.ErrorHandling;

type
  Payload = record
    private
      Bytes: TBytes;
    public
      function AsValueOf<T>(): T;
    private
      class function ReadFromLocalFile(RelativeFilePath: string): Payload; static;
    end;

function ReadPayload(RelativeFilePath: String): Payload;

implementation

uses
  System.Rtti,
  System.Types,
  System.TypInfo,
  System.StrUtils;

function ReadPayload(RelativeFilePath: String): Payload;
begin
  Result := Payload.ReadFromLocalFile(RelativeFilePath);
end;

{ Payload }

function Payload.AsValueOf<T>: T;
var
  lValue: TValue;
  lTypeInfo: PTypeInfo;
  lContent: String;
  lJSONValue: TJSONValue;
begin
  lValue := TValue.Empty;
  lContent := TEncoding.UTF8.GetString(Bytes);

  if lTypeInfo^.Kind in [tkString, tkUString, tkWString] then
    lValue := TValue.From<String>(lContent)

  else if lTypeInfo^.Kind = tkClass then
  begin
    lJSONValue := TJSONValue.ParseJSONValue(lContent);

    if TJSONObject.ClassNameIs(String(lTypeInfo^.Name)) then
      lValue := TValue.From<TJSONObject>(TJSONObject(lJSONValue))

    else if TJSONArray.ClassNameIs(String(lTypeInfo^.Name)) then
      lValue := TValue.From<TJSONArray>(TJSONArray(lJSONValue))

    else if TJSONValue.ClassNameIs(String(lTypeInfo^.Name)) then
      lValue := TValue.From<TJSONValue>(lJSONValue)
  end;

  if lValue.IsEmpty then
    raise ERESTAssuredException.CreateFmt(
      'Content "%s" is not supported by "Payload#AsValueOf<%s>()"',
      [lContent, lTypeInfo^.Name]);

  Result := lValue.AsType<T>(False);
end;

class function Payload.ReadFromLocalFile(
  RelativeFilePath: String): Payload;
var
  lFilePath: String;
begin
  RelativeFilePath := TRESTAssuredUtils.TrimPath(RelativeFilePath);

  lFilePath := ExtractFilePath(ParamStr(0));
  lFilePath := IncludeTrailingPathDelimiter(lFilePath);
  lFilePath := lFilePath + RelativeFilePath;

  Result.Bytes := TFile.ReadAllBytes(lFilePath);
end;

end.
