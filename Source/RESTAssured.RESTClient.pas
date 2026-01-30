unit RESTAssured.RESTClient;

interface

uses
  REST.Client,
  REST.Types,
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.Variants,
  RESTAssured.Utils,
  RESTAssured.Settings;

type
  {$SCOPEDENUMS ON}
  TRESTMethod = (GET, POST, PUT, DELETE);
  {$SCOPEDENUMS OFF}

  IRESTRequest = interface
    function GetMethod(): TRESTMethod;
    procedure SetMethod(Method: TRESTMethod);

    function GetResource(): String;
    procedure SetResource(Resource: String);

    function GetHeaders(): TStringList;
    procedure SetHeader(Key: String; Value: Variant);

    function GetParameters(): TStringList;
    procedure SetParameter(Key: String; Value: Variant);
  end;

  IRESTResponse = interface
    function GetStatus(): Integer;
    function GetBody(): String;
  end;

  IRESTClient = interface
    function NewRequest(): IRESTRequest;
    function PerformRequest(RESTRequest: IRESTRequest): IRESTResponse;
    procedure SetUrl(Value: String);
  end;

  TNativeRESTRequest = class(TInterfacedObject, IRESTRequest)
    strict private
      FHeaders: TStringList;
      FParameters: TStringList;
      FResource: String;
      FMethod: TRESTMethod;
      FVariantConversor: TVariantConversor;
    public
      function GetMethod(): TRESTMethod;
      procedure SetMethod(Method: TRESTMethod);
      function GetResource(): String;
      procedure SetResource(Resource: String);
      function GetHeaders(): TStringList;
      procedure SetHeader(Key: String; Value: Variant);
      function GetParameters(): TStringList;
      procedure SetParameter(Key: String; Value: Variant);
    public
      constructor Create();
      destructor Destroy(); override;
    end;

  TNativeRESTResponse = class(TInterfacedObject, IRESTResponse)
    strict private
      FBody: String;
      FStatus: Integer;
    public
      function GetStatus(): Integer;
      function GetBody(): String;
    public
      constructor Create(Body: String; Status: Integer);
    end;

  TNativeRESTClient = class(TInterfacedObject, IRESTClient)
    strict private
      FUrl: String;
      FClient: TRESTClient;
    private
      procedure FillMethod(Request: TRESTRequest;
                           Method: TRESTMethod);

      procedure FillParameter(Request: TRESTRequest;
                              Pairs: TStringList;
                              Kind: TRESTRequestParameterKind);
    public
      function NewRequest(): IRESTRequest;
      function PerformRequest(RESTRequest: IRESTRequest): IRESTResponse;
      procedure SetUrl(Value: String);
    public
      constructor Create();
      destructor Destroy(); override;
    end;

  TRESTClientFactory = class sealed
    public
      class function New(): IRESTClient;
    end;

implementation

{ TNativeRESTRequest }

constructor TNativeRESTRequest.Create();
begin
  FHeaders := TStringList.Create();
  FParameters := TStringList.Create();
  FVariantConversor := TVariantConversor.Create();
end;

procedure TNativeRESTClient.SetUrl;
begin
  TRESTAssuredUtils.CheckNotEmpty(Value, 'SetUrl#Value');
  FUrl := Value;
end;

procedure TNativeRESTRequest.SetResource;
begin
  TRESTAssuredUtils.CheckNotEmpty(Resource, 'SetResource#Resource');
  FResource := TRESTAssuredUtils.TrimPath(Resource);
end;

procedure TNativeRESTRequest.SetHeader;
begin
  TRESTAssuredUtils.CheckNotEmpty(Key, 'SetHeader#Key');
  TRESTAssuredUtils.CheckNotNull(Value, 'SetHeader#Value');

  FHeaders.AddPair(Key, FVariantConversor.Convert(Value));
end;

procedure TNativeRESTRequest.SetParameter;
begin
  TRESTAssuredUtils.CheckNotEmpty(Key, 'SetParameter#Key');
  TRESTAssuredUtils.CheckNotNull(Value, 'SetParameter#Value');

  FParameters.AddPair(Key, FVariantConversor.Convert(Value));
end;

procedure TNativeRESTRequest.SetMethod;
begin
  FMethod := Method;
end;

function TNativeRESTRequest.GetResource;
begin
  Result := FResource;
end;

function TNativeRESTRequest.GetHeaders;
begin
  Result := FHeaders;
end;

function TNativeRESTRequest.GetParameters;
begin
  Result := FParameters;
end;

function TNativeRESTRequest.GetMethod;
begin
  Result := FMethod;
end;

destructor TNativeRESTRequest.Destroy;
begin
  FHeaders.Free();
  FParameters.Free();
  FVariantConversor.Free();
  inherited;
end;

{ TNativeRESTResponse }

constructor TNativeRESTResponse.Create;
begin
  FBody := Body;
  FStatus := Status;
end;

function TNativeRESTResponse.GetBody;
begin
  Result := FBody;
end;

function TNativeRESTResponse.GetStatus;
begin
  Result := FStatus;
end;

{ TNativeRESTClient }

constructor TNativeRESTClient.Create;
begin
  FClient := TRESTClient.Create(nil);
end;

function TNativeRESTClient.PerformRequest;
var { Native stuff }
  lRequest: TRESTRequest;
  lResponse: TRESTResponse;
var
  lBaseUrl: String;
  lDefaultHeaders: TStringList;
begin
  TRESTAssuredUtils.CheckNotNull(RESTRequest, 'PerformRequest#RESTRequest');

  lBaseUrl := TRESTAssuredSettings.DefaultUrl;
  lBaseUrl := TRESTAssuredUtils.First([FUrl, lBaseUrl]);

  lDefaultHeaders := TRESTAssuredSettings.DefaultHeaders;

  FClient.BaseURL := lBaseUrl;

  lRequest := TRESTRequest.Create(nil);
  lResponse := TRESTResponse.Create(nil);

  lRequest.Response := lResponse;
  lRequest.Resource := RESTRequest.GetResource();
  try
    FillParameter(lRequest, TRESTAssuredSettings.DefaultHeaders, pkHTTPHEADER);

    FillMethod(lRequest, RESTRequest.GetMethod());
    FillParameter(lRequest, RESTRequest.GetHeaders(), pkHTTPHEADER);
    FillParameter(lRequest, RESTRequest.GetParameters(), pkQUERY);
    lRequest.Execute();

    Result := TNativeRESTResponse.Create(lResponse.Content,
                                         lResponse.StatusCode);
  finally
    lRequest.Free();
    lResponse.Free();
  end;
end;

procedure TNativeRESTClient.FillParameter;
var
  lKey, lValue: String;
begin
  for var I := 0 to Pairs.Count - 1 do
  begin
    lKey := Pairs.Names[I];
    lValue := Pairs.ValueFromIndex[I];
    Request.AddParameter(lKey, lValue, Kind);
  end;
end;

procedure TNativeRESTClient.FillMethod;
begin
  case Method of
    TRESTMethod.GET:    Request.Method := rmGET;
    TRESTMethod.POST:   Request.Method := rmPOST;
    TRESTMethod.PUT:    Request.Method := rmPUT;
    TRESTMethod.DELETE: Request.Method := rmDELETE;
  end;
end;

function TNativeRESTClient.NewRequest;
begin
  Result := TNativeRESTRequest.Create();
end;

destructor TNativeRESTClient.Destroy;
begin
  FClient.Free();
  inherited;
end;

{ TRESTClientFactory }

class function TRESTClientFactory.New;
begin
  Result := TNativeRESTClient.Create();
end;

end.
