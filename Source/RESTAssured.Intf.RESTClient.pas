unit RESTAssured.Intf.RESTClient;

interface

uses
  REST.Types,
  System.Classes;

type
  {$SCOPEDENUMS ON}
  TRESTMethod = (GET, POST, PUT, DELETE);
  {$SCOPEDENUMS OFF}

  TRESTContentType = class sealed
    const
      APPLICATION_JSON = REST.Types.CONTENTTYPE_APPLICATION_JSON;
    end;

  IRESTRequest = interface
    function GetMethod(): TRESTMethod;
    procedure SetMethod(Method: TRESTMethod);

    function GetBody(): String;
    procedure SetBody(Content: String);

    function GetContentType(): String;
    procedure SetContentType(Value: String);

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
    function GetUrl(): String;
    procedure SetUrl(Value: String);
  end;

  IRESTClientFactory = interface
    function NewRESTClient(): IRESTClient;
  end;

implementation

end.
