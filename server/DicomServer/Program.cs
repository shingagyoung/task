using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(option => {
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "DICOM API", Description = "DICOM 정보 제공을 위한 서버", Version = "v1"});
});

var app = builder.Build();
app.UseSwagger();
app.UseSwaggerUI( option => {
    option.SwaggerEndpoint("/swagger/v1/swagger.json", "DICOM API V1");
});


app.MapGet("/", () => "Hello World!");

app.Run();
