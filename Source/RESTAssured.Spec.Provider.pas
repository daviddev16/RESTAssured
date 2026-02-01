unit RESTAssured.Spec.Provider;

interface

uses
  System.JSON,
  RESTAssured.Utils,
  RESTAssured.Spec.JSON,
  RESTAssured.Spec.JSON.Base,
  RESTAssured.Spec.Response,
  RESTAssured.Intf.RESTClient;

type
  TRESTAssuredSpecProvider = class sealed
    public
      class function Against(JSONValue: TJSONValue): IRESTAssuredJSONSpec; overload;
      class function Against(RESTResponse: IRESTResponse): IRESTAssuredResponseSpec; overload;
    end;

implementation

{ TRESTAssuredSpecProvider }

class function TRESTAssuredSpecProvider.Against(
  JSONValue: TJSONValue): IRESTAssuredJSONSpec;
begin
  Assert(JSONValue <> nil);
  Result := TRESTAssuredJSONSpec.Create(JSONValue);
end;

class function TRESTAssuredSpecProvider.Against(
  RESTResponse: IRESTResponse): IRESTAssuredResponseSpec;
begin
  Assert(RESTResponse <> nil);
  Result := TRESTAssuredResponseSpec.Create(RESTResponse);
end;

end.
