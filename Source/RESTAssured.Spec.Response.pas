unit RESTAssured.Spec.Response;

interface

uses
  System.SysUtils,
  RESTAssured.Utils,
  RESTAssured.Assert,
  RESTAssured.Spec.JSON,
  RESTAssured.RESTClient,
  DUnitX.TestFramework;

type
  IRESTAssuredResponseSpec = interface
    function BodyAsJson(): IRESTAssuredJSONSpec;
    function StatusCodeIs(Expected: Integer): IRESTAssuredResponseSpec; overload;
    function StatusCodeIs(Predicate: TPredicate<Integer>): IRESTAssuredResponseSpec; overload;
  end;

  TRESTAssuredResponseSpec = class(TInterfacedObject, IRESTAssuredResponseSpec)
    strict private
      FRESTResponse: IRESTResponse;
    public
      function BodyAsJson(): IRESTAssuredJSONSpec;
      function StatusCodeIs(Expected: Integer): IRESTAssuredResponseSpec; overload;
      function StatusCodeIs(Predicate: TPredicate<Integer>): IRESTAssuredResponseSpec; overload;
    public
      constructor Create(RESTResponse: IRESTResponse);
      destructor Destroy(); override;
    end;

implementation

uses
  System.JSON;

{ TRESTAssuredResponseSpec }

constructor TRESTAssuredResponseSpec.Create;
begin
  FRESTResponse := RESTResponse;
end;

function TRESTAssuredResponseSpec.StatusCodeIs(
  Expected: Integer): IRESTAssuredResponseSpec;
begin
  TRESTAssuredAssert.AreEqual<Integer>(
      Expected,
      FRESTResponse.GetStatus(),
      'Status Code expected to be {{EXPECTED}} but got {{ACTUAL}}.');
end;

function TRESTAssuredResponseSpec.StatusCodeIs(
  Predicate: TPredicate<Integer>): IRESTAssuredResponseSpec;
begin
  Result := Self;
  if not Predicate(FRESTResponse.GetStatus()) then
    TRESTAssuredAssert.Fail('StatusCodeIs#Predicate failed.', []);
end;

function TRESTAssuredResponseSpec.BodyAsJson;
var
  lBody: String;
  lJSONValue: TJSONValue;
begin
  lBody := FRESTResponse.GetBody();
  lJSONValue := TJSONValue.ParseJSONValue(lBody);
  Result := TRESTAssuredJSONSpec.Create(lJSONValue);
end;

destructor TRESTAssuredResponseSpec.Destroy;
begin
  FRESTResponse := nil;
  inherited;
end;

end.
