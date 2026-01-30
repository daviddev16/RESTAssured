## RESTAssured

RESTAssured is a minimalist framework that allows you to create API integration tests within DUnit test procedures.

### Basic example

```pascal
procedure TMyTestObject.RestCalculatorTest;
begin
  TRESTAssured.Start()
      .Url('http://127.0.0.1:9000')
      .WithResource('/calculator')
      .WithParameter('x', 100)
      .WithParameter('y', 250)
      .WithHeader('operator', 'sum;multiply')
      .WithHeader('Authorization', BasicAuth('daviddev16', 'passw0rd'))
      .PerformRequest(TRESTMethod.GET)
          .StatusCodeIs(204)
          .BodyAsJson()
              .AssertThat('sum_result', (100 + 250))
              .AssertThat('multiply_result', (100 * 250));
end;
```

### Basic example + Settings per Fixture 

```pascal
procedure TMyTestObject.SetupFixture;
begin
  TRESTAssuredSettings.SetDefaultUrl('http://127.0.0.1:9000');
  TRESTAssuredSettings.AddDefaultHeader('Authorization', BearerAuth('Jwt Token Here'));
end;

procedure TMyTestObject.RestCalculatorTest_2;
begin
  TRESTAssured.Start()
      .WithResource('/calculator')
      .WithParameter('x', 100)
      .WithParameter('y', 250)
      .WithHeader('operator', 'sum;multiply')
      .PerformRequest(TRESTMethod.GET)
          .StatusCodeIs(204)
          .BodyAsJson()
              .AssertThat('sum_result', (100 + 250))
              .AssertThat('multiply_result', (100 * 250));
end;

procedure TMyTestObject.TeardownFixture;
begin
  TRESTAssuredSettings.Clear();
end;

```

### Custom validation 

```pascal
procedure TMyTestObject.CustomValidationRestTest;
begin
  TRESTAssured.Start()
      .WithResource('/calculator')
      .WithParameter('x', 50)
      .WithParameter('y', 25)
      .WithHeader('operator', 'divide')
      .PerformRequest(TRESTMethod.GET)
// ...
          .StatusCodeIs(
              function(StatusCode: Integer): Boolean
              begin
                Result := (StatusCode >= 200) and (StatusCode <= 204);
              end);
// ...

end;
```
