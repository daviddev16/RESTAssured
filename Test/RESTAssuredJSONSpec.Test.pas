unit RESTAssuredJSONSpec.Test;

interface

uses
  RESTAssured,
  System.JSON,
  System.SysUtils,
  DUnitX.TestFramework;

type
  [TestFixture]
  TRESTAssuredJSONSpecTest = class
    public
      [Test]
      procedure AssertThatJSONValueTest();
      [SetupFixture]
      procedure SetupFixture();
      [TearDownFixture]
      procedure TearDownFixture();
    end;

implementation

uses
  System.DateUtils,
  RESTAssured.Spec.Provider;

{ TRESTAssuredJSONSpecTest }

procedure TRESTAssuredJSONSpecTest.SetupFixture;
begin
end;

procedure TRESTAssuredJSONSpecTest.AssertThatJSONValueTest;
var
  lJSONObjectMock: TJSONObject;
begin
  lJSONObjectMock := TJSONObject.Create();
  lJSONObjectMock.AddPair('NotEmptyStringField1', 'Something');
  lJSONObjectMock.AddPair('StringField1', 'Hello world');
  lJSONObjectMock.AddPair('IntegerField1', 1996);
  lJSONObjectMock.AddPair('DoubleField1', 3.1415);
  lJSONObjectMock.AddPair('BooleanField1', True);
  lJSONObjectMock.AddPair('DateTimeField1', DateToISO8601(EncodeDate(2026, 01, 20)));

  TRESTAssuredSpecProvider
      .Against(lJSONObjectMock)
          .AssertNotEmpty('NotEmptyStringField1')
          .AssertThat('StringField1', 'Hello world')
          .AssertThat('IntegerField1', 1996)
          .AssertThat('DoubleField1', 3.1415)
          .AssertThat('BooleanField1', True)
          .AssertDateTime('DateTimeField1', EncodeDate(2026, 01, 20));
end;

procedure TRESTAssuredJSONSpecTest.TearDownFixture;
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TRESTAssuredJSONSpecTest);

end.
