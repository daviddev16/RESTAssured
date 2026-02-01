unit RESTAssuredResponseSpec.Test;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TRESTAssuredResponseSpecTest = class
  public
    [Test]
    procedure NoContentResponseTest();
    [Test]
    procedure OKWithHelloWorldBodyResponseTest();
  end;

implementation

uses
  RESTAssured.Spec.Provider,
  RESTAssured.Intf.RESTClient,
  RESTAssuredResponseSpec.Mocking;


{ TRESTAssuredResponseSpecTest }

procedure TRESTAssuredResponseSpecTest.NoContentResponseTest;
var
  lRESTResponse: IRESTResponse;
begin
  lRESTResponse := TRESTResponseMockUtil.MockWithNoContent();

  TRESTAssuredSpecProvider
      .Against(lRESTResponse)
          .StatusCodeIs(204)
          .Bodyless();
end;

procedure TRESTAssuredResponseSpecTest.OKWithHelloWorldBodyResponseTest;
var
  lRESTResponse: IRESTResponse;
begin
  lRESTResponse := TRESTResponseMockUtil.MockWithOKAndHelloWorldBody();

  TRESTAssuredSpecProvider
      .Against(lRESTResponse)
          .StatusCodeIs(200)
          .BodyAsJson()
          .AssertThat('hello', 'world');
end;

initialization
  TDUnitX.RegisterTestFixture(TRESTAssuredResponseSpecTest);

end.
