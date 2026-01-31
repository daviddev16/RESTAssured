unit RESTAssured.Default.RESTClient;

interface

uses
  REST.Client,
  REST.Types,
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.Variants,
  DUnitX.WeakReference,
  RESTAssured.Intf.RESTClient,
  RESTAssured.Utils,
  RESTAssured.Utils.ErrorHandling;

type
  TNativeRESTRequest = class(TInterfacedObject, IRESTRequest)
    strict private
      FHeaders: TStringList;
      FParameters: TStringList;
      FBody: String;
      FResource: String;
      FContentType: String;
      FMethod: TRESTMethod;
      FVariantConversor: TVariantConversor;
    public
      function GetMethod(): TRESTMethod;
      procedure SetMethod(Method: TRESTMethod);

      function GetBody(): String;
      procedure SetBody(Content: String);

      function GetContentType(): String;
      procedure SetContentType(Value: String);

      function GetResource(): String;
      procedure SetResource(Value: String);

      function GetHeaders(): TStringList;
      procedure SetHeader(Key: String; Value: Variant);

      function GetParameters(): TStringList;
      function GetParameter(Key: String): String;
      procedure SetParameter(Key: String; Value: Variant);
    public
      constructor Create();
      destructor Destroy(); override;
    end;

  TNativeRESTResponse = class(TInterfacedObject, IRESTResponse)
    strict private
      FBody: String;
      FStatus: Integer;
      FRESTRequest: IRESTRequest;
    public
      function GetStatus(): Integer;
      function GetBody(): String;
      function GetRESTRequest(): IRESTRequest;
    public
      constructor Create(Body: String;
                         Status: Integer;
                         RESTRequest: IRESTRequest);
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
      function GetUrl(): String;
    public
      constructor Create();
      destructor Destroy(); override;
    end;

  TNativeRESTClientFactory = class(TInterfacedObject, IRESTClientFactory)
    public
      function NewRESTClient(): IRESTClient;
    end;

implementation

{ TNativeRESTRequest }

constructor TNativeRESTRequest.Create;
begin
  FHeaders := TStringList.Create();
  FParameters := TStringList.Create();
  FVariantConversor := TVariantConversor.Create();
  FBody := '';
  FContentType := '';
end;

procedure TNativeRESTRequest.SetResource;
begin
  TRESTAssuredUtils.CheckNotEmpty(Value, 'Value');
  FResource := TRESTAssuredUtils.TrimPath(Value);
end;

procedure TNativeRESTRequest.SetHeader;
begin
  TRESTAssuredUtils.CheckNotEmpty(Key, 'Key');
  TRESTAssuredUtils.CheckNotNull(Value, 'Value');

  FHeaders.AddPair(Key, FVariantConversor.Convert(Value));
end;

procedure TNativeRESTRequest.SetParameter;
begin
  TRESTAssuredUtils.CheckNotEmpty(Key, 'Key');
  TRESTAssuredUtils.CheckNotNull(Value, 'Value');

  FParameters.AddPair(Key, FVariantConversor.Convert(Value));
end;

procedure TNativeRESTRequest.SetMethod;
begin
  FMethod := Method;
end;

procedure TNativeRESTRequest.SetBody;
begin
  TRESTAssuredUtils.CheckNotNull(Content, 'Content');
  FBody := Content;
end;

procedure TNativeRESTRequest.SetContentType;
begin
  TRESTAssuredUtils.CheckNotNull(Value, 'Value');
  FContentType := Value;
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

function TNativeRESTRequest.GetParameter;
begin
  Result := FParameters.Values[Key];
end;

function TNativeRESTRequest.GetBody;
begin
  Result := FBody;
end;

function TNativeRESTRequest.GetContentType;
begin
  Result := FContentType;
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
  FRESTRequest := RESTRequest;
end;

function TNativeRESTResponse.GetBody;
begin
  Result := FBody;
end;

function TNativeRESTResponse.GetRESTRequest;
begin
  Result := FRESTRequest;
end;

function TNativeRESTResponse.GetStatus;
begin
  Result := FStatus;
end;

{ TNativeRESTClient }

constructor TNativeRESTClient.Create;
begin
  FClient := TRESTClient.Create(nil);
  FClient.RaiseExceptionOn500 := False;
end;

function TNativeRESTClient.PerformRequest;
var { Native stuff }
  lRequest: TRESTRequest;
  lResponse: TRESTResponse;
  lMessage: String;
  lBody, lContentType: String;
begin
  TRESTAssuredUtils.CheckNotNull(RESTRequest, 'RESTRequest');
  FClient.BaseURL := FUrl;

  lRequest := TRESTRequest.Create(FClient);
  lResponse := TRESTResponse.Create(nil);

  lRequest.Response := lResponse;
  lRequest.Resource := RESTRequest.GetResource();

  lBody := RESTRequest.GetBody();
  lContentType := RESTRequest.GetContentType();
  try
    try
      if not lBody.IsEmpty() then
        lRequest.AddBody(lBody, lContentType);

      FillMethod(lRequest, RESTRequest.GetMethod());
      FillParameter(lRequest, RESTRequest.GetHeaders(), pkHTTPHEADER);
      FillParameter(lRequest, RESTRequest.GetParameters(), pkQUERY);

      lRequest.Execute();

      Result := TNativeRESTResponse.Create(lResponse.Content,
                                           lResponse.StatusCode,
                                           RESTRequest);
    except
      on Ex: Exception do
      begin
        lMessage := '';
        lMessage := lMessage + 'An error ocurred while requesting resource ';
        lMessage := lMessage + '"' + lRequest.FullResource + '" ';
        lMessage := lMessage + '(ClassName: %s, Message: %s)';

        raise ERESTAssuredException.CreateFmt(lMessage, [Ex.ClassName, Ex.Message]);
      end;
    end;
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

procedure TNativeRESTClient.SetUrl;
begin
  TRESTAssuredUtils.CheckNotEmpty(Value, 'Value');
  FUrl := Value;
end;

function TNativeRESTClient.GetUrl: String;
begin
  Result := FUrl;
end;

destructor TNativeRESTClient.Destroy;
begin
  FClient := nil;
  inherited;
end;

{ TNativeRESTClientFactory }

function TNativeRESTClientFactory.NewRESTClient;
begin
  Result := TNativeRESTClient.Create();
end;

end.
