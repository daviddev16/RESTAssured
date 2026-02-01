unit RESTAssuredResponseSpec.Mocking;

interface

uses
  RESTAssured.Intf.RESTClient,
  RESTAssured.Utils.ErrorHandling;

type
  TRESTResponseMock = class(TInterfacedObject, IRESTResponse)
    private
      FBody: String;
      FStatusCode: Integer;
    public
      constructor Create(StatusCode: Integer; Body: String);
    public
      function GetStatus(): Integer;
      function GetBody(): String;
      function GetRESTRequest(): IRESTRequest;
    end;

  TRESTResponseMockUtil = class sealed
    public
      class function MockWithNoContent(): IRESTResponse;
      class function MockWithOKAndHelloWorldBody(): IRESTResponse;
    end;

implementation

{ TRESTResponseMock }

constructor TRESTResponseMock.Create;
begin
  FBody := Body;
  FStatusCode := StatusCode;
end;

function TRESTResponseMock.GetBody;
begin
  Result := FBody;
end;

function TRESTResponseMock.GetStatus;
begin
  Result := FStatusCode;
end;

function TRESTResponseMock.GetRESTRequest: IRESTRequest;
begin
  Result := nil;
  raise ERESTAssuredException.Create('TRESTResponseMock#GetRESTRequest()');
end;

{ TRESTResponseMockUtil }

class function TRESTResponseMockUtil.MockWithNoContent: IRESTResponse;
begin
  Result := TRESTResponseMock.Create(204, '');
end;

class function TRESTResponseMockUtil.MockWithOKAndHelloWorldBody: IRESTResponse;
begin
  Result := TRESTResponseMock.Create(200, '{"hello":"world"}');
end;



end.
