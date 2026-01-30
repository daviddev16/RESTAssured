unit RESTAssured.Spec.JSON;

interface

uses
  System.JSON,
  System.SysUtils,
  RESTAssured.Assert;

type
  IRESTAssuredJSONSpec = interface
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
      Format('Json field "%s" expected to be {{EXPECTED}} but it was {{ACTUAL}}.',
             [FieldName]));

  Result := Self;
end;

destructor TRESTAssuredJSONSpec.Destroy;
begin
  FJSONValue.Free();
  inherited;
end;

end.
