unit RESTAssured.Miscs;

interface

uses
  System.Rtti,
  System.TypInfo,
  System.StrUtils,
  System.SysUtils,
  System.Variants;

type
  TGenericHelper = class
  public
    class function Describe<T>(Any: T): String;
    class function EnumToString<T>(EnumValue: T): String;
    class function BetterStringOf(Value: TValue): String;
    class function CreateArguments(FunctionArgs: Array Of Const): String;
  end;

  TRESTAssuredMessage = record
    private
      FFunctionName: String;
      FAssertationMessage: String;
      FParameters: TArray<TVarRec>;
    public
      function Build(): String;
      function Exception(Value: Exception): TRESTAssuredMessage;
      function Parameters(Value: Array Of Const): TRESTAssuredMessage;
      function AssertationMessage(Value: String; Args: Array Of Const): TRESTAssuredMessage;
    public
      constructor New(FunctionName: String);
    end;

const
  NULL_STRING = 'NULL';
  EMPTY_STRING = '???';
  UNKNOWN_STRING = EMPTY_STRING;

implementation

{ TGenericHelper }

class function TGenericHelper.CreateArguments(
  FunctionArgs: Array Of Const): String;
var
  lValue: TValue;
  lSb: TStringBuilder;
  lValueAsString: String;
  lLength: Integer;
begin
  lSb := TStringBuilder.Create();
  lLength := Length(FunctionArgs);
  try
    for var I := 0 to lLength - 1 do
    begin
      lValue := TValue.FromVarRec(FunctionArgs[I]);
      if lValue.IsEmpty then
        lValueAsString := EMPTY_STRING
      else
        lValueAsString := QuotedStr(BetterStringOf(lValue));

      lSb.Append(lValueAsString);

      if I < lLength - 1 then
        lSb.Append(', ');
    end;
    Result := lSb.ToString();
  finally
    lSb.Free();
  end;
end;

class function TGenericHelper.EnumToString<T>(
  EnumValue: T): String;
begin
  Result := 'Not a Enum';
  if PTypeInfo(TypeInfo(T))^.Kind = tkEnumeration then
    Result := Describe(TValue.From<T>(EnumValue));
end;

class function TGenericHelper.Describe<T>(Any: T): String;
begin
  Result := BetterStringOf(TValue.From<T>(Any));
end;

class function TGenericHelper.BetterStringOf(
  Value: TValue): String;
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

{ TRESTAssuredMessage }

constructor TRESTAssuredMessage.New(FunctionName: String);
begin
  FFunctionName := FunctionName;
end;

function TRESTAssuredMessage.AssertationMessage(
  Value: String; Args: Array Of Const): TRESTAssuredMessage;
begin
  FAssertationMessage := Format(Value, Args);
  Result := Self;
end;

function TRESTAssuredMessage.Parameters(
  Value: Array Of Const): TRESTAssuredMessage;
begin
  SetLength(FParameters, Length(Value));
  for var I := 0 to Length(Value) - 1 do
    FParameters[I] := Value[I];
  Result := Self;
end;

function TRESTAssuredMessage.Exception(
  Value: Exception): TRESTAssuredMessage;
begin
  FAssertationMessage := Format('ClassName: %s, Message: %s',
                                [Value.ClassName, Value.Message]);
  Result := Self;
end;

function TRESTAssuredMessage.Build(): String;
const
  FUNCTION_CALL_FMT = '%s(%s)';
  FINAL_MESSAGE_FMT = 'At %s Failed -> %s';
var
  lFunction, lArguments: String;
begin
  lArguments := TGenericHelper.CreateArguments(FParameters);
  lFunction := Format(FUNCTION_CALL_FMT, [FFunctionName, lArguments]);
  Result := Format(FINAL_MESSAGE_FMT, [lFunction, FAssertationMessage]);
end;





end.
