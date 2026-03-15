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
    function AssertIsEmpty(FieldName: string): IRESTAssuredJSONSpec;
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
      function AssertIsEmpty(FieldName: string): IRESTAssuredJSONSpec;
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
  AssertThatInternal<T>(FieldName, Expected);
  Result := Self;
end;

function TRESTAssuredJSONSpec.AssertGreaterThan(
  FieldName: String;
  Expected: Double): IRESTAssuredJSONSpec;
begin
  AssertGreaterThanInternal<Double>(FieldName, Expected);
  Result := Self;
end;

function TRESTAssuredJSONSpec.AssertLessThan(
  FieldName: String;
  Expected: Double): IRESTAssuredJSONSpec;
begin
  AssertLessThanInternal<Double>(FieldName, Expected);
  Result := Self;
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: String): IRESTAssuredJSONSpec;
begin
  AssertThatInternal<String>(FieldName, Expected);
  Result := Self;
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: Boolean): IRESTAssuredJSONSpec;
begin
  AssertThatInternal<Boolean>(FieldName, Expected);
  Result := Self;
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: Integer): IRESTAssuredJSONSpec;
begin
  AssertThatInternal<Integer>(FieldName, Expected);
  Result := Self;
end;

function TRESTAssuredJSONSpec.AssertThat(
  FieldName: String;
  Expected: Double): IRESTAssuredJSONSpec;
begin
  AssertThatInternal<Double>(FieldName, Expected);
  Result := Self;
end;

function TRESTAssuredJSONSpec.AssertDateTime(
  FieldName: String;
  Expected: TDateTime): IRESTAssuredJSONSpec;
begin
  AssertThatInternal<TDateTime>(FieldName, Expected);
  Result := Self;
end;

function TRESTAssuredJSONSpec.AssertNotEmpty(
  FieldName: String): IRESTAssuredJSONSpec;
begin
  AssertNotEmptyInternal(FieldName);
  Result := Self;
end;

function TRESTAssuredJSONSpec.AssertIsEmpty(
  FieldName: string): IRESTAssuredJSONSpec;
begin
  AssertIsEmptyInternal(FieldName);
  Result := Self;
end;

end.
