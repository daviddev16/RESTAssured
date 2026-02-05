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
      ASSERT_THAT_UNSUPPORTED_KINDS: Set Of TTypeKind =
        [tkUnknown,   tkRecord,    tkClass,
         tkClassRef,  tkInterface, tkPointer,
         tkProcedure, tkMethod,    tkMRecord];
    protected
      procedure AssertThatCheckSupportedType<T>();
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
  RESTAssured.Assert,
  RESTAssured.Utils.ErrorHandling;

constructor TTRESTAssuredJSONBaseSpec.Create(
  JSONValue: TJSONValue;
  OwnJSONValue: Boolean);
begin
  FJSONValue := JSONValue;
  FOwnJSONValue := OwnJSONValue;
end;

procedure TTRESTAssuredJSONBaseSpec.AssertLessThanInternal<T>;
var
  lActual: T;
  lJSONValue: TJSONValue;
  lExpectedTValue: TValue;
begin
  lExpectedTValue := TValue.From<T>(Value);
  try
    lJSONValue := FindJSONValue(FieldName);
    lActual := lJSONValue.AsType<T>();
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(
          'AssertGreaterThan',
          [FieldName, lExpectedTValue.ToString()], Ex);
  end;

  TRESTAssuredAssert.IsLessThan<T>(
      Value,
      lActual,
      Format('Field "%s" expected to be less than {{LESSER}}.', [FieldName]));
end;

procedure TTRESTAssuredJSONBaseSpec.AssertGreaterThanInternal<T>;
var
  lActual: T;
  lJSONValue: TJSONValue;
  lExpectedTValue: TValue;
begin
  lExpectedTValue := TValue.From<T>(Value);
  try
    lJSONValue := FindJSONValue(FieldName);
    lActual := lJSONValue.AsType<T>();
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(
          'AssertGreaterThan',
          [FieldName, lExpectedTValue.ToString()], Ex);
  end;

  TRESTAssuredAssert.IsGreaterThan<T>(
      Value,
      lActual,
      Format('Field "%s" expected to be greater than {{GREATER}}.', [FieldName]));
end;

procedure TTRESTAssuredJSONBaseSpec.AssertThatInternal<T>;
var
  lActual: T;
  lJSONValue: TJSONValue;
  lExpectedTValue: TValue;
begin
  AssertThatCheckSupportedType<T>();

  lExpectedTValue := TValue.From<T>(Expected);
  try
    lJSONValue := FindJSONValue(FieldName);
    lActual := lJSONValue.AsType<T>();
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(
          'AssertThat',
          [FieldName, lExpectedTValue.ToString()], Ex);
  end;

  TRESTAssuredAssert.AreEqual<T>(
      Expected,
      lActual,
      Format('Field "%s" expected to be {{EXPECTED}} but it was {{ACTUAL}}.',
             [FieldName]));
end;

procedure TTRESTAssuredJSONBaseSpec.AssertIsEmptyInternal;
var
  lValue: String;
begin
  try
    lValue := FindAsJSONString(FieldName);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(
          'AssertIsEmpty',
          [FieldName], Ex);
  end;

  TRESTAssuredAssert.IsEmpty(
      lValue,
      Format('Field "%s" must be empty.', [FieldName]));
end;

procedure TTRESTAssuredJSONBaseSpec.AssertNotEmptyInternal;
var
  lValue: String;
begin
  try
    lValue := FindAsJSONString(FieldName);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(
          'AssertNotEmpty',
          [FieldName], Ex);
  end;

  TRESTAssuredAssert.IsNotEmpty(
      lValue,
      Format('Field "%s" must not be empty.', [FieldName]));
end;

function TTRESTAssuredJSONBaseSpec.FindAsJSONString;
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

function TTRESTAssuredJSONBaseSpec.FindJSONValue;
begin
  Result := FJSONValue.FindValue(FieldName);
  if not Assigned(Result) then
  begin
    raise ERESTAssuredException.CreateFmt(
      'Field "%s" does not exist.', [FieldName]);
  end;
end;

procedure TTRESTAssuredJSONBaseSpec.AssertThatCheckSupportedType<T>;
var
  lTypeInfo: PTypeInfo;
begin
  lTypeInfo := PTypeInfo(TypeInfo(T));

  if not (lTypeInfo^.Kind in ASSERT_THAT_UNSUPPORTED_KINDS) then
    Exit;

  raise ERESTAssuredException.CreateFmt(
    'Unsupported type : %s.',[lTypeInfo^.Name]);
end;

destructor TTRESTAssuredJSONBaseSpec.Destroy;
begin
  if FOwnJSONValue then
    FJSONValue.Free();
  inherited;
end;

end.
