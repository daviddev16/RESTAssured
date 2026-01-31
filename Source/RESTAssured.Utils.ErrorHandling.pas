unit RESTAssured.Utils.ErrorHandling;

interface

uses
  System.Rtti,
  System.Classes,
  System.SysUtils;

type
  ERESTAssuredException = class(Exception);

  TRESTAssuredErrorHandler = class sealed
    private
      class function GetLegibleValue(Value: TValue): String;
      class function HandleSpecificMessage(Ex: Exception): String;
    public
      class function Beautify<T>(EnumValue: T): String;
      class function CreateArguments(FunctionArgs: Array Of Const): String;
      class procedure Handle(FunctionName: String; FunctionArgs: Array Of Const; Ex: Exception);
    end;

implementation

uses
  System.JSON,
  System.Variants,
  System.TypInfo,
  System.StrUtils;

const
  NULL_STRING = 'NULL';
  EMPTY_STRING = '???';
  UNKNOWN_STRING = EMPTY_STRING;

{ TRESTAssuredErrorHandler }

class procedure TRESTAssuredErrorHandler.Handle;
var
  lMessage: String;
begin
  lMessage := HandleSpecificMessage(Ex);

  raise ERESTAssuredException.CreateFmt(
    'At %s(%s) -> %s',
    [FunctionName, CreateArguments(FunctionArgs), lMessage]);
end;

class function TRESTAssuredErrorHandler.HandleSpecificMessage(
  Ex: Exception): String;
begin
  Result := Ex.Message;

  if Ex is EJSONParseException then
    Result := 'Could not parse. Invalid JSON structure.';
end;

class function TRESTAssuredErrorHandler.CreateArguments;
var
  lValue: TValue;
  lSb: TStringBuilder;
  lLegibleValue: String;
  lLength: Integer;
begin
  lSb := TStringBuilder.Create();
  lLength := Length(FunctionArgs);
  try
    for var I := 0 to lLength - 1 do
    begin
      lValue := TValue.FromVarRec(FunctionArgs[I]);
      if lValue.IsEmpty then
        lLegibleValue := EMPTY_STRING
      else
        lLegibleValue := QuotedStr(GetLegibleValue(lValue));

      lSb.Append(lLegibleValue);

      if I < lLength - 1 then
        lSb.Append(', ');
    end;
    Result := lSb.ToString();
  finally
    lSb.Free();
  end;
end;

class function TRESTAssuredErrorHandler.Beautify<T>;
begin
  Result := GetLegibleValue(TValue.From<T>(EnumValue));
end;

class function TRESTAssuredErrorHandler.GetLegibleValue;
var
  lTypeInfo: PTypeInfo;
begin
  lTypeInfo := Value.TypeInfo;

  if Value.Kind = tkEnumeration then
  begin
    if lTypeInfo = TypeInfo(Boolean) then
    begin
      Result := BoolToStr(Value.AsBoolean, True);
      Exit;
    end;

    Result := lTypeInfo^.Name + '.';
    Result := Result + GetEnumName(lTypeInfo, Value.AsOrdinal);
  end
  else if Value.IsEmpty then
    Result := EMPTY_STRING
  else if Value.Kind = tkVariant then
    Result := VarToStrDef(Value.AsVariant, NULL_STRING)
  else
    Result := Value.ToString();
end;

end.
