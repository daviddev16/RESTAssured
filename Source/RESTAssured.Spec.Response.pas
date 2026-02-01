unit RESTAssured.Spec.Response;

interface

uses
  System.SysUtils,
  RESTAssured.Utils,
  RESTAssured.Assert,
  RESTAssured.Types,
  RESTAssured.Spec.JSON,
  RESTAssured.Intf.RESTClient,
  RESTAssured.Default.RESTClient,
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
      function GroupSeparator(GroupName: String): IRESTAssuredResponseSpec;
    public
      constructor Create(RESTResponse: IRESTResponse);
      destructor Destroy(); override;
    end;

implementation

uses
  System.JSON,
  RESTAssured.Spec.Provider,
  RESTAssured.Utils.ErrorHandling;

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

  Result := Self;
end;

function TRESTAssuredResponseSpec.StatusCodeIs(
  Predicate: TPredicate<Integer>): IRESTAssuredResponseSpec;
begin
  if not Predicate(FRESTResponse.GetStatus()) then
    TRESTAssuredAssert.Fail('Predicate failed.', []);

  Result := Self;
end;

function TRESTAssuredResponseSpec.BodyAsJson;
var
  lBody: String;
  lJSONValue: TJSONValue;
begin
  lBody := FRESTResponse.GetBody();
  try
    lJSONValue := TJSONValue.ParseJSONValue(lBody, True, True);
  except
    on Ex: Exception do
      TRESTAssuredErrorHandler.Handle('BodyAsJson', [lBody], Ex);
  end;
  Result := TRESTAssuredSpecProvider.Against(lJSONValue);
end;

destructor TRESTAssuredResponseSpec.Destroy;
begin
  FRESTResponse := nil;
  inherited;
end;

function TRESTAssuredResponseSpec.GroupSeparator;
begin
  Result := Self;
end;

end.
