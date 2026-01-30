unit RESTAssured;

interface

uses
  System.Classes,
  System.Variants,
  System.SysUtils,
  System.StrUtils,
  System.Generics.Collections,
  RESTAssured.Assert,
  RESTAssured.Settings,
  RESTAssured.RESTClient,
  RESTAssured.Spec.Response;

type
  TRESTMethod = RESTAssured.RESTClient.TRESTMethod;
  TRESTAssuredSettings = RESTAssured.Settings.TRESTAssuredSettings;

  IRESTAssuredSpec = interface
    function Url(Value: String): IRESTAssuredSpec;
    function WithResource(Value: String): IRESTAssuredSpec;
    function WithHeader(Key: String; Value: Variant): IRESTAssuredSpec;
    function WithParameter(Key: String; Value: Variant): IRESTAssuredSpec;
    function PerformRequest(Method: TRESTMethod): IRESTAssuredResponseSpec;
  end;

  TRESTAssured = class sealed(TInterfacedObject, IRESTAssuredSpec)
    strict private
      FRESTClient: IRESTClient;
      FRESTRequest: IRESTRequest;
      FRESTResponse: IRESTResponse;
    public
      function Url(Value: String): IRESTAssuredSpec;
      function WithResource(Value: String): IRESTAssuredSpec;
      function WithHeader(Key: String; Value: Variant): IRESTAssuredSpec;
      function WithParameter(Key: String; Value: Variant): IRESTAssuredSpec;
      function PerformRequest(Method: TRESTMethod): IRESTAssuredResponseSpec;
    public
      constructor Create();
      destructor Destroy(); override;
    public
      class function Start(Url: String = ''): IRESTAssuredSpec;
      class procedure Fail(Message: String; Args: Array Of Const);
    end;

function BearerAuth(Token: String): Variant;
function BasicAuth(Username: String; Password: String): Variant;

implementation

uses
  System.NetEncoding;

function BearerAuth(Token: String): Variant;
begin
  Result := 'Bearer ' + Token;
end;

function BasicAuth(Username: String; Password: String): Variant;
begin
  Result := 'Basic ' + TBase64Encoding.Base64.Encode(UserName + ':' + Password);
end;

{ TRESTAssured }

constructor TRESTAssured.Create();
begin
  FRESTClient := TRESTClientFactory.New();
  FRESTRequest := FRESTClient.NewRequest();
end;

function TRESTAssured.Url;
begin
  FRESTClient.SetUrl(Value);
end;

function TRESTAssured.WithResource;
begin
  FRESTRequest.SetResource(Value);
end;

function TRESTAssured.WithHeader;
begin
  FRESTRequest.SetHeader(Key, Value);
end;

function TRESTAssured.WithParameter;
begin
  FRESTRequest.SetParameter(Key, Value);
end;

function TRESTAssured.PerformRequest;
var
  lRESTResponse: IRESTResponse;
begin
  lRESTResponse := FRESTClient.PerformRequest(FRESTRequest);
  Assert(lRESTResponse <> nil);
  Result := TRESTAssuredResponseSpec.Create(lRESTResponse);
end;

destructor TRESTAssured.Destroy();
begin
  FRESTClient := nil;
  FRESTRequest := nil;
  FRESTResponse := nil;
  inherited;
end;

class function TRESTAssured.Start;
begin
  Result := TRESTAssured.Create().Url(Url);
end;

class procedure TRESTAssured.Fail;
begin
  TRESTAssuredAssert.Fail(Message, Args);
end;

end.
