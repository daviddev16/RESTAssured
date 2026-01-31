unit RESTAssured.Spec.JSON;

interface

uses
  System.JSON,
  System.SysUtils,
  RESTAssured.Assert,
  RESTAssured.Utils.ErrorHandling;

type
  IRESTAssuredJSONSpec = interface
    function AssertNotEmpty(FieldName: String): IRESTAssuredJSONSpec;
    function AssertThat(FieldName: String; Expected: String): IRESTAssuredJSONSpec; overload;
    function AssertThat(FieldName: String; Expected: Integer): IRESTAssuredJSONSpec; overload;
    function AssertThat(FieldName: String; Expected: Double): IRESTAssuredJSONSpec; overload;
  end;

  TRESTAssuredJSONSpec = class(TInterfacedObject, IRESTAssuredJSONSpec)
    strict private
      FJSONValue: TJSONValue;
    private
      procedure ValidateJSONValue(FieldName: String; JSONValue: TJSONValue);
      function AssertThatInternal<T>(FieldName: String; Expected: T): IRESTAssuredJSONSpec;
    public
      function AssertNotEmpty(FieldName: String): IRESTAssuredJSONSpec;
      function AssertThat(FieldName: String; Expected: String): IRESTAssuredJSONSpec; overload;
      function AssertThat(FieldName: String; Expected: Integer): IRESTAssuredJSONSpec; overload;
      function AssertThat(FieldName: String; Expected: Double): IRESTAssuredJSONSpec; overload;
    public
      constructor Create(JSONValue: TJSONValue);
      destructor Destroy(); override;
    end;

implementation

uses
  System.Rtti;

{ TRESTAssuredJSONSpec }

constructor TRESTAssuredJSONSpec.Create;
begin
  FJSONValue := JSONValue;
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: String): IRESTAssuredJSONSpec;
begin
  Result := AssertThatInternal<String>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: Integer): IRESTAssuredJSONSpec;
begin
  Result := AssertThatInternal<Integer>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: Double): IRESTAssuredJSONSpec;
begin
  Result := AssertThatInternal<Double>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertThatInternal<T>(
  FieldName: String;
  Expected: T): IRESTAssuredJSONSpec;
var
  lActual: T;
  lJSONValue: TJSONValue;
  lExpectedTValue: TValue;
begin
  Result := Self;
  lJSONValue := FJSONValue.FindValue(FieldName);
  lExpectedTValue := TValue.From<T>(Expected);
  try
    ValidateJSONValue(FieldName, lJSONValue);
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

function TRESTAssuredJSONSpec.AssertNotEmpty(
  FieldName: String): IRESTAssuredJSONSpec;
var
  lJSONValue: TJSONValue;
begin
  Result := Self;
  lJSONValue := FJSONValue.FindValue(FieldName);
  try
    ValidateJSONValue(FieldName, lJSONValue);

    if not (lJSONValue is TJSONString) then
    begin
      raise ERESTAssuredException.CreateFmt('Field "%s" must be a JSONString.',
                                            [FieldName]);
    end;

    if String.IsNullOrEmpty(TJSONString(lJSONValue).Value) then
      TRESTAssuredAssert.Fail('Field "%s" must not be empty.',
                              [FieldName]);

  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle(
          'AssertNotEmpty',
          [FieldName], Ex);
  end;
end;

procedure TRESTAssuredJSONSpec.ValidateJSONValue;
begin
  if not Assigned(JSONValue) then
  begin
    raise ERESTAssuredException.CreateFmt('Field "%s" does not exist.',
                                          [FieldName]);
  end;
end;
destructor TRESTAssuredJSONSpec.Destroy;
begin
  FJSONValue.Free();
  inherited;
end;

end.
