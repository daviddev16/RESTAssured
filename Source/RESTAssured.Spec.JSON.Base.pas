unit RESTAssured.Spec.JSON.Base;

interface

uses
  System.JSON;

type
  TTRESTAssuredJSONBaseSpec = class abstract(TInterfacedObject)
    strict private
      FJSONValue: TJSONValue;
    private
      const
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
      function FindJSONValue(FieldName: String): TJSONValue;
    public
      constructor Create(JSONValue: TJSONValue);
      destructor Destroy(); override;
    end;

implementation

uses
  System.Rtti,
  System.TypInfo,
  System.SysUtils,
  RESTAssured.Assert,
  RESTAssured.Utils.ErrorHandling;

constructor TTRESTAssuredJSONBaseSpec.Create(JSONValue: TJSONValue);
begin
  FJSONValue := JSONValue;
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

procedure TTRESTAssuredJSONBaseSpec.AssertNotEmptyInternal;
var
  lJSONValue: TJSONValue;
begin
  try
    lJSONValue := FindJSONValue(FieldName);

    if not (lJSONValue is TJSONString) then
    begin
      raise ERESTAssuredException.CreateFmt(
        'Field "%s" must be a JSONString.',
        [FieldName]);
    end;
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(
          'AssertNotEmpty',
          [FieldName], Ex);
  end;

  if String.IsNullOrEmpty(TJSONString(lJSONValue).Value) then
    TRESTAssuredAssert.Fail(
      'Field "%s" must not be empty.', [FieldName]);
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
  FJSONValue.Free();
  inherited;
end;

end.
