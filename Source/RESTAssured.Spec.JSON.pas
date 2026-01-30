unit RESTAssured.Spec.JSON;

interface

uses
  System.JSON,
  System.SysUtils,
  RESTAssured.Assert;

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

{ TRESTAssuredJSONSpec }

constructor TRESTAssuredJSONSpec.Create;
begin
  FJSONValue := JSONValue;
end;

function TRESTAssuredJSONSpec.AssertNotEmpty(
  FieldName: String): IRESTAssuredJSONSpec;
var
  lJSONValue: TJSONValue;
begin
  Result := Self;
  lJSONValue := FJSONValue.FindValue(FieldName);

  if (Assigned(lJSONValue)) and (lJSONValue is TJSONString) then
  begin
    if TJSONString(lJSONValue).Value.IsEmpty() then
    begin
      TRESTAssuredAssert.Fail('Field "%s" must not be empty.',
                              [FieldName]);
    end;

    Exit;
  end;

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
begin
  lActual := FJSONValue.GetValue<T>(FieldName);

  TRESTAssuredAssert.AreEqual<T>(
      Expected,
      lActual,
      Format('Field "%s" expected to be {{EXPECTED}} but it was {{ACTUAL}}.',
             [FieldName]));

  Result := Self;
end;

destructor TRESTAssuredJSONSpec.Destroy;
begin
  FJSONValue.Free();
  inherited;
end;

end.
