unit RESTAssured.Spec.JSON;

interface

uses
  System.JSON,
  System.SysUtils,
  RESTAssured.Assert,
  RESTAssured.Spec.JSON.Base,
  RESTAssured.Utils.ErrorHandling;

type
  IRESTAssuredJSONSpec = interface
    function AssertNotEmpty(FieldName: String): IRESTAssuredJSONSpec;
    function AssertThat(FieldName: String; Expected: String): IRESTAssuredJSONSpec; overload;
    function AssertThat(FieldName: String; Expected: Boolean): IRESTAssuredJSONSpec; overload;
    function AssertThat(FieldName: String; Expected: Integer): IRESTAssuredJSONSpec; overload;
    function AssertThat(FieldName: String; Expected: Double): IRESTAssuredJSONSpec; overload;
    function AssertDateTime(FieldName: String; Expected: TDateTime): IRESTAssuredJSONSpec; overload;
    function AssertGreaterThan(FieldName: String; Expected: Double): IRESTAssuredJSONSpec; overload;
    function AssertLessThan(FieldName: String; Expected: Double): IRESTAssuredJSONSpec; overload;
  end;

  TRESTAssuredJSONSpec = class(TTRESTAssuredJSONBaseSpec, IRESTAssuredJSONSpec)
    public
      function AssertNotEmpty(FieldName: String): IRESTAssuredJSONSpec;
      function AssertThat<T>(FieldName: String; Expected: T): IRESTAssuredJSONSpec; overload;
      function AssertThat(FieldName: String; Expected: String): IRESTAssuredJSONSpec; overload;
      function AssertThat(FieldName: String; Expected: Boolean): IRESTAssuredJSONSpec; overload;
      function AssertThat(FieldName: String; Expected: Integer): IRESTAssuredJSONSpec; overload;
      function AssertThat(FieldName: String; Expected: Double): IRESTAssuredJSONSpec; overload;
      function AssertDateTime(FieldName: String; Expected: TDateTime): IRESTAssuredJSONSpec; overload;
      function AssertGreaterThan(FieldName: String; Expected: Double): IRESTAssuredJSONSpec; overload;
      function AssertLessThan(FieldName: String; Expected: Double): IRESTAssuredJSONSpec; overload;
  end;

implementation

uses
  System.Rtti,
  System.TypInfo;

{ TRESTAssuredJSONSpec }

function TRESTAssuredJSONSpec.AssertThat<T>(
  FieldName: String;
  Expected: T): IRESTAssuredJSONSpec;
begin
  Result := Self;
  AssertThatInternal<T>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertGreaterThan(
  FieldName: String;
  Expected: Double): IRESTAssuredJSONSpec;
begin
  Result := Self;
  AssertGreaterThanInternal<Double>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertLessThan(
  FieldName: String;
  Expected: Double): IRESTAssuredJSONSpec;
begin
  Result := Self;
  AssertLessThanInternal<Double>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: String): IRESTAssuredJSONSpec;
begin
  Result := Self;
  AssertThatInternal<String>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: Boolean): IRESTAssuredJSONSpec;
begin
  Result := Self;
  AssertThatInternal<Boolean>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: Integer): IRESTAssuredJSONSpec;
begin
  Result := Self;
  AssertThatInternal<Integer>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: Double): IRESTAssuredJSONSpec;
begin
  Result := Self;
  AssertThatInternal<Double>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertDateTime(
  FieldName: String;
  Expected: TDateTime): IRESTAssuredJSONSpec;
begin
  Result := Self;
  AssertThatInternal<TDateTime>(FieldName, Expected);
end;

function TRESTAssuredJSONSpec.AssertNotEmpty(
  FieldName: String): IRESTAssuredJSONSpec;
begin
  Result := Self;
  AssertNotEmptyInternal(FieldName);
end;

end.
