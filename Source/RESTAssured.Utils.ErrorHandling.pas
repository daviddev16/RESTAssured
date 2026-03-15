unit RESTAssured.Utils.ErrorHandling;

interface

uses
  System.SysUtils,
  RESTAssured.Miscs;

type
  ERESTAssuredException = class(Exception);

  TRESTAssuredErrorHandler = class sealed
    public
      class procedure Handle(Message: TRESTAssuredMessage; Ex: Exception); overload;
      class procedure Handle(FunctionName: String; Parameters: Array Of Const; Ex: Exception); overload;
    end;

implementation

{ TRESTAssuredErrorHandler }

class procedure TRESTAssuredErrorHandler.Handle(
  Message: TRESTAssuredMessage;
  Ex: Exception);
begin
  Message.Exception(Ex);
  raise ERESTAssuredException.Create(Message.Build());
end;

class procedure TRESTAssuredErrorHandler.Handle(
  FunctionName: String;
  Parameters: Array of Const;
  Ex: Exception);
var
  lMessage: TRESTAssuredMessage;
begin
  lMessage := TRESTAssuredMessage
      .New(FunctionName)
      .Parameters(Parameters)
      .Exception(Ex);

  raise ERESTAssuredException.Create(lMessage.Build());
end;

end.
