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
    function BodyIsJson(): IRESTAssuredJSONSpec;
    function StatusCodeIs(Expected: Integer): IRESTAssuredResponseSpec;
  end;

  TRESTAssuredResponseSpec = class(TInterfacedObject, IRESTAssuredResponseSpec)
    strict private
      FRESTResponse: IRESTResponse;
    public
      function BodyIsJson(): IRESTAssuredJSONSpec;
      function StatusCodeIs(Expected: Integer): IRESTAssuredResponseSpec;
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

function TRESTAssuredResponseSpec.StatusCodeIs;
begin
  TRESTAssuredAssert.AreEqual<Integer>(
      Expected,
      FRESTResponse.GetStatus(),
      'Status Code expected to be {{EXPECTED}} but got {{ACTUAL}}.');
end;

function TRESTAssuredResponseSpec.BodyIsJson;
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
