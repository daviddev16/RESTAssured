unit RESTAssured.Spec.JSON.Base;

interface

uses
  System.JSON;

type
  TTRESTAssuredJSONBaseSpec = class abstract(TInterfacedObject)
    strict private
      FJSONValue: TJSONValue;
      FOwnJSONValue: Boolean;
    private const
    protected
      procedure AssertThatInternal<T>(FieldName: String; Expected: T);
      procedure AssertGreaterThanInternal<T>(FieldName: String; Value: T);
      procedure AssertLessThanInternal<T>(FieldName: String; Value: T);
      procedure AssertNotEmptyInternal(FieldName: String);
      procedure AssertIsEmptyInternal(FieldName: string);
      function FindJSONValue(FieldName: String): TJSONValue;
      function FindAsJSONString(FieldName: string): String;
    public
      constructor Create(JSONValue: TJSONValue; OwnJSONValue: Boolean = True);
      destructor Destroy(); override;
    end;

implementation

uses
  System.Rtti,
  System.TypInfo,
  System.SysUtils,
  RESTAssured.Miscs,
  RESTAssured.Assert,
  RESTAssured.Utils.ErrorHandling;

constructor TTRESTAssuredJSONBaseSpec.Create(
  JSONValue: TJSONValue;
  OwnJSONValue: Boolean);
begin
  FJSONValue := JSONValue;
  FOwnJSONValue := OwnJSONValue;
end;

procedure TTRESTAssuredJSONBaseSpec.AssertLessThanInternal<T>(
  FieldName: String;
  Value: T);
const
  MESSAGE_FMT = 'Field "%s" expected to be less than "{{LESSER}}" (Actual "{{ACTUAL}}").';
var
  lActual: T;
  lJSONValue: TJSONValue;
  lMessage: TRESTAssuredMessage;
begin
  lMessage := TRESTAssuredMessage
      .New('AssertGreaterThan')
      .Parameters([FieldName, TGenericHelper.Describe<T>(Value)])
      .AssertationMessage(MESSAGE_FMT, [FieldName]);

  try
    lJSONValue := FindJSONValue(FieldName);
    lActual := lJSONValue.AsType<T>();
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  TRESTAssuredAssert.IsLessThan<T>(Value,
                                   lActual,
                                   lMessage.Build());
end;

procedure TTRESTAssuredJSONBaseSpec.AssertGreaterThanInternal<T>(
  FieldName: String;
  Value: T);
const
  MESSAGE_FMT = 'Field "%s" expected to be greater than "{{GREATER}}" (Actual "{{ACTUAL}}").';
var
  lActual: T;
  lJSONValue: TJSONValue;
  lMessage: TRESTAssuredMessage;
begin
  lMessage := TRESTAssuredMessage
      .New('AssertGreaterThan')
      .Parameters([FieldName, TGenericHelper.Describe<T>(Value)])
      .AssertationMessage(MESSAGE_FMT, [FieldName]);

  try
    lJSONValue := FindJSONValue(FieldName);
    lActual := lJSONValue.AsType<T>();
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  TRESTAssuredAssert.IsGreaterThan<T>(Value,
                                      lActual,
                                      lMessage.Build());
end;

procedure TTRESTAssuredJSONBaseSpec.AssertThatInternal<T>(
  FieldName: String;
  Expected: T);
const
  MESSAGE_FMT = 'Field "%s" expected to be "{{EXPECTED}}" but it was "{{ACTUAL}}".';
var
  lActual: T;
  lJSONValue: TJSONValue;
  lMessage: TRESTAssuredMessage;
begin
  lMessage := TRESTAssuredMessage
      .New('AssertThat')
      .Parameters([FieldName, TGenericHelper.Describe<T>(Expected)])
      .AssertationMessage(MESSAGE_FMT, [FieldName]);

  try
    lJSONValue := FindJSONValue(FieldName);
    lActual := lJSONValue.AsType<T>();
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  TRESTAssuredAssert.AreEqual<T>(Expected,
                                 lActual,
                                 lMessage.Build());
end;

procedure TTRESTAssuredJSONBaseSpec.AssertIsEmptyInternal(
  FieldName: string);
const
  MESSAGE_FMT = 'Field "%s" must be empty.';
var
  lValue: String;
  lMessage: TRESTAssuredMessage;
begin
  lMessage := TRESTAssuredMessage
      .New('AssertIsEmpty')
      .Parameters([FieldName])
      .AssertationMessage(MESSAGE_FMT, [FieldName]);

  try
    lValue := FindAsJSONString(FieldName);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  TRESTAssuredAssert.IsEmpty(lValue,
                             lMessage.Build());
end;

procedure TTRESTAssuredJSONBaseSpec.AssertNotEmptyInternal(
  FieldName: String);
const
  MESSAGE_FMT = 'Field "%s" must not be empty.';
var
  lValue: String;
  lMessage: TRESTAssuredMessage;
begin
  lMessage := TRESTAssuredMessage
      .New('AssertNotEmpty')
      .Parameters([FieldName])
      .AssertationMessage(MESSAGE_FMT, [FieldName]);

  try
    lValue := FindAsJSONString(FieldName);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(lMessage, Ex);
  end;

  TRESTAssuredAssert.IsNotEmpty(lValue,
                                lMessage.Build());
end;

function TTRESTAssuredJSONBaseSpec.FindAsJSONString(
  FieldName: string): String;
var
  lJSONValue: TJSONValue;
begin
  lJSONValue := FindJSONValue(FieldName);

  if not (lJSONValue is TJSONString) then
  begin
    raise ERESTAssuredException.CreateFmt(
      'Field "%s" must be a JSONString.',
      [FieldName]);
  end;

  Result := TJSONString(lJSONValue).Value;
end;

function TTRESTAssuredJSONBaseSpec.FindJSONValue(
  FieldName: String): TJSONValue;
begin
  Result := FJSONValue.FindValue(FieldName);
  if not Assigned(Result) then
  begin
    raise ERESTAssuredException.CreateFmt(
      'Field "%s" does not exist.', [FieldName]);
  end;
end;

destructor TTRESTAssuredJSONBaseSpec.Destroy();
begin
  if FOwnJSONValue then
    FJSONValue.Free();
  inherited;
end;

end.
